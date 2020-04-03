//
//  NSAttributedString.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/3.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

public extension NSAttributedString {

    /**
     获取富文本框大小
     *@param width 每行最大宽度
     *@return 富文本框大小
     */
    func gkBounds(constraintWidth: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGSize {
        
        return self.boundingRect(with: CGSize(width: constraintWidth, height: 8388608.0), options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin, .usesFontLeading], context: nil).size
    }

}
