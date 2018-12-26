//
//  ChatViewController.swift
//  DDingDong
//
//  Created by Byunsangjin on 17/12/2018.
//  Copyright © 2018 Byunsangjin. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK:- Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var sendButton: UIButton!
    
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    
    
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
    var peopleCount: Int?
    
    var messageList: [ChatModel.Message] = [] // 채팅을 받아올 배열
    
    
    
    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 화면 세팅
        self.initViewSet()
        
        // 내 정보를 넣어준다.
        self.userDic[myUid!] = true
        
        // 받아온 유저들의 정보를 넣어준다
        for user in users {
            self.userDic[user.uid!] = true
        }
        
        // 터치 했을 때 키보드가 사라지게 하는 제스처 추가
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        self.tabBarController?.tabBar.isHidden = true
        
        // 이미 생성된 방인지 아닌지 확인
        self.checkChatRoom()
    }
    
    
    
    // 컨트롤러가 시작 될 때
    override func viewWillAppear(_ animated: Bool) {
        // 알림 센터에 키보드 동작 알림 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        self.tabBarController?.tabBar.isHidden = false
        
        self.databaseRef?.removeObserver(withHandle: observe!)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageList.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.messageList[indexPath.row].uid == self.myUid { // 내 메세지라면
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageTableViewCell", for: indexPath) as! MyMessageTableViewCell
            
            // 메세지 설정
            cell.messageLabel.text = self.messageList[indexPath.row].message
            cell.messageLabel.numberOfLines = 0
            
            // 시간 설정
            if let time = self.messageList[indexPath.row].timestamp {
                cell.timeLabel.text = time.toDayTime
            }
            
            // 메세지 읽었는지를 카운트 하는 메소드
            self.setReadCount(label: cell.readUserLabel, postion: indexPath.row)
            
            return cell
        } else { // 다른 사람의 메세지라면
            let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationTableViewCell", for: indexPath) as! DestinationTableViewCell
            
            // 메세지 설정
            cell.messageLabel.text = self.messageList[indexPath.row].message
            cell.messageLabel.numberOfLines = 0
            
            // 시간 설정
            if let time = self.messageList[indexPath.row].timestamp {
                cell.timeLabel.text = time.toDayTime
            }
            
            // 유저 배열을 순회하여 uid가 일치 하는 유저의 이름과 이미지를 넣어준다.
            for user in users {
                if self.messageList[indexPath.row].uid == user.uid {
                    cell.userName.text = user.userName
                    
                    // 이미지 URL
                    let url = URL(string: user.profileImageUrl!)
                    
                    // 이미지 원형으로 만들기
                    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.width / 2
                    cell.profileImage.clipsToBounds = true
                    
                    // Kingfisher를 이용해 url을 통해 이미지를 받아오기
                    cell.profileImage.kf.setImage(with: url)
                }
            }
            
            // 메세지 읽었는지를 카운트 하는 메소드
            self.setReadCount(label: cell.readUserLabel, postion: indexPath.row)
            
            return cell
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 높이를 유동적으로 변경
        return UITableView.automaticDimension
    }
    
    
    
    func initViewSet() {
        // StatusBar 색상 설정
        appDelegate.statusBarSet(view: self.view)
        
        // 탭바를 숨긴다
        self.tabBarController?.tabBar.isHidden = true
        
        // 구분선 없애기
        self.tableView.separatorStyle = .none
    }
    
    
    
    // 메세지 보내는 버튼
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
            "timestamp": ServerValue.timestamp()
        ]
        
        self.dataRef.child("chatrooms").child(self.chatRoomUid!).child("messages").childByAutoId().setValue(value) { (error, ref) in
            // 나를 제외한 사람들의 유저 토큰을 FCM서버에 전송
            for user in self.users {
                if user.uid != self.myUid {
                    self.sendFCM(pushToken: user.pushToken!)
                }
            }
            
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
            
            // 채팅방이 생성되었으면 첫 메세지 보내기
            self.sendMessage()
        }
    }
    
    
    
    // 메세지를 불러온다.
    func getMessage() {
        self.databaseRef = dataRef.child("chatrooms").child(self.chatRoomUid!).child("messages")
        self.observe = self.databaseRef?.observe(.value, with: { (dataSnapshot) in
            self.messageList.removeAll()
            var readUsersDic: Dictionary<String, AnyObject> = [:]
            
            for children in dataSnapshot.children.allObjects as! [DataSnapshot] {
                // 메세지를 읽었는지 확인하는 변수
                let key = children.key as String
                let message = ChatModel.Message(JSON: children.value as! [String: AnyObject])
                let message_modify = ChatModel.Message(JSON: children.value as! [String: AnyObject])
                
                // 읽은 유저에 내 uid 추가
                message_modify?.readUsers[self.myUid!] = true
                readUsersDic[key] = message_modify?.toJSON() as! NSDictionary
                
                self.messageList.append(message!)
            }
            
            let nsDic = readUsersDic as NSDictionary
            
            print("if = \(self.messageList.last?.readUsers.keys.contains(self.myUid!))")
            if !(self.messageList.last?.readUsers.keys.contains(self.myUid!))! { // comments에 내 uid가 없을 경우 서버에 보고한다.
                print("11")
                
                dataSnapshot.ref.updateChildValues(nsDic as! [AnyHashable : Any], withCompletionBlock: { (error, ref) in
                    self.tableView.reloadData()
                    
                    // 테이블 뷰가 채팅 끝으로 이동 하도록 설정
                    self.scrollBottom()
                })
            } else { // 내 uid가 있을 경우 메세지만 표현
                print("22")
                
                self.tableView.reloadData()
                
                // 테이블 뷰가 채팅 끝으로 이동 하도록 설정
                self.scrollBottom()
            }
        })
    }
    
    
    
    func setReadCount(label: UILabel?, postion: Int?) {
        let readCount = self.messageList[postion!].readUsers.count // 읽은 유저의 수
        
        if self.peopleCount == nil { // 처음 받아올 때
            self.dataRef.child("chatrooms").child(chatRoomUid!).child("users").observeSingleEvent(of: .value) { (dataSnapshot) in
                let dic = dataSnapshot.value as! [String: Any]
                self.peopleCount = dic.count
                
                let noReadCount = self.peopleCount! - readCount // 방 전체 카운드 - 읽은 유저의 수
                
                if noReadCount > 0 { // 읽지 않은 사람이 있을 경우
                    label?.isHidden = false
                    label?.text = String(noReadCount)
                } else { // 모두 읽었을 경우
                    label?.isHidden = true
                }
            }
        } else { // 처음 받아오는게 아닐 때
            let noReadCount = self.peopleCount! - readCount // 방 전체 카운드 - 읽은 유저의 수
            
            if noReadCount > 0 { // 읽지 않은 사람이 있을 경우
                label?.isHidden = false
                label?.text = String(noReadCount)
            } else { // 모두 읽었을 경우
                label?.isHidden = true
            }
        }
    }
    
    
    
    // 테이블 뷰를 맨 밑으로 이동 시키는 메소드
    func scrollBottom() {
        // 메세지 작성시 테이블 뷰가 맨 밑으로 이동 하는 코드
        if self.messageList.count > 0 {
            self.tableView.scrollToRow(at: IndexPath(item: self.messageList.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
        }
    }
    
    
    
    // FCM 서버에 전송
    func sendFCM(pushToken: String?) {
        let url = "https://fcm.googleapis.com/fcm/send"
        let header: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "key=AAAAZG3IWJg:APA91bGNjixyWppfVZu3Sokoz3RPH0APW0VlgwDzIX6H75CYpeYZf4owsCvJuFQOWNUptfKEO_D3i8vn83ZXGx2U70ZOqjAnO1o4VVXID4WmCuk_AqSkt-Q-k3ClndH7MRhwUvdEDlMc"
        ]
        
        let userName = Auth.auth().currentUser?.displayName
        print("userName : \(userName)")
        
        var notificationModel = NotificationModel()
        notificationModel.to = pushToken!
        notificationModel.notification.title = userName
        notificationModel.notification.text = self.messageTextField.text!
        notificationModel.data.title = userName
        notificationModel.data.text = self.messageTextField.text!
        
        let params = notificationModel.toJSON()
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            print("Fmc send Success")
        }
    }
    
    
    
    // 키보드가 나타나게 하는 메소드
    @objc func keyboardWillShow(notification: Notification) {
        // 키보드 사이즈를 구해 constant에 대입 시킨다. (키보드 높이 만큼 위로 올려야 하기 때문)
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomConstraint.constant = keyboardSize.height + 5
        }
        
        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded()
        }) { (complete) in
            self.scrollBottom()
        }
    }
    
    
    
    // 키보드가 사라지게 하는 메소드
    @objc func keyboardWillHide(notification: Notification) {
        self.bottomConstraint.constant = 20
        self.view.layoutIfNeeded()
    }
    
    
    
    // 터치 했을 떄 키보드가 사라지게 하는 메소드
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
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
