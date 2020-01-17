//
//  AppDelegate.swift
//  GliKitSwiftDemo
//
//  Created by 罗海雄 on 2020/1/16.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import GliKitSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var param: CGFloat = 0{
        
        didSet{
            print("didSet \(self.param)")
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RootViewController()
        window?.makeKeyAndVisible()
        
        param = 10
        save(guide: .none)
        return true
    }

   
    func save(guide: SafeLayoutGuide) -> Void {
        
    }
}

