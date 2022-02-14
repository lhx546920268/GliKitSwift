//
//  AlertController.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/8/27.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

/**
 弹窗控制器 AlertView 和 ActionSheet的整合
 @warning 在显示show前设置好属性
 */
public class AlertController: BaseViewController {
    
    ///样式
    public private(set) var style: Style!

    ///弹窗属性 默认使用单例
    public var props: AlertProps {
        set{
            _props = newValue
        }
        get{
            if _props == nil {
                return style == .alert ? AlertProps.defaultAlertProps : AlertProps.defaultactionSheetProps
            } else {
                return _props!
            }
        }
    }
    private var _props: AlertProps?

    ///按钮 不包含actionSheet 的取消按钮
    public let actions: [AlertAction]!

    ///具有警示意义的按钮 下标，default is ’NSNotFound‘，表示没有这个按钮
    public var destructiveButtonIndex: Int = NSNotFound

    ///是否关闭弹窗当点击某一个按钮的时候
    public var dismissWhenSelectButton: Bool = true

    ///点击回调 index 按钮下标 包含取消按钮 actionSheet 从上到下， alert 从左到右
    public var selectCallback: ((_ index: Int) -> Void)?

    ///按钮列表
    private var collectionView: UICollectionView?

    ///头部
    private var header: AlertHeader?

    ///取消按钮 用于 actionSheet
    private var cancelButton: UIButton?

    ///取消按钮标题
    private var cancelTitle: String?

    ///标题 NSString 或者 NSAttributedString
    private var alertTitle: Any?

    ///信息 NSString 或者 NSAttributedString
    private var message: Any?

    ///图标
    private var icon: UIImage?

    /**
     实例化一个弹窗
     @param title 标题 NSString 或者 NSAttributedString
     @param message 信息 NSString 或者 NSAttributedString
     @param icon 图标
     @param style 样式
     @param cancelButtonTitle 取消按钮 default is ‘取消’
     @param otherButtonTitles 按钮标题，优先使用actions
     @param actions 按钮
     @return 一个实例
     */
    init(title: Any? = nil,
         message: Any? = nil,
         icon: UIImage? = nil,
         style: Style,
         cancelButtonTitle: String? = nil,
         otherButtonTitles: [String]? = nil,
         actions: [AlertAction]? = nil) {

        assert(title == nil || title is String || title is NSAttributedString, "AlertController title 必须为 nil 或者 NSString 或者 NSAttributedString");
        assert(message == nil || message is String || message is NSAttributedString, "AlertController message 必须为 nil 或者 NSString 或者 NSAttributedString");

        var actions = actions ?? [AlertAction]()

        self.alertTitle = title
        self.message = message
        self.icon = icon

        self.cancelTitle = cancelButtonTitle
        self.style = style

        if actions.count == 0 && otherButtonTitles != nil {
            for buttonTitle in otherButtonTitles! {
                actions.append(AlertAction(title: buttonTitle))
            }
        }

        if style == .alert {

            if actions.count == 0 && cancelButtonTitle == nil {
                self.cancelTitle = "取消"
            }

            if self.cancelTitle != nil {
                if actions.count < 2 {
                    actions.insert(AlertAction(title: self.cancelTitle), at: 0)
                } else {
                    actions.append(AlertAction(title: self.cancelTitle))
                }
            }
        }

        self.actions = actions
        super.init(nibName: nil, bundle: nil)
        self.dialogShouldUseNewWindow = true
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, use designed init instead")
    }

