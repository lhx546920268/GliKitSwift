//
//  Router.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2021/2/8.
//  Copyright © 2021 luohaixiong. All rights reserved.
//

import UIKit

///路由
public extension UIViewController {
    
    ///设置路由参数，如果参数名和属性名一致，则不需要处理这个
    @objc func setRouterParams(_ params: Dictionary<String, Any>?){
        
    }
}

///路由方式
public enum RouteStyle {
    
    ///直接用系统的push
    case push
    
    ///用push替换当前的页面
    case replace
    
    ///present 有导航栏
    case present
    
    ///没导航栏
    case presentWithoutNavigationBar
    
    ///这个页面只打开一个，用push
    case onlyOne
}

///路由参数类型
public typealias RouteParameters = Dictionary<String, Any>

///路由属性
public class RouteProps {
    
    ///页面原始链接
    public fileprivate(set) var urlComponents: NSURLComponents?
    
    ///路由参数
    public fileprivate(set) var routeParams: RouteParameters?
    
    ///打开方式
    public var style: RouteStyle = .push
    
    ///app的路由路径 如 goods/detail
    public var path: String?
    
    ///一个完整的URL 和 path二选一 优先使用这个
    public var urlString: String?
    
    ///额外参数，可传递对象，在拦截器会加入到 routeParams
    public var extras: Dictionary<String, Any>?

    ///完成回调
    fileprivate var completion: RouteCompletion?

    ///是否是弹出来
    fileprivate var isPresent: Bool {
        style == .present || style == .presentWithoutNavigationBar
    }
}

///页面拦截策略
public enum RouteInterceptPolicy {
    
    ///允许打开
    case allow
    
    ///取消
    case cancel
}

///拦截处理结果
public typealias RouteInterceptCallback = (_ policy: RouteInterceptPolicy) -> Void

///拦截器
public protocol RouteInterceptor: NSObjectProtocol {
    
    ///处理路由
    func processRoute(_ props: RouteProps, interceptCallback: RouteInterceptCallback)
}

///路由结果
public enum RouteResult {
    
    ///打开了
    case success
    
    ///取消了
    case cancelled
    
    ///失败
    case failed
}

///路由回调
public typealias RouteCompletion = (_ result: RouteResult) -> Void

///页面初始化处理 自己处理则返回nil
public typealias RouteCallback = (_ routeParams: RouteParameters?) -> UIViewController?

///注册的信息
fileprivate struct RouteRegistration {
    
    ///类
    let cls: AnyClass?
    
    ///回调
    let callback: RouteCallback?
    
    init(cls: AnyClass?) {
        self.cls = cls
        callback = nil
    }
    
    init(callback: RouteCallback?) {
        cls = nil
        self.callback = callback
    }
}

///路由 在URLString中的特殊字符和参数值必须编码
public class Router: NSObject {
    
    ///单例
    public static let sharedRouter = Router()
    
    ///失败回调
    public var failureCallback: ((_ URLString: String, _ routeParams: RouteParameters?) -> Void)?
    
    ///已注册的
    private var registrations = [String: RouteRegistration]()
    
    ///拦截器
    private var interceptors = [RouteInterceptor]()
    
    ///添加拦截器
    public func addInterceptor(_ interceptor: RouteInterceptor) {
        interceptors.append(interceptor)
    }
    
    ///移除拦截器
    public func removeInterceptor(_ interceptor: RouteInterceptor) {
        let index = interceptors.firstIndex { element -> Bool in
            return element.isEqual(interceptor)
        }
        if index != nil {
            interceptors.remove(at: index!)
        }
    }
    
    /**
     注册一个页面
     
     @param path 页面路径
     @param cls 页面对应的类 会根据对应的cls创建一个页面，必须是UIViewController
     */
    public func register(path: String, forClass cls: AnyClass) {
        assert(cls == UIViewController.self, "register path, cls must a UIViewController")
        registrations[path] = RouteRegistration(cls: cls)
    }
    
    /**
    注册一个页面 与上一个方法互斥 不会调用 setRouterParams

    @param path 页面路径
    @param handler 页面初始化回调
    */
    public func register(path: String, forCallback callback: @escaping RouteCallback) {
        registrations[path] = RouteRegistration(callback: callback)
    }
    
    /**
     取消注册一个页面
     
     @param path 页面路径
     */
    public func unregister(path: String) {
        registrations[path] = nil
    }
    
    /**
     打开一个链接
     
     @param block 用来配置的
     */
    public func open(_ block: (_ props: RouteProps) -> Void) {
        let props = RouteProps()
        block(props)
        assert(props.urlString != nil || props.path != nil, "RouteProps must set urlString or path")
        
        if let urlString = props.urlString {
            props.urlComponents = NSURLComponents(string: urlString)
        } else if let path = props.path {
            props.urlComponents = NSURLComponents(string: path)
        }
        open(props: props)
    }
    
    
    // MARK: - ViewController

