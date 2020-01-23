//
//  ListDetailViewController.swift
//  Spell Me!
//
//  Created by Etash Kalra on 6/18/16.
//  Copyright © 2016 Kalra. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseDatabase

var wordsInThisList: [String]?

class ListDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var appDel: AppDelegate!
    var context: NSManagedObjectContext!
    
    @IBOutlet var letsSpellButton: UIButton!
    @IBOutlet var wordsTableView: UITableView!
    @IBOutlet var listLabel: UILabel!
    @IBOutlet var addAWordButton: UIBarButtonItem!
    @IBOutlet var renameListButton: UIBarButtonItem!
    
    var daList: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let font = UIFont(name: "Kohinoor Devanagari", size: UIFont.labelFontSize - 2)
        
        addAWordButton.setTitleTextAttributes([NSFontAttributeName: font!], for: UIControlState())
        
        renameListButton.setTitleTextAttributes([NSFontAttributeName: font!], for: UIControlState())
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        wordsTableView.reloadData()
        
        if wordsInThisList == nil || wordsInThisList?.count == 0 {
            
            letsSpellButton.setTitle("No words yet!", for: UIControlState())
            
        } else {
            
            letsSpellButton.setTitle("Take a test", for: UIControlState())
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func letsSpellClicked(_ sender: AnyObject) {
    
        performSegue(withIdentifier: "goToSpellSegue", sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //Fetch request to initialize wordsInThisList before cellForRowAtIndexPath
        //@return number of words in wordsInThisList
        let thisListName = (UserDefaults.standard.object(forKey: "listNames") as! [String])[listSelectedIndex!]
        
        daList = thisListName
        
        listLabel.text = daList!
        
        letsSpellButton.isEnabled = true
        
        wordsInThisList = [" "]
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        context = appDel.managedObjectContext
        
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Word")
        
        request.predicate = NSPredicate(format: "list = %@", daList!)
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(request)
            
            //print(results.count)
            
            if results.count > 0 {
            
                for result in results as! [NSManagedObject] {
                
                    if let spelling = result.value(forKey: "spelling") as? String {
                    
                       //print(spelling)
                        
                        wordsInThisList!.append(spelling)
                    
                    } else {
                        
                        //print("here")
                        
                    }
                
                }
            
            } else {
                
                letsSpellButton.isEnabled = false
                
                letsSpellButton.setTitle("No words yet!", for: UIControlState())
                
                print("asdfas")

            }
            
        } catch {
            
            let alert235 = createAlert("Error", msg: "Sorry, there was an error retrieving the words from that list. Please try again", btn: "Okay")
            
            self.present(alert235, animated: true, completion: nil)
            
        }
        
        wordsInThisList?.removeFirst()
        
        //Actual return value
        return (wordsInThisList?.count)!
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "wordInListReuseIdentifier", for: indexPath)
        
        cell.textLabel?.text = wordsInThisList![(indexPath as NSIndexPath).row]
        
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        cell.textLabel?.textColor = UIColor(red: 1 , green: 0.5764, blue: 0.1, alpha: 1)
        
        cell.textLabel?.font = UIFont(name: "Kohinoor Devanagari", size: 17)
        
        cell.textLabel?.textAlignment = NSTextAlignment.center
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
        
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
         
            let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Word")
            
            request.returnsObjectsAsFaults = false
            
            request.predicate = NSPredicate(format: "list = %@", daList!)
            
            do {
                
                let results = try context.fetch(request)
                
                if results.count > 0 {
                    
                    resultLoop: for result in results as! [NSManagedObject] {
                        
                        if let spelling = result.value(forKey: "spelling") as? String {
                            
                            if spelling == wordsInThisList![(indexPath as NSIndexPath).row] {
                                
                                context.delete(result)
                                
                                do {
                                    
                                    try context.save()
                                    
                                } catch {
                                
                                    let alert113 = createAlert("Error", msg: "Sorry! There was an error deleting that word!", btn: "Okay")
                                    
                                    self.present(alert113, animated: true, completion: nil)
                                
                                }
                                
                                wordsTableView.reloadData()
                                
                                if wordsInThisList == nil || wordsInThisList!.count == 0 {
                                    
                                    letsSpellButton.isEnabled = false
                                    
                                    letsSpellButton.setTitle("No words yet!", for: UIControlState())
                                    
                                } else {
                                    
                                    letsSpellButton.isEnabled = true
                                    
                                    letsSpellButton.setTitle("Take a test", for: UIControlState())
                                    
                                    
                                }
                                
                                break resultLoop
                                
                            }
                            
                        }
                    }
                    
                }
                
            } catch {
                
                let alert1d13 = createAlert("Error", msg: "Sorry! There was an error deleting that word!", btn: "Okay")
                
                self.present(alert1d13, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        
        self.wordsTableView.setEditing(editing, animated: animated)
        
    }

    @IBAction func renameClicked(_ sender: AnyObject) {
    
        let oldList = daList
        var newList: String?
        
        let newListBox = UIAlertController(title: "List Name", message: "What would you like to name this list?", preferredStyle: .alert)
        
        newListBox.addTextField { (tField) in
            
            tField.text = oldList
            
        }
        
        newListBox.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            
            let enteredText = (newListBox.textFields![0] as UITextField).text
            
            var oldListNames: [String]
            
            if UserDefaults.standard.value(forKey: "listNames") == nil {
                
                oldListNames = [String]()
                
            } else {
                
                oldListNames = UserDefaults.standard.value(forKey: "listNames") as! [String]
                
            }
            
            if enteredText == "" || enteredText == nil {
                
                //Do Nothing
                
            } else {
                
                //Not Blank
                
                newList = enteredText
                
                if oldListNames.index(of: enteredText!) == nil && enteredText! != "" { //List name is available
                    
                    //Update data source with new listname
                    let indx = oldListNames.index(of: oldList!)
                    
                    oldListNames.remove(at: indx!)
                    oldListNames.insert(newList!, at: indx!)
                    
                    let newListNames = oldListNames
                    
                    UserDefaults.standard.set(newListNames, forKey: "listNames")
                    
                    //Change ALL WORDS to have new list attribute
                    let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Word")
                    
                    request.returnsObjectsAsFaults = false
                    
                    request.predicate = NSPredicate(format: "list = %@", oldList!)
                    
                    do {
                        
                        let resultz = try self.context.fetch(request) as! [NSManagedObject]
                        
                        if resultz.count > 0 {
                            
                            for result in resultz {
                                
                                let resultNew = NSEntityDescription.insertNewObject(forEntityName: "Word", into: self.context)
                                
                                resultNew.setValue(newList, forKey: "list")
                                resultNew.setValue(result.value(forKey: "audio"), forKey: "audio")
                                resultNew.setValue(result.value(forKey: "spelling"), forKey: "spelling")
                                resultNew.setValue(result.value(forKey: "info"), forKey: "info")
                                
                                self.context.delete(result)
                                
                                do {
                                    
                                    try self.context.save()
                                
                                } catch {
                                    
                                    //Error
                                    self.present(self.createAlert("Error", msg: "There was an error. Try again.", btn: "Okay"), animated: true, completion: nil)
                                    
                                }
                                
                            }
                            
                        }
                        
                    } catch {
                        
                        self.present(self.createAlert("Error", msg: "Sorry. There was an error. Try again.", btn: "Okay"), animated: true, completion: nil)
                        
                    }
                    
                    self.viewDidLoad()
                    self.wordsTableView.reloadData()
                    
                } else { //List name is taken
                    
                    //Display error message
                    
                    let alert = UIAlertController(title: "List name", message: "The name of the list you have entered is already taken by another list. Please choose a different name.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action2) in
                        
                        
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    
                }

                
            }
            
        }))
        
        newListBox.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
        self.present(newListBox, animated: true, completion: nil)
        
    }
    
    
    @IBAction func addWordClicked(_ sender: AnyObject) {
    
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let modalVC = sb.instantiateViewController(withIdentifier: "addWordFromListVC") as! AddWordFromListViewController
        
        modalVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        
        modalVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        modalVC.listSel = daList
        
        self.present(modalVC, animated: true, completion: nil)
    
    }
    
    @IBAction func shareClicked(_ sender: AnyObject) {
    
        let alert1 = UIAlertController(title: "Beehive List", message: "This feature allows you to transfer a list to another device, or share it with friends, family, classmates, or anyone else.", preferredStyle: .alert)
        
        alert1.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action1) in
            
            var theWords: [[String: AnyObject]] = []
            
            self.appDel = UIApplication.shared.delegate as! AppDelegate
            
            self.context = self.appDel.managedObjectContext
            
            let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Word")
            
            request.predicate = NSPredicate(format: "list = %@", self.daList!)
            
            request.returnsObjectsAsFaults = false
            
            do {
                
                let results = try self.context.fetch(request)
                
                //print(results.count)
                
                if results.count > 0 {
                    
                    var allTheWords: [AnyObject] = []
                    
                    for result in results as! [NSManagedObject] {
                        
                        var thisWord = [String: String]()
                        
                        if let spelling = result.value(forKey: "spelling") as? String {
                            
                            thisWord["spelling"] = spelling
                            
                        }
                        
                        if let info = result.value(forKey: "info") as? String {
                            
                            thisWord["info"] = info
                            
                        }
                        
                        if let list = result.value(forKey: "list") as? String {
                            
                            thisWord["list"] = list
                            
                        }
                        
                        if let audio = result.value(forKey: "audio") as? Data {
                            
                            print(audio)
                            
                            let audioString = audio.base64EncodedString() as String
                            
                            thisWord["audio"] = audioString
                            
                        }
                        
                        allTheWords.append(thisWord as AnyObject)
                        
                    }
                    
                    let ref = FIRDatabase.database().reference()
                    
                    ref.childByAutoId().setValue(allTheWords, withCompletionBlock: { (error0, reference0) in
                        
                        if error0 == nil {
                            
                            let alert2 = self.createAlert("List Shared!", msg: "Please keep and/or share this code \n \n \(reference0.key) \n \n  and enter it when prompted on \"Lists\" page to retrieve the list! You can also copy it by clicking the \'copy\' button", btn: "Okay")
                            
                            alert2.addAction(UIAlertAction(title: "Copy the code", style: .default, handler: { (action11) in
                                
                                UIPasteboard.general.string = reference0.key
                                
                            }))
                            
                            self.present(alert2, animated: true, completion: {
                                //
                            })
                            
                        } else {
                            
                            let alert3 = self.createAlert("Error", msg: error0!.localizedDescription, btn: "Okay")
                            
                            self.present(alert3, animated: true, completion: {
                                //
                            })
                            
                        }
                        
                        
                    })
                    

                    
                } else { //Results == 0
                    
                    let alertr235 = self.createAlert("No Words!", msg: "There are no words in this list!", btn: "Okay")
                    
                    self.present(alertr235, animated: true, completion: nil)

                    
                }
                
            } catch {
                
                let alertr235 = self.createAlert("Error", msg: "Sorry, there was an error retrieving the words from that list. Please try again", btn: "Okay")
                
                self.present(alertr235, animated: true, completion: nil)
                
            }

        }))
        
        alert1.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            //
        }))
        
        self.present(alert1, animated: true) {
            //
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
