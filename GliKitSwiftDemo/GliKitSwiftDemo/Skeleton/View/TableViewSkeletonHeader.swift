//
//  TableViewSkeletonHeader.swift
//  GliKitSwiftDemo
//
//  Created by 罗海雄 on 2020/10/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

class TableViewSkeletonHeader: UITableViewHeaderFooterView {

    public var titleLabel: UILabel!
    override init(reuseIdentifier: String?) {
        
        titleLabel = UILabel()
        titleLabel.text = "这是一个标题"
        
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.centerY.equalTo(contentView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
