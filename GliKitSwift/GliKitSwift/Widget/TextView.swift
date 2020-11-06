//
//  TextView.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/11/5.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

/// UITextView的子类，支持像UITextField那样的placeholder.
open class TextView: UITextView {

///当文本框中没有内容时，显示placeholder
    @NeedDisplayWrapper
    public var placeholder: String?

///placeholder 的字体颜色
    @NeedDisplayWrapper
    public var placeholderTextColor: UIColor = .gkPlaceholderColor

///placeholder的字体 默认和 输入框字体一样
    private var _placeholderFont: UIFont?
    public var placeholderFont: UIFont {
        set{
            _placeholderFont = newValue
            updatePlaceholder()
        }
        get{
            _placeholderFont ?? font ?? UIFont.systemFont(ofSize: 14)
        }
    }

///placeholder画的起始位置
    @NeedDisplayWrapper
    public var placeholderOffset: CGPoint = CGPoint(8, 8)

///最大输入数量
    @NeedDisplayWrapper
    public var maxLength: UInt = .max

///是否需要显示 当前输入数量和 最大输入数量 当 maxLength = max 时，不显示
    public var shouldDisplayTextLength: Bool = false

///输入限制文字 属性
    public var textLengthAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 13),
        .foregroundColor: UIColor.lightGray
    ] {
        didSet{
            updatePlaceholder()
        }
    }

    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        initParams()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initParams()
    }
    
    func initParams(){
        textContainerInset = UIEdgeInsets(8, 5, 8, 5)
        NotificationCenter.default.addObserver(self, selector: #selector(gkTextDidChange(_:)), name: UITextView.textDidChangeNotification, object: self)
        
        font = .systemFont(ofSize: 14)
        if #available(iOS 11, *) {
            pasteDelegate = self
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: self)
    }

    // MARK: - property
    
    open override var text: String! {
        didSet{
            updatePlaceholder()
        }
    }
    
    open override var font: UIFont? {
        didSet{
            updatePlaceholder()
        }
    }

    // MARK: - draw

    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let width = rect.width
        let height = rect.height
        
        //绘制placeholder
        if !String.isEmpty(placeholder), text.count == 0, let placeholder = self.placeholder as NSString? {
            let attrs: [NSAttributedString.Key: Any] = [.font: placeholderFont, .foregroundColor: placeholderTextColor]
            let rect = CGRect(placeholderOffset.x, placeholderOffset.y, width - placeholderOffset.x * 2, height - placeholderOffset.y * 2);
            placeholder.draw(in: rect, withAttributes: attrs)
        }
        
        //绘制输入的文字数量和限制
        if shouldDisplayTextLength && maxLength != .max {
            let padding: CGFloat = 8
            let text = textByRemoveMarkedRange()
            let string = "\(text.count)/\(maxLength)" as NSString
            
            let size = string.size(withAttributes: textLengthAttributes)
            let rect = CGRect(width - size.width - padding, height - size.height - padding, size.width, size.height)
            string.draw(in: rect, withAttributes: textLengthAttributes)
        }
    }

    ///获取去除markedText的 text
    private func textByRemoveMarkedRange() -> String {
        if let range = markedTextRange {
            let location = offset(from: beginningOfDocument, to: range.start)
            let length = offset(from: range.start, to: range.end)
            
            return text.replaceString(in: NSRange(location: location, length: length), with: "")
        }
        return text
    }

    // MARK: - private method

    ///更新placeholder
    private func updatePlaceholder() {
        setNeedsDisplay()
    }

    ///文字输入改变
    @objc private func gkTextDidChange(_ notification: Notification) {
        updatePlaceholder()
        
        //有输入法情况下忽略
        if markedTextRange == nil,
           maxLength != .max,
           var text = self.text,
           text.count > maxLength {
            
            let maxLength: Int = self.maxLength.intValue
            
            //删除超过长度的字符串
            let length = text.count - maxLength
            var range = selectedRange
            
            let location = range.location >= length ? range.location - length : 0
            range.location = location
            text = text.replaceString(in: NSRange(location: location, length: length), with: "")
            self.text = text
            if range.location < text.count {
                selectedRange = range
            }
        }
    }
}

@available(iOS 11.0, *)
extension TextView: UITextPasteDelegate {
    
    public func textPasteConfigurationSupporting(_ textPasteConfigurationSupporting: UITextPasteConfigurationSupporting, shouldAnimatePasteOf attributedString: NSAttributedString, to textRange: UITextRange) -> Bool {
        return false
    }
}
