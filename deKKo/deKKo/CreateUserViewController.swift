//
//  CreateUserViewController.swift
//  deKKo
//
//  Created by YangSzu Kai on 2017/4/1.
//  Copyright © 2017年 ArcCotagent. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class CreateUserViewController: UIViewController {

    
    var userInfo:Dictionary<String, Any> = [:]
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var userName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onTapCreate(_ sender: Any) {
        if (userName.text == "" || password.text == ""){
            let alertC = UIAlertController(title: "Error", message: "Please Enter a UserName or Password", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alertC.addAction(okAction)
            self.present(alertC, animated: true, completion: nil)
             self.userName.becomeFirstResponder()
        }
        
        let newUser = PFUser()
        
        newUser.username = userName.text
        newUser.password = password.text
        
        newUser.signUpInBackground { (success: Bool, error: Error?) in
            MBProgressHUD.showAdded(to: self.view, animated: true)
            if success {
                print("New User Created")
                MBProgressHUD.hide(for: self.view, animated: true)
                self.userInfo["userName"] = self.userName.text
                self.defaults.set(self.userInfo, forKey: "userInfo")
                let mainView = UIStoryboard(name: "mainView", bundle: nil)
                let vc = mainView.instantiateViewController(withIdentifier: "mainViewNavigation")
                self.present(vc, animated: true, completion: {})
            }else{
                MBProgressHUD.hide(for: self.view, animated: true)
                let code = (error as! NSError).code
                print(error?.localizedDescription ?? 0)
                if code == 202{
                    let alertU = UIAlertController(title: "Error", message: "User Already exist", preferredStyle: .alert)
                    let okA = UIAlertAction(title: "OK", style: .default, handler: nil)
                    
                    alertU.addAction(okA)
                    self.userName.text = ""
                    self.password.text = ""
                    self.userName.becomeFirstResponder()
                    self.present(alertU, animated: true, completion: nil)
                    
                }
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
