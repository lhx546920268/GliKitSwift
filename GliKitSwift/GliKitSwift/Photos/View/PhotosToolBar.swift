//
//  PhotosToolBar.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/29.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///相册工具条
class PhotosToolBar: UIView {
    
    ///分割线
    public let divider: Divider = Divider()
    
    ///使用按钮
    public let useButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("使用", for: .normal)
        btn.titleLabel?.font = UIFont.gkNavigationBarItemFont
        btn.contentEdgeInsets = .only(left: UIApplication.gkNavigationBarMargin, right: UIApplication.gkNavigationBarMargin)
        btn.isEnabled = false
        btn.setTitleColor(.black, for: .normal)
        btn.setTitleColor(.gray, for: .disabled)
        btn.setTitleColor(UIColor(white: 0, alpha: 0.5), for: .highlighted)
        
        return btn
    }()
    
    ///预览按钮
    public let previewButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("预览", for: .normal)
        btn.titleLabel?.font = UIFont.gkNavigationBarItemFont
        btn.contentEdgeInsets = .only(left: UIApplication.gkNavigationBarMargin, right: UIApplication.gkNavigationBarMargin)
        btn.isEnabled = false
        btn.setTitleColor(.black, for: .normal)
        btn.setTitleColor(.gray, for: .disabled)
        btn.setTitleColor(UIColor(white: 0, alpha: 0.5), for: .highlighted)
        
        return btn
    }()
    
    ///选择的数量
    public let countLabel: UILabel = {
        let label = UILabel()
        label.text = "已选0张图片"
        label.font = .systemFont(ofSize: 15)
        
        return label
    }()
    
    ///当前选的图片数量
    public var count: Int = 0 {
        didSet{
            if oldValue != count {
                countLabel.text = "已选\(count)张图片"
                useButton.isEnabled = count > 0
                previewButton.isEnabled = count > 0
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(divider)
        divider.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(0)
        }
        
        let bottom: CGFloat = UIApplication.shared.delegate?.window??.gkSafeAreaInsets.bottom ?? 0
        previewButton.snp.makeConstraints { (make) in
            make.leading.top.equalTo(0)
            make.bottom.equalTo(-bottom)
        }
        
        useButton.snp.makeConstraints { (make) in
            make.trailing.top.equalTo(0)
            make.bottom.equalTo(-bottom)
        }
        
        countLabel.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.centerX.equalTo(self)
            make.bottom.equalTo(-bottom)
        }
        
        self.snp.makeConstraints { (make) in
            make.height.equalTo(45 + bottom)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
