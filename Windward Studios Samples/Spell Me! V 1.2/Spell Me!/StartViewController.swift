//
//  ViewController.swift
//  Spell Me!
//
//  Created by Etash Kalra on 6/15/16.
//  Copyright © 2016 Kalra. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class StartViewController: UIViewController, AVAudioPlayerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       // UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        UIApplication.shared.setStatusBarHidden(false, with: .fade)

        
    }

    @IBAction func addWordClick(_ sender: AnyObject) {
    
        //Create Storyboard Instance
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let modalVC = sb.instantiateViewController(withIdentifier: "addWordMainVC")
        
        //Present instance of view controller
        modalVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        modalVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        self.present(modalVC, animated: true, completion: nil)
        
    }
    
    @IBAction func resultsClicked(_ sender: AnyObject) {
        
        //Create Storyboard Instance
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let modalVC = sb.instantiateViewController(withIdentifier: "resultsNavi")
        
        //Present instance of view controller
        modalVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        modalVC.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        self.present(modalVC, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
