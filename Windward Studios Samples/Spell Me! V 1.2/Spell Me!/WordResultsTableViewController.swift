//
//  WordResultsTableViewController.swift
//  Spell Me!
//
//  Created by Etash Kalra on 6/22/16.
//  Copyright © 2016 Kalra. All rights reserved.
//

import UIKit
import CoreData

class WordResultsTableViewController: UITableViewController {

    var appDel: AppDelegate!
    var context: NSManagedObjectContext!
    var allWords: [String]?
    var userWords: [String]?
    var corrects: [Bool]?
    var rows: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        context = appDel.managedObjectContext
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        let selected = resultNumberSelected
        
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Test_Session")
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            
            let results = try context.fetch(request) as! [NSManagedObject]
            
            //test session
            let result = results[selected!]
            
            allWords = result.value(forKey: "words") as? [String]
            userWords = result.value(forKey: "userType") as? [String]
            corrects = result.value(forKey: "correctOrNot") as? [Bool]
            rows = allWords!.count
            
            return rows!
            
        } catch {
            
            let alert0031 = createAlert("Error", msg: "Sorry, there was an error", btn: "Okay")
            
            self.present(alert0031, animated: true, completion: {
                
                self.navigationController?.popViewController(animated: true)
                
            })
            
            return 0
            
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ummmIDKReuseIdentifier", for: indexPath)

        // Configure the cell...

        cell.textLabel?.text = (allWords![(indexPath as NSIndexPath).row] ).lowercased()
        cell.detailTextLabel?.text = userWords![(indexPath as NSIndexPath).row]
        
        if corrects![(indexPath as NSIndexPath).row] == true {
            
            cell.detailTextLabel?.textColor = UIColor(red: 90.0/255.0, green: 1, blue: 13.0/255.0, alpha: 1) //Green
            
        } else {
            
            cell.detailTextLabel?.textColor = UIColor.red
            
        }
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
