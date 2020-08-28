//
//  AlertProps.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/8/27.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///弹窗属性
public class AlertProps: NSObject, NSCopying, Copyable {
    
    // MARK: - 通用

    ///主题颜色
    public var mainColor: UIColor = .white

    ///整个内容边距
    public var contentInsets: UIEdgeInsets = .all(15)

    ///提示框内容（除了按钮）最低高度
    public var contentMinHeight: CGFloat = 0

    ///圆角
    public var cornerRadius: CGFloat = 8

    ///文字和图标和父视图的间距
    public var textInsets: UIEdgeInsets = .all(15)

    ///内容垂直间距
    public var verticalSpacing: CGFloat = 8

    ///actionSheet 取消按钮和 内容视图的背景颜色
    public var spacingBackgroundColor: UIColor?

    // MARK: - 取消按钮

    ///actionSheet 取消按钮和 内容视图的间距
    public var cancelButtonVerticalSpacing: CGFloat = 18

    ///取消按钮字体
    public var cancelButtonFont: UIFont = .boldSystemFont(ofSize: 17)

    ///取消按钮字体颜色
    public var cancelButtonTextColor: UIColor = .systemBlue

    //MARK: - 标题

    ///标题字体
    public var titleFont: UIFont = .boldSystemFont(ofSize: 17)

    ///标题字体颜色
    public var titleTextColor: UIColor = .black

    ///标题对其方式
    public var titleTextAlignment: NSTextAlignment = .center

    //MARK: - 信息

    ///信息字体
    public var messageFont: UIFont = .systemFont(ofSize: 13)

    ///信息字体颜色
    public var messageTextColor: UIColor = .black

    ///信息对其方式
    public var messageTextAlignment: NSTextAlignment = .center

    // MARK: - 按钮

    ///按钮高度
    public var buttonHeight: CGFloat = 45

    ///按钮字体
    public var butttonFont: UIFont = .systemFont(ofSize: 17)

    ///高亮背景
    public var highlightedBackgroundColor: UIColor = .gkHighlightedBackgroundColor

    ///按钮无法点击时的字体颜色
    public var disableButtonTextColor: UIColor = .gray

    ///按钮无法点击时的字体
    public var disableButtonFont: UIFont = .systemFont(ofSize: 17)

    //MARK: - 警示

    ///按钮字体颜色
    public var buttonTextColor: UIColor = .systemBlue

    ///警示按钮字体
    public var destructiveButtonFont: UIFont = .systemFont(ofSize: 17)

    ///警示按钮字体颜色
    public var destructiveButtonTextColor: UIColor = .red

    ///警示按钮背景颜色
    public var destructiveButtonBackgroundColor: UIColor?

    //MARK: - Init

    ///默认的alert属性
    public class var defaultAlertProps: AlertProps {
        return _defaultAlertProps
    }
    private static var _defaultAlertProps: AlertProps = {
        let props = AlertProps()
        props.buttonHeight = 45
        return props
    }()

    ///默认的actionSheet属性
    public class var defaultactionSheetProps: AlertProps {
        return _defaultactionSheetProps
    }
    private static var _defaultactionSheetProps: AlertProps = {
       let props = AlertProps()
        props.buttonHeight = 50
        return props
    }()
    
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return gkCopy()
    }
}
