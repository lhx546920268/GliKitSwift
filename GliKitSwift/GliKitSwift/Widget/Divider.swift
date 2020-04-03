//
//  Divider.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/3.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///分割线 会自己设置高度 宽度和背景
class Divider: UIView {
    
    ///是否是垂直的
    public private(set) var isVertical = false
        
    init(vertical: Bool) {
        
        super.init(frame: .zero)
        self.isVertical = vertical
        initParams()
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        isVertical = self.gkWidthLayoutConstraint != nil
        initParams()
    }

    ///初始化
    private func initParams(){
        
        self.backgroundColor = UIColor.gkSeparatorColor;
        if self.isVertical {
            
            if let constraint = self.gkWidthLayoutConstraint {
                constraint.constant = UIApplication.gkSeparatorHeight
            } else {
                self.snp.makeConstraints { (make) in
                    make.width.equalTo(UIApplication.gkSeparatorHeight)
                }
            }
        } else {
            
            if let constraint = self.gkHeightLayoutConstraint {
                constraint.constant = UIApplication.gkSeparatorHeight
            } else {
                self.snp.makeConstraints { (make) in
                    make.height.equalTo(UIApplication.gkSeparatorHeight)
                }
            }
        }
    }
}
