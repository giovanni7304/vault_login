//
//  LoginViewController.swift
//  Vault
//
//  Created by Terry Johnson on 11/14/16.
//  Copyright © 2016 Terry Johnson. All rights reserved.
//
import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
    
    //MARK: properties
    //var managedObjectContext: NSManagedObjectContext? = nil
    let MyKeychainWrapper = KeychainWrapper()
    let createloginButtonTag = 0
    let loginButtonTag = 1
    var context = LAContext()
    
    
    //MARK: Outlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createInfoLabel: UILabel!
    @IBOutlet weak var touchIDButton: UIButton!
    
    //MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // 1.
        let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
        
        // 2.
        if hasLogin {
            loginButton.setTitle("Login", for: UIControlState.normal)
            loginButton.tag = loginButtonTag
            createInfoLabel.isHidden = true
        } else {
            loginButton.setTitle("Create", for: UIControlState.normal)
            loginButton.tag = createloginButtonTag
            createInfoLabel.isHidden = false
        }
        
        // 3.
        if let storedUsername = UserDefaults.standard.value(forKey: "username") as? String {
            usernameTextField.text = storedUsername as String
        }
        touchIDButton.isHidden = true
        
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            touchIDButton.isHidden = false
        }
    }
    
    // MARK: - TouchID Action for checking username/password
    @IBAction func touchIDLoginAction(_ sender: Any) {
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error:nil) {
            
            // 2.
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "Logging in with Touch ID",
                                   reply: { (success : Bool, error : Error? ) -> Void in
                                    
                                    // 3.
                                    DispatchQueue.main.async {()
                                        if (success) {
                                            //self.performSegue(withIdentifier: "dismissLogin", sender: self)
                                            self.navigateToAuthenticatedViewController()
                                        }
                                        
                                        if error != nil {
                                            
                                            var message : NSString
                                            var showAlert : Bool
                                            
                                            // 4.
                                            switch(error!._code) {
                                            case LAError.authenticationFailed.rawValue:
                                                message = "There was a problem verifying your identity."
                                                showAlert = true
                                                break;
                                            case LAError.userCancel.rawValue:
                                                message = "You pressed cancel."
                                                showAlert = true
                                                break;
                                            case LAError.userFallback.rawValue:
                                                message = "You pressed password."
                                                showAlert = true
                                                break;
                                            default:
                                                showAlert = true
                                                message = "Touch ID may not be configured"
                                                break;
                                            }
                                            
                                            let alertView = UIAlertController(title: "Error",
                                                                              message: message as String, preferredStyle:.alert)
                                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                            alertView.addAction(okAction)
                                            if showAlert {
                                                self.present(alertView, animated: true, completion: nil)
                                            }
                                            
                                        }
                                    }
                                    
            })
        } else {
            // 5.
            let alertView = UIAlertController(title: "Error",
                                              message: "Touch ID not available" as String, preferredStyle:.alert)
            let okAction = UIAlertAction(title: "OK!", style: .default, handler: nil)
            alertView.addAction(okAction)
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    
    //MARK: Login Usename Password Verification
    @IBAction func loginPressed(_ sender: Any) {
        if( usernameTextField.text == "" || passwordTextField.text == "" )
        {    let alertView = UIAlertController(title: "Login Problem.", message: "Wrong username or password." as String, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Try Again", style: .default, handler: nil)
            alertView.addAction(okAction)
            self.present(alertView, animated: true, completion: nil)
            return
        }
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if (sender as AnyObject).tag == createloginButtonTag {
            print("at createLoginButtonTag")
            let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
            if hasLoginKey == false {
                print("at has login key")
                UserDefaults.standard.setValue(self.usernameTextField.text, forKey: "username")
            }
            
            // 5.
            print("at 5")
            MyKeychainWrapper.mySetObject(passwordTextField.text, forKey:kSecValueData)
            MyKeychainWrapper.writeToKeychain()
            UserDefaults.standard.set(true, forKey: "hasLoginKey")
            UserDefaults.standard.synchronize()
            loginButton.tag = loginButtonTag
            
            print("Navigate to ViewController")
            //performSegue(withIdentifier: "dismissLogin", sender: self)
            self.navigateToAuthenticatedViewController()
        } else if (sender as AnyObject).tag == loginButtonTag {
            // 6.
            if checkLogin(username: usernameTextField.text!, password: passwordTextField.text!) {
                //performSegue(withIdentifier: "dismissLogin", sender: self)
                self.navigateToAuthenticatedViewController()
            } else {
                // 7.
                let alertView = UIAlertController(title: "Login Problem",
                                                  message: "Wrong username or password." as String, preferredStyle:.alert)
                let okAction = UIAlertAction(title: "Try Again!", style: .default, handler: nil)
                alertView.addAction(okAction)
                self.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func loginAction(_ sender: AnyObject) {
        if( usernameTextField.text == "" || passwordTextField.text == "" )
        {    let alertView = UIAlertController(title: "Login Problem.", message: "Wrong username or password." as String, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Try Again", style: .default, handler: nil)
            alertView.addAction(okAction)
            self.present(alertView, animated: true, completion: nil)
            return
        }
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if sender.tag == createloginButtonTag {
            
            let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
            if hasLoginKey == false {
                UserDefaults.standard.setValue(self.usernameTextField.text, forKey: "username")
            }
            
            // 5.
            MyKeychainWrapper.mySetObject(passwordTextField.text, forKey:kSecValueData)
            MyKeychainWrapper.writeToKeychain()
            UserDefaults.standard.set(true, forKey: "hasLoginKey")
            UserDefaults.standard.synchronize()
            loginButton.tag = loginButtonTag
            
            //performSegue(withIdentifier: "dismissLogin", sender: self)
            self.navigateToAuthenticatedViewController()
        } else if sender.tag == loginButtonTag {
            // 6.
            if checkLogin(username: usernameTextField.text!, password: passwordTextField.text!) {
                //performSegue(withIdentifier: "dismissLogin", sender: self)
                self.navigateToAuthenticatedViewController()
            } else {
                // 7.
                let alertView = UIAlertController(title: "Login Problem",
                                                  message: "Wrong username or password." as String, preferredStyle:.alert)
                let okAction = UIAlertAction(title: "Try Again!", style: .default, handler: nil)
                alertView.addAction(okAction)
                self.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    func checkLogin(username: String, password: String ) -> Bool {
        if password == MyKeychainWrapper.myObject(forKey: "v_Data") as? String &&
            username == UserDefaults.standard.value(forKey: "username") as? String {
            return true
        } else {
            return false
        }
    }
    
    /**
     This method will push the authenticated view controller onto the UINavigationController stack
     */
    func navigateToAuthenticatedViewController(){
        
        if let loggedInVC = storyboard?.instantiateViewController(withIdentifier: "LoggedInViewController") {
            print("At Navigate to the LoggedInViewController")
            passwordTextField.text = ""
            DispatchQueue.main.async { () -> Void in
                
                self.navigationController?.pushViewController(loggedInVC, animated: true)
                
            }
        }
    }
}
