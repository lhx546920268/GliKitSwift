//
//  AppDelegate.swift
//  GliKitSwiftDemo
//
//  Created by 罗海雄 on 2020/1/16.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import GliKitSwift
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var param: ((UIView) -> ())?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RootViewController()
        window?.makeKeyAndVisible()

        let view = UIView()
        
        if window == view {
            
        }
        
        window?.bbc = 20
        window?.aac = 10
        
        print(window!.bbc!)
        print(window!.aac!)
        
        return true
    }

   
    func save(guide: SafeLayoutGuide) -> Void {
        
    }
}

extension UIView {
    
    var bbc: Int?{
        set{
            objc_setAssociatedObject(self, &UIView.key1, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get{
            objc_getAssociatedObject(self, &UIView.key1) as? Int
        }
    }
    private static var key1 = 0
    var aac: Int?{
           set{
               objc_setAssociatedObject(self, &UIView.key2, newValue, .OBJC_ASSOCIATION_RETAIN)
           }
           get{
               objc_getAssociatedObject(self, &UIView.key2) as? Int
           }
       }
       private static var key2 = 0
}

