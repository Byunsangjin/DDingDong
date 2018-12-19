//
//  SettingViewController.swift
//  DDingDong
//
//  Created by Byunsangjin on 17/12/2018.
//  Copyright © 2018 Byunsangjin. All rights reserved.
//

import UIKit
import Firebase

class SettingViewController: UIViewController {
    // MARK:- Outlets
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var conditionLabel: UILabel!
    
    
    
    // MARK:- Variables
    var user: UserModel?
    var myUid: String! = Auth.auth().currentUser?.uid
    var imageView = UIImageView()
    
    
    // MARK:- Constants
    let dataRef = Database.database().reference()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // StatusBar 색상 설정
        self.appDelegate.statusBarSet(view: self.view)
        
        self.getUserInfo()
    }
    
    
    
    // 유저의 정보를 받아오는 메소드
    func getUserInfo() {
        // 상태 메세지나 이미지가 변경될 때마다 변경해 줘야 하기 때문에 observe메소드로 받음
        self.dataRef.child("users").child(self.myUid!).observeSingleEvent(of: .value) { (dataSnapshot) in
            self.user = UserModel()
            // user에 대한 데이터 담기
            self.user?.setValuesForKeys(dataSnapshot.value as! [String: AnyObject])
            
            // 이미지 뷰
            let url = URL(string: self.user!.profileImageUrl!)
            self.profileImageView.kf.setImage(with: url)
            
            // 상태 메세지
            self.conditionLabel.text = self.user?.condition
        }
    }
    
    
    
    // 상태메세지를 변경하는 알람 메소드
    func changeConditinon() {
        let conditionAlert = UIAlertController(title: "상태 메세지", message: nil, preferredStyle: .alert)
        conditionAlert.addTextField(configurationHandler: { (tf) in
            if self.user?.condition == nil || self.user?.condition == "" { // 상태 메세지가 없으면
                tf.placeholder = "상태 메세지"
            } else { // 상태 메세지가 있으면 기존 텍스트 띄워주기
                tf.text = self.user?.condition
            }
        })
        
        conditionAlert.addAction(UIAlertAction(title: "확인", style: .default) { (_) in
            self.conditionLabel.text = conditionAlert.textFields?[0].text!
            self.user?.condition = conditionAlert.textFields?[0].text!
            self.dataRef.child("users").child(self.myUid!).updateChildValues(["condition": conditionAlert.textFields?[0].text!])
        })
        
        self.present(conditionAlert, animated: true)
    }
    
    
    
    // 이미지 피커
    func imagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        self.present(picker, animated: true)
    }
    
    
    
    
    // MARK:- Actions
    // 프로필 변경 버튼 클릭시
    @IBAction func changeBtnPressed(_ sender: Any) {
        let alert = UIAlertController(title: "프로필 변경", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "이미지 변경", style: .default) { (_) in
            self.imagePicker()
        })
        alert.addAction(UIAlertAction(title: "상태메세지 변경", style: .default) { (_) in
            self.changeConditinon()
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        self.present(alert, animated: true)
    }
}



extension SettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.profileImageView.image = image
        
        self.saveImage(image: image)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // 이미지를 Storage에 저장, 이미지 url을 DB에 저장
    func saveImage(image: UIImage) {
        // 이미지 데이터로 변환
        let data = image.jpegData(compressionQuality: 0.1) as! Data
        
        // 저장소에 저장
        let spaceRef = Storage.storage().reference().child("users").child(self.myUid!)
        
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
                    self.dataRef.child("users").child(self.myUid!).updateChildValues(["profileImageUrl": imageUrl.absoluteString])
                }
            }
        }
    }
}
