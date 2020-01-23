//
//  TestResultsTableViewController.swift
//  Spell Me!
//
//  Created by Etash Kalra on 6/22/16.
//  Copyright © 2016 Kalra. All rights reserved.
//

var resultNumberSelected: Int?

import UIKit
import CoreData

class TestResultsTableViewController: UITableViewController {

    var appDel: AppDelegate!
    var context: NSManagedObjectContext!
    
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
        
        //Get info
        
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Test_Session")
        request.returnsObjectsAsFaults = false
        //request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            
            let results = try context.fetch(request) as! [NSManagedObject]
            
            //Removes Blank Test Sessions (Accidental -- Fixed BUt still need this block)
            for result in results {
                
                if result.value(forKey: "score") == nil || result.value(forKey: "date") == nil {
                    
                    context.delete(result)
                    
                    do {
                        
                        try context.save()
                        
                    } catch { }
                    
                }
                
            }
            
            if results.count == 0 {
                
                let alert109 = UIAlertController(title: "No Tests Yet", message: "You haven't taken a test yet. You can do so by tapping one of your lists in the \"My Lists\" page", preferredStyle: .alert)
                
                alert109.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }))
                
                self.present(alert109, animated: true, completion: nil)
                
            }
            
            return results.count
            
        } catch {
            
            let alert1309 = UIAlertController(title: "No Tests Yet", message: "You haven't taken a test yet. You can do so by tapping one of your lists in the \"My Lists\" page", preferredStyle: .alert)
            
            alert1309.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                
                self.navigationController?.popViewController(animated: true)
                
            }))
                
            self.present(alert1309, animated: true, completion: {
                    
                self.navigationController?.popViewController(animated: true)
                    
            })
            
            return 0
            
        }

    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCell", for: indexPath) as! CustomCellTableViewCell

        var date = String()
        var score = String()
        var list = String()
        
        //Get da info . . .
        
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Test_Session")
        request.returnsObjectsAsFaults =  false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            
            let results = try context.fetch(request) as! [NSManagedObject]
            
            if results.count > 0 {
                
                let result = results[(indexPath as NSIndexPath).row]
                
                if let date0 = result.value(forKey: "date") { date = date0 as! String }
                if let score0 = result.value(forKey: "score") { score = score0 as! String }
                if let list0 = result.value(forKey: "list") { list = list0 as! String }
                
            }
            
        } catch {
            
            
            
        }
        
        // Configure the cell...

        cell.label1.text = score
        cell.label2.text = list
        cell.label3.text = date
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        resultNumberSelected = (indexPath as NSIndexPath).row
        
        self.performSegue(withIdentifier: "segueNumeroSomething", sender: self)
        
    }
    @IBAction func xPress(_ sender: AnyObject) {
    
        self.dismiss(animated: true, completion: nil)
    
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
