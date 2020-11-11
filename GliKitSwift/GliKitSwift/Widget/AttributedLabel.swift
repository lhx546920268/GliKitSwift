//
//  AttributedLabel.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/11/5.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///URL 正则表达式识别器
private let urlRegularExpression: NSRegularExpression = {
    let allCharacter = "[a-zA-Z0-9_.-~!@#$%^&*+?:/=]" //所有字符
    
    let scheme = "((http[s]?|ftp)://)?" //协议 可选
    let user = "(\(allCharacter)+@)?" //用户 密码
    let host = "([a-zA-Z0-9_-]+\\.)+[a-zA-Z]{2,6}" //主机
    let port = "(:\\d+)?" //端口
    let path = "(/\(allCharacter)+)*" //路径
    let parameterString = "(;\(allCharacter)+)*" //参数
    let query = "(\\?\(allCharacter)+)*" //查询参数
    
    let pattern = "\(scheme)\(user)\(host)\(port)\(path)\(parameterString)\(query)"
    do {
        return try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }catch{
        return NSRegularExpression()
    }
}()

///自定义label
open class AttributedLabel: UILabel {

///文本边距
    @NeedDisplayWrapper
    public var contentInsets: UIEdgeInsets = .zero

    ///是否可以长按选中
    public var selectable: Bool = false {
        didSet{
            if oldValue != selectable {
                if selectable && longPressGesture == nil {
                    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
                    longPress.minimumPressDuration = 0.3
                    addGestureRecognizer(longPress)
                    longPressGesture = longPress
                    isUserInteractionEnabled = true
                }
                
                longPressGesture?.isEnabled = selectable
                let name = UIMenuController.willHideMenuNotification
                if selectable {
                    NotificationCenter.default.addObserver(self, selector: #selector(handleWillHideMenuNotification(_:)), name: name, object: nil)
                } else {
                    NotificationCenter.default.removeObserver(self, name: name, object: nil)
                }
            }
        }
    }

///选中时背景颜色
    public var selectedBackgroundColor: UIColor = UIColor.gkThemeColor.gkColor(withAlpha: 0.5)

///显示的菜单按钮
    public var menuItems: [UIMenuItem] = [UIMenuItem(title: "复制", action: #selector(copy))]

///要显示的按钮
    public var canPerformActionInspector: ((_ action: Selector, _ sender: Any?) -> Bool)?

///是否识别链接
    public var shouldDetectURL: Bool = false {
        didSet{
            if oldValue != shouldDetectURL {
                if shouldDetectURL {
                    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
                    isUserInteractionEnabled = true
                } else {
                    clickableRanges.removeAll()
                }
            }
        }
    }

///URL和其他设置可点击的 样式
    public var clickableAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.systemBlue,
        .underlineStyle: true
    ]

///点击识别的字符串回调
    public var clickStringCallback: ((_ string: String) -> Void)?

///长按手势
    private var longPressGesture: UILongPressGestureRecognizer?

///可点击的位置
    private lazy var clickableRanges: [NSRange] = {
        []
    }()

///文字绘制区域
    private var textDrawRect: CGRect = .zero

///点击时高亮区域
    @NeedDisplayWrapper
    private var highlightedRects: [CGRect]?

    // MARK: - Insets

    open override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if size.width < 2777777 {
            size.width += contentInsets.width
        }
        
        if size.height < 2777777 {
            size.height += contentInsets.height
        }
        
        return size
    }
    
    open override func drawText(in rect: CGRect) {
        let drawRect = rect.inset(by: contentInsets)
        textDrawRect = drawRect
        super.drawText(in: drawRect)
    }

    // MARK: - Select

    deinit {
        self.classForCoder.cancelPreviousPerformRequests(withTarget: self)
        NotificationCenter.default.removeObserver(self)
    }

    open override func draw(_ rect: CGRect) {
        if let rects = highlightedRects, rects.count > 0 {
            //绘制高亮状态
            if let context = UIGraphicsGetCurrentContext() {
                context.saveGState()
                context.setFillColor(selectedBackgroundColor.cgColor)
                for rect in rects {
                    context.addRect(rect)
                }
                context.fillPath()
                context.restoreGState()
            }
        }
        super.draw(rect)
    }
    
    // MARK: - 通知

    ///菜单按钮将要消失
    @objc private func handleWillHideMenuNotification(_ notification: Notification){
        highlightedRects = nil
    }

    // MARK: - action

    ///长按
    @objc private func handleLongPress(_ longPress: UILongPressGestureRecognizer){
        if longPress.state == .began {
            showMenuItems()
        }
    }
    
    open override func copy(_ sender: Any?) {
        if !String.isEmpty(text) {
            UIPasteboard.general.string = text
            gkCurrentViewController.gkShowSuccessText("复制成功")
        }
    }

    ///显示items
    private func showMenuItems() {
        //计算高亮区域
        let highlightedRect = self.textDrawRect
        highlightedRects = [highlightedRect]
        
        //显示菜单
        becomeFirstResponder()
        let controller = UIMenuController.shared
        controller.menuItems = menuItems
        
        if #available(iOS 13, *) {
            controller.showMenu(from: self, rect: highlightedRect)
        } else {
            controller.setTargetRect(highlightedRect, in: self)
            controller.setMenuVisible(true, animated: true)
        }
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if canPerformActionInspector != nil {
            return canPerformActionInspector!(action, sender)
        }
        
        //只显示自己的
        return action == #selector(copy(_:))
    }
    
