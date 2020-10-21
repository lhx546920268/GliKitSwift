//
//  UITableView+RowHeight.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/16.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

private var registerObjectsKey: UInt8 = 0
private var registerCellsKey: UInt8 = 0

///保存行高的
public protocol RowHeightModel: AnyObject {
    
    ///行高
    var rowHeight: CGFloat?{
        get
        set
    }
}

///可配置的item
public protocol TableConfigurableItem where Self: UIView {
    
    ///指明类型
    associatedtype Model: RowHeightModel
    
    ///对应的数据
    var model: Model?{
        get
        set
    }
}

///缓存行高的
public extension UITableView {
    
    // MARK: - 计算
    
    /// 获取cell高度
    /// - Parameters:
    ///   - type: cell类型 传 YourTableViewCell.self
    ///   - model: 保存行高的
    ///   - identifier: cell唯一标识，如果是空，则获取type的类型
    /// - Returns: cell 高度
    func gkRowHeight<Item: TableConfigurableItem>(forType type: Item.Type, model: Item.Model, identifier: String? = nil) -> CGFloat {
        if model.rowHeight == nil {
            var identifier = identifier
            if identifier == nil {
                identifier = String(describing: type)
            }
            var cell: Item? = gkCell(for: identifier!)
            if cell == nil {
                //有时候cell没有注册，而是直接创建的
                cell = dequeueReusableCell(withIdentifier: identifier!) as? Item
            }
            return gkRowHeight(forCell: cell!, model: model)
        }
        return model.rowHeight!
    }
    
    /// 获取cell高度 主要用于静态cell，不重用的cell
    /// - Parameters:
    ///   - identifier: cell唯一标识
    ///   - model: 保存行高的
    /// - Returns: cell 高度
    func gkRowHeight<Item: TableConfigurableItem>(forCell cell: Item, model: Item.Model) -> CGFloat {
        if model.rowHeight == nil {
            var width = self.frame.width
            
            let item = cell as! UITableViewCell
            //当使用系统的accessoryView时，content宽度会向右偏移
            if item.accessoryView != nil {
                width -= 16.0 + item.accessoryView!.frame.width
            }else{
                switch item.accessoryType {
                case .disclosureIndicator :
                    //箭头
                    width -= 34.0
                    
                case .checkmark :
                    //勾
                    width -= 40.0
                    
                case .detailButton :
                    //详情
                    width -= 48.0
                    
                case .detailDisclosureButton :
                    //箭头+详情
                    width -= 68.0
                    
                default:
                    break
                }
            }
            
            cell.model = model
            var height = item.contentView.gkSizeThatFits(CGSize(width, 0), type: .height).height
            //如果有分割线 加上1px
            if separatorStyle != .none {
                height += 1.0 / UIScreen.main.scale
            }
            model.rowHeight = height;
        }
        return model.rowHeight!;
    }
    
    /// 获取header footer高度
    /// - Parameters:
    ///   - type: cell类型 传 YourHeaderFooterView.self
    ///   - model: 保存行高的
    ///   - identifier: cell唯一标识，如果是空，则获取type的类型
    /// - Returns: header footer 高度
    func gkHeaderFooterHeight<Item: TableConfigurableItem>(forType type: Item.Type, model: Item.Model, identifier: String? = nil) -> CGFloat {
        if model.rowHeight == nil {
            var identifier = identifier
            if identifier == nil {
                identifier = String(describing: type)
            }
            var cell: Item? = gkCell(for: identifier!)
            if cell == nil {
                //有时候cell没有注册，而是直接创建的
                cell = dequeueReusableHeaderFooterView(withIdentifier: identifier!) as? Item
            }
            return gkRowHeight(forHeaderFooter: cell!, model: model)
        }
        return model.rowHeight!
    }
    
    /// 获取header footer高度 主要用于静态 header footer，不重用的
    /// - Parameters:
    ///   - identifier: cell唯一标识
    ///   - model: 保存行高的
    /// - Returns: header footer 高度
    func gkRowHeight<Item: TableConfigurableItem>(forHeaderFooter headerFooter: Item, model: Item.Model) -> CGFloat {
        if model.rowHeight == nil {
            headerFooter.model = model
            model.rowHeight = headerFooter.gkSizeThatFits(CGSize(self.frame.width, 0), type: .height).height
        }
        
        return model.rowHeight!
    }
    
    // MARK: - 注册的 cells
    
    internal static func swizzleTableViewRowHeight(){
        
        let selectors: [String] = [
            "registerNib:forCellReuseIdentifier:",
            "registerClass:forCellReuseIdentifier:",
            "registerNib:forHeaderFooterViewReuseIdentifier:",
            "registerClass:forHeaderFooterViewReuseIdentifier:"
        ]

        for selector in selectors {
            swizzling(selector1: Selector(selector), selector2: Selector("gkRowHeight_\(selector)"), cls1: self)
        }
    }
    
    @objc private func gkRowHeight_registerClass(_ cls: AnyClass?, forCellReuseIdentifier identifier: String) {
        gkRowHeight_registerClass(cls, forCellReuseIdentifier: identifier)
        gkRegisterObjects[identifier] = cls
    }

    @objc private func gkRowHeight_registerNib(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
        gkRowHeight_registerNib(nib, forCellReuseIdentifier: identifier)
        gkRegisterObjects[identifier] = nib;
    }

    @objc private func gkRowHeight_registerClass(_ cls: AnyClass?, forHeaderFooterViewReuseIdentifier identifier: String) {
        gkRowHeight_registerClass(cls, forHeaderFooterViewReuseIdentifier: identifier)
        gkRegisterObjects[identifier] = cls
    }

    @objc private func gkRowHeight_registerNib(_ nib: UINib?, forHeaderFooterViewReuseIdentifier identifier: String) {
        gkRowHeight_registerNib(nib, forHeaderFooterViewReuseIdentifier: identifier)
        gkRegisterObjects[identifier] = nib;
    }

    ///注册的 class nib
    private var gkRegisterObjects: NSMutableDictionary {
        get{
            var objects = objc_getAssociatedObject(self, &registerObjectsKey) as? NSMutableDictionary
            if objects == nil {
                objects = NSMutableDictionary()
                objc_setAssociatedObject(self, &registerObjectsKey, objects, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return objects!
        }
    }

    ///注册的cells header footer 用来计算
    private func gkCell<Item: TableConfigurableItem>(for identifier: String) -> Item? {
        /**
         不用 dequeueReusableCellWithIdentifier 是因为会创建N个cell
         */
        var cells = objc_getAssociatedObject(self, &registerCellsKey) as? NSMutableDictionary
        if cells == nil {
            cells = NSMutableDictionary()
            objc_setAssociatedObject(self, &registerCellsKey, cells, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        if let cells = cells {
            var view = cells[identifier] as? Item
            if view == nil {
                let obj = gkRegisterObjects[identifier]
                if obj is UINib {
                    let nib: UINib = obj as! UINib
                    view = nib.instantiate(withOwner: nil, options: nil).first as? Item
                    cells[identifier] = view
                } else if obj is AnyClass {
                    let cls = obj as! Item.Type
                    view = cls.init()
                    cells[identifier] = view
                }
            }
            
            return view
        }
        
        return nil
    }
}
