//
//  ChatRoomsViewController.swift
//  DDingDong
//
//  Created by Byunsangjin on 20/12/2018.
//  Copyright © 2018 Byunsangjin. All rights reserved.
//

import UIKit
import Firebase

class ChatRoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK:- Outlets
    @IBOutlet var tableView: UITableView!
    
    
    
    // MARK:- Variables
    var chatRooms: [ChatModel] = []
    var userDic = Dictionary<Int, [UserModel]>() // UserModel 배열 딕셔너리
    
    
    
    // MARK:- Constants
    let myUid = Auth.auth().currentUser?.uid
    let dataRef = Database.database().reference()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    

    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        
        self.appDelegate.statusBarSet(view: (self.navigationController?.view)!)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.getRoomInfo()
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatRooms.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomTableViewCell", for: indexPath) as! ChatRoomTableViewCell
        

        var nameString: String? = "" // nameLabel에 들어갈 String
        var userModelArray: [UserModel] = [] // 딕셔너리에 들어갈 UserModel 배열
        
        for user in self.chatRooms[indexPath.row].users {
            if user.key != self.myUid {
                if self.chatRooms[indexPath.row].users.count > 2 { // 단체방일 때
                    // 이미지 둥그렇게 처리
                    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.width / 2
                    cell.profileImage.clipsToBounds = true
                    
                    cell.profileImage.image = #imageLiteral(resourceName: "groupImage")
                }
                
                dataRef.child("users").child(user.key).observeSingleEvent(of: .value) { (dataSnapshot) in
                    let userModel = UserModel()
                    userModel.setValuesForKeys(dataSnapshot.value as! [String: AnyObject])
                    userModelArray.append(userModel)
                    self.userDic[indexPath.row] = userModelArray
                    
                    if self.chatRooms[indexPath.row].users.count == 2 { // 1:1 채팅방일 때
                        // 이미지 URL
                        let url = URL(string: userModel.profileImageUrl!)
                        
                        // 이미지 둥그렇게 처리
                        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.width / 2
                        cell.profileImage.clipsToBounds = true
                        
                        // 이미지 받아오기
                        cell.profileImage?.kf.setImage(with: url)
                    }
                    
                    //단체 채팅방일 때도 생각해서 분기처리
                    if (nameString?.isEmpty)! {
                        nameString?.append(userModel.userName!)
                    } else {
                        nameString?.append(", \(userModel.userName!)")
                    }
                    
                    cell.nameLabel.text = nameString
                    
                    // 오름차순($0>$1)으로 comments의 값들을 받아온다
                    let lastMsgKey = self.chatRooms[indexPath.row].messages.keys.sorted() { $0 > $1 }
                    
                    cell.lastMessageLabel.text = self.chatRooms[indexPath.row].messages[lastMsgKey[0]]?.message
                }
            }
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        let users = self.userDic[indexPath.row] as! [UserModel]
        
        chatVC.users = users
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    
    
    // 방 정보를 불러오는 메소드
    
    func getRoomInfo() {
        self.chatRooms.removeAll()
        
        self.dataRef.child("chatrooms").queryOrdered(byChild: "users/" + self.myUid!).queryEqual(toValue: true).observeSingleEvent(of: .value) { (dataSnapshot) in
            for child in dataSnapshot.children.allObjects as! [DataSnapshot] {
                if let chatroomdic = child.value as? [String: AnyObject] {
                    let chatModel = ChatModel(JSON: chatroomdic)
                    
                    self.chatRooms.append(chatModel!)
                }
            }
            
            self.tableView.reloadData()
        }
    }
}
