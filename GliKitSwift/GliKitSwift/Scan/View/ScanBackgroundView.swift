//
//  ScanBackgroundView.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/11/5.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///扫描背景
class ScanBackgroundView: UIView {
    
    ///扫描框位置大小
    private(set) var scanBoxRect: CGRect = .zero
    
    ///扫描框大小
    var scanBoxSize: CGSize {
        didSet {
            scanBoxRect = CGRect((gkWidth - scanBoxSize.width) / 2, (gkHeight - scanBoxSize.height) / 2, scanBoxSize.width, scanBoxSize.height)
            boxView.snp.remakeConstraints { (make) in
                make.center.equalTo(self)
                make.size.equalTo((CGSize(scanBoxSize.width + cornerLineWidth * 2, scanBoxSize.width + cornerLineWidth * 2)))
            }
            overlayClipping()
            scanBoxRectDidChange?(scanBoxRect)
        }
    }
    
    ///四角线条宽度
    var cornerLineWidth: CGFloat = 5 {
        didSet{
            if oldValue != cornerLineWidth {
                boxView.cornerLineWidth = cornerLineWidth
                boxView.snp.remakeConstraints { (make) in
                    make.center.equalTo(self)
                    make.size.equalTo((CGSize(scanBoxSize.width + cornerLineWidth * 2, scanBoxSize.width + cornerLineWidth * 2)))
                }
            }
        }
    }
    
    ///扫描区域改变
    var scanBoxRectDidChange: ((_ scanBoxRect: CGRect) -> Void)?
    
    ///扫描动画视图
    private let animationView: UIView = {
        let view = UIView()
        view.backgroundColor = .gkThemeColor
        view.isHidden = true
        
        return view
    }()
    
    ///部分控制图层，不被扫描的部分会覆盖黑色半透明
    private let overlayView: UIView = {
        let view = UIView()
        view.alpha = 0.5
        view.backgroundColor = .black
        view.isUserInteractionEnabled = false
        view.isOpaque = false
        
        return view
    }()
    
    ///扫描框
    private let boxView: ScanBoxView = ScanBoxView()
    
    override init(frame: CGRect) {
        
        //扫描框大小
        let x = UIScreen.gkWidth / 6
        let width = UIScreen.gkWidth - x * 2
        scanBoxSize = CGSize(width, width)
        
        super.init(frame: frame)
        
        isOpaque = false
        backgroundColor = .clear
        
        addSubview(overlayView)
        overlayView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        boxView.cornerLineWidth = cornerLineWidth
        addSubview(boxView)
        boxView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.size.equalTo((CGSize(width + cornerLineWidth * 2, width + cornerLineWidth * 2)))
        }
        
        boxView.addSubview(animationView)
        animationView.snp.makeConstraints { (make) in
            make.leading.top.equalTo(10)
            make.trailing.equalTo(-10)
            make.height.equalTo(2)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///开始动画
    func startAnimating() {
        backgroundColor = .clear
        animationView.isHidden = false
        
        let animation = CABasicAnimation(keyPath: "position.y")
        animation.autoreverses = true
        animation.isRemovedOnCompletion = false
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.duration = 1
        animation.fromValue = 10
        animation.toValue = scanBoxSize.height - animationView.gkHeight
        
        animationView.layer.add(animation, forKey: "poitionAnimation")
    }
    
    ///停止动画
    func stopAnimating() {
        backgroundColor = .black
        animationView.isHidden = false
        animationView.layer.removeAllAnimations()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let rect = CGRect((gkWidth - scanBoxSize.width) / 2, (gkHeight - scanBoxSize.height) / 2, scanBoxSize.width, scanBoxSize.height)
        if !rect.equalTo(scanBoxRect) {
            scanBoxRect = rect
            overlayClipping()
            scanBoxRectDidChange?(scanBoxRect)
        }
    }
    
    //绘制裁剪区分图层
    private func overlayClipping() {
        
        let layer = CAShapeLayer()
        let path = CGMutablePath()
        
        //左边
        path.addRect(CGRect(0, 0, scanBoxRect.minX, gkHeight))
        
        //右边
        path.addRect(CGRect(scanBoxRect.maxX, 0, gkWidth - scanBoxRect.maxX, gkHeight))
        
        //上面
        path.addRect(CGRect(0, 0, gkWidth, scanBoxRect.minY))
        
        //下面
        path.addRect(CGRect(0, scanBoxRect.maxY, gkWidth, gkHeight - scanBoxRect.maxY))
        
        layer.path = path
        overlayView.layer.mask = layer
    }
}
