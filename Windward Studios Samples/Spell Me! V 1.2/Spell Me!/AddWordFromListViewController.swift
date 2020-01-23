//
//  AddWordFromListViewController.swift
//  Spell Me!
//
//  Created by Etash Kalra on 7/19/16.
//  Copyright © 2016 Kalra. All rights reserved.
//

import UIKit
import QuartzCore
import AVFoundation
import CoreData

class AddWordFromListViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, AVAudioPlayerDelegate, AVAudioRecorderDelegate, UITextViewDelegate, UITextFieldDelegate, UIViewControllerTransitioningDelegate, UIAlertViewDelegate {
    
    //@IBOutlet var wordTextField: UITextField!
    //@IBOutlet var listPickerView: UIPickerView!
    @IBOutlet var dcImage: UIImageView!
    @IBOutlet var mwImage: UIImageView!
    
    @IBOutlet var wordTF: UITextField!
    @IBOutlet var infoTV: UITextView!
    
    var wordTho: String!
    var infoTho: String!
    
    @IBOutlet var listLabel: UILabel!
    var listSel: String!
    
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
        let dcTGR = UITapGestureRecognizer(target:self, action:#selector(AddWordFromListViewController.dcTapped))
        dcImage.isUserInteractionEnabled = true
        dcImage.addGestureRecognizer(dcTGR)
        
        let mwTGR = UITapGestureRecognizer(target:self, action:#selector(AddWordFromListViewController.mwTapped))
        mwImage.isUserInteractionEnabled = true
        mwImage.addGestureRecognizer(mwTGR)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        listLabel.text = listSel
        
        didRecordYet = false
        
        //Info Text View Style
        let bC = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
        infoTV.layer.cornerRadius = 5
        infoTV.layer.borderWidth = 1
        infoTV.layer.borderColor = bC.cgColor
        
        //theScrollView.flashScrollIndicators()
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
        
        if wordTF.text == nil || wordTF.text == "" || infoTV.text == nil || infoTV.text == "" {
            
            let alert3373 = createAlert("Empty Fields", msg: "Please make sure no fields are left blank", btn: "Okay")
            
            self.present(alert3373, animated: true, completion: nil)
            
        } else {
            
            let list0 = listSel
            
            wordTho = wordTF.text
            infoTho = infoTV.text
            
            if isWordInList((wordTho.lowercased()), list: list0!) {
                
                let alert101012 = createAlert("Word exists", msg: "The word you are trying to create already exists in this list. Make a different word or choose another list.", btn: "Okay")
                
                self.present(alert101012, animated: true, completion: nil)
                
            } else if didRecordYet == false { //audio blank
                
                let alert = createAlert("No pronounciation", msg: "Please make sure you have recorded a pronounciation and try again", btn: "Okay")
                
                self.present(alert, animated: true, completion: nil)
                
            } else { //ALL FILLED IN****
                
                var spelling = wordTho.lowercased()
                
                //Removes spaces at the end
                while spelling.substring(from: (spelling.endIndex)) == " " {
                    
                    spelling.remove(at: spelling.endIndex)
                    
                }
                
                let info = infoTho
                
                let list = listSel
                
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
                            
                        }))
                        
                        self.present(alert1, animated: true, completion: {
                            
                            //Reset everything
                            self.didRecordYet = false
                            self.wordTF.text = ""
                            self.infoTV.text = ""
                            
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
        
        let listNames = UserDefaults.standard.object(forKey: "listNames")
        
        //@return 0 or number of lists
        
        if listNames == nil { //No Lists
            
            return 0
            
        } else { //has at least one list
            
            return (listNames as! [String]).count
            
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    //Returns where the audio file WILL be stored (or is already)
    //uses random string path name
    func getAudioFileURL() -> URL {
        
        let docDirs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        let documentDirectory = docDirs[0] as NSString
        
        let path = documentDirectory.appendingPathComponent(audioRecordingName)
        
        let urlPath = URL(fileURLWithPath: path)
        
        return urlPath
        
    }
    
    
    @IBAction func record(_ sender: AnyObject) {
        
        didRecordYet = true
        
        if recordButton.titleLabel?.text == "Record" {
            
            //Setup Recorder
            
            do {
                
                try audioSession.setCategory(AVAudioSessionCategoryRecord)
                
            } catch let error as NSError {
                
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
                
                let thisUrl = getAudioFileURL()
                
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
        
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Word")
        
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "spelling = %@", word)
        
        do {
            
            let results = try context.fetch(request)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
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
    
    func dcTapped() {
        
        if wordTF.text == "" || wordTF.text == nil {
            
            let alert = createAlert("Blank Field", msg: "Please enter a word before searching for definitions on Dictionary.com", btn: "Okay")
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            self.performSegue(withIdentifier: "dc2", sender: self)
            
        }
        
    }
    
    func mwTapped() {
        
        if wordTF.text == "" || wordTF.text == nil {
            
            let alert = createAlert("Blank Field", msg: "Please enter a word before searching for definitions on Dictionary.com", btn: "Okay")
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            self.performSegue(withIdentifier: "mw2", sender: self)
            
        }
        
        
    }
    
    @IBAction func xPressed(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let word = wordTF.text
        
        var linkS: String = ""
        
        if segue.identifier == "dc2" {
            
            linkS = "http://www.dictionary.com/browse/\(word!)"
            
        } else if segue.identifier == "mw2" {
            
            linkS = "http://www.merriam-webster.com/dictionary/\(word!)"
            
        } else {
            
            linkS = "https://www.google.com/#q=\(word!)"
            
        }
        
        let webVC = segue.destination as! WebDefinitionViewController
        
        webVC.linkString = linkS
        
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
