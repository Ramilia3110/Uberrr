//
//  ViewController.swift
//  Uberrr
//
//  Created by Ramilia Imankulova on 12/5/18.
//  Copyright © 2018 Ramilia Imankulova. All rights reserved.
//

import UIKit
import FirebaseAuth


class ViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var riderLbl: UILabel!
    @IBOutlet weak var driverLbl: UILabel!
    
    @IBOutlet weak var riderToDriverSwitch: UISwitch!
    
    @IBOutlet weak var topBtn: UIButton!
    
    @IBOutlet weak var bottomBtn: UIButton!
    var signUpMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func topTapped(_ sender: Any) {
        if emailTextField.text == "" || passwordTextField.text == "" {
            displayAlert(title: "Missing Information", message: "You must  provide both email and password")
            
        } else {
            
            if let email = emailTextField.text {
                if let password = passwordTextField.text {
                    if signUpMode {
                        //SIGN UP
                        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            } else {
                                if self.riderToDriverSwitch.isOn {
                                    //Driver
                                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                    req?.displayName = "Driver"
                                    req?.commitChanges(completion: nil)
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                } else {
                                    //Rider
                                    let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                    req?.displayName = "Rider"
                                    req?.commitChanges(completion: nil)
                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                }
                            }
                        })
                    } else {
                     
                        //LOG IN
                        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    
                            if error != nil {
                                self.displayAlert(title: "Error", message: error!.localizedDescription)
                            } else {
                              
                                if user?.user.displayName == "Driver" {
                                    // Driver
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)

                                } else {
                                   //Rider
                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                }

                            }
                        }
                    }
                }
            }
            
        }
        
    }
    
    func displayAlert(title:String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func bottomTapped(_ sender: Any) {
        if signUpMode {
            topBtn.setTitle("Log In", for: .normal)
            bottomBtn.setTitle("Switch to Sign Up", for: .normal)
            riderLbl.isHidden = true
            driverLbl.isHidden = true
            riderToDriverSwitch.isHidden = true
            signUpMode = false
        } else {
            topBtn.setTitle("Sign Up", for: .normal)
            bottomBtn.setTitle("Switch to Log In", for: .normal)
            riderLbl.isHidden = false
            driverLbl.isHidden = false
            riderToDriverSwitch.isHidden = false
            signUpMode = true
        }
        
    }
}
