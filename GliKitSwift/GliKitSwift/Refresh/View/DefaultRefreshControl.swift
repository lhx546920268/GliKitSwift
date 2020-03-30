//
//  DefaultRefreshControl.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/30.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///默认的下拉刷新控件
open class DefaultRefreshControl: RefreshControl {
    
    ///是否要显示菊花 默认显示
    public var showIndicatorView = true
    
    ///刷新指示器
    public private(set) lazy var indicatorView: UIActivityIndicatorView = {
        return UIActivityIndicatorView(style: .gray)
    }()
    
    ///刷新控制的状态信息视图
    public private(set) lazy var statusLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = UIColor(white: 0.4, alpha: 1.0)
        label.autoresizingMask = .flexibleWidth
        label.font = UIFont.systemFont(ofSize: 13)
        label.backgroundColor = .clear
        label.textAlignment = .left
        
        addSubview(label)
        
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let margin = (criticalPoint - indicatorView.gkHeight) / 2
        indicatorView.gkTop = self.gkHeight - statusLabel.gkHeight - margin
        statusLabel.gkTop = indicatorView.gkTop
    }
    
    // MARK: - Super Method
    
    override func onStateChange(_ state: DataControlState) {
        
        super.onStateChange(state)
        switch state {
        case .pulling, .normal, .fail :
            if !animating {
                statusLabel.text = titleForState(state)
                updatePosition()
            }
        case .reachCirticalPoint :
            statusLabel.text = titleForState(state)
            updatePosition()
        case .loading :
            statusLabel.text = titleForState(state)
            if showIndicatorView {
                indicatorView.startAnimating()
            }
            updatePosition()
        default:
            break
        }
    }
    
    override func stopLoading() {
        
        super.stopLoading()
        indicatorView.stopAnimating()
        statusLabel.text = finishText
        updatePosition()
    }
    
    ///更新位置
    private func updatePosition(){
        
        let width = indicatorView.isAnimating ? indicatorView.gkWidth : 0
        let size = statusLabel.text?.gkStringSize(font: statusLabel.font, with: self.gkWidth - width) ?? CGSize.zero
        indicatorView.gkLeft = (self.gkWidth - size.width - width) / 2
        
        var frame = indicatorView.frame
        frame.origin.x = indicatorView.gkLeft + width + 3.0
        frame.size.width = self.gkWidth - indicatorView.gkLeft - width
        statusLabel.frame = frame
    }
}
