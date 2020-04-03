//
//  TabMenuBarCell.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/3.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///菜单按钮
class TabMenuBarCell: UICollectionViewCell {
    
    ///按钮
    public private(set) lazy var button: Button = {
        
        let button = Button()
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        button.titleLabel?.textAlignment = .center
        button.isUserInteractionEnabled = false
        button.titleLabel?.numberOfLines = 0
        self.contentView.addSubview(button)
        
        button.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        return button
    }()

    ///分隔符
    public private(set) lazy var divider: Divider = {
        
        let divider = Divider(vertical: true)
        divider.isUserInteractionEnabled = false
        self.contentView.addSubview(divider)
        
        divider.snp.makeConstraints { (make) in
            make.trailing.centerY.equalTo(0)
            make.height.equalTo(15)
        }
        return divider
    }()

    ///是否选中
    public var tick = false {
        didSet{
            button.isSelected = self.tick
            button.tintColor = button.titleColor(for: self.tick ? .selected : .normal)
        }
    }

    ///按钮信息
    public var item: TabMenuBarItem?{
        didSet{
            
            self.button.setTitle(self.item?.title, for: .normal)
            self.button.setImage(self.item?.icon, for: .normal)
            self.button.setBackgroundImage(self.item?.backgroundImage, for: .normal)
            self.button.imagePadding = self.item?.iconPadding ?? 0
            self.button.imagePosition = self.item?.iconPosition ?? .left
            self.button.titleEdgeInsets = self.item?.titleInsets ?? .zero
            
            self.customView = self.item?.customView
        }
    }

    /**
     自定义视图
     */
    public var customView: UIView?{
        didSet{
            oldValue?.removeFromSuperview()
            if self.customView != nil {
                self.contentView.addSubview(self.customView!)
            }
        }
    }
}
