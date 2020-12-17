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

        let queue = DispatchQueue(label: "xx", attributes: .concurrent)

        queue.async {
            for _ in 0..<1000 {
                let time = Date.gkCurrentTime(format: Date.dateFormatYMd)
                if time.count != 10 {
                    print("10 diff", time)
                }
            }
        }

        queue.async {
            for _ in 0..<1000 {
                let time = Date.gkCurrentTime(format: Date.dateFormatYMdHm)
                if time.count != 16 {
                    print("16 diff", time)
                }
            }
        }
        
        
        return true
    }
}

