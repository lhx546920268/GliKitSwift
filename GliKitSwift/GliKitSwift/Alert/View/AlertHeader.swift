//
//  AlertHeader.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/8/27.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///弹窗头部
class AlertHeader: UIScrollView {

    ///图标
    public private(set) lazy var imageView: UIImageView = {
        return UIImageView()
    }()

    ///标题
    public private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        self.addSubview(label)
        
        return label
    }()

    ///信息
    public private(set) lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        self.addSubview(label)
        
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initParams()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initParams()
    }
    
    func initParams(){
        self.alwaysBounceHorizontal = false
        self.alwaysBounceVertical = false
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        self.backgroundColor = .clear
    }
}
