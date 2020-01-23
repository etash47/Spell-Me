//
//  ListsTableViewController.swift
//  Spell Me!
//
//  Created by Etash Kalra on 6/15/16.
//  Copyright © 2016 Kalra. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreData

var listSelectedIndex: Int?

class ListsTableViewController: UITableViewController {

    @IBOutlet var tableHeaderLabel: UILabel!
    
    var appDel: AppDelegate!
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        context = appDel.managedObjectContext

        //hideKeyboardWhenTappedAround()
        
        let oldNumberOfLists = UserDefaults.standard.value(forKey: "numberOfLists") as? Int
        
        if oldNumberOfLists == nil || oldNumberOfLists == 0 { //If no lists created yet
            
            //Initializes User Defaults for later use
            //Commented because they cause an error
            //NSUserDefaults.standardUserDefaults().setObject(0, forKey: "numberOfLists")
            
            //NSUserDefaults.standardUserDefaults().setObject([String](), forKey: "listNames")
            
            //User info
            
            tableHeaderLabel.text = "You haven't created any lists"
            
        } else {
            
            //User info
            tableHeaderLabel.text = "Spelling Lists"
            
        }

        // display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
    
        // #warning Incomplete implementation, return the number of sections
        
        //Section zero: lists | Section one: add lists button (cell)
        return 2
    
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // #warning Incomplete implementation, return the number of rows
        
        if section == 0 { //lists section
            
            if UserDefaults.standard.object(forKey: "numberOfLists") == nil {
                
                UserDefaults.standard.set(0, forKey: "numberOfLists")
                
            }
            
            if UserDefaults.standard.object(forKey: "numberOfLists") as! Int == 0 {
                
                return 0
                
            }
            
            return UserDefaults.standard.object(forKey: "numberOfLists") as! Int
        
        } else { //add lists and shared list button cell section
            
            return 2
            
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //"listReuseI..." is generic
        let cell = tableView.dequeueReusableCell(withIdentifier: "listReuseIdentifier", for: indexPath)
        
        // Configure the cell...
        if (indexPath as NSIndexPath).section == 0 { //lists section
        
            let listNames: [String] = UserDefaults.standard.object(forKey: "listNames") as! [String]
            cell.textLabel?.text = listNames[(indexPath as NSIndexPath).row]
            
            //Dark Blue Text
            cell.textLabel?.textColor = UIColor(red: 0.04705 , green: 0.1686, blue: 0.6941, alpha: 1)
            
            cell.textLabel?.font = UIFont(name: "Kohinoor Devanagari", size: 17)
            
        } else {
            
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "➕ \t add list"
                
                cell.textLabel?.textColor = UIColor(red: 1 , green: 0.5764, blue: 0.1, alpha: 1) //Orange
                
                cell.textLabel?.font = UIFont(name: "Kohinoor Devanagari", size: 17)
                
                //cell.backgroundColor = UIColor(red: 209.0/255.0, green: 215.0/255.0, blue: 1, alpha: 1)
                    
            } else if indexPath.row == 1 {
                
                cell.textLabel?.text = "🔃 \t get shared list (with code)"
                
                cell.textLabel?.textColor = UIColor(red: 1 , green: 0.5764, blue: 0.1, alpha: 1) //Orange
                
                cell.textLabel?.font = UIFont(name: "Kohinoor Devanagari", size: 17)
                
                //cell.backgroundColor = UIColor(red: 209.0/255.0, green: 215.0/255.0, blue: 1, alpha: 1)
                
            }
        
        }
        
        return cell
        
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        // Return false if you do not want the specified item to be editable.
        
        if (indexPath as NSIndexPath).section == 0 { //Lists can be deleted and moved around
        
            return true
            
        } else { //Add lists cell acts like a button and should be static (non-editable)
            
            return false
            
        }
    
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        
            //Can delete lists with edit button
            return UITableViewCellEditingStyle.delete
        
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // Delete the info from the data source
            var oldListNames = UserDefaults.standard.object(forKey: "listNames") as! [String]
            let oldNumOfLists = UserDefaults.standard.object(forKey: "numberOfLists") as! Int
            
            let listName = oldListNames.remove(at: (indexPath as NSIndexPath).row)
            let newListNames = oldListNames
            let newNumOfLists = oldNumOfLists - 1
            
            UserDefaults.standard.set(newNumOfLists, forKey: "numberOfLists")
            UserDefaults.standard.set(newListNames, forKey: "listNames")
            
            //Delete the words from the database
            let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Word")
            
            request.predicate = NSPredicate(format: "list = %@", listName)
            request.returnsObjectsAsFaults = false
            
            do {
                
                let results = try context.fetch(request) as! [NSManagedObject]
                
                if results.count > 0 {
                    
                    for result in results {
                        
                        context.delete(result)
                        
                    }
                    
                    do { try context.save() } catch {
                        
                        let alert23s5 = createAlert("Error", msg: "Sorry, there was an error deleting the words from that list. Please try again", btn: "Okay")
                        
                        self.present(alert23s5, animated: true, completion: nil)
                        
                    }
                    
                }
                
            } catch {
                
                let alert2e35 = createAlert("Error", msg: "Sorry, there was an error deleting the words from that list. Please try again", btn: "Okay")
                
                self.present(alert2e35, animated: true, completion: nil)
                
            }
            