    open override var canBecomeFirstResponder: Bool {
        true
    }

    // MARK: - Text

    open override var text: String? {
        set{
            let result = handleTextChange(newValue)
            if let str = result as? String {
                super.text = str
            } else {
                super.attributedText = result as? NSAttributedString
            }
        }
        get{
            super.text
        }
    }
    
    open override var attributedText: NSAttributedString? {
        set{
            super.attributedText = handleTextChange(newValue) as? NSAttributedString
        }
        get{
            super.attributedText
        }
    }

    ///文字改变
    private func handleTextChange(_ text: Any?) -> Any?{
        return detectURL(for: text)
    }

    // MARK: - URL Detect

    ///识别链接
    private func detectURL(for text: Any?) -> Any? {
        if shouldDetectURL {
            clickableRanges.removeAll()
            
            var str = text as? String
            if text is NSAttributedString {
                str = (text as? NSAttributedString)?.string
            }
        
            if !String.isEmpty(str){
                let results = urlRegularExpression.matches(in: str!, options: [], range: NSRange(location: 0, length: str!.count))
                if results.count > 0 {
                    var attr: NSMutableAttributedString
                    if text is NSAttributedString {
                        attr = NSMutableAttributedString(attributedString: text as! NSAttributedString)
                    } else {
                        attr = NSMutableAttributedString(string: text as! String)
                        let range = NSRange(location: 0, length: attr.length)
                        attr.addAttribute(.font, value: font ?? .systemFont(ofSize: 17), range: range)
                        attr.addAttribute(.foregroundColor, value: textColor ?? .black, range: range)
                    }
                    for result in results {
                        clickableRanges.append(result.range)
                        attr.addAttributes(clickableAttributes, range: result.range)
                    }
                    return attr
                }
            }
        }
        return text
    }

    // MARK: - Clickable
    
    /**
     *添加可点击的位置，重新设置text会忽略以前添加的
     
     *@param range 可点击的位置，如果该范围不在text中，则忽略
     */
        public func addClickableRange(_ range: NSRange) {
            if let text = self.text, range.max < text.count {
                clickableRanges.append(range)
            }
        }

