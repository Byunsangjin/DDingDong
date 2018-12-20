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
        
        getRoomInfo()
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("self.chatRooms.count : \(self.chatRooms.count)")
        return self.chatRooms.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRoomTableViewCell", for: indexPath) as! ChatRoomTableViewCell
        
        print(self.chatRooms[indexPath.row].users)
        
        return UITableViewCell()
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
