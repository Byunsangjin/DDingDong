//
//  NotificationModel.swift
//  DDingDong
//
//  Created by Byunsangjin on 21/12/2018.
//  Copyright © 2018 Byunsangjin. All rights reserved.
//

import ObjectMapper

class NotificationModel: Mappable {
    public var to: String?
    public var notification: Notification = Notification()
    public var data: Data = Data()
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        to <- map["to"]
        notification <- map["notification"]
        data <- map["data"]
    }
    
    class Notification: Mappable {
        public var title: String?
        public var text: String?
        var sound: String? =  "default"
        
        init() {
            
        }
        
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            title <- map["title"]
            text <- map["text"]
            sound <- map["sound"]
        }
    }
    
    
    class Data: Mappable {
        public var title: String?
        public var text: String?
        
        init() {
            
        }
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            title <- map["title"]
            text <- map["text"]
        }
    }
}
