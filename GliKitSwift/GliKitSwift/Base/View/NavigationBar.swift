//
//  NavigationBar.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/17.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///导航栏
open class NavigationBar: UIView {

    ///阴影
    public lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gkSeparatorColor;
        [self addSubview:_shadowView];
        
        [_shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(self);
            make.height.equalTo(UIApplication.gkSeparatorHeight);
        }];
    }()

    ///背景
    public private(set) var backgroundView = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initParams()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initParams()
    }
    
    func initParams(){
        backgroundView.backgroundColor = .gkNavigationBarBackgroundColor
        addSubview(backgroundView)
        
        backgroundView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(0)
        }
    }
    
    open override var alpha: CGFloat{
        set{
            super.alpha = 1.0
            self.backgroundView.alpha = newValue
        }
        get{
            self.backgroundView.alpha
        }
    }
    
    open override var backgroundColor: UIColor?{
        set{
            super.backgroundColor = .clear
            self.backgroundView.backgroundColor = newValue
        }
        get{
            self.backgroundView.backgroundColor
        }
    }
}
