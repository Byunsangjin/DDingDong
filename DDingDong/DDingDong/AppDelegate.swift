//
//  AppDelegate.swift
//  DDingDong
//
//  Created by Byunsangjin on 14/12/2018.
//  Copyright © 2018 Byunsangjin. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        // 구글 로그인 설정
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        GIDSignIn.sharedInstance()?.signOut()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
}



extension AppDelegate: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error { // 에러가 있다면
            print("구글 로그인 에러 : \(error.localizedDescription)")
            return
        } else {
            
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if error != nil { // 에러가 있으면
                    print("로그인 데이터 에러 : \(error?.localizedDescription)")
                    return
                } else { // 에러가 없다면
                    let user = authResult?.user
                    let uid = user?.uid
                    
                    // 데이터 베이스에 구글 유저 정보 넣기
                    var image = UIImage()
                    image = #imageLiteral(resourceName: "profile")
                    
                    // 이미지 데이터로 변환
                    let data = image.jpegData(compressionQuality: 0.1) as! Data
                    
                    // 저장소에 저장
                    let spaceRef = Storage.storage().reference().child("users").child(uid!)
                    
                    spaceRef.putData(data, metadata: nil) { (metadata, error) in
                        // 에러가 발생 했을 때
                        guard metadata != nil else {
                            print("metadata error")
                            return
                        }
                        
                        // 다운로드 url에 접근한다.
                        spaceRef.downloadURL { (url, error) in
                            // 에러가 발생 했을 때
                            guard let imageUrl = url else {
                                print("download error \(error?.localizedDescription)")
                                return
                            }
                            
                            if error != nil {
                                print("에러 = \(error?.localizedDescription)")
                            } else {
                                // 데이터 베이스에 접근해서 이름 값과 이미지 다운로드 url을 넣어준다
                                
                                InstanceID.instanceID().instanceID(handler: { (result, error) in
                                    Database.database().reference().child("users").child(uid!).setValue(["userName": user?.displayName,"pushToken": result?.token, "profileImageUrl": imageUrl.absoluteString, "uid": uid!])
                                })
                                
                            }
                        }
                    }
                    
                    let loginVC = self.window?.rootViewController?.presentedViewController as! LoginViewController
                    let mainVC = loginVC.storyboard?.instantiateViewController(withIdentifier: "MainViewTabBarController") as! UITabBarController
                    loginVC.present(mainVC, animated: true)
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("구글 로그인 끊어짐")
    }
    
    
}
