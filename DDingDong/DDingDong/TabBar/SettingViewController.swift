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
    
    
    
    // MARK:- Variables
    var user: UserModel?
    var myUid: String! = Auth.auth().currentUser?.uid
    
    
    
    // MARK:- Constants
    let dataRef = Database.database().reference()
    
    
    
    
    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getUserInfo()
    }
    
    
    
    // 유저의 정보를 받아오는 메소드
    func getUserInfo() {
        // 상태 메세지나 이미지가 변경될 때마다 변경해 줘야 하기 때문에 observe메소드로 받음
        self.dataRef.child("users").child(self.myUid!).observe(.value) { (dataSnapshot) in
            self.user = UserModel()
            // user에 대한 데이터 담기
            self.user?.setValuesForKeys(dataSnapshot.value as! [String: AnyObject])
        }
    }
    
    
    
    
    // MARK:- Actions
    // 프로필 변경 버튼 클릭시
    @IBAction func changeBtnPressed(_ sender: Any) {
        let alert = UIAlertController(title: "프로필 변경", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "이미지 변경", style: .default) { (_) in
            print("이미지 변경")
        })
        alert.addAction(UIAlertAction(title: "상태메세지 변경", style: .default) { (_) in
            let conditionAlert = UIAlertController(title: "상태 메세지", message: nil, preferredStyle: .alert)
            conditionAlert.addTextField(configurationHandler: { (tf) in
                tf.placeholder = self.user?.condition ?? "상태 메세지"
            })
            
            conditionAlert.addAction(UIAlertAction(title: "확인", style: .default) { (_) in
                self.dataRef.child("users").child(self.myUid!).updateChildValues(["condition": conditionAlert.textFields?[0].text!])
            })
            
            self.present(conditionAlert, animated: true)
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        
        
        self.present(alert, animated: true)
    }
    

}
