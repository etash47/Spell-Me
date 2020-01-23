//
//  AddWordViewController.swift
//  Spell Me!
//
//  Created by Etash Kalra on 6/16/16.
//  Copyright © 2016 Kalra. All rights reserved.
//

import UIKit
import QuartzCore
import AVFoundation
import CoreData

class AddWordViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, AVAudioPlayerDelegate, AVAudioRecorderDelegate, UITextViewDelegate, UITextFieldDelegate, UIViewControllerTransitioningDelegate, UIAlertViewDelegate {

    //@IBOutlet var wordTextField: UITextField!
    @IBOutlet var listPickerView: UIPickerView!
   
    @IBOutlet var dcImage: UIImageView!
    @IBOutlet var mwImage: UIImageView!
    
    @IBOutlet var wordTF: UITextField!
    @IBOutlet var infoTV: UITextView!
    
    var wordTho: String!
    var infoTho: String!
    
    //@IBOutlet var theScrollView: UIScrollView!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var playButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    var audioRecordingName = "audioFile.m4a"
    
    let audioSession = AVAudioSession.sharedInstance()
    
    var didRecordYet: Bool!
    
    //App Delegate and Context
    var appDel: AppDelegate!
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //App delegate settings
        appDel = UIApplication.shared.delegate as! AppDelegate
        context = appDel.managedObjectContext
        
        hideKeyboardWhenTappedAround()
        
