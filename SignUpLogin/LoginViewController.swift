//
//  LoginViewController.swift
//  SignUpLogin
//
//  Created by Yisselda Rhoc on 5/14/19.
//  Copyright © 2019 YR. All rights reserved.
//
import SwiftKeychainWrapper
import UIKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    //Calls this function when the tap is recognized.
    func endEditing() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func loginAction(_ sender: Any){
        
        if email.text!.isEmpty || password.text!.isEmpty {
            let alertController = UIAlertController(
                title: "Missing login information",
                message: "Both email and password are required",
                preferredStyle: .alert)
            let defaultAction = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        login(email: email.text!, password: password.text!)
    }
    
    struct LoginToken:Codable {
        var exp: String
        var token: String
        var username: String
    }
    
    // auth/login to get the token and store it
    func login(email: String, password: String) {
        let session = URLSession.shared
        let url = URL(string: "http://localhost:3000/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let json = [
            "email": email,
            "password": password
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        
        let task = session.uploadTask(with: request, from: jsonData) { data, response, error in
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
            }
            
            if error != nil {
                print("Client Error")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server Error")
                return
            }
            
            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type!")
                return
            }
            
            do {
                let token = try JSONDecoder().decode(LoginToken.self, from: data!)
                print(token.token)
                let saveAccessToken: Bool = KeychainWrapper.standard.set(token.token, forKey: "accessToken")
                let saveUsername: Bool = KeychainWrapper.standard.set(token.username, forKey: "username")
                
                print("The access token save result: \(saveAccessToken)")
                print("The username save result: \(saveUsername)")
                
                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}
