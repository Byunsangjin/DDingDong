//
//  ChatModel.swift
//  DDingDong
//
//  Created by Byunsangjin on 18/12/2018.
//  Copyright © 2018 Byunsangjin. All rights reserved.
//

import ObjectMapper

class ChatModel: Mappable {
    // MARK:- Variables
    public var users: Dictionary<String, Bool> = [:] // 채팅방에 참여한 사람들
    public var messages: Dictionary<String, Message> = [:] // 채팅방의 대화 내용
    
    
    
    // MARK:- Methods
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        self.users <- map["users"]
        self.messages <- map["messages"]
    }
    
    public class Message: Mappable{
        public var uid: String?
        public var message: String?
        public var timestamp: Int?
        public var readUsers: Dictionary<String, Bool> = [:]
        
        
        public required init?(map: Map) {
        }
        
        public func mapping(map: Map) {
            self.uid <- map["uid"]
            self.message <- map["message"]
            self.timestamp <- map["timestamp"]
            self.readUsers <- map["readUsers"]
        }
    }
}