    ///更新某个按钮 不包含actionSheet 的取消按钮
    public func reloadButton(for index: Int) {
        if index < actions.count {
            collectionView?.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }

    ///通过下标回去按钮标题
    public func buttonTitle(for index: Int) -> String? {
        if index < actions.count {
            return actions[index].title
        }

        if(style == .actionSheet && index == actions.count){
            return self.cancelTitle
        }

        return nil
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.dialogShowAnimate = .custom
        self.dialogDismissAnimate = .custom
        self.shouldDismissDialogOnTapTranslucent = style == .actionSheet && !String.isEmpty(self.cancelTitle)
        self.tapDialogBackgroundGestureRecognizer.delegate = self
    }

    // MARK: - layout

    ///弹窗宽度
    private var alertViewWidth: CGFloat {
        switch style {
        case .alert :
            return 260 + UIApplication.gkSeparatorHeight
        case .actionSheet :
            return self.view.gkWidth - props.contentInsets.width
        default:
            return 0
        }
    }

    public override func viewDidLayoutSubviews() {

        if !isViewDidLayoutSubviews {
            let props = self.props
            let width = alertViewWidth
            let margin = (self.view.gkWidth - width) / 2

            let container = self.container!
            container.backgroundColor = props.mainColor
            container.layer.cornerRadius = props.cornerRadius
            container.layer.masksToBounds = true

            layoutHeader()
            switch style {
            case .alert :
                container.frame = CGRect(margin, margin, width, 0)
                
            case .actionSheet :
                container.frame = CGRect(props.contentInsets.left, margin, width, 0)
                if !String.isEmpty(cancelTitle) {
                    let btn = UIButton(frame: CGRect(margin, margin, width, props.buttonHeight))
                    btn.layer.cornerRadius = props.cornerRadius
                    btn.gkSetBackgroundColor(props.mainColor, state: .normal)
                    btn.setTitle(cancelTitle, for: .normal)
                    btn.setTitleColor(props.cancelButtonTextColor, for: .normal)
                    btn.gkSetBackgroundColor(props.highlightedBackgroundColor, state: .highlighted)
                    btn.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
                    
                    //取消按钮和 内容视图的间隔
                    if props.spacingBackgroundColor != nil && props.cancelButtonVerticalSpacing > 0 {
                        let view = UIView(frame: CGRect(0, -props.cancelButtonVerticalSpacing, btn.gkWidth, props.cancelButtonVerticalSpacing))
                        view.backgroundColor = props.spacingBackgroundColor
                        btn.addSubview(view)
                        btn.clipsToBounds = false
                    }
                    
                    view.addSubview(btn)
                    cancelButton = btn
                }
                
            default: break
            }
            
            if actions.count > 0 {
                collectionView = UICollectionView(frame: CGRect(0, header?.gkBottom ?? 0, width, 0), collectionViewLayout: layout)
                collectionView?.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
                collectionView?.registerClass(AlertCell.self)
                collectionView?.delegate = self
                collectionView?.dataSource = self
                collectionView?.bounces = false
                collectionView?.showsHorizontalScrollIndicator = false
                container.addSubview(collectionView!)
            }
            
            layoutSubViews()
        }
        super.viewDidLayoutSubviews()
    }
    
    
    ///collectionView布局方式
    private var layout: UICollectionViewLayout {
        get{
            let props = self.props
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = UIApplication.gkSeparatorHeight
            layout.minimumInteritemSpacing = UIApplication.gkSeparatorHeight
            
            switch style {
            case .actionSheet :
                layout.itemSize = CGSize(alertViewWidth, props.buttonHeight)
                
            case .alert :
                layout.itemSize = CGSize(actions.count == 2 ? (alertViewWidth - UIApplication.gkSeparatorHeight) / 2.0 : alertViewWidth, props.buttonHeight)
                layout.scrollDirection = actions.count > 2 ? .vertical : .horizontal
            default:
                break
            }
            return layout
        }
    }
    
    ///布局头部视图
    private func layoutHeader() {
        if alertTitle != nil || message != nil || icon != nil {
            
            let width = alertViewWidth
            let props = self.props
            let header = AlertHeader(frame: CGRect(0, 0, width, 0))
            let constraintWidth = header.gkWidth - props.textInsets.width

            var y = props.textInsets.top
            if icon != nil {
                header.imageView.image = icon
                if icon!.size.width > constraintWidth {
                    let size = icon!.gkFit(with: CGSize(constraintWidth, 0))
                    header.imageView.frame = CGRect((header.gkWidth - size.width) / 2, y, icon!.size.width, icon!.size.height)
                } else {
                    header.imageView.frame = CGRect((header.gkWidth - icon!.size.width) / 2, y, icon!.size.width, icon!.size.height)
                }
                y += header.imageView.gkHeight
            }
            
            if alertTitle != nil {
                if icon != nil {
                    y += props.verticalSpacing
                }
                header.titleLabel.font = props.titleFont
                header.titleLabel.textColor = props.titleTextColor
                header.titleLabel.textAlignment = props.titleTextAlignment
                
                var size: CGSize = .zero
                if alertTitle is String {
                    let str = alertTitle as! String
                    header.titleLabel.text = str
                    size = str.gkStringSize(font: props.titleFont, with: constraintWidth)
                } else if alertTitle is NSAttributedString {
                    let attr = alertTitle as! NSAttributedString
                    header.titleLabel.attributedText = attr
                    size = attr.gkBounds(constraintWidth: constraintWidth)
                }
                
                header.titleLabel.frame = CGRect(props.textInsets.left, y, constraintWidth, size.height)
                y += header.titleLabel.gkHeight
            }
            
            if message != nil {
                if icon != nil || alertTitle != nil {
                    y += props.verticalSpacing
                }
                header.messageLabel.font = props.messageFont
                header.messageLabel.textColor = props.messageTextColor
                header.messageLabel.textAlignment = props.messageTextAlignment
                
                var size: CGSize = .zero
                if message is String {
                    let str = message as! String
                    header.messageLabel.text = str
                    size = str.gkStringSize(font: props.messageFont, with: constraintWidth)
                } else if message is NSAttributedString {
                    let attr = message as! NSAttributedString
                    header.messageLabel.attributedText = attr
                    size = attr.gkBounds(constraintWidth: constraintWidth)
                }
                
                header.messageLabel.frame = CGRect(props.textInsets.left, y, constraintWidth, size.height)
                y += header.messageLabel.gkHeight
            }
            
            header.gkHeight = y + props.textInsets.bottom
            
            //小于最低高度
            if header.gkHeight < props.contentMinHeight {
                let rest = (props.contentMinHeight - header.gkHeight) / 2
                var y = props.textInsets.top + rest
                if icon != nil {
                    header.imageView.gkTop = y
                    y += header.imageView.gkHeight
                }
                
                if alertTitle != nil {
                    if icon != nil {
                        y += props.verticalSpacing
                    }
                    header.titleLabel.gkTop = y
                    y += header.titleLabel.gkHeight
                }
                
                if message != nil {
                    if icon != nil || alertTitle != nil {
                        y += props.verticalSpacing
                    }
                    header.messageLabel.gkTop = y
                    y += header.messageLabel.gkHeight
                }
                header.gkHeight = y + props.textInsets.bottom + rest
            }
            
            header.contentSize = header.gkSize
            header.backgroundColor = props.mainColor
            container!.addSubview(header)
            self.header = header
        }
    }

    ///布局子视图
    private func layoutSubViews() {
        let props = self.props

        //头部高度
        var headerHeight: CGFloat = 0
        if header != nil {
            headerHeight = header!.gkHeight
        }

        //按钮高度
        var buttonHeight: CGFloat = 0

        if actions.count > 0 {
            switch style {
            case .alert :
                buttonHeight = actions.count <= 2 ? props.buttonHeight : actions.count.cgFloatValue * (UIApplication.gkSeparatorHeight + props.buttonHeight)
                if headerHeight > 0 {
                    buttonHeight += 0.1
                }
                
            case .actionSheet :
                buttonHeight = actions.count.cgFloatValue * props.buttonHeight + (actions.count - 1).cgFloatValue * UIApplication.gkSeparatorHeight
                
                if headerHeight > 0 {
                    buttonHeight += UIApplication.gkSeparatorHeight
                }
                
            default: break
            }
        }

        ///取消按钮高度
        let cancelHeight: CGFloat = cancelButton != nil ? (cancelButton!.gkHeight + props.contentInsets.bottom) : 0

        let maxContentHeight: CGFloat = self.view.gkHeight - props.contentInsets.top - props.contentInsets.bottom - cancelHeight - self.view.gkSafeAreaInsets.bottom

        var frame: CGRect = collectionView?.frame ?? .zero
        if headerHeight + buttonHeight > maxContentHeight {
            let contentHeight = maxContentHeight
            if headerHeight >= contentHeight / 2.0 && buttonHeight >= contentHeight / 2.0 {
                header?.gkHeight = contentHeight / 2.0
                frame.size.height = buttonHeight
            }else if headerHeight >= contentHeight / 2.0 && buttonHeight < contentHeight / 2.0 {
                header?.gkHeight = contentHeight - buttonHeight
                frame.size.height = buttonHeight
            }else{
                header?.gkHeight = headerHeight
                frame.size.height = contentHeight - headerHeight
            }

            frame.origin.y = header?.gkBottom ?? 0
            collectionView?.frame = frame
            container?.gkHeight = maxContentHeight
        }else{

            frame.origin.y = header?.gkBottom ?? 0
            frame.size.height = buttonHeight
            collectionView?.frame = frame
            container?.gkHeight = headerHeight + buttonHeight
        }

        if (header?.gkHeight ?? 0) > 0 {
            collectionView?.gkHeight += UIApplication.gkSeparatorHeight
            container?.gkHeight += UIApplication.gkSeparatorHeight
        }

        switch style {
        case .actionSheet :
                container?.gkTop = self.view.gkHeight
       
        case .alert :
                container?.gkTop = (self.view.gkHeight - (container?.gkHeight ?? 0 )) / 2.0
            
        default: break
        }

        cancelButton?.gkTop = (container?.gkBottom ?? 0) + props.cancelButtonVerticalSpacing
    }

    // MARK: - private method

    ///取消
    @objc private func handleCancel() {
        var index = 0
        if style == .actionSheet {
            index = actions.count
        }
        dialogDismissCompletion = {
            self.selectCallback?(index)
        }
        dismiss()
    }
    
    public override func didExecuteDialogShowCustomAnimate(_ completion: ((Bool) -> Void)?) {
        switch style {
        case .alert :
            container?.alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                self.dialogBackgroundView?.alpha = 1.0
                self.container?.alpha = 1.0
                let animation = CABasicAnimation(keyPath: "transform.scale")
                animation.fromValue = 1.3
                animation.toValue = 1.0
                animation.duration = 0.25
                self.container?.layer.add(animation, forKey: "scale")
            }, completion: completion)
            
        case .actionSheet :
            let props = self.props
            UIView.animate(withDuration: 0.25, animations: {
                let spacing = self.cancelButton != nil ? props.cancelButtonVerticalSpacing : 0
                self.dialogBackgroundView?.alpha = 1.0
                
                if let container = self.container {
                    container.gkTop = self.view.gkHeight - container.gkHeight - max(props.contentInsets.bottom, self.view.gkSafeAreaInsets.bottom) - (self.cancelButton?.gkHeight ?? 0) - spacing
                    self.cancelButton?.gkTop = container.gkBottom + props.cancelButtonVerticalSpacing
                }
            }, completion: completion)
            
        default:
            break
        }
    }

    public override func didExecuteDialogDismissCustomAnimate(_ completion: ((Bool) -> Void)?) {
        switch style {
        case .alert :
            UIView.animate(withDuration: 0.25, animations: {
                self.dialogBackgroundView?.alpha = 0
                self.container?.alpha = 0
            }, completion: completion)
            
        case .actionSheet :
            UIView.animate(withDuration: 0.25, animations: {
                self.dialogBackgroundView?.alpha = 0;
                self.container?.gkTop = self.view.gkHeight
                self.cancelButton?.gkTop = (self.container?.gkBottom ?? 0) + self.props.cancelButtonVerticalSpacing
            }, completion: completion)
            
        default:
            break
        }
    }

    // MARK: - UITapGestureRecognizer delegate

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let container = self.container {
            var point = gestureRecognizer.location(in: self.dialogBackgroundView)
            point.y += self.dialogBackgroundView?.gkTop ?? 0
            
            if container.frame.contains(point) {
                return false
            }
        }
        
        return true
    }

    public override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self.dialogBackgroundView
    }
}

