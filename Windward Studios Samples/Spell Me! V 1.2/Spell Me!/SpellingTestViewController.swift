//
//  SpellingTestViewController.swift
//  Spell Me!
//
//  Created by Etash Kalra on 6/20/16.
//  Copyright © 2016 Kalra. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class SpellingTestViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate, UITextFieldDelegate {

    @IBOutlet var playButton: UIButton!
    @IBOutlet var infoTextView: UITextView!
    @IBOutlet var wordTextField: UITextField!
    @IBOutlet var nextButtton: UIButton!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var endOfTestLabel: UILabel!
    @IBOutlet var goToResultsButton: UIButton!
    
    var appDel: AppDelegate!
    var context: NSManagedObjectContext!
    
    let audioSession = AVAudioSession.sharedInstance()
    var audioPlayer: AVAudioPlayer!
    
    var list: String!
    var wordsInThisList_c = wordsInThisList
    var wordOn: String!
    
    var numberWordOn: Int = 0
    let totalNumberOfWords = wordsInThisList?.count
    
    var thisTestSession: NSManagedObject!
    
    var wordsInRespRandOrder = [String]()
    var userInputInOrder = [String]()
    var correctOrNotInOrder = [Bool]()
    
    var numCorrect: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        endOfTestLabel.alpha = 0
        goToResultsButton.isEnabled = false
        goToResultsButton.alpha = 0
        
        wordTextField.delegate = self
        
        //CoreData
        appDel = UIApplication.shared.delegate as! AppDelegate
        context = appDel.managedObjectContext
        
        hideKeyboardWhenTappedAround()
        
        //Init the list
        list = (UserDefaults.standard.object(forKey: "listNames") as! [String])[listSelectedIndex!]
        
        //Get da word
        wordOn = getNextWord()
        
        //Get da information
        infoTextView.text = getInformation(list, word: wordOn)
        
        //Progress bar stuff
        progressBar.setProgress(Float(numberWordOn) / Float(totalNumberOfWords!), animated: true)
        progressLabel.text = "\(numberWordOn)/\(totalNumberOfWords!)"
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        nextClicked(textField)
        
        print("alksdjfa")
        
        textField.resignFirstResponder()
        
        return true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextClicked(_ sender: AnyObject) {
    
        if wordTextField.text == nil || wordTextField.text == "" { //Blank
            
            let alert2222233 = createAlert("Blank field", msg: "Make sure you have entered something for the spelling", btn: "Okay")
            
            self.present(alert2222233, animated: true, completion: nil)
            
        } else { //not blank
            
            var enteredSpelling = wordTextField.text!
            
            //Removes spaces at the end
            while enteredSpelling.substring(from: enteredSpelling.endIndex) == " " {
                
                enteredSpelling.remove(at: enteredSpelling.endIndex)
                
            }
            
            userInputInOrder.append(enteredSpelling)
            
            //Check
            if enteredSpelling.lowercased() == wordOn { //Correct
                
                correctOrNotInOrder.append(true)
                numCorrect += 1
                
            } else { //incorrect
                
                correctOrNotInOrder.append(false)
                
            }
            
            wordOn = getNextWord()
            
            if wordOn == nil { //Last word
                
                thisTestSession = NSEntityDescription.insertNewObject(forEntityName: "Test_Session", into: context)
                
                //Calculate score, update core data to create new Test_Session entity
                
                let score = "\(Int(numCorrect)) / \(Int(totalNumberOfWords!))"
                
                //Date and time
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = DateFormatter.Style.short
                dateFormatter.dateStyle = DateFormatter.Style.short
                var localDate = dateFormatter.string(from: date)
                let localDateSpaceArray = localDate.components(separatedBy: " ")
                let amORpm = localDateSpaceArray[localDateSpaceArray.count - 1]
                localDate = localDateSpaceArray[0]
                localDate += " " + amORpm + " - " + localDateSpaceArray[localDateSpaceArray.count - 2]
                
                //Set values for entity
                thisTestSession.setValue(correctOrNotInOrder, forKey: "correctOrNot")
                thisTestSession.setValue(localDate, forKey: "date")
                thisTestSession.setValue(list, forKey: "list")
                thisTestSession.setValue(score, forKey: "score")
                thisTestSession.setValue(userInputInOrder, forKey: "userType")
                thisTestSession.setValue(wordsInRespRandOrder, forKey: "words")
                
                //Save context
                do {
                    
                    try context.save()
                    
                    //Disable and fade away
                    playButton.isEnabled = false
                    nextButtton.isEnabled = false
                    wordTextField.endEditing(true)
                    
                    UIView.animate(withDuration: 1, animations: {
                        
                        self.playButton.alpha = 0
                        self.nextButtton.alpha = 0
                        self.infoTextView.alpha = 0
                        self.wordTextField.alpha = 0
                        self.progressLabel.alpha = 0
                        self.progressBar.alpha = 0
                        
                    }, completion: { (true) in
                            
                        self.endOfTestLabel.text = "You have completed this test with a score of \(score).\nGo to \"Results\" page for details."
                        
                        UIView.animate(withDuration: 1, animations: {
                        
                            self.endOfTestLabel.alpha = 1
                            
                            self.goToResultsButton.alpha = 1
                            
                            self.goToResultsButton.isEnabled = true
                            
                        })
                            
                    })
                    
                } catch {
                    
                    let alert22500 = createAlert("Error", msg: "There was an error!", btn: "Okay")
                    
                    self.present(alert22500, animated: true, completion: nil)
                    
                }
                
            } else { //Another word coming up
                
                //Disable and fade away
                playButton.isEnabled = false
                nextButtton.isEnabled = false
                wordTextField.endEditing(true)
                
                UIView.animate(withDuration: 1, animations: {
                    
                    self.playButton.alpha = 0
                    self.nextButtton.alpha = 0
                    self.infoTextView.alpha = 0
                    self.wordTextField.alpha = 0
                    self.progressLabel.alpha = 0
                    
                }, completion: { (true) in
                    
                    //update (while hidden)
                    self.infoTextView.text = self.getInformation(self.list, word: self.wordOn)
                    self.progressLabel.text = "\(self.numberWordOn)/\(self.totalNumberOfWords!)"
                    self.wordTextField.text = ""
                    
                    //Enable and fade back in
                    self.playButton.isEnabled = true
                    self.nextButtton.isEnabled = true
                    
                    UIView.animate(withDuration: 1, animations: {
                        
                        self.playButton.alpha = 1
                        self.nextButtton.alpha = 1
                        self.infoTextView.alpha = 1
                        self.wordTextField.alpha = 1
                        self.progressLabel.alpha = 1
                        
                    })
                    
                    self.progressBar.setProgress( (Float(self.numberWordOn) / Float(self.totalNumberOfWords!)),  animated: true)
                    
                })
                
            }
            
        }
        
        
    }
    
    
    @IBAction func playSound(_ sender: AnyObject) {
    
        if playButton.titleLabel?.text == "Play" {
            
            playButton.setTitle("Playing", for: UIControlState())
            playButton.isEnabled = false
            
            let audioData = getAudioData(list, word: wordOn)
            
            do {
                
                audioPlayer = try AVAudioPlayer(data: audioData!)
                
                audioPlayer.delegate = self
                audioPlayer.prepareToPlay()
                audioPlayer.volume = 1.0
                
            } catch {
                
                audioPlayer = nil
                
                let alert00333 = createAlert("Error", msg: "Sorry, but there was an error trying to play the pronounciation of the word. Try again", btn: "Okay")
                
                self.present(alert00333, animated: true, completion: nil)
                
            }
            
            do {
                
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                
            } catch {
                
                let alert00633 = createAlert("Error", msg: "Sorry, but there was an error trying to play the pronounciation of the word. Try again", btn: "Okay")
                
                self.present(alert00633, animated: true, completion: nil)
                
            }
            
            audioPlayer.play()
            
        } else {
            
            //Do Nothing
            
        }
        
    }
    
    
    
    func getAudioData(_ list: String, word: String) -> Data? {
        
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Word")
        
        request.predicate = NSPredicate(format: "spelling = %@", word)
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(request)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
                    if result.value(forKey: "list") as! String == list {
                        
                        //Correct result/word
                        
                        let data: Data = result.value(forKey: "audio") as! Data
                        
                        return data
                        
                    }
                    
                }
                
                
            } else {
                
                let alert003 = createAlert("Error", msg: "Sorry, but there was an error trying to load the pronounciation of the word. Try again", btn: "Okay")
                
                self.present(alert003, animated: true, completion: nil)
                
            }
            
        } catch {
            
            let alert0033 = createAlert("Error", msg: "Sorry, but there was an error trying to load the pronounciation of the word. Try again", btn: "Okay")
            
            self.present(alert0033, animated: true, completion: nil)
            
        }
        
        return nil
        
    }
    
    func getInformation(_ list: String, word: String) -> String? {
        
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Word")
        
        request.predicate = NSPredicate(format: "spelling = %@", word)
        
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(request)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    
                    if result.value(forKey: "list") as! String == list {
                        
                        let info = result.value(forKey: "info") as! String
                        
                        return info
                        
                    }
                    
                }
                
            } else {
                
                let alert0303 = createAlert("Error", msg: "Sorry, but there was an error trying to load the information of the word. Try again", btn: "Okay")
                
                self.present(alert0303, animated: true, completion: nil)
                
            }
            
        } catch {
            
            let alert0013 = createAlert("Error", msg: "Sorry, but there was an error trying to load the information of the word. Try again", btn: "Okay")
            
            self.present(alert0013, animated: true, completion: nil)
            
        }
        
        return nil
        
    }
    
    func getNextWord() -> String? {
        
        let number = wordsInThisList_c?.count
        
        if number == 0 {
            
            return nil
            
        } else {
            
            let rnd = Int(arc4random_uniform(UInt32(number!)))
            
            let daWord = wordsInThisList_c![rnd]
            
            wordsInThisList_c!.remove(at: rnd)
            
            numberWordOn += 1
            
            wordsInRespRandOrder.append(daWord)
            
            return daWord
            
        }
    
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        playButton.setTitle("Play", for: UIControlState())
        playButton.isEnabled = true
        
    }

    @IBAction func goToResultsYo(_ sender: AnyObject) {
    
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let modalVC = sb.instantiateViewController(withIdentifier: "resultsNavi")
        
        modalVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        modalVC.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        self.present(modalVC, animated: true, completion: nil)
        
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