    ///处理点击
    @objc private func handleTap(_ tap: UITapGestureRecognizer) {
        self.classForCoder.cancelPreviousPerformRequests(withTarget: self, selector: #selector(removeHighlightedRects), object: nil)
        
        if let text = self.text {
            let point = tap.location(in: self)
            let range = clickableString(at: point)
            
            if range.location != NSNotFound {
                clickStringCallback?(text.substring(in: range))
                perform(#selector(removeHighlightedRects), with: nil, afterDelay: 0.3)
            }
        }
    }

    ///获取点中的字符串
    private func clickableString(at point: CGPoint) -> NSRange {
        
        var range = NSMakeRange(NSNotFound, 0)
        if !String.isEmpty(self.text), let attr = self.attributedText as CFAttributedString?, textDrawRect.contains(point) {
            
            //转换成coreText 坐标
            let _point = CGPoint(point.x, textDrawRect.height - point.y)
            
            let path = CGMutablePath()
            path.addRect(textDrawRect)
            
            let frameSetter = CTFramesetterCreateWithAttributedString(attr)
            let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, CFAttributedStringGetLength(attr)), path, nil)
            
            let lines = CTFrameGetLines(frame)
            let numberOfLines = CFArrayGetCount(lines)
            
            if numberOfLines > 0 {
                //行起点
                var lineOrigins: [CGPoint] = []
                CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), &lineOrigins)
                
                //获取点击的行的位置，数组是倒序的
                var lineIndex: CFIndex = 0
                for i in 0 ..< numberOfLines {
                    lineIndex = i
                    let lineOrigin = lineOrigins[lineIndex]
                    if let line = CFArrayGetValueAtIndex(lines, i)?.assumingMemoryBound(to: CTLine.self).pointee {
                        
                        var lineDescent: CGFloat = 0
                        CTLineGetTypographicBounds(line, nil, &lineDescent, nil)
                        if lineOrigin.y - lineDescent - contentInsets.top < _point.y {
                            break
                        }
                    } else {
                        break
                    }
                }
                
                if lineIndex < numberOfLines {
                    //获取行信息
                    let lineOrigin = lineOrigins[lineIndex]
                    if let line = CFArrayGetValueAtIndex(lines, lineIndex)?.assumingMemoryBound(to: CTLine.self).pointee {
                        
                        //把坐标转成行对应的坐标
                        let position = CGPoint(_point.x - lineOrigin.x - contentInsets.left, _point.y - lineOrigin.y)
                     
                        //获取该点的字符位置，返回下一个输入的位置，比如点击的文字下标是0时，返回1
                        var index = CTLineGetStringIndexForPosition(line, position)
                        
                        //检测字符位置是否超出该行字符的范围，有时候行的末尾不够现实一个字符了，点击该空旷位置时无效
                        let stringRange = CTLineGetStringRange(line)
                        
                        //获取整段文字中charIndex位置的字符相对line的原点的x值
                        let offset = CTLineGetOffsetForStringIndex(line, index, nil)
                        
                        if position.x <= offset {
                            index -= 1
                        }
                        
                        if index < stringRange.max {
                            //获取对应的可点信息
                            for _range in clickableRanges {
                                if index >= _range.location && index < _range.max {
                                    range = _range
                                    break
                                }
                            }
                        }
                    }
                }
                
                detectHighlightedRects(for: range, frame: frame)
            }
        }
        
        return range
    }

    //获取高亮区域
    private func detectHighlightedRects(for range: NSRange, frame: CTFrame) {
        
        if range.location != NSNotFound {
            var rects: [CGRect] = []
            let lines = CTFrameGetLines(frame)
            
            let count = CFArrayGetCount(lines)
            var lineOrigins: [CGPoint] = []
            CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), &lineOrigins)
            
            for i in 0 ..< count {
                if let line = CFArrayGetValueAtIndex(lines, i)?.assumingMemoryBound(to: CTLine.self).pointee {
                    let lineRange = CTLineGetStringRange(line)
                    let start = lineRange.location == kCFNotFound ? NSNotFound : lineRange.location
                    let innerRange = innerRangeBetween(range, and: NSMakeRange(start, lineRange.length))
                    
                    if innerRange.isValid && lineRange.length > 0 {
                        var lineAscent: CGFloat = 0
                        var lineDescent: CGFloat = 0
                        var lineLeading: CGFloat = 0
                        
                        //获取文字排版
                        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading)
                        let startX = CTLineGetOffsetForStringIndex(line, innerRange.location, nil)
                        let endX = CTLineGetOffsetForStringIndex(line, innerRange.max, nil)
                        
                        let lineOrigin = lineOrigins[i]
                        var rect = CGRect(
                            lineOrigin.x + startX + contentInsets.left,
                            lineOrigin.y - lineDescent + contentInsets.top,
                            endX - startX,
                            lineAscent + lineDescent + lineLeading)
                        
                        //转成UIKit坐标
                        rect.origin.y = textDrawRect.height - rect.maxY
                        rects.append(rect)
                    } else if lineRange.location > range.max {
                        break
                    }
                }
            }
            highlightedRects = rects
        } else {
            highlightedRects = nil
        }
    }

    ///获取内部的range
    private func innerRangeBetween(_ one: NSRange, and second: NSRange) -> NSRange {
        
        var _one = one
        var _second = second
        var range = NSMakeRange(NSNotFound, 0)
        
        //交换
        if _one.location > _second.location {
            swap(&_one, &_second)
        }
        
        if _second.location < _one.max {
            range.location = _second.location
            let end: Int = min(_one.max, _second.max)
            range.length = end - range.location
        }
        
        return range
        
    }

    ///取消高亮
    @objc private func removeHighlightedRects(){
        highlightedRects = nil
    }
}
