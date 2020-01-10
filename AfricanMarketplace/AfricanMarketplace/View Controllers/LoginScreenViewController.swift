//
//  LoginScreenViewController.swift
//  AfricanMarketplace
//
//  Created by Patrick Millet on 1/6/20.
//  Copyright © 2020 Patrick Millet. All rights reserved.
//

import UIKit

enum LoginType {
    case signUp
    case signIn
}
class LoginScreenViewController: UIViewController {
    
    //MARK: - Outlets    
    
    @IBOutlet weak var signInUpSegmentedControl: UISegmentedControl!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signInUpButton: UIButton!
    
    //MARK: - Properties
    
    var apiController: ItemController?
    var loginType = LoginType.signUp
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInUpButton.setTitle("Sign Up", for: .normal)
        self.signInUpSegmentedControl.selectedSegmentIndex = 0
    }
    
    //MARK: - Actions
    
    @IBAction func signInUpButtonTapped(_ sender: Any) {
        guard let apiController = apiController else { return }
            
            if let username = usernameTextField.text, !username.isEmpty,
                let password = passwordTextField.text, !password.isEmpty,
                let email = emailTextField.text {
                let user = User(username: username, password: password, email: email)
            
            if loginType == .signUp {
                apiController.signUp(with: user) { (error) in
                    if let error = error {
                        print("Error occured during sign up: \(error)")
                    } else {
                        let alertController = UIAlertController(title: "Sign Up Successful", message: "Now please log in", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true) {
                            self.loginType = .signIn
                            self.signInUpSegmentedControl.selectedSegmentIndex = 1
                            self.signInUpButton.setTitle("Sign In", for: .normal)
                        }
                    }
                }
            } else {
                emailTextField.isHidden = true
                apiController.signIn(with: user) { (error) in
                    if let error = error {
                        print("Error occured during sign in: \(error)")
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                
            }
        }
    }
    
    @IBAction func signInUpChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            loginType = .signUp
            signInUpButton.setTitle("Sign Up", for: .normal)
            emailTextField.isHidden = false
        } else {
            emailTextField.isHidden = true
            loginType = .signIn
            signInUpButton.setTitle("Sign In", for: .normal)
            }
        }
}

