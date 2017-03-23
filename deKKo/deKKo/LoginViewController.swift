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

class LoginViewController: UIViewController,GIDSignInUIDelegate,GIDSignInDelegate
{

    override func viewDidLoad() {
        super.viewDidLoad()
        var configureError: NSError?
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = "963253939831-hod6842oqnllcnvhrmn7s56q7nn2baan.apps.googleusercontent.com"

        // Do any additional setup after loading the view.
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
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
            print("userID: \(user.userID)")
            print("email: \(user.profile.email)")
            
            let mainView = UIStoryboard(name: "mainView", bundle: nil)
            let vc = mainView.instantiateViewController(withIdentifier: "mainViewNavigation")
            present(vc, animated: true, completion: {})
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
