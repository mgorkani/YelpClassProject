//
//  FilterController.swift
//  FinalYelpApp
//
//  Created by Monika Gorkani on 9/23/14.
//  Copyright (c) 2014 Monika Gorkani. All rights reserved.
//

import UIKit

class FilterController: UIViewController, UITableViewDataSource, UITableViewDelegate, FilterChangedProtocol {

    @IBOutlet weak var tableView: UITableView!
    var delegate:SearchProtocol?
    var settings = NSMutableArray()
    var isExpanded:[Int:Bool]! = [Int:Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 58
        
    }
    @IBAction func cancell(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }

    @IBAction func search(sender: AnyObject) {
        
        
        delegate?.searchWithParams(settings)
        dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })

        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let name = settings[indexPath.section]["name"] as String
        if (name == "Category" && indexPath.row == 3) {
            isExpanded[indexPath.section] = true
            tableView.reloadData()
            return
        }
        
        if let expanded = isExpanded[indexPath.section] {
            isExpanded[indexPath.section] = !expanded
        } else {
            isExpanded[indexPath.section] = true
        }
        tableView.reloadData()
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = UIView(frame: CGRect(x:0,y:0,width:tableView.frame.size.width,height:50.0))
        headerView.backgroundColor = UIColor(white:0.8,alpha:0.8)
        var headerLabel = UILabel(frame: CGRect(x:10,y:0,width:tableView.frame.size.width,height:50.0))
        headerLabel.text = settings[section]["name"] as? String
        headerView.addSubview(headerLabel)
        return headerView
        
    }
 
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rows = settings[section]["rows"] as NSArray
        let name = settings[section]["name"] as String
        
        if let expanded = isExpanded[section]  {
            if (expanded) {
               
                return rows.count
            } else {
                if (name == "Category") {
                    return 4
                }
                else {
                    return 1
                }
                
            }
        }
        else {
            isExpanded[section] = false
            return 1
        }
        
       
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
        
        let section = indexPath.section
        let settingsDict = settings[section] as NSMutableDictionary
        let type = settingsDict["cell_type"] as String
        let rows = settingsDict["rows"] as [NSMutableDictionary]
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell") as SettingsCell
        let name = settingsDict["name"] as String
        var sectionExpanded:Bool = isExpanded[section]!
        if (name == "Category" && !sectionExpanded) {
            if (indexPath.row == 3) {
                cell.settingsName.text = "Select All"
                cell.settingsSwitch.hidden = true
            }
            else {
                cell.settingsName.text = rows[indexPath.row]["display_name"] as? String
                let selected = rows[indexPath.row]["selected"] as Bool
                cell.settingsSwitch.hidden = false
                cell.settingsSwitch.setOn(selected,animated:true)
            }
        }
        else if (rows.count == 1 || sectionExpanded) {
           
            cell.settingsName.text = rows[indexPath.row]["display_name"] as? String
            let selected = rows[indexPath.row]["selected"] as Bool
            cell.settingsSwitch.hidden = false
            cell.settingsSwitch.setOn(selected,animated:true)

        }
        else {
            // show only the selected one
            for row in rows {
                let selected = row["selected"] as Bool
                if (selected) {
                    cell.settingsName.text = row["display_name"] as? String
                    cell.settingsSwitch.hidden = true
                    break
                }
                
            }
            
        }
        
        
        
        cell.type = settings[section]["cell_type"] as String
        cell.section = indexPath.section
        cell.delegate = self
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
        
    }
    
    func updateFilterParams(section:Int,filterDisplayName:String,selected:Bool) {
        
        // find the right settings section and update the values and then update the appropriate section
        var rows = settings[section]["rows"] as [NSMutableDictionary]
        let name = settings[section]["name"] as String
        for var index = 0; index < rows.count; index++ {
            var row = rows[index] as NSMutableDictionary
            let displayName = row["display_name"] as String
            if (displayName == filterDisplayName) {
                row["selected"] = selected
            
            }
            else {
                
                if (name != "Category") {
                    row["selected"] = false
                }
            }
        }
        if (name != "Category") {
            isExpanded[section] = false
        }
        tableView.reloadData()
        
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int  {
        return settings.count
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
