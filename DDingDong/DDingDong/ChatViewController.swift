//
//  ChatViewController.swift
//  DDingDong
//
//  Created by Byunsangjin on 17/12/2018.
//  Copyright © 2018 Byunsangjin. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    // MARK:- Outlets
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    
    // MARK:- Variable
    var users: [UserModel] = []
    
    
    
    
    // MARK:- Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // StatusBar 색상 설정
        appDelegate.statusBarSet(view: self.view)
        print("ChatViewController")
    }

}
