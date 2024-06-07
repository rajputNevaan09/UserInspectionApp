//
//  ViewController.swift
//  UserInspection
//
//  Created by Bhagwan Rajput on 07/06/24.
//

import UIKit
import Foundation

class MainVC: UIViewController {
    
    //Outlests and connections
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSingUp: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initUI()
        
    }
    
    func initUI() {
        txtUserName.tintColor = .black
        txtPassword.tintColor = .black
    }
    
    //MARK: Action for login and signup
    @IBAction func btnLoginAction(_ sender: Any) {
        print("user clicked on login button")
        validatedFields(isLogin: true)
    }
    
    @IBAction func btnSingUpAction(_ sender: Any) {
        print("user clicked on Sing Up button")
        validatedFields(isLogin: false)
    }
    
    func validatedFields(isLogin:Bool) {
        let userName = txtUserName.text ?? ""
        let password = txtPassword.text ?? ""
        
        if userName.isEmpty && password.isEmpty {
            showAlert(message: "Please enter both username and password.")
        } else if userName.isEmpty {
            showAlert(message: "Please enter your username.")
        } else if password.isEmpty {
            showAlert(message: "Please enter your password.")
        } else {
            // Proceed with login
            guard let email = txtUserName.text,
                  let password = txtPassword.text else {
                return
            }
            let user = User(email: email, password: password)
            if isLogin == true{
                loginUser(user: user)
                print("We can proceed for Login")
            }else{
                registerUser(user: user)
                print("We can proceed for Sign up")
            }
        }
    }
    
    // To show alert
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "User Inspection", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showSuccessAlert(msg:String) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Inspection", message: msg, preferredStyle: .alert)
        
        // Add an action (button) to the alert
        let okAction = UIAlertAction(title: "START", style: .default) { _ in
            // Handle the action when the button is tapped
            self.gotoHomeVC()
            print("START button tapped")
        }
        
        // Add the action to the alert controller
        alertController.addAction(okAction)
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }
    
    
    //To call Login API
    func loginUser(user: User) {
        guard let url = URL(string: API.baseUrl+API.loginURL) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        do {
            request.httpBody = try encoder.encode(user)
        } catch {
            self.showAlert(message: msg_UnknownError)
            print("Failed to encode user: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.showAlert(message: msg_UnknownError)
                    print("Invalid response from server")
                }
                return
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.showAlert(message: msg_NetworkError)
                    print("Network error: \(error!.localizedDescription)")
                }
                return
            }
            
            DispatchQueue.main.async {
                switch httpResponse.statusCode {
                case 200:
                    self.showSuccessAlert(msg: msg_LoginSuccess)
                    print("Login successful!")
                    // Handle successful login and update UI accordingly
                case 400:
                    self.showAlert(message: msg_LoginMissingParams)
                    print("Missing email or password.")
                case 401:
                    self.showAlert(message: msg_LoginInvalidParams)
                    print("Invalid credentials.")
                default:
                    self.showAlert(message: msg_UnknownError)
                    print("Unknown error. Status code: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
    
    func gotoHomeVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailViewController = storyboard.instantiateViewController(withIdentifier: "mainInspectionVC") as? MainInspectionVC {
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    
    
    
    //To call Login API
    func registerUser(user: User) {
        guard let url = URL(string: API.baseUrl+API.registerURL) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        do {
            request.httpBody = try encoder.encode(user)
        } catch {
            self.showAlert(message: msg_UnknownError)
            print("Failed to encode user: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.showAlert(message: msg_UnknownError)
                    print("Invalid response from server")
                }
                return
            }
            
            guard error == nil else {
                DispatchQueue.main.async {
                    self.showAlert(message: msg_NetworkError)
                    print("Network error: \(error!.localizedDescription)")
                }
                return
            }
            
            DispatchQueue.main.async {
                switch httpResponse.statusCode {
                case 200:
                    self.showSuccessAlert(msg: msg_SignupSuccess)
                    print("Registration successful!")
                    // Handle successful registration and update UI accordingly
                case 400:
                    self.showAlert(message: msg_SignUpMissingParams)
                    print("Missing email or password.")
                case 401:
                    self.showAlert(message: msg_SignUpUserExistErr)
                    print("User already exists.")
                default:
                    self.showAlert(message: msg_UnknownError)
                    print("Unknown error. Status code: \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
}

