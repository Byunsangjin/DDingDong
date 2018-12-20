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
    
    
    
    // MARK:- Constants
    let myUid = Auth.auth().currentUser?.uid
    let dataRef = Database.database().reference()
    
    

    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        
        self.getRoomInfo()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.getRoomInfo()
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatRooms.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomTableViewCell", for: indexPath) as! ChatRoomTableViewCell
        
        var destinationUid: [String] = []
        var destinationUsers: [UserModel] = []
        
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
                    
                    if self.chatRooms[indexPath.row].users.count == 2 { // 1:1 채팅방일 때
                        // 이미지 URL
                        let url = URL(string: userModel.profileImageUrl!)
                        
                        // 이미지 둥그렇게 처리
                        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.width / 2
                        cell.profileImage.clipsToBounds = true
                        
                        // 이미지 받아오기
                        cell.profileImage?.kf.setImage(with: url)
                    }
                    
                    if (cell.nameLabel.text?.elementsEqual(""))!{
                        print("빈칸")
                        cell.nameLabel.text?.append(userModel.userName!)
                    } else {
                        print("노 빈칸")
                        cell.nameLabel.text?.append(", \(userModel.userName!)")
                    }
                    
                    // 오름차순($0>$1)으로 comments의 값들을 받아온다
                    let lastMsgKey = self.chatRooms[indexPath.row].messages.keys.sorted() { $0 > $1 }
                    
                    cell.lastMessageLabel.text = self.chatRooms[indexPath.row].messages[lastMsgKey[0]]?.message
                }
            }
        }
        
        
        return cell
    }
    
    
    
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