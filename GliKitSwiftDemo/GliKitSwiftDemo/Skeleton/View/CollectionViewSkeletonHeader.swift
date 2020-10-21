//
//  CollectionViewSkeletonHeader.swift
//  GliKitSwiftDemo
//
//  Created by 罗海雄 on 2020/10/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

class CollectionViewSkeletonHeader: UICollectionReusableView {
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let label = UILabel()
        label.text = "这是一个标题"
        addSubview(label)
        
        backgroundColor = .white
        label.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.centerY.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
