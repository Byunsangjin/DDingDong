//
//  SelectUserViewController.swift
//  DDingDong
//
//  Created by Byunsangjin on 19/12/2018.
//  Copyright © 2018 Byunsangjin. All rights reserved.
//

import UIKit
import Firebase
import BEMCheckBox

class SelectUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BEMCheckBoxDelegate {
    // MARK:- Outlets
    @IBOutlet var tableView: UITableView!
    
    
    
    // MARK:- Variables
    var users: [UserModel] = [] // 유저 정보를 담을 객체
    
    var selectedUser: [UserModel] = [] // 체크 한 유저
    var selectedUserDic = Dictionary<String, Bool>()
    
    
    // MARK:- Constants
    let dataRef = Database.database().reference()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    

    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // StatusBar 색상 설정
        self.appDelegate.statusBarSet(view: (self.navigationController?.view)!)
        
        // 구분선 없애기
        self.tableView.separatorStyle = .none
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SelectUserCell", for: indexPath) as! SelectUserCell
        
        // 이미지 설정
        let url = URL(string: users[indexPath.row].profileImageUrl!) // 이미지 URL
        
        cell.profileImage.kf.setImage(with: url) // 이미지 설정
        
        // 이미지 동그랗게 만들기
        cell.profileImage.layer.cornerRadius = 50 / 2
        cell.profileImage.clipsToBounds = true
        
        cell.nameLabel.text = users[indexPath.row].userName // 이름 설정
        
        cell.checkBox.delegate = self
        cell.checkBox.tag = indexPath.row
        
        return cell
    }
    
    
    
    // 체크박스를 클릭 했을 때
    func didTap(_ checkBox: BEMCheckBox) {
        if checkBox.on { // 체크 박스가 체크 됐을 때
            self.selectedUserDic[self.users[checkBox.tag].uid!] = true // 선택 유저 딕셔너리에 넣기
        } else { // 체크를 풀었을 때
            self.selectedUserDic.removeValue(forKey: self.users[checkBox.tag].uid!) // 선택 유저 딕셔너리에서 제거
        }
    }
    
    
    
    
    // MARK:- Actions
    @IBAction func chatRoomBtnPressed(_ sender: Any) {
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        // 선택한 유저 초기화
        selectedUser.removeAll()
        
        // 딕셔너리에 넣은 유저들 uid를 비교해 선택된 유저모델을 넣어준다.
        for dic in self.selectedUserDic {
            for user in self.users {
                if user.uid == dic.key {
                    self.selectedUser.append(user)
                }
            }
        }
        
        if self.selectedUser.count < 2 { // 선택한 유저가 2명 미만이라면
            self.alert("친구를 2명이상 선택해 주세요.", nil)
            return
        }
        
        chatVC.users = self.selectedUser
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}
