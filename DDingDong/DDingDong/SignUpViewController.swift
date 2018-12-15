//
//  SignUpViewController.swift
//  DDingDong
//
//  Created by Byunsangjin on 15/12/2018.
//  Copyright © 2018 Byunsangjin. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    // MARK:- Outlets
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var pwTextField: UITextField!
    @IBOutlet var rePwTextField: UITextField!
    
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var cancelButton: UIButton!

    @IBOutlet var topConstraint: NSLayoutConstraint!
    
    
    
    // MARK:- Constants
    let remoteConfig = RemoteConfig.remoteConfig()
    
    
    
    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topConstraint.constant = self.view.frame.height / 20
        
        // 버튼 색상 설정
        let color = self.remoteConfig["splash_background"].stringValue
        self.signUpButton.backgroundColor = UIColor(hexString: color!)
        self.cancelButton.backgroundColor = UIColor(hexString: color!)
    }
    
    
    
    func createUser(email: String, password: String) {
        Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.pwTextField.text!) { (result, error) in
            if error == nil { // 에러가 없다면
                self.alert("회원가입에 성공 하셨습니다.")
                
                self.dismiss(animated: true, completion: nil)
            } else {
                if error?._code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    self.alert("이미 동일한 이메일이 있습니다.")
                    
                }
                
            }
        }
    }
    
    
    
    // MARK:- Actions
    @IBAction func signUpBtnPressed(_ sender: Any) {
        if self.emailTextField.text!.isEmpty || self.nameTextField.text!.isEmpty || self.pwTextField.text!.isEmpty { // 텍스트 필드에 입력하지 않은 값이 있으면
            self.alert("공백을 입력하세요.")
        } else if self.pwTextField.text != self.rePwTextField.text { // 패스워드가 다르면
            self.alert("패스워드를 확인해주세요.")
        } else {
            createUser(email: self.emailTextField.text!, password: self.pwTextField.text!)
        }
    }
    
    
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
