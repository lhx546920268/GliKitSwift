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
            let cell: Item? = gkCell(for: identifier!, isHeaderFooter: false)
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
            let cell: Item? = gkCell(for: identifier!, isHeaderFooter: true)
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

    ///注册的cells header footer 用来计算
    private func gkCell<Item: TableConfigurableItem>(for identifier: String, isHeaderFooter: Bool) -> Item? {
        var cells = objc_getAssociatedObject(self, &registerCellsKey) as? NSMutableDictionary
        if cells == nil {
            cells = NSMutableDictionary()
            objc_setAssociatedObject(self, &registerCellsKey, cells, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        if let cells = cells {
            var view = cells[identifier] as? Item
            if view == nil {
                if isHeaderFooter {
                    view = dequeueReusableHeaderFooterView(withIdentifier: identifier) as? Item
                } else {
                    view = dequeueReusableCell(withIdentifier: identifier) as? Item
                }
                cells[identifier] = view
            }
            
            return view
        }
        
        return nil
    }
}
