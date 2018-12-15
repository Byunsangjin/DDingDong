//
//  LoginViewController.swift
//  DDingDong
//
//  Created by Byunsangjin on 15/12/2018.
//  Copyright © 2018 Byunsangjin. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import SnapKit

class LoginViewController: UIViewController {
    
    // MARK:- Outlets
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    
    @IBOutlet var googleSignInButton: GIDSignInButton! // 구글 로그인 버튼
    
    
    
    
    // MARK:- Constants
    let remoteConfig = RemoteConfig.remoteConfig()
    let dataRef = Database.database().reference()
    
    
    
    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 구글 아이디 로그인 델리 게이트
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // statusBar 설정
        var statusBar = UIView()
        self.view.addSubview(statusBar)
        
        statusBar.snp.makeConstraints { (make) in
            make.right.left.equalTo(self.view)
            make.height.equalTo(UIApplication.shared.statusBarFrame.height)
        }
        
        let color = remoteConfig["splash_background"].stringValue
        
        // 배경 색상 설정
        statusBar.backgroundColor = UIColor(hexString: color!)
        self.loginButton.backgroundColor = UIColor(hexString: color!)
        self.signUpButton.backgroundColor = UIColor(hexString: color!)
        
        // 사용자가 바뀌었을 때 리스너
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainViewTabBarController") as! UITabBarController

                self.present(mainVC, animated: true)

                let uid =  Auth.auth().currentUser?.uid

                // 토큰을 받아온다
                InstanceID.instanceID().instanceID(handler: { (result, error) in
                    if error == nil {
                        let token = result?.token
                        self.dataRef.child("users").child(uid!).updateChildValues(["pushToken": token!])
                    } else {
                        print("Token error : \(error?.localizedDescription)")
                    }
                })
            }
        }
    }
    
    
    
    // MARK:- Actions
    // 로그인 버튼 클릭시
    @IBAction func loginBtnPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
            if error != nil { // 에러가 있을 때
                let alert = UIAlertController(title: "로그인 실패", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                
                self.present(alert, animated: false)
            }
        }
    }
    
    
    
    // 회원가입 버튼 클릭시
    @IBAction func signUpBtnPressed(_ sender: Any) {
        let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        
        self.present(signUpVC, animated: true)
    }
    
}



// 구글 로그인 델리게이트
extension LoginViewController: GIDSignInUIDelegate {
    
}
