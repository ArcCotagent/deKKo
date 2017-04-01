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
import FacebookCore
class LoginViewController: UIViewController,GIDSignInUIDelegate,GIDSignInDelegate
{

    var userInfo:Dictionary<String, Any> = [:]
    let defaults = UserDefaults.standard
    override func viewDidLoad()
    {
        super.viewDidLoad()
        /*GOOGLE Login settings*/
        var configureError: NSError?
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = "963253939831-hod6842oqnllcnvhrmn7s56q7nn2baan.apps.googleusercontent.com"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let userInfo = defaults.object(forKey: "userInfo") as? Dictionary<String, Any>
        {
            
            let mainView = UIStoryboard(name: "mainView", bundle: nil)
            let vc = mainView.instantiateViewController(withIdentifier: "mainViewNavigation")
            present(vc, animated: true, completion: {})
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
