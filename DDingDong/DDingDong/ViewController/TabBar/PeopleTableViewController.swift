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
    var users: [UserModel] = [] // 유저 정보를 담을 객체
    
    
    
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
        
        
        
        // 유저 정보 받아오기
        self.getUserInfo()
        
        // 단체 채팅방 버튼
        self.createSelectBtn()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.getUserInfo()
        
        // 탭바 나오게 하기
        self.tabBarController?.tabBar.isHidden = false
        // 내비게이션 바 숨기기
        self.navigationController?.navigationBar.isHidden = true
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell", for: indexPath) as! PeopleCell
        
        // 이미지 설정
        let url = URL(string: users[indexPath.row].profileImageUrl!) // 이미지 URL
        
        cell.profileImageView.kf.setImage(with: url) // 이미지 설정
        
        // 이미지 동그랗게 만들기
        cell.profileImageView.layer.cornerRadius = 50 / 2
        cell.profileImageView.clipsToBounds = true
        
        cell.nameLabel.text = users[indexPath.row].userName // 이름 설정
        cell.conditionLabel.text = users[indexPath.row].condition // 상태 메세지
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        // 선택한 유저의 정보를 넘긴다.
        chatVC.users = [self.users[indexPath.row]]
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectUserVC = segue.destination as! SelectUserViewController
        
        selectUserVC.users = self.users
    }
    
    
    
    func getUserInfo() {
        // DB에서 정보 받아오기
        self.dataRef.child("users").observeSingleEvent(of: .value) { (dataSnapshot) in
            print("getUserInfo")
            // 배열 초기화 (이유 : 새로 계정을 생성할 때 DB에서 정보를 다시 받아오게 되는데 그 때 중복되기 때문)
            self.users.removeAll()
            
            let myUid = Auth.auth().currentUser?.uid
            
            // 데이터 순회하며 유저 정보 배열 검색
            for item in dataSnapshot.children {
                let userModel = UserModel()
                let fchild = item as! DataSnapshot
                
                userModel.setValuesForKeys(fchild.value as! [String : Any])
                
                // 자신을 제외한 나머지 데이터를 배열에 저장한다.
                if myUid != userModel.uid {
                    self.users.append(userModel)
                }
            }
            
            // 테이블 뷰 초기화
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    
    
    
    func createSelectBtn() {
        var selectFriendBtn = UIButton()
        self.view.addSubview(selectFriendBtn)
        selectFriendBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(view).offset(-90)
            make.right.equalTo(view).offset(-20)
            make.width.height.equalTo(50)
        }
        
        // 단체 채팅방 버튼 동그랗게 만들기
        selectFriendBtn.layer.cornerRadius = 25
        selectFriendBtn.clipsToBounds = true
        
        // 버튼 이미지 설정
        selectFriendBtn.setBackgroundImage(UIImage(named: "select"), for: .normal)
        
        selectFriendBtn.addTarget(self, action: #selector(showSelectFriendController), for: .touchUpInside)
    }
    
    
    
    
    @objc func showSelectFriendController() {
        self.performSegue(withIdentifier: "SelectFriendSegue", sender: self)
    }
}
