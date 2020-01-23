//
//  NavigationController.swift
//  Spell Me!
//
//  Created by Etash Kalra on 6/16/16.
//  Copyright © 2016 Kalra. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let font = UIFont(name: "Kohinoor Devanagari", size: 17)
        
        self.navigationItem.backBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: font!], for: UIControlState())
        
        UIApplication.shared.setStatusBarHidden(false, with: .slide)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
