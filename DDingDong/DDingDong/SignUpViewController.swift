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

    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var topConstraint: NSLayoutConstraint!
    
    
    
    // MARK:- Constants
    let remoteConfig = RemoteConfig.remoteConfig() // 원격
    var imageSelected: Bool? = false
    let stroage = Storage.storage() // 저장소 참조
    let dataRef = Database.database().reference() // 데이터 베이스 참조
    
    
    
    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 유동적 constraints
        self.topConstraint.constant = self.view.frame.height / 20
        
        // 버튼 색상 설정
        let color = self.remoteConfig["splash_background"].stringValue
        self.signUpButton.backgroundColor = UIColor(hexString: color!)
        self.cancelButton.backgroundColor = UIColor(hexString: color!)
        
        // 이미지 탭
        self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker)))
        
    }
    
    
    
    func createUser(email: String, password: String) {
        Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.pwTextField.text!) { (result, error) in
            if error == nil { // 에러가 없다면
                let uid = result?.user.uid
                
                // 선택 유무에 따른 이미지 가져오기
                var image = UIImage()
                if self.imageSelected! { // 이미지를 선택 했다면
                    image = self.imageView.image!
                } else { // 이미지를 선택하지 않았다면
                    image = #imageLiteral(resourceName: "profile")
                }
                
                // 이미지 데이터로 변환
                let data = image.jpegData(compressionQuality: 0.1) as! Data
                
                // 사용자 이름을 넣어준다.
                result!.user.createProfileChangeRequest().displayName = self.nameTextField.text!
                result!.user.createProfileChangeRequest().commitChanges(completion: nil)
                
                // 저장소에 저장
                let spaceRef = self.stroage.reference().child("users").child(uid!)
                
                spaceRef.putData(data, metadata: nil) { (metadata, error) in
                    // 에러가 발생 했을 때
                    guard metadata != nil else {
                        print("metadata error")
                        return
                    }
                    
                    // 다운로드 url에 접근한다.
                    spaceRef.downloadURL { (url, error) in
                        // 에러가 발생 했을 때
                        guard let imageUrl = url else {
                            print("download error \(error?.localizedDescription)")
                            return
                        }
                        
                        if error != nil {
                            print("에러 = \(error?.localizedDescription)")
                        } else {
                            // 데이터 베이스에 접근해서 이름 값과 이미지 다운로드 url을 넣어준다
                            self.dataRef.child("users").child(uid!).setValue(["userName": self.nameTextField.text!, "profileImageUrl": imageUrl.absoluteString, "uid": uid])
                            
                            // 시작 할 때 로그아웃 상태로 만들어 놓는다.
                            try! Auth.auth().signOut()
                        }
                    }
                }
                
                self.alert("회원가입에 성공 하셨습니다.") {
                    self.dismiss(animated: true, completion: nil)
                }
            } else { // 에러가 있다면
                if error?._code == AuthErrorCode.emailAlreadyInUse.rawValue {
                    self.alert("이미 동일한 이메일이 있습니다.")
                } else if error?._code == AuthErrorCode.weakPassword.rawValue {
                    self.alert("비밀번호는 6자리 이상이어야 합니다.")
                } else {
                    self.alert("계정 생성 실패 : \(error?.localizedDescription)")
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



extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @objc func imagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        self.present(picker, animated: true)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.imageSelected = true // 이미지를 선택 했다면 true
        
        self.imageView.image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        self.dismiss(animated: true, completion: nil)
    }
}