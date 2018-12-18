//
//  ChatViewController.swift
//  DDingDong
//
//  Created by Byunsangjin on 17/12/2018.
//  Copyright © 2018 Byunsangjin. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    // MARK:- Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var sendButton: UIButton!
    
    
    
    // MARK:- Constants
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let dataRef = Database.database().reference()
    
    
    
    // MARK:- Variable
    var users: [UserModel] = []
    var myUid: String? = Auth.auth().currentUser?.uid
    
    var userDic = Dictionary<String, Bool>() // 현재 방의 유저들
    var chatRoomUid: String? // 채팅방 키값
    
    var databaseRef: DatabaseReference?
    var observe: UInt?
    
    var messageList: [ChatModel.Message] = [] // 채팅을 받아올 배열
    
    
    
    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // StatusBar 색상 설정
        appDelegate.statusBarSet(view: self.view)
        
        // 탭바를 숨긴다
        self.tabBarController?.tabBar.isHidden = true
        
        // 내 정보를 넣어준다.
        self.userDic[myUid!] = true
        
        // 받아온 유저들의 정보를 넣어준다
        for user in users {
            self.userDic[user.uid!] = true
        }
        
        self.checkChatRoom()
    }
    
    
    
    func sendMessage() {
        // 메세지가 아무것도 입력 되지 않았을 때 동작 동작 안하게 한다.
        let trimmingMsg = self.messageTextField.text?.trimmingCharacters(in: CharacterSet.whitespaces)
        if (trimmingMsg?.isEmpty)! { // 빈 공백만 있었다면
            print("글자를 입력해주세요.")
            return
        }
        
        // 채팅 데이터 딕셔너리
        let value: Dictionary<String, Any> = [
            "uid": self.myUid!,
            "message": self.messageTextField.text!,
        ]
        
        self.dataRef.child("chatrooms").child(self.chatRoomUid!).child("messages").childByAutoId().setValue(value) { (error, ref) in
            //self.fmcSend()
            
            // 입력 텍스트 필드 초기화
            self.messageTextField.text = ""
        }
    }
    
    
    
    // 방이 있는지 없는지 체크한다.
    func checkChatRoom() {
        // 내 정보를 넣어준다.
        self.userDic[myUid!] = true
        
        // 받아온 유저들의 정보를 넣어준다
        for user in users {
            self.userDic[user.uid!] = true
        }
        
        self.dataRef.child("chatrooms").queryOrdered(byChild: "users/" + self.myUid!).queryEqual(toValue: true).observeSingleEvent(of: .value) { (dataSnapshot) in
            // 모든 채팅방 탐색
            for item in dataSnapshot.children.allObjects as! [DataSnapshot] {
                if let chatRoomDic = item.value as? [String: AnyObject] {
                    // 채팅방 정보 받아오기
                    let chatModel = ChatModel(JSON: chatRoomDic)
                    
                    if chatModel?.users == self.userDic { // 채팅방의 유저들과 현재 유저들과 일치 한다면
                        // 채팅방 키를 받는다
                        self.chatRoomUid = item.key
                        
                        // 방 키를 받았으면 메세지를 받아온다.
                        self.getMessage()
                    }
                }
            }
        }
    }
    
    
    
    // 메세지를 불러온다.
    func getMessage() {
        self.databaseRef = dataRef.child("chatrooms").child(self.chatRoomUid!).child("messages")
        self.observe = self.databaseRef?.observe(.value, with: { (dataSnapshot) in
            self.messageList.removeAll()
            
            for children in dataSnapshot.children.allObjects as! [DataSnapshot] {
                let message = ChatModel.Message(JSON: children.value as! [String: AnyObject])
                
                self.messageList.append(message!)
            }
        })
    }
    
    
    
    // MARK:- Actions
    @IBAction func sendBtnPressed(_ sender: Any) {
        if self.chatRoomUid == nil { // 채팅방이 없다면
            let nsDic = self.userDic as! NSDictionary
            
            // 채팅방을 생성한다.
            self.dataRef.child("chatrooms").childByAutoId().child("users").setValue(nsDic) { (error, ref) in
                print("채팅방 생성")
                // 채팅방을 생성하고 다시 채팅방 uid를 설정해 주기위해 방을 한번 더 체크 한다.
                self.checkChatRoom()
            }
        } else { // 채팅방이 있다면
            print("이미 채팅방이 있습니다.")
            // 메세지 보내기
            self.sendMessage()
        }
    }
    

}
