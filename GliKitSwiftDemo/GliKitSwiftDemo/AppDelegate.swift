//
//  AppDelegate.swift
//  GliKitSwiftDemo
//
//  Created by 罗海雄 on 2020/1/16.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import GliKitSwift
import PromiseKit
import Alamofire

class SignInTask: HttpTask {
    

}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GliKitSwift.initialize()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = BaseNavigationController(rootViewController: RootViewController())
        window?.makeKeyAndVisible()

        firstly {
            URLSession.shared.dataTask(.promise, with: URL(string: "https://www.baidu.com")!)
        }.done { (_, _) in
            print("finish")
        }.catch { (e) in
            
        }
        
        
        
        return true
    }
}

