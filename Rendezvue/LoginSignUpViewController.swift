//
//  LoginSignUpViewController.swift
//  Rendezvue
//
//  Created by Richard Dang on 2020-02-01.
//  Copyright © 2020 Rendezvue. All rights reserved.
//

import UIKit

class LoginSignUpViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    /**
     * Called when 'return' key pressed. return NO to ignore.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /**
       * Called when the user click on the view (outside the UITextField).
       */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        let username = usernameTextField.text
        let password = passwordTextField.text

        
        if identifier == "loginSegue" || identifier == "signupSegue" {
            if username!.isEmpty || password!.isEmpty {
                let alertController = UIAlertController(
                    title: "Input username/password",
                    message: "Username/password is required",
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))


                present(alertController, animated: true, completion: nil)
                return false
            }
        }
        print(username!)
        print(password!)
        return true
    }


    @IBAction func signupButton(_ sender: UIButton) {
//        var username = usernameTextField.text
//
//        if (username != nil) {
//            print(username)
//        }
        
        
    }
    @IBAction func loginButton(_ sender: UIButton) {
    }
}
