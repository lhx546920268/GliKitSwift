//
//  UICollectionView+ItemSize.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/10/16.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

private var registerObjectsKey: UInt8 = 0
private var registerCellsKey: UInt8 = 0

///保存item大小的
public protocol ItemSizeModel: AnyObject {
    
    ///item大小
    var itemSize: CGSize?{
        get
        set
    }
}

///可配置的item
public protocol CollectionConfigurableItem where Self: UICollectionReusableView{
    
    associatedtype Model: ItemSizeModel
    
    ///对应的数据
    var model: Model?{
        get
        set
    }
}

public extension UICollectionView {
    
    // MARK: - 计算
    
    ///限制item的宽度 获取item大小
    func gkItemSize<Item: CollectionConfigurableItem>(forType type: Item.Type, model: Item.Model, width: CGFloat, identifier: String? = nil) -> CGSize {
        return gkItemSize(forType: type, model: model, constraintSize: CGSize(width, 0), identifier: identifier)
    }
    
    ///限制item的高度 获取item大小
    func gkItemSize<Item: CollectionConfigurableItem>(forType type: Item.Type, model: Item.Model, height: CGFloat, identifier: String? = nil) -> CGSize {
        return gkItemSize(forType: type, model: model, constraintSize: CGSize(0, height), identifier: identifier)
    }
    
    
    /// 获取item 大小
    /// - Parameters:
    ///   - type: item类型 传 YourCollectionReusableView.self
    ///   - model: 保存item大小
    ///   - constraintSize: item的最大取值范围，0表示没有限制
    ///   - identifier: item唯一标识符，如果是空的，则获取type的类型
    /// - Returns: item大小
    func gkItemSize<Item: CollectionConfigurableItem>(
        forType type: Item.Type,
        model: Item.Model,
        constraintSize: CGSize = .zero,
        identifier: String? = nil) -> CGSize {
        
        if model.itemSize == nil {
            if self.frame.size.hasZero {
                return .zero
            }
            //计算大小
            var identifier = identifier
            if identifier == nil {
                identifier = String(describing: type)
            }
            let item: Item = gkCell(for: identifier!)
            item.model = model
            
            var contentView: UIView = item
            if contentView is UICollectionViewCell {
                let cell = item as! UICollectionViewCell
                contentView = cell.contentView
            }
            
            var calcType: AutoLayoutCalcType = .size
            if constraintSize.width > 0 && constraintSize.height == 0 {
                calcType = .height
            } else if constraintSize.width == 0 && constraintSize.height > 0 {
                calcType = .width
            }
            
            model.itemSize = contentView.gkSizeThatFits(constraintSize, type: calcType)
        }
        
        return model.itemSize!
    }
    
    // MARK: - 注册的 cells
    
    internal static func swizzleCollectionViewItemSize(){
        
        let selectors: [String] = [
            "registerNib:forCellWithReuseIdentifier:",
            "registerClass:forCellWithReuseIdentifier:",
            "registerNib:forSupplementaryViewOfKind:withReuseIdentifier:",
            "registerClass:forSupplementaryViewOfKind:withReuseIdentifier:"
        ]

        for selector in selectors {
            swizzling(selector1: Selector(selector), selector2: Selector("gkItemSize_\(selector)"), cls1: self)
        }
    }
    
    @objc private func gkItemSize_registerClass(_ cls: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        gkItemSize_registerClass(cls, forCellWithReuseIdentifier: identifier)
        gkRegisterObjects[identifier] = cls
    }

    @objc private func gkItemSize_registerNib(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        gkItemSize_registerNib(nib, forCellWithReuseIdentifier: identifier)
        gkRegisterObjects[identifier] = nib;
    }

    @objc private func gkItemSize_registerClass(_ cls: AnyClass?, forSupplementaryViewOfKind kind: String, withReuseIdentifier identifier: String) {
        gkItemSize_registerClass(cls, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
        gkRegisterObjects[identifier] = cls
    }

    @objc private func gkItemSize_registerNib(_ nib: UINib?, forSupplementaryViewOfKind kind: String, withReuseIdentifier identifier: String) {
        gkItemSize_registerNib(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
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
    private func gkCell<Item: CollectionConfigurableItem>(for identifier: String) -> Item {
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
                } else {
                    fatalError("must register cell header footer for \(identifier)")
                }
            }
            
            return view!
        }
        
        fatalError("must register cell header footer for \(identifier)")
    }
}
