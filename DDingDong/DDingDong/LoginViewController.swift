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
    }
    
    
    
    // MARK:- Actions
    // 로그인 버튼 클릭시
    @IBAction func loginBtnPressed(_ sender: Any) {
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
