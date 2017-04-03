//
//  LoginViewController.swift
//  deKKo
//
//  Created by YangSzu Kai on 2017/3/21.
//  Copyright © 2017年 ArcCotagent. All rights reserved.
//

import UIKit
import GoogleSignIn
import Google
import FBSDKLoginKit

import Parse
import MBProgressHUD
import FacebookCore

class LoginViewController: UIViewController,GIDSignInUIDelegate,GIDSignInDelegate,UITextFieldDelegate
{
    @IBOutlet weak var newUser: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet var gButton: UIButton!
    
    @IBOutlet var fbBtn: FBSDKLoginButton!
    var userInfo:Dictionary<String, Any> = [:]
    let defaults = UserDefaults.standard
  
    override func viewDidLoad(){
        super.viewDidLoad()
        //Add our icon to the backgorund and create a dark blur effect
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "eye")
        blurView.frame = backgroundImage.bounds
        backgroundImage.addSubview(blurView)
        self.view.insertSubview(backgroundImage, at: 0)

        /*GOOGLE Login settings*/
        var _: NSError?
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = "963253939831-hod6842oqnllcnvhrmn7s56q7nn2baan.apps.googleusercontent.com"
        
        //Implment return function
        self.passWord.delegate = self
        
        gButton.backgroundColor = .clear
        gButton.layer.cornerRadius = 10.0
        gButton.layer.shadowOpacity = 0.7
        gButton.layer.shadowRadius = 5.0
        gButton.layer.shadowOffset = CGSize(width: 4.0, height: 4.0)
        
        fbBtn.layer.cornerRadius = 10.0
        fbBtn.layer.shadowOpacity = 0.7
        fbBtn.layer.shadowRadius = 5.0
        fbBtn.layer.shadowOffset = CGSize(width: 4.0, height: 4.0)
        
        //let greenColor = UIColor(hue: 120/360, saturation: 61/100, brightness: 70/100, alpha: 1.0)
        loginBtn.backgroundColor = .clear
        loginBtn.layer.cornerRadius = 15.0
        //loginBtn.layer.borderWidth = 0.3
        //loginBtn.layer.borderColor = UIColor.black.cgColor
        
