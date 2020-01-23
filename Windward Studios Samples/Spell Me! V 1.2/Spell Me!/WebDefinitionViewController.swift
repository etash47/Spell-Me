//
//  WebDefinitionViewController.swift
//  Spell Me!
//
//  Created by Etash Kalra on 10/13/16.
//  Copyright © 2016 Etash Kalra. All rights reserved.
//

import UIKit

class WebDefinitionViewController: UIViewController {

    var linkString: String!
    
    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let webUrl = URL(string: linkString)
        
        //print(linkString)
        
        webView.loadRequest(URLRequest(url: webUrl!))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func xPressed(_ sender: AnyObject) {
    
        self.dismiss(animated: true, completion: nil)
    
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
