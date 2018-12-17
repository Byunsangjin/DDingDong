//
//  PeopleTableViewController.swift
//  DDingDong
//
//  Created by Byunsangjin on 15/12/2018.
//  Copyright © 2018 Byunsangjin. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class PeopleTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK:- Outlets
    @IBOutlet var tableView: UITableView!
    
    
    
    // MARK:- Variables
    var user: [UserModel] = [] // 유저 정보를 담을 객체
    
    
    
    // MARK:- Constants
    let dataRef = Database.database().reference()
    
    
    
    
    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 구분선 없애기
        self.tableView.separatorStyle = .none
        
        self.getUserInfo()
    }
    
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.user.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell", for: indexPath) as! PeopleCell
        
        // 이미지 설정
        let url = URL(string: user[indexPath.row].profileImageUrl!) // 이미지 URL
        
        cell.profileImageView.kf.setImage(with: url) // 이미지 설정
        
        // 이미지 동그랗게 만들기
        cell.profileImageView.layer.cornerRadius = 50 / 2
        cell.profileImageView.clipsToBounds = true
        
        cell.nameLabel.text = user[indexPath.row].userName // 이름 설정
        cell.conditionLabel.text = user[indexPath.row].condition // 상태 메세지
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    
    func getUserInfo() {
        // DB에서 정보 받아오기
        self.dataRef.child("users").observe(.value) { (dataSnapshot) in
            // 배열 초기화 (이유 : 새로 계정을 생성할 때 DB에서 정보를 다시 받아오게 되는데 그 때 중복되기 때문)
            self.user.removeAll()
            
            let myUid = Auth.auth().currentUser?.uid
            
            // 데이터 순회하며 유저 정보 배열 검색
            for item in dataSnapshot.children {
                let userModel = UserModel()
                let fchild = item as! DataSnapshot
                
                userModel.setValuesForKeys(fchild.value as! [String : Any])
                
                // 자신을 제외한 나머지 데이터를 배열에 저장한다.
                if myUid != userModel.uid {
                    self.user.append(userModel)
                }
            }
            
            // 테이블 뷰 초기화
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
}
