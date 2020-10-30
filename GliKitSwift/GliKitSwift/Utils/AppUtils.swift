//
//  AppUtils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/29.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import KeychainAccess
import Photos.PHPhotoLibrary

///与app有关的工具类
public struct AppUtils {
    
    ///app版本号
    public static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }
    
    ///是否是测试包 用版本号识别是否是测试包 如2.6.3.01 3个点以上的是测试包
    public static var isTestApp: Bool {
        return appVersion.components(separatedBy: ".").count > 3
    }
    
    ///app名称
    public static var appName: String {
        var name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        if String.isEmpty(name) {
            name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        }
        
        return name ?? ""
    }
    
    ///app图标
    public static var appIcon: UIImage? {
        if let iconName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles") as? String {
            return UIImage(named: iconName)
        }
        return nil
    }
    
    ///bundle id
    public static var bundleId: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String ?? ""
    }
    
    private static var sharedUuid: String? = nil
    private static var keyChain: Keychain? = nil
    
    ///获取唯一标识符
    public static var uuid: String {
        
        if String.isEmpty(sharedUuid) {
            let service = bundleId
            let key = "GliKitUUID"
            
            if keyChain == nil {
                if UIApplication.gkKeychainAcessGroup != nil {
                    keyChain = Keychain(service: service, accessGroup: UIApplication.gkKeychainAcessGroup!)
                } else {
                    keyChain = Keychain(service: service)
                }
            }
            
            var uuid = UserDefaults.standard.string(forKey: service + key)
            if String.isEmpty(uuid) {
                uuid = keyChain![key]
                if String.isEmpty(uuid) {
                    uuid = UUID().uuidString
                    keyChain![key] = uuid
                }
                UserDefaults.standard.set(uuid, forKey: service + key)
                UserDefaults.standard.synchronize()
            }
            
            sharedUuid = uuid
            if sharedUuid == nil {
                sharedUuid = ""
            }
            debugPrint("uuid = \(sharedUuid!)")
        }
        
        return sharedUuid!
    }
    
    ///获取ip地址
    public static var currentIP: String {
        
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifaddr) == 0 {
            if let firstAddr = ifaddr {
                // For each interface ...
                for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
                    let interface = ifptr.pointee
                    
                    // Check for IPv4 or IPv6 interface:
                    let addrFamily = interface.ifa_addr.pointee.sa_family
                    if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                        
                        // Check interface name:
                        let name = String(cString: interface.ifa_name)
                        if  name == "en0" {
                            
                            // Convert interface address to a human readable string:
                            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                            getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                        &hostname, socklen_t(hostname.count),
                                        nil, socklen_t(0), NI_NUMERICHOST)
                            address = String(cString: hostname)
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return address ?? "0.0.0.0";
    }
    
    ///拨打电话 是否显示提示框
    public static func makePhoneCall(_ mobile: String?) {
        if !String.isEmpty(mobile) {
            openCompatURL(URL(string: "tel:\(mobile!)"))
        }
    }
    
    ///打开一个URL 兼容所有版本 校验是否可以打开
    public static func openCompatURL(_ url: URL?, callCanOpen call: Bool = true) {
        if let _url = url {
            if call {
                if UIApplication.shared.canOpenURL(_url) {
                    openCompatURLDirectly(_url)
                }
            } else {
                openCompatURLDirectly(_url)
            }
        }
    }
    
    private static func openCompatURLDirectly(_ url: URL) {
        let options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:]
        UIApplication.shared.open(url, options: options, completionHandler: nil)
    }
    
    
    ///打开设置
    public static func openSettings() {
        openCompatURL(URL(string: UIApplication.openSettingsURLString))
    }
    
    ///是否有相册权限
    public static var hasPhotosAuthorization: Bool {
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            if status == .authorized || status == .limited {
                return true
            }
        }else{
            return PHPhotoLibrary.authorizationStatus() == .authorized
        }
        return false
    }
    
    public static var photosAuthorizationStatus: PHAuthorizationStatus {
        if #available(iOS 14, *) {
            return PHPhotoLibrary.authorizationStatus(for: .readWrite)
        }else{
            return PHPhotoLibrary.authorizationStatus()
        }
    }
    
    ///请求相册权限 如果已授权 则回调，否则在授权完成后才回调 保证在主线程回调
    public static func requestPhotosAuthorization(completion: @escaping (_ hasAuth: Bool) -> Void) {
        
        if photosAuthorizationStatus == .notDetermined {
            //没有权限 先申请授权
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { (_) in
                    //可能在其他线程回调
                    dispatchAsyncMainSafe {
                        completion(hasPhotosAuthorization)
                    }
                }
            } else {
                PHPhotoLibrary.requestAuthorization({ (_) in
                    //可能在其他线程回调
                    dispatchAsyncMainSafe {
                        completion(hasPhotosAuthorization)
                    }
                })
            }
        } else {
            completion(hasPhotosAuthorization)
        }
    }
}