        wordTF.delegate = self
        infoTV.delegate = self
        
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        
        let dekha = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 20.0))
        
        dekha.backgroundColor = UIColor(red: 31.0/255.0, green: 52.0/255.0, blue: 131.0/255.0, alpha: 1)
        
        self.view.addSubview(dekha)
        
        //Rest moved to viewDidAppear for more logic
        
        //add Buttton-like qualities to dictionary.com and mw image views
        let dcTGR = UITapGestureRecognizer(target:self, action:#selector(AddWordViewController.dcTapped))
        dcImage.isUserInteractionEnabled = true
        dcImage.addGestureRecognizer(dcTGR)

        let mwTGR = UITapGestureRecognizer(target:self, action:#selector(AddWordViewController.mwTapped))
        mwImage.isUserInteractionEnabled = true
        mwImage.addGestureRecognizer(mwTGR)

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        didRecordYet = false
        
        listPickerView.reloadAllComponents()
        
        //Info Text View Style
        let bC = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        infoTV.layer.cornerRadius = 5
        infoTV.layer.borderWidth = 1
        infoTV.layer.borderColor = bC.cgColor
        listPickerView.layer.cornerRadius = 10
        listPickerView.layer.borderWidth = 1
        listPickerView.layer.borderColor = bC.cgColor
        
        //theScrollView.flashScrollIndicators()
        
        //Get number of lists from the core data information
        let listNames = UserDefaults.standard.object(forKey: "numberOfLists") as? Int
        
        //Notifies user if no lists present
        if listNames == nil || listNames == 0 {
                
            //Tells user that they have no lists
            
            Thread.sleep(forTimeInterval: 0.25)
            
            self.dismiss(animated: true, completion: {
               
                let asd = UIAlertView(title: "No Lists!", message: "You haven't created a list yet. Please create a list and then you may add words to that list.", delegate: self, cancelButtonTitle: "Okay")
                
                asd.show()
                
            })
            
        }
        
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        wordTF.resignFirstResponder()
        infoTV.resignFirstResponder()
        //theScrollView.flashScrollIndicators()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
        
       // theScrollView.flashScrollIndicators()
        
    }
    
    @IBAction func addWord(_ sender: AnyObject) {
    
        //If some fields are nil
        if wordTF.text == nil || wordTF.text == "" || infoTV.text == nil || infoTV.text == "" {
            
            //Alert the user of empty fields
            let alert3373 = createAlert("Empty Fields", msg: "Please make sure no fields are left blank", btn: "Okay")
            
            self.present(alert3373, animated: true, completion: nil)
            
        } else { //If no fields are nil
            
            //Finds the default list (0th index) in the listPicker
            let listIndex0 = listPickerView.selectedRow(inComponent: 0)
            let list0 = (UserDefaults.standard.object(forKey: "listNames") as! [String])[listIndex0]
            
            //Temp variables
            wordTho = wordTF.text
            infoTho = infoTV.text
            
            //If the word is already in the list
            if isWordInList((wordTho.lowercased()), list: list0) {
            
                //Notify user that the word already exists
                let alert101012 = createAlert("Word exists", msg: "The word you are trying to create already exists in this list. Make a different word or choose another list.", btn: "Okay")
                
                self.present(alert101012, animated: true, completion: nil)
                
            } else if didRecordYet == false { //audio blank
                
                //Notify user that audio was not recorded before adding the word
                let alert = createAlert("No pronounciation", msg: "Please make sure you have recorded a pronounciation and try again", btn: "Okay")
        
                self.present(alert, animated: true, completion: nil)
                
            } else { //ALL FILLED IN****
                
                var spelling = wordTho.lowercased()
                
                //Removes spaces at the end
                while spelling.substring(from: (spelling.endIndex)) == " " {
                    
                    spelling.remove(at: spelling.endIndex)
                    
                }
                
                let info = infoTho
                
                //Selected list in the listpicker view
                let listIndex = listPickerView.selectedRow(inComponent: 0)
                //Gets the list object from the core data log (using selected list name)
                let list = (UserDefaults.standard.object(forKey: "listNames") as! [String])[listIndex]
                
                if let audio: Data = try? Data(contentsOf: getAudioFileURL()) { //Everthing ready to go and become Core Data!
                    
                    //New Object for Word entity
                    let newWord = NSEntityDescription.insertNewObject(forEntityName: "Word", into: context)
                    
                    //Set Values
                    newWord.setValue(spelling, forKey: "spelling")
                    newWord.setValue(info, forKey: "info")
                    newWord.setValue(list, forKey: "list")
                    newWord.setValue(audio, forKey: "audio")
                    
                    //Save context
                    do {
                        
                        try context.save()
                        
                        //Everything was successful if this line is executed!
                       
                        let alert1 = UIAlertController(title: "Word Added!", message: "Your word was successfully added", preferredStyle: .alert)
                        
                        alert1.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                            
                            //Reset everything
                            self.didRecordYet = false
                            self.wordTF.text = ""
                            self.infoTV.text = ""
                            self.listPickerView.selectRow(0, inComponent: 0, animated: true)
                            
                        }))
                        
                        self.present(alert1, animated: true, completion: {
                        
                            //Reset everything
                            self.didRecordYet = false
                            self.wordTF.text = ""
                            self.infoTV.text = ""
                            self.listPickerView.selectRow(0, inComponent: 0, animated: true)
                            
                            
                        })
                        
                    } catch let error as NSError { //error saving newWord in context
                        
                        print(error.description)
                        print("103 Error")
                        let alert2 = createAlert("Oops", msg: "Something went wrong! Try again!", btn: "Okay")
                        
                        self.present(alert2, animated: true, completion: nil)
                        
                    }
                    
                    
                } else { //Couldn't transform cache audio to NSData
                    
                    print("error 90")
                    let alert34 = createAlert("Oops", msg: "Something went wrong! Try again!", btn: "Okay")
                    self.present(alert34, animated: true, completion: nil)
                    
                }
                
            }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Sets pickerview rows to lists and formats them (color, size, font, etc.)
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        var name: String?
        
        //Gets all the list names from the core data
        let listNames = UserDefaults.standard.object(forKey: "listNames") as! [String]
        
        if listNames.count == 0 { //No Lists
            
            //Alert for "no lists created" shown in numberOfRowsInComponent func
            
            name = nil
            
        } else { //has at least one list
            
            name = listNames[row]
        }
        
        //Format
        let pickerLabel = UILabel()
    
        pickerLabel.textColor = UIColor(red: 0.04705 , green: 0.1686, blue: 0.6941, alpha: 1) //Dark Blue

        pickerLabel.text = name
        
        pickerLabel.font = UIFont(name: "Kohinoor Devanagari", size: 15)
        
        pickerLabel.textAlignment = NSTextAlignment.center
        
        return pickerLabel
    
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        //Gets all the list names from the core data
        let listNames = UserDefaults.standard.object(forKey: "numberOfLists") as? Int
        
        //@return 0 or number of lists
        
        if listNames == nil || listNames == 0 { //No Lists

            return 0
            
        } else { //has at least one list
            
            //return (listNames as! [String]).count
            return listNames!
            
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    //Returns where the audio file WILL be stored (or is already)
    //uses random string path name
    func getAudioFileURL() -> URL {
        
        //Instance of the Directories in the app
        let docDirs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        //Finds the first directory
        let documentDirectory = docDirs[0] as NSString
        
        //Adds a path from that directory
        let path = documentDirectory.appendingPathComponent(audioRecordingName)
        
        //Extract the url from the path just added
        let urlPath = URL(fileURLWithPath: path)
        
        return urlPath
        
    }
    
    
    @IBAction func record(_ sender: AnyObject) {
    
        didRecordYet = true
        
        if recordButton.titleLabel?.text == "Record" {
            
            //Setup Recorder
            
            do {
                
                //Set the audiosession mode to record
                try audioSession.setCategory(AVAudioSessionCategoryRecord)
                
            } catch let error as NSError { //Error catching
                
                print("62 Error")
                print(error.description)
                let alert2345 = createAlert("Oops", msg: "Something went wrong! Try again!", btn: "Okay")
                self.present(alert2345, animated: true, completion: nil)
                
            }
            
            let recorderSettings = [AVSampleRateKey : NSNumber(value: Float(44100.0) as Float),
                                    AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC) as Int32),
                                    AVNumberOfChannelsKey : NSNumber(value: 2 as Int32),
                                    AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.max.rawValue) as Int32)]
            
            do { //Make Audio Recorder and Prepare
                
                //Set the recorder to an instance targetted towards a designated file URL
                audioRecorder = try AVAudioRecorder(url: getAudioFileURL(), settings: recorderSettings)
                
                audioRecorder.delegate = self
                
                audioRecorder.prepareToRecord()
                
            } catch { //Error
                
                audioRecorder = nil
                
                print("error 69")
                
                let alert = createAlert("Error", msg: "The message couldn't be recorded. Try checking if you allowed this app to record audio in Settings>Privacy>Microphone", btn: "Okay")
                
                self.present(alert, animated: true, completion: nil)

            }
            
            
            audioRecorder.record()
            
            recordButton.setTitle("Stop", for: UIControlState())
            
           // theScrollView.flashScrollIndicators()
            
        } else { //'Stop' Text
            
            audioRecorder.stop()
            
            recordButton.setTitle("Record", for: UIControlState())
         
            //This helps increase volume of playback
            do {
                
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                
            } catch let error as NSError {
                
                print("245 Error")
                print(error.description)
                let alert2246 = createAlert("Oops", msg: "Something went wrong! Try again!", btn: "Okay")
                self.present(alert2246, animated: true, completion: nil)
                
            }
            
          //  theScrollView.flashScrollIndicators()
            
        }
        
        playButton.isEnabled = false
        
    }
    
    @IBAction func play(_ sender: AnyObject) {
    
        if playButton.titleLabel?.text == "Play" {
            
            recordButton.isEnabled = false
            
            playButton.setTitle("Playing", for: UIControlState())
            
            //Setup Player
            
            do {
                
                //Get file url for recent recording
                let thisUrl = getAudioFileURL()
             
                //Play contents of URL
                audioPlayer = try AVAudioPlayer(contentsOf: thisUrl)
                
                audioPlayer.delegate = self
                audioPlayer.prepareToPlay()
                audioPlayer.volume = 1.0
                
            } catch { //Error
                
                audioPlayer = nil
                
                print("error 233")
                
                let alert = createAlert("Error", msg: "The message couldn't be recorded. Try checking if you allowed this app to record audio in Settings>Privacy>Microphone", btn: "Okay")
                
                self.present(alert, animated: true, completion: nil)

                
            }
            
            
            audioPlayer.play()
            
            //theScrollView.flashScrollIndicators()
            
        }
    
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        //theScrollView.flashScrollIndicators()
        
        playButton.isEnabled = true
    
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    
        recordButton.isEnabled = true
        
        playButton.setTitle("Play", for: UIControlState())
        
        //theScrollView.flashScrollIndicators()
    
    }
    
    func isWordInList(_ word: String, list: String) -> Bool {
        
        //Core data fetch request for a word object
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Word")
        request.returnsObjectsAsFaults = false
        //Searches for spelling of word
        request.predicate = NSPredicate(format: "spelling = %@", word)
        
        do {
            
            //Execute fetch request
            let results = try context.fetch(request)
            
            //If result found
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
                    //Identify result is in the current list
                    if let cList = result.value(forKey: "list") as? String {
                        
                        if cList == list {
                            
                            return true
                            
                        }
                        
                    }
                    
                }
                
            }
            
        } catch {
            
            return false
        }
        
        return false
        
    }
    
    //Dictionary.com
    func dcTapped() {
        
        if wordTF.text == "" || wordTF.text == nil {
            
            let alert = createAlert("Blank Field", msg: "Please enter a word before searching for definitions on Dictionary.com", btn: "Okay")
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            self.performSegue(withIdentifier: "dc1", sender: self)
            
        }
        
    }
    
    //Merriam Webster
    func mwTapped() {
        
        if wordTF.text == "" || wordTF.text == nil {
            
            let alert = createAlert("Blank Field", msg: "Please enter a word before searching for definitions on Dictionary.com", btn: "Okay")
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            self.performSegue(withIdentifier: "mw1", sender: self)
            
        }

        
    }
    
    @IBAction func xPressed(_ sender: AnyObject) {
    
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let word = wordTF.text
        
        var linkS: String = ""
        
        if segue.identifier == "dc1" {
            
            linkS = "http://www.dictionary.com/browse/\(word!)"
            
        } else if segue.identifier == "mw1" {
            
            linkS = "http://www.merriam-webster.com/dictionary/\(word!)"
            
        } else {
            
            linkS = "https://www.google.com"
            
        }
        
        let webVC = segue.destination as! WebDefinitionViewController
        
        webVC.linkString = linkS
        
    }
    

}
