//
//  SystemNavigationBar.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/19.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///导航栏
open class SystemNavigationBar: UINavigationBar {

    ///是否可以点击 直接设置 userInteractionEnabled 是无效的
    public var enable = true
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initParams()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initParams()
    }
    
    func initParams(){
        
        //把导航栏变成透明
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
        tintColor = UIColor.gkNavigationBarTintColor
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !enable {
            return nil
        }
        return super.hitTest(point, with: event)
    }
}