            //user info
            if newNumOfLists == 0 {
            
                tableHeaderLabel.text = "You haven't created any lists"
            
                UserDefaults.standard.set(nil, forKey: "listNames")
                
            }
            
            //reload
            tableView.reloadData()
            
            tableView.setEditing(false, animated: true)
            setEditing(false, animated: true)
        
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    
    // Override to support rearranging the table view.
    // THIS FUNCTION DOES NOT ACTUALLY CONTROL THE PHYSICAL MOVEMENT
    // IT ONLY CONTROLS THE CHANGING OF ORDER OR ROWS IN THE **DATA SOURCE**
    // See function below for physical movement of rows
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
    
        var oldListNames = UserDefaults.standard.object(forKey: "listNames") as! [String]
        
        let from_ = (fromIndexPath as NSIndexPath).row //last position of row
        let to_ = (toIndexPath as NSIndexPath).row //new position of row
        
        let temp = oldListNames[from_]
        
        if from_ < to_ { //row moved downwards
            
            for i in stride(from: from_, to: to_, by: 1) {
                
                oldListNames[i] = oldListNames[i+1] //moves everything one row up
                
            }
            
            oldListNames[to_] = temp //moves intended row from old pos to new pos
        
            let newListNames = oldListNames
            
            UserDefaults.standard.set(newListNames, forKey: "listNames") //update
            
        } else if from_ > to_ { //row moved upwards
            
            for i in stride(from: from_, to: to_, by: -1) {
                
                oldListNames[i] = oldListNames[i-1] //moves everything one row down
                
            }
            
            oldListNames[to_] = temp //moves intended row from old pos to new pos
            
            let newListNames = oldListNames
            
            UserDefaults.standard.set(newListNames, forKey: "listNames") //update
            
        }
        
    
    }
 
    // Only limits moving around within a section. Not "inter-section"
    // Ex. Section 1 Row 1 can be moved to Section 1 Row 2 but nowhere in section 2
    // Because the add lists section/cell/button is NOT Editable,
    //      there is no need for specification of which row (only section 1 items are moveable)
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        
        if (sourceIndexPath as NSIndexPath).section != (proposedDestinationIndexPath as NSIndexPath).section {
        
            var row = 0
            
            if (sourceIndexPath as NSIndexPath).section < (proposedDestinationIndexPath as NSIndexPath).section {
            
                row = self.tableView(tableView, numberOfRowsInSection: (sourceIndexPath as NSIndexPath).section) - 1
            
            }
            
            return IndexPath(row: row, section: (sourceIndexPath as NSIndexPath).section)
        
        }
        
        return proposedDestinationIndexPath
    
    }
    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        if (indexPath as NSIndexPath).section == 0 {//list cells
        
            return true
            
        } else { //add list cell/row/button
            
            return false
            
        }
    }
    
    
    //ALSO INCLUDES CODE FOR ADDING A LIST
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Add list
        if (indexPath as NSIndexPath).section == 1 { //Add list  or transfer button
            
            if indexPath.row == 0 { //Add List
            
                //Creates alert message box w/ textfield (for list name)
                let newListBox = UIAlertController(title: "New List", message: "What would you like to name this list?", preferredStyle: .alert)
                
                newListBox.addTextField(configurationHandler: { (textField) -> Void in
                    
                    textField.text = ""
                
                })
                
                
                newListBox.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action) -> Void in
                    
                    let textField = newListBox.textFields![0] as UITextField
                    var oldListNames: [String]
                    
                    if UserDefaults.standard.value(forKey: "numberOfLists") as? Int == 0 || UserDefaults.standard.value(forKey: "numberOfLists") == nil  {
                        
                        oldListNames = [String]()
                        
                    } else {
                        
                        oldListNames = UserDefaults.standard.value(forKey: "listNames") as! [String]
                        
                    }
                    
                    if oldListNames.index(of: textField.text!) == nil && textField.text! != "" { //List name is available
                    
                        //Add row with name textfield.text
                        
                        //Update data source with new listname and number of lists
                        var oldNumOfLists: Int
                        
                        if UserDefaults.standard.value(forKey: "numberOfLists") == nil {
                            
                            oldNumOfLists = 0
                            
                        } else {
                            
                            oldNumOfLists = UserDefaults.standard.value(forKey: "numberOfLists") as! Int
                            
                        }
                        
                        oldListNames.append(textField.text!)
                        let newListNames = oldListNames
                        let newNumOfLists = oldNumOfLists + 1
                        
                        UserDefaults.standard.set(newListNames, forKey: "listNames")
                        UserDefaults.standard.set(newNumOfLists, forKey: "numberOfLists")
                        
                        //Reload + small detail
                        self.tableHeaderLabel.text = "Spelling Lists" //At least 1 now
                        self.tableView.reloadData()
                        
                    } else { //List name is taken
                     
                        //Display error message
                        
                        let alert = UIAlertController(title: "List name", message: "The name of the list you have entered is already taken by another list. Please choose a different name.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action2) in
                            
                            tableView.deselectRow(at: indexPath, animated: true)
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                        
                    }
                    
                }))
                
                newListBox.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action2) in
                
                    //
                
                }))
                
                self.present(newListBox, animated: true, completion: nil)
                
            } else if indexPath.row == 1 { //Shared List download
                
                let alert10 = UIAlertController(title: "Get a beehive list", message: "You can get a beehive list by entering its code in the text field below:", preferredStyle: .alert)
                
                alert10.addTextField(configurationHandler: { (tF) in
                    
                })
                
                alert10.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                alert10.addAction(UIAlertAction(title: "Go!", style: .default, handler: { (action) in
                    
                    let code: String? = alert10.textFields?[0].text
                    
                    if code == "" || code  == nil {
                        
                        self.dismiss(animated: true, completion: nil)
                        
                    } else {
                        
                        let ref = FIRDatabase.database().reference()
                        
                        //Gets List
                        
                        ref.child(code!).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                            if snapshot.value != nil {
                            
                                let wordsArray = snapshot.value as! [[String: String]]
                                
                                var oldNumLists: Int = 0
                                
                                var oldListNames: [String]
                                
                                if UserDefaults.standard.value(forKey: "listNames") == nil {
                                    
                                    oldListNames = [String]()
                                    
                                } else {
                                    
                                    oldListNames = UserDefaults.standard.value(forKey: "listNames") as! [String]
                                    
                                }
                                
                                
                                if !oldListNames.contains(wordsArray[0]["list"]!) {
                                
                                    for word in wordsArray {
                                        
                                        //Assign attributes to variables
                                        let spelling = word["spelling"]! 
                                        let info = word["info"]!
                                        let list = word["list"]!
                                        let audioString = word["audio"]!
                                        let audio = NSData(base64Encoded: audioString, options: NSData.Base64DecodingOptions(rawValue: UInt(0)))
                                        
                                        let newWord = NSEntityDescription.insertNewObject(forEntityName: "Word", into: self.context)
                                        
                                        //Set Values
                                        newWord.setValue(spelling, forKey: "spelling")
                                        newWord.setValue(info, forKey: "info")
                                        newWord.setValue(list, forKey: "list")
                                        newWord.setValue(audio, forKey: "audio")
                                        
                                        do {
                                            
                                            try self.context.save()
                                            
                                            //Everything was successful if this line is executed!
                                            
                                            let alert9 = UIAlertController(title: "List Added!", message: "Your list was successfully added", preferredStyle: .alert)
                                            
                                            alert9.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                                                
                                            }))
                                            
                                            self.present(alert9, animated: true, completion: {
                                                
                                                //Current Lists Update
                                                
                                                if UserDefaults.standard.value(forKey: "numberOfLists") == nil {
                                                    
                                                    oldNumLists = 0
                                                    
                                                } else {
                                                    
                                                    oldNumLists = UserDefaults.standard.value(forKey: "numberOfLists") as! Int
                                                    
                                                }
                                                
                                                oldListNames.append(wordsArray[0]["list"]!)
                                                let newListNames = oldListNames
                                                let newNumOfLists = oldNumLists + 1
                                                
                                                UserDefaults.standard.set(newListNames, forKey: "listNames")
                                                UserDefaults.standard.set(newNumOfLists, forKey: "numberOfLists")
                                                
                                                //Reload + small detail
                                                self.tableHeaderLabel.text = "Spelling Lists" //At least 1 now
                                                self.tableView.reloadData()
                                                
                                            })
                                            
                                            
                                        } catch let error as NSError { //error saving newWord in context
                                            
                                            print(error.description)
                                            print("103 Error")
                                            let alert2 = self.createAlert("Oops", msg: "Something went wrong! Try again!", btn: "Okay")
                                            
                                            self.present(alert2, animated: true, completion: nil)
                                            
                                        }

                                        
                                    }
                                    
                                }
                                
                            } else /*snapshot is nil*/ {
                                
                                let alertNil = self.createAlert("Error", msg: "The code you have entered is invalid. Please try again.", btn: "Okay")
                                
                                self.present(alertNil, animated: true, completion: {})
                                
                            }

                        }, withCancel: { (error22) in
                                
                            let alertError = self.createAlert("Error", msg: "There was an error while retrieving the list. Please check the code and try again.", btn: "Okay")
                            
                            self.present(alertError, animated: true, completion: {})
                            
                        })
                        
                    }
                    
                }))
                
                self.present(alert10, animated: true, completion: {
                    //
                })
                
            }
            
        } else if (indexPath as NSIndexPath).section == 0 { //Lists Cells
            
            //Prepare info for segue
            //Segue along with info
            
            //Info should include name of list selected 
            //          (or index path; corresponds to NSUserDefaults: "listNames"
            
            
            listSelectedIndex = (indexPath as NSIndexPath).row
            
            self.performSegue(withIdentifier: "goFromListsToReady", sender: self)
            
        }
        
    }
    
    
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    
    }
    */
    

}
