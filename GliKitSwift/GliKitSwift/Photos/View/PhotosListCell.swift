//
//  PhotosListCell.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/29.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

class PhotosListCell: UITableViewCell {
    
    ///缩略图
    public let thumbnailImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        
        return view
    }()

    ///标题
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        return label
    }()

    ///数量
    public let countLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.setContentHuggingPriority(.defaultHigh - 1, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh + 1, for: .horizontal)
        
        return label
    }()

    ///asset标识符
    public var assetLocalIdentifier: String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .gray
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
            make.width.equalTo(thumbnailImageView.snp.height)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(15)
            make.centerY.equalTo(contentView)
        }
        
        contentView.addSubview(countLabel)
        countLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel.snp.trailing).offset(5)
            make.centerY.equalTo(contentView)
            make.trailing.equalTo(-15)
        }
        
        let divider = Divider()
        contentView.addSubview(divider)
        divider.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel)
            make.bottom.trailing.equalTo(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
