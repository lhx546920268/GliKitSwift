//
//  TabBarItem.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/11/2.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///选项卡按钮
public class TabBarItem: UIControl {

///标题
public let textLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.backgroundColor = .clear
    
    return label
}()

///边缘数值
    public var badgeValue: String? {
        didSet{
            if oldValue != badgeValue {
                initBadge()
                if badgeValue == "" {
                    badge?.isPoint = true
                } else {
                    badge?.isPoint = false
                    badge?.value = badgeValue
                }
            }
        }
    }

///边缘视图
    public var badge: BadgeValueView?

    ///图片
    public let imageView: UIImageView = UIImageView()
    
    ///内容
    private let contentView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = false
        addSubview(contentView)
        
        contentView.addSubview(imageView)
        contentView.addSubview(textLabel)
        
        contentView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(0)
            make.centerY.equalTo(self)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.centerX.equalTo(contentView)
        }
        
        textLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(5)
            make.bottom.equalTo(0)
            make.centerX.equalTo(contentView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///创建角标
    public func initBadge() {
        
        if badge == nil {
            let _badge = BadgeValueView()
            _badge.font = .systemFont(ofSize: 13)
            addSubview(_badge)
            
            _badge.snp.makeConstraints { (make) in
                make.centerX.equalTo(imageView.snp.trailing)
                make.top.equalTo(5)
            }
            badge = _badge
        }
    }
}