extension AlertController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actions.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if header != nil && header!.gkHeight > 0 {
            return UIEdgeInsets(UIApplication.gkSeparatorHeight, 0, 0, 0)
        } else {
            return .zero
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlertCell.gkNameOfClass, for: indexPath) as! AlertCell
        
        let action = actions[indexPath.item]
        let props = self.props
        var font: UIFont
        var textColor: UIColor
        
        if action.enable {
            var isCancel = false
            if style == .alert && cancelTitle != nil {
                isCancel = (indexPath.item == 0 && actions.count <= 2) || (indexPath.item == actions.count - 1 && actions.count >= 3)
            }

            if isCancel {
                textColor = action.textColor ?? props.cancelButtonTextColor
                font = action.font ?? props.cancelButtonFont
            }else if indexPath.item == destructiveButtonIndex {
                textColor = action.textColor ?? props.destructiveButtonTextColor
                font = action.font ?? props.destructiveButtonFont
            }else{
                textColor = action.textColor ?? props.buttonTextColor
                font = action.font ?? props.butttonFont
            }
        }else{
            textColor = props.disableButtonTextColor
            font = props.disableButtonFont
        }
        
        cell.button.setTitleColor(textColor, for: .normal)
        cell.button.setImage(action.icon, for: .normal)
        cell.button.setTitle(action.title, for: .normal)
        cell.button.imagePadding = action.spacing
        cell.button.imagePosition = action.imagePosition
        cell.button.titleLabel?.font = font
        cell.selectedBackgroundView?.backgroundColor = props.highlightedBackgroundColor
        
        if indexPath.item == destructiveButtonIndex && props.destructiveButtonBackgroundColor != nil {
            cell.backgroundColor = props.destructiveButtonBackgroundColor
        }else{
            cell.backgroundColor = props.mainColor
        }

        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let action = actions[indexPath.item]
        if action.enable {
            if dismissWhenSelectButton {
                dialogDismissCompletion = {
                    self.selectCallback?(indexPath.item)
                }
                dismiss()
            }else{
                self.selectCallback?(indexPath.item)
            }
        }
    }

    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return actions[indexPath.item].enable
    }
}

public extension AlertController {
    
    ///弹窗样式
    enum Style {
        
        ///UIActionSheet 样式
        case actionSheet
        
        ///UIAlertView 样式
        case alert
    }
    
    ///显示弹窗
    func show() {
        showAsDialog()
    }
    
    ///隐藏弹窗
    func dismiss() {
        dismissDialog()
    }
}
