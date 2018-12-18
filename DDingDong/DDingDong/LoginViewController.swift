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

class LoginViewController: UIViewController, GIDSignInUIDelegate, UIGestureRecognizerDelegate {
    
    // MARK:- Outlets
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    
    @IBOutlet var googleSignBtn: GIDSignInButton!
    
    
    
    // MARK:- Constants
    let remoteConfig = RemoteConfig.remoteConfig()
    let dataRef = Database.database().reference()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.accessibilityScroll(UIAccessibilityScrollDirection.down)
        
        // 제스쳐 추가
        self.addGesture()
        
        // 화면 세팅
        self.initSet()
        
        // 사용자가 바뀌었을 때 리스너
        self.changeUser()
        
    }
    
    
    
    // 제스쳐 추가
    func addGesture() {
        // 탭 클릭시 키보드 사라지게 하는 제스처 추가
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        // 구글 로그인 버튼 클릭 시 로그인 제스처 추가
        let googleBtnTap = UITapGestureRecognizer(target: self, action: #selector(googleSign))
        self.googleSignBtn.addGestureRecognizer(googleBtnTap)
    }
    
    
    
    // 화면 세팅
    func initSet() {
        GIDSignIn.sharedInstance().uiDelegate = self // 델리게이트 설정
        self.googleSignBtn.style = .wide // 구글 버튼 속성
        
        let color = appDelegate.themeColor
        
        // statusBar 색상 설정
        appDelegate.statusBarSet(view: self.view)
        
        // 테마 색상 설정
        self.loginButton.backgroundColor = UIColor(hexString: color!)
        self.signUpButton.backgroundColor = UIColor(hexString: color!)
    }
    
    
    
    func changeUser() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainViewTabBarController") as! UITabBarController
                
                self.present(mainVC, animated: true)
                
                let uid =  Auth.auth().currentUser?.uid
                
                // 토큰을 받아온다
                InstanceID.instanceID().instanceID(handler: { (result, error) in
                    if error == nil {
                        let token = result?.token
                        // 토큰을 DB에 업데이트
                        self.dataRef.child("users").child(uid!).updateChildValues(["pushToken": token!])
                    } else {
                        print("Token error : \(error?.localizedDescription)")
                    }
                })
            }
        }
    }
    
    
    
    // 터치 했을 떄 키보드가 사라지게 하는 메소드
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    
    
    // 구글 로그인 액션
    @objc func googleSign() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    
    // MARK:- Actions
    // 로그인 버튼 클릭시
    @IBAction func loginBtnPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
            if error != nil { // 에러가 있을 때
                self.alert("로그인 실패", (error?.localizedDescription)!)
            }
        }
    }
    
    
    
    // 회원가입 버튼 클릭시
    @IBAction func signUpBtnPressed(_ sender: Any) {
        let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        
        self.present(signUpVC, animated: true)
    }
}
