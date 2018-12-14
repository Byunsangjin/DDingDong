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

class LoginViewController: UIViewController {
    
    // MARK:- Outlets
    @IBOutlet var signInButton: GIDSignInButton!
    
    
    
    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self // 구글 아이디 로그인 델리 게이트
        
    }
    
    
    
    func signIn() {
        let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        
        self.present(mainVC, animated: true)
    }
}



// 구글 로그인 델리게이트
extension LoginViewController: GIDSignInUIDelegate {
    
}
