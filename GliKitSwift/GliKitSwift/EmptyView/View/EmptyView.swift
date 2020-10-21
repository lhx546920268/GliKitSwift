//
//  EmptyView.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///空视图代理
@objc public protocol EmptyViewDelegate: NSObjectProtocol{
    
    @objc optional func emptyViewWillAppear(_ view: EmptyView)
}

///数据为空的视图
open class EmptyView: UIView {
    
    ///内容
    private lazy var contentView: UIView = {
        
        let contentView = UIView()
        contentView.backgroundColor = .clear
        self.addSubview(contentView)
        
        contentView.snp.makeConstraints { (make) in
            make.leading.equalTo(10)
            make.trailing.equalTo(-10)
            make.centerY.equalTo(self)
        }
        
        return contentView
    }()

    ///图标
    private var _iconImageView: UIImageView?
    public var iconImageView: UIImageView{
        if _iconImageView == nil {
            let iconImageView = UIImageView()
            iconImageView.contentMode = .scaleAspectFit
            self.contentView.addSubview(iconImageView)
            
            iconImageView.snp.makeConstraints { (make) in
                make.leading.greaterThanOrEqualTo(0)
                make.trailing.lessThanOrEqualTo(0)
                make.centerX.top.equalTo(0)
            }
            
            
            if _textLabel != nil {
                if let constraint = _textLabel?.gkTopLayoutConstraint {
                    self.contentView.removeConstraint(constraint)
                }
                _textLabel?.snp.makeConstraints({ (make) in
                    make.top.equalTo(iconImageView.snp.bottom).offset(10)
                })
            }else{
                
                iconImageView.snp.makeConstraints { (make) in
                    make.bottom.equalTo(0)
                }
            }
            _iconImageView = iconImageView
        }
        
        return _iconImageView!
    }

    
    ///文字信息
    private var _textLabel: UILabel?
    public var textLabel: UILabel{
        if _textLabel == nil {
            let textLabel = UILabel()
            textLabel.backgroundColor = .clear
            textLabel.textColor = UIColor.gkColorFromHex("aeaeae")
            textLabel.font = UIFont.systemFont(ofSize: 14)
            textLabel.textAlignment = .center
            textLabel.numberOfLines = 0
            self.contentView.addSubview(textLabel)
            
            
            let exist = _iconImageView != nil
            textLabel.snp.makeConstraints { (make) in
                if exist {
                    if let constraint = _iconImageView?.gkBottomLayoutConstraint {
                        self.contentView.removeConstraint(constraint)
                    }
                    make.top.equalTo(_iconImageView!.snp.bottom).offset(10)
                } else {
                    make.top.equalTo(0)
                }
                make.leading.trailing.bottom.equalTo(0)
            }
            _textLabel = textLabel
        }
        
        return _textLabel!
    }


    ///自定义视图 如果设置将忽略以上两个，并且会重新设置customView的约束，高度约束和frame.size.height一样
    public var customView: UIView?{
        didSet{
            oldValue?.removeFromSuperview()
            if let customView = self.customView {
                self.contentView.addSubview(customView)
                customView.snp.makeConstraints { (make) in
                    make.edges.equalTo(0)
                }
            }
        }
    }
    

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = false
        self.backgroundColor = .clear
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
