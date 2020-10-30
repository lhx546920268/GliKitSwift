//
//  DefaultLoadMoreControl.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/27.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///默认的加载更多控件
open class DefaultLoadMoreControl: LoadMoreControl {

    ///是否要显示菊花 默认显示
    public var showIndicatorView = true

    ///加载菊花
    public private(set) lazy var indicatorView: UIActivityIndicatorView = {
        if #available(iOS 13, *) {
            let view = UIActivityIndicatorView(style: .medium)
            view.color = .gray
            return view
        } else {
            return UIActivityIndicatorView(style: .gray)
        }
    }()

    ///加载显示的提示信息
    public private(set) lazy var textLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = UIColor(white: 0.4, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = .clear
        label.numberOfLines = 0
        addSubview(label)
        
        return label
    }()

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if isHorizontal {
            let contentWidth = (indicatorView.isAnimating ? (indicatorView.gkWidth + 3.0) : 0) + textLabel.gkWidth
            indicatorView.gkLeft = (criticalPoint - contentWidth) / 2
            textLabel.gkLeft = indicatorView.isAnimating ? indicatorView.gkRight + 3.0 : indicatorView.gkLeft
        }else{
            indicatorView.gkTop = (criticalPoint - indicatorView.gkHeight) / 2
            textLabel.gkTop = (criticalPoint - textLabel.gkHeight) / 2
        }
    }

    // MARK: - Super Method

    open override func onStateChange(_ state: DataControlState) {
        super.onStateChange(state)
        
        switch state {
        case .normal, .pulling :
            textLabel.text = titleForState(state)
            indicatorView.stopAnimating()
            updatePosition()
            
        case .noData :
            textLabel.text = titleForState(state)
            indicatorView.stopAnimating()
            textLabel.isHidden = !shouldStayWhileNoData
            updatePosition()
            
        case .loading :
            textLabel.text = titleForState(state)
            if showIndicatorView {
                indicatorView.startAnimating()
            }
            updatePosition()
            
        case .reachCirticalPoint :
            textLabel.text = titleForState(state)
            updatePosition()
            
        default:
            break
        }
    }

    ///更新位置
    private func updatePosition(){
        
        if isHorizontal {
            let height = indicatorView.gkHeight
            let size = textLabel.text?.gkStringSize(font: textLabel.font, with: 18) ?? CGSize.zero
            indicatorView.gkTop = (self.gkHeight - height) / 2.0
            
            var frame = textLabel.frame
            frame.origin.y = (self.gkHeight - size.height) / 2.0
            frame.size.width = size.width
            frame.size.height = size.height
            textLabel.frame = frame
        }else{
            
            let width = indicatorView.isAnimating ? indicatorView.gkWidth : 0
            var size = textLabel.text?.gkStringSize(font: textLabel.font, with: self.gkWidth - width) ?? CGSize.zero
            size.width += 1.0
            size.height += 1.0
            indicatorView.gkLeft = (self.gkWidth - size.width - width) / 2.0
            
            var frame = textLabel.frame
            frame.origin.x = indicatorView.gkLeft + width + 3.0
            frame.size.width = self.gkWidth - indicatorView.gkLeft - width
            frame.size.height = size.height;
            textLabel.frame = frame
        }
    }
}