        newUser.backgroundColor = .clear
        
    }
    
    override func viewDidAppear(_ animated: Bool)
  {
        if let userInfo = defaults.object(forKey: "userInfo") as? Dictionary<String, Any>
        {
            
            let mainView = UIStoryboard(name: "mainView", bundle: nil)
            let vc = mainView.instantiateViewController(withIdentifier: "mainViewNavigation")
            present(vc, animated: true, completion: {})
        }
    }
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (userName.text == "" || passWord.text == ""){
            let alertA = UIAlertController(title: "Error", message: "Username and Password cannot be empty", preferredStyle: .alert)
            let okC = UIAlertAction(title: "OK", style: .default, handler: nil)
            userName.becomeFirstResponder()
            alertA.addAction(okC)
            self.userName.text = ""
            self.passWord.text = ""
            self.userName.becomeFirstResponder()
            self.present(alertA, animated: true, completion: nil)
            
        }
        
        performLogin()
        return true
    }
    
    func performLogin() {
        PFUser.logInWithUsername(inBackground: userName.text!, password: passWord.text!) { (user: PFUser?, error: Error?) in
            MBProgressHUD.showAdded(to: self.view, animated: true)
            if user != nil{
                print("Login")
                MBProgressHUD.hide(for: self.view, animated: true)
                self.userInfo["userName"] = user?.username!
                self.defaults.set(self.userInfo, forKey: "userInfo")
                let mainView = UIStoryboard(name: "mainView", bundle: nil)
                let vc = mainView.instantiateViewController(withIdentifier: "mainViewNavigation")
                self.present(vc, animated: true, completion: {})
            }else{
                MBProgressHUD.hide(for: self.view, animated: true)
                print("Error failed")
                print(error?.localizedDescription ?? 0)
                let alertc = UIAlertController(title: "Error", message: "Login error please login again", preferredStyle: .alert)
                let okC = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertc.addAction(okC)
                self.userName.text = ""
                self.passWord.text = ""
                self.userName.becomeFirstResponder()
                self.present(alertc, animated: true, completion: nil)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func logInWithGoogle(_ sender: Any)
    {
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
    {
        if error != nil
        {
            print(error)
            return
        }
        else
        {
            print("userName: \(user.profile.name)")
            print("email: \(user.profile.email)")
            
            let mainView = UIStoryboard(name: "mainView", bundle: nil)
            let vc = mainView.instantiateViewController(withIdentifier: "mainViewNavigation")
           
            userInfo["userName"] = user.profile.name
            defaults.set(userInfo, forKey: "userInfo")
            
            present(vc, animated: true, completion: {})
        }
        
    }



    @IBAction func loginWithFB(_ sender: Any)
    {
        let loginManager = FBSDKLoginManager()
        
        
        loginManager.logIn(withReadPermissions: nil, from: self)
        {
            (loginResult: FBSDKLoginManagerLoginResult?, error: Error?) in
            
            if(error != nil)
            {
                print(error?.localizedDescription)
            }
            else
            {
                print("FB Login success")
                let mainView = UIStoryboard(name: "mainView", bundle: nil)
                let vc = mainView.instantiateViewController(withIdentifier: "mainViewNavigation")
                
                let connection = GraphRequestConnection()
                connection.add(GraphRequest(graphPath: "/me")) { httpResponse, result in
                    switch result {
                    case .success(let response):
                        print("Graph Request Succeeded: \(response)")
                        print(response.dictionaryValue!["name"]!)
                        self.userInfo["userName"] = response.dictionaryValue!["name"]!
                        self.defaults.set(self.userInfo, forKey: "userInfo")
                        
                        
                    case .failed(let error):
                        print("Graph Request Failed: \(error)")
                    }
                }
                connection.start()
                
                
                
                self.present(vc, animated: true, completion: {})

            }
        }
        

    }
    
    @IBAction func onTapCreateNewUser(_ sender: Any) {
    
    }
    @IBAction func onTapEndEditing(_ sender: Any) {
        view.endEditing(true)
        if (userName.text != "" || passWord.text != ""){
            PFUser.logInWithUsername(inBackground: userName.text!, password: passWord.text!) { (user: PFUser?, error: Error?) in
                MBProgressHUD.showAdded(to: self.view, animated: true)
                if user != nil{
                    print("Login")
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.userInfo["userName"] = user?.username!
                    self.defaults.set(self.userInfo, forKey: "userInfo")
                    let mainView = UIStoryboard(name: "mainView", bundle: nil)
                    let vc = mainView.instantiateViewController(withIdentifier: "mainViewNavigation")
                    self.present(vc, animated: true, completion: {})
                }else{
                    MBProgressHUD.hide(for: self.view, animated: true)
                    print("Error failed")
                    print(error?.localizedDescription ?? 0)
                    let alertc = UIAlertController(title: "Error", message: "Login error please login again", preferredStyle: .alert)
                    let okC = UIAlertAction(title: "OK", style: .default, handler: nil)
                    self.userName.text = ""
                    self.passWord.text = ""
                    self.userName.becomeFirstResponder()
                    alertc.addAction(okC)
                    self.present(alertc, animated: true, completion: nil)
                    
                }
            }

        }
           }
    
    func googleB(sender: GIDSignInButton!){
        GIDSignIn.sharedInstance().signIn()
    }
    
    //Custom TextField
    override func viewDidLayoutSubviews() {
        let lineColor = UIColor(red: 0.12, green: 0.23, blue: 0.35, alpha: 1.0)
        self.userName.setBottomLine(borderColor: lineColor)
        self.passWord.setBottomLine(borderColor: lineColor)
    }
    
    @IBAction func onTapLoginDekko(_ sender: Any) {
        PFUser.logInWithUsername(inBackground: userName.text!, password: passWord.text!) { (user: PFUser?, error: Error?) in
            MBProgressHUD.showAdded(to: self.view, animated: true)
            if user != nil {
                MBProgressHUD.hide(for: self.view, animated: true)
                let mainView = UIStoryboard(name: "mainView", bundle: nil)
                let vc = mainView.instantiateViewController(withIdentifier: "mainViewNavigation")
                self.present(vc, animated: true, completion: {})
            }else{
                MBProgressHUD.hide(for: self.view, animated: true)
                print("Error failed")
                print(error?.localizedDescription ?? 0)
                let alertc = UIAlertController(title: "Error", message: "Login error please login again", preferredStyle: .alert)
                let okC = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertc.addAction(okC)
                self.present(alertc, animated: true, completion: nil)
                self.userName.text = ""
                self.passWord.text = ""
                self.userName.becomeFirstResponder()
            }
        }
    }
    
}

extension UITextField {
    
    func setBottomLine(borderColor: UIColor) {
        //Clear the textbox backgound and border style. Make it to transparent
        self.borderStyle = UITextBorderStyle.none
        self.backgroundColor = UIColor.clear
        /*After we set transparent background and disable borders for the textfield, UIView is created.
         Then we set its frame to the line of height equal to 1.0 and place it at the bottom of textfield by the following y calculation*/
        let borderLine = UIView()
        let height = 1.0
        borderLine.frame = CGRect(x: 0, y: Double(self.frame.height) - height, width: Double(self.frame.width), height: height)
        
        borderLine.backgroundColor = borderColor
        self.addSubview(borderLine)
    }
    
}

