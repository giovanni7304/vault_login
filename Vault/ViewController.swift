//
//  ViewController.swift
//  Vault
//
//  Created by Terry Johnson on 11/14/16.
//  Copyright © 2016 Terry Johnson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var isAuthenticated = false
    
    @IBOutlet weak var logOut: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View DidLoad()")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    @IBAction func logOutPressed(_ sender: Any) {
        print("LogOut Pressed")
        navigationController?.popViewController(animated: true)
        //performSegue(withIdentifier: "loginSegue", sender: self)
    }
}
