//
//  CollectionViewSkeletonCellCollectionViewCell.swift
//  GliKitSwiftDemo
//
//  Created by 罗海雄 on 2020/10/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

class CollectionViewSkeletonCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let size = (UIScreen.gkWidth - 10 * 4) / 3
        
        let imageView = UIImageView(image: UIImage(named: "test_1"))
        contentView.addSubview(imageView)
        contentView.backgroundColor = .white
        
        imageView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(size - 10, size - 10))
            make.centerX.equalTo(contentView)
            make.top.equalTo(5)
        }
        
        let label = UILabel()
        label.text = "标题"
        label.textAlignment = .center
        contentView.addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(5)
            make.leading.equalTo(5)
            make.trailing.equalTo(-5)
        }
        
        contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