    private func viewController(for props: RouteProps) -> UIViewController? {
        
        var viewController: UIViewController? = nil
        var processBySelf: Bool = false
        
        
        if let path = props.path, let registration = registrations[path] {
            if let callback = registration.callback {
                viewController = callback(props.routeParams)
                processBySelf = true
            } else if let cls = registration.cls as? UIViewController.Type {
                viewController = cls.init()
            } else if let cls = NSClassFromString(path) as? UIViewController.Type {
                viewController = cls.init()
            }
        }
        
        if viewController == nil {
            if !processBySelf {
                cannotFound(props: props)
            }
        } else if let routeParams = props.routeParams, routeParams.count > 0 {
            viewController?.setRouterParams(routeParams)
        }
        
        return viewController
    }

    ///获取在tabBar上面对应的下标
    private func tabBarIndex(for name: String) -> Int? {
        guard let controller = UIApplication.shared.delegate?.window??.rootViewController as? UITabBarController else {
            return nil
        }
        
        guard let viewControllers = controller.viewControllers else {
            return nil
        }
        for i in 0 ..< viewControllers.count {
            var vc = viewControllers[i]
            if let nav = vc as? UINavigationController, nav.viewControllers.count > 0 {
                vc = nav.viewControllers.first!
            }
            if vc.gkNameOfClass == name {
                return i
            }
        }
        return nil
    }

    ///打开一个页面
    private func open(props: RouteProps) {
        guard let components = props.urlComponents else {
            cannotFound(props: props)
            props.completion?(.failed)
            return
        }
        
        var params: RouteParameters? = nil
        if let extras = props.extras, extras.count > 0,
           let queryItems = components.queryItems, queryItems.count > 0 {
            params = RouteParameters()
            //添加URL上的参数
            for item in queryItems {
                if let value = item.value {
                    params![item.name] = value
                }
            }
            
            params!.merge(extras) { (_, new) in new}
        }
        
        props.routeParams = params
        if interceptors.count > 0 {
            interceptRoute(props, for: 0)
        } else {
            continueRoute(props)
        }
    }

    ///拦截器处理
    private func interceptRoute(_ props: RouteProps, for index: Int) {
        interceptors[index].processRoute(props) { (policy) in
            if policy == .allow {
                if index + 1 < interceptors.count {
                    self.interceptRoute(props, for: index + 1)
                } else {
                    self.continueRoute(props)
                }
            } else {
                props.completion?(.cancelled)
            }
        }
    }

    ///跳转
    private func continueRoute(_ props: RouteProps) {
        guard let path = props.path else {
            return
        }
        
        if let index = tabBarIndex(for: path) {
            gkCurrentViewController.gkBack(animated: false) {
                guard let controller = UIApplication.shared.delegate?.window??.rootViewController as? UITabBarController else {
                    return
                }
                controller.selectedIndex = index
                props.completion?(.success)
            }
            return
        }
        
        guard var viewController = viewController(for: props) else {
            return
        }
        
        let parent = gkCurrentViewController
        if props.isPresent {
            if props.style == .present {
                viewController = viewController.gkCreateWithNavigationController
            }
            parent.gkTopestPresentedViewController.present(viewController, animated: true) {
                props.completion?(.success)
            }
        } else {
            var nav = parent.navigationController
            if parent.isKind(of: UINavigationController.self) {
                nav = parent as? UINavigationController
            }
            
            if let baseNav = nav as? BaseNavigationController {
                baseNav.transitionCompletion = {
                    props.completion?(.success)
                }
            }
            
            if let nav = nav {
                var toReplaceds: [UIViewController]? = nil
                switch props.style {
                case .replace :
                    if nav.viewControllers.count > 0 {
                        toReplaceds = [nav.viewControllers.last!]
                    }
                    
                case .onlyOne :
                    toReplaceds = [UIViewController]()
                    for vc in nav.viewControllers {
                        if vc.isKind(of: viewController.classForCoder) {
                            toReplaceds?.append(vc)
                        }
                    }
                    
                case .present, .push, .presentWithoutNavigationBar :
                    break
                }
                
                if let toReplaceds = toReplaceds, toReplaceds.count > 0 {
                    var viewControllers = nav.viewControllers
                    viewControllers.removeAll { (vc) -> Bool in
                        return toReplaceds.contains(vc)
                    }
                    nav.setViewControllers(viewControllers, animated: true)
                } else {
                    nav.pushViewController(viewController, animated: true)
                }
                    
            }
        }
    }

    ///找不到对应的页面
    private func cannotFound(props: RouteProps) {
        
        let urlString = props.urlString != nil ? props.urlString : props.path
        #if DEBUG
        print("Can not found viewControlelr for \(urlString!)")
        #endif
        failureCallback?(urlString!, props.extras)
    }
}

