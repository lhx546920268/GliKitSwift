//
//  AlertCell.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/8/27.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///弹窗按钮列表cell
class AlertCell: UICollectionViewCell {
    
    ///按钮
    public private(set) var button: Button = {
        
        let btn = Button()
        btn.adjustsImageWhenHighlighted = false
        btn.adjustsImageWhenDisabled = false
        btn.isUserInteractionEnabled = false
        
        return btn
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
        self.selectedBackgroundView = UIView()
        
        self.contentView.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
    }
}
