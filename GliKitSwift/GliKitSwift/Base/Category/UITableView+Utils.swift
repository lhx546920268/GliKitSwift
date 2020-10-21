//
//  UITableView+Utils.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

public extension UITableView{
    
    ///隐藏多余的分割线
    func setExtraCellLineHidden(){
        
        self.tableFooterView = nil
        self.tableFooterView = UIView()
    }

    ///注册cell
    func registerNib(_ cls: AnyClass){
        
        let name = String(describing: cls)
        register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
    }
    
    func registerClass(_ cls: AnyClass){
        register(cls, forCellReuseIdentifier: String(describing: cls))
    }

    ///注册header footer
    func registerNibForHeaderFooterView(_ cls: AnyClass){
        
        let name = String(describing: cls)
        register(UINib(nibName: name, bundle: nil), forHeaderFooterViewReuseIdentifier: name)
    }
    
    func registerClassForHeaderFooterView(_ cls: AnyClass){
        register(cls, forHeaderFooterViewReuseIdentifier: String(describing: cls))
    }
}
