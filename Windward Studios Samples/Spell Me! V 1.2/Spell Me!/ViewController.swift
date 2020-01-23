//
//  ViewController.swift
//  Spell Me!
//
//  Created by Etash Kalra on 6/18/16.
//  Copyright © 2016 Kalra. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
       
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
    
        view.endEditing(true)
    
    }
    
    func createAlert(_ ttl: String, msg: String, btn: String) -> UIAlertController {
        
        let alert = UIAlertController(title: ttl, message: msg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: btn, style: .default, handler: nil))
        
        return alert
        
    }
    
}

class ViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

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


