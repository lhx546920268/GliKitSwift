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
public class AlertController: BaseViewController, UIGestureRecognizerDelegate {
    
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
    public var selectionHandler: ((_ index: Int) -> Void)?
        
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
        
        assert(title == nil || title is String || title is NSAttributedString, "\(NSStringFromClass(self.classForCoder)) title 必须为 nil 或者 NSString 或者 NSAttributedString");
        assert(message == nil || message is String || message is NSAttributedString, "\(NSStringFromClass(self.classForCoder)) message 必须为 nil 或者 NSString 或者 NSAttributedString");
        
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
            
            if actions.count == 0 && self.cancelTitle == nil {
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
        
        self.dialogShouldUseNewWindow = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, use designed init instead")
    }
    
    ///更新某个按钮 不包含actionSheet 的取消按钮
    public func reloadButton(for index: Int) {
        
    }

    ///通过下标回去按钮标题
    public func buttonTitle(for index: Int) -> String? {
        
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
        
        if isViewDidLayoutSubviews {
            let props = self.props
            let width = alertViewWidth
            let margin = (self.view.gkWidth - width) / 2
            
            let container = self.container!
            container.backgroundColor = props.mainColor
            container.layer.cornerRadius = props.cornerRadius
            container.layer.masksToBounds = true
            
            if alertTitle != nil || message != nil || icon != nil {
                let header = AlertHeader(frame: CGRect(0, 0, width, 0))
                let constraintWidth = header.gkWidth - props.textInsets.width
                
                var y = props.textInsets.top
                if icon != nil {
                    header.imageView.image = icon
                    if icon!.size.width > constraintWidth {
                        let size = icon!.
                    }
                }
            }
        }
    }
    - (void)viewDidLayoutSubviews
    {
        if(!self.isViewDidLayoutSubviews){
            
            GKAlertProps *props = self.props;
            CGFloat width = [self alertViewWidth];
            CGFloat margin = (self.view.gkWidth - width) / 2.0;
            
            self.container.backgroundColor = [UIColor redColor];
            self.container.layer.cornerRadius = props.cornerRadius;
            self.container.layer.masksToBounds = YES;
            
            
            if(self.alertTitle || self.message || self.icon){
                self.header = [[GKAlertHeader alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
                CGFloat constraintWidth = self.header.gkWidth - props.textInsets.left - props.textInsets.right;
                
                CGFloat y = props.textInsets.top;
                if(self.icon){
                    self.header.imageView.image = self.icon;
                    if(self.icon.size.width > constraintWidth){
                        CGSize size = [self.icon gkFitWithSize:CGSizeMake(constraintWidth, 0) type:GKImageFitTypeWidth];
                        self.header.imageView.frame = CGRectMake((self.header.gkWidth - size.width) / 2, y, size.width, size.height);
                    }else{
                        self.header.imageView.frame = CGRectMake((self.header.gkWidth - self.icon.size.width) / 2, y, self.icon.size.width, self.icon.size.height);
                    }
                    y += self.header.imageView.gkHeight;
                }
                
                if(self.alertTitle){
                    if(self.icon){
                        y += props.verticalSpacing;
                    }
                    self.header.titleLabel.font = props.titleFont;
                    self.header.titleLabel.textColor = props.titleTextColor;
                    self.header.titleLabel.textAlignment = props.titleTextAlignment;
                    
                    CGSize size = CGSizeZero;
                    if([self.alertTitle isKindOfClass:[NSString class]]){
                        self.header.titleLabel.text = self.alertTitle;
                        size = [self.alertTitle gkStringSizeWithFont:props.titleFont contraintWith:constraintWidth];
                    }else if([self.alertTitle isKindOfClass:[NSAttributedString class]]){
                        self.header.titleLabel.attributedText = self.alertTitle;
                        size = [self.alertTitle gkBoundsWithConstraintWidth:constraintWidth];
                    }
                    
                    self.header.titleLabel.frame = CGRectMake(props.textInsets.left, y, constraintWidth, size.height);
                    y += self.header.titleLabel.gkHeight;
                }
                
                if(self.message){
                    if(self.icon || self.alertTitle){
                        y += props.verticalSpacing;
                    }
                    self.header.messageLabel.font = props.messageFont;
                    self.header.messageLabel.textColor = props.messageTextColor;
                    self.header.messageLabel.textAlignment = props.messageTextAlignment;
                    
                    CGSize size = CGSizeZero;
                    if([self.message isKindOfClass:[NSString class]]){
                        self.header.messageLabel.text = self.message;
                        size = [self.message gkStringSizeWithFont:props.messageFont contraintWith:constraintWidth];
                    }else if ([self.message isKindOfClass:[NSAttributedString class]]){
                        self.header.messageLabel.attributedText = self.message;
                        size = [self.message gkBoundsWithConstraintWidth:constraintWidth];
                    }
                    self.header.messageLabel.frame = CGRectMake(props.textInsets.left, y, constraintWidth, size.height);
                    y += self.header.messageLabel.gkHeight;
                }
                
                self.header.gkHeight = y + props.textInsets.bottom;
                
                //小于最低高度
                if(self.header.gkHeight < props.contentMinHeight){
                    CGFloat rest = (props.contentMinHeight - self.header.gkHeight) / 2.0;
                    CGFloat y = props.textInsets.top + rest;
                    if(self.icon){
                        self.header.imageView.gkTop = y;
                        y += self.header.imageView.gkHeight;
                    }
                    
                    if(self.alertTitle){
                        if(self.icon){
                            y += props.verticalSpacing;
                        }
                        self.header.titleLabel.gkTop = y;
                        y += self.header.titleLabel.gkHeight;
                    }
                    
                    if(self.message){
                        if(self.icon || self.alertTitle){
                            y += props.verticalSpacing;
                        }
                        self.header.messageLabel.gkTop = y;
                        y += self.header.messageLabel.gkHeight;
                    }
                    self.header.gkHeight = y + props.textInsets.bottom + rest;
                }
                self.header.contentSize = CGSizeMake(self.header.gkWidth, self.header.gkHeight);
                
                self.header.backgroundColor = props.mainColor;
                [self.container addSubview:self.header];
            }
            
            switch (_style){
                case GKAlertControllerStyleAlert : {
                    self.container.frame = CGRectMake(margin, margin, width, 0);
                }
                    break;
                case GKAlertControllerStyleActionSheet : {
                    
                    self.container.frame = CGRectMake(props.contentInsets.left, margin, width, 0);
                    
                    if(![NSString isEmpty:self.cancelTitle]){
                        self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(margin, margin, width, props.buttonHeight)];
                        self.cancelButton.layer.cornerRadius = props.cornerRadius;
                        [self.cancelButton gkSetBackgroundColor:props.mainColor forState:UIControlStateNormal];
                        [self.cancelButton setTitle:self.cancelTitle forState:UIControlStateNormal];
                        [self.cancelButton setTitleColor:props.cancelButtonTextColor forState:UIControlStateNormal];
                        self.cancelButton.titleLabel.font = props.cancelButtonFont;
                        [self.cancelButton gkSetBackgroundColor:props.highlightedBackgroundColor forState:UIControlStateHighlighted];
                        [self.cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
                        
                        //取消按钮和 内容视图的间隔
                        if(props.spacingBackgroundColor && props.cancelButtonVerticalSpacing > 0){
                            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -props.cancelButtonVerticalSpacing, self.cancelButton.gkWidth, props.cancelButtonVerticalSpacing)];
                            view.backgroundColor = props.spacingBackgroundColor;
                            [self.cancelButton addSubview:view];
                            self.cancelButton.clipsToBounds = NO;
                        }
                        
                        [self.view addSubview:self.cancelButton];
                    }
                }
                    break;
            }
            
            if(self.actions.count > 0){
                self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.header.gkBottom, width, 0)collectionViewLayout:[self layout]];
                self.collectionView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
                [self.collectionView registerClass:[GKAlertCell class] forCellWithReuseIdentifier:@"GKAlertCell"];
                self.collectionView.dataSource = self;
                self.collectionView.delegate = self;
                self.collectionView.bounces = NO;
                self.collectionView.showsHorizontalScrollIndicator = NO;
                [self.container addSubview:self.collectionView];
            }
            
            [self layoutSubViews];
        }
        [super viewDidLayoutSubviews];
    }

   

    ///collectionView布局方式
    - (UICollectionViewFlowLayout*)layout
    {
        GKAlertProps *style = self.props;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = UIApplication.gkSeparatorHeight;
        layout.minimumLineSpacing = UIApplication.gkSeparatorHeight;
        
        switch (_style){
            case GKAlertControllerStyleActionSheet : {
                layout.itemSize = CGSizeMake([self alertViewWidth], style.buttonHeight);
            }
                break;
            case GKAlertControllerStyleAlert : {
                layout.itemSize = CGSizeMake(self.actions.count == 2 ? ([self alertViewWidth] - UIApplication.gkSeparatorHeight) / 2.0 : [self alertViewWidth], style.buttonHeight);
                layout.scrollDirection = self.actions.count >= 3 ? UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
            }
                break;
        }
        
        return layout;
    }

    ///布局子视图
    - (void)layoutSubViews
    {
        GKAlertProps *props = self.props;
        
        ///头部高度
        CGFloat headerHeight = 0;
        if(self.header){
            headerHeight = self.header.gkHeight;
        }
        
        ///按钮高度
        CGFloat buttonHeight = 0;
        
        if(self.actions.count > 0){
            switch (_style){
                case GKAlertControllerStyleAlert : {
                    buttonHeight = self.actions.count < 3 ? props.buttonHeight : self.actions.count * (UIApplication.gkSeparatorHeight + props.buttonHeight);
                    if(headerHeight > 0){
                        buttonHeight += 0.1;
                    }
                }
                    break;
                case GKAlertControllerStyleActionSheet : {
                    buttonHeight = self.actions.count * props.buttonHeight + (self.actions.count - 1) * UIApplication.gkSeparatorHeight;
                    
                    if(headerHeight > 0){
                        buttonHeight += UIApplication.gkSeparatorHeight;
                    }
                }
                    break;
            }
        }
        
        
        ///取消按钮高度
        CGFloat cancelHeight = self.cancelButton ? (self.cancelButton.gkHeight + props.contentInsets.bottom) : 0;
        
        CGFloat maxContentHeight = self.view.gkHeight - props.contentInsets.top - props.contentInsets.bottom - cancelHeight;
        
        CGRect frame = self.collectionView.frame;
        if(headerHeight + buttonHeight > maxContentHeight){
            CGFloat contentHeight = maxContentHeight;
            if(headerHeight >= contentHeight / 2.0 && buttonHeight >= contentHeight / 2.0){
                self.header.gkHeight = contentHeight / 2.0;
                frame.size.height = buttonHeight;
            }else if (headerHeight >= contentHeight / 2.0 && buttonHeight < contentHeight / 2.0){
                self.header.gkHeight = contentHeight - buttonHeight;
                frame.size.height = buttonHeight;
            }else{
                self.header.gkHeight = headerHeight;
                frame.size.height = contentHeight - headerHeight;
            }
            
            frame.origin.y = self.header.gkBottom;
            self.collectionView.frame = frame;
            self.container.gkHeight = maxContentHeight;
        }else{
            
            frame.origin.y = self.header.gkBottom;
            frame.size.height = buttonHeight;
            self.collectionView.frame = frame;
            self.container.gkHeight = headerHeight + buttonHeight;
        }
        
        if(self.header.gkHeight > 0){
            self.collectionView.gkHeight += UIApplication.gkSeparatorHeight;
            self.container.gkHeight += UIApplication.gkSeparatorHeight;
        }
        
        switch (_style){
            case GKAlertControllerStyleActionSheet : {
                self.container.gkTop = self.view.gkHeight;
            }
                break;
            case GKAlertControllerStyleAlert : {
                self.container.gkTop = (self.view.gkHeight - self.container.gkHeight) / 2.0;
            }
                break;
        }
        
        self.cancelButton.gkTop = self.container.gkBottom + props.cancelButtonVerticalSpacing;
    }

    // MARK: - private method

    ///取消
    - (void)cancel:(id) sender
    {
        NSUInteger index = 0;
        if(_style == GKAlertControllerStyleActionSheet){
            index = self.actions.count;
        }
        
        void(^handler)(NSUInteger index) = self.selectionHandler;
        self.dialogDismissCompletionHandler = ^{
            !handler ?: handler(index);
        };
        [self dismiss];
    }

    - (void)didExecuteDialogShowCustomAnimate:(void (^)(BOOL))completion
    {
        switch (_style){
            case GKAlertControllerStyleAlert : {
                self.container.alpha = 0;
                [UIView animateWithDuration:0.25 animations:^(void){
                    
                    self.dialogBackgroundView.alpha = 1.0;
                    self.container.alpha = 1.0;
                    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                    animation.fromValue = [NSNumber numberWithFloat:1.3];
                    animation.toValue = [NSNumber numberWithFloat:1.0];
                    animation.duration = 0.25;
                    [self.container.layer addAnimation:animation forKey:@"scale"];
                }completion:completion];
            }
                break;
            case GKAlertControllerStyleActionSheet : {
                GKAlertProps *props = self.props;
                [UIView animateWithDuration:0.25 animations:^(void){
                    
                    CGFloat spacing = self.cancelButton ? props.cancelButtonVerticalSpacing : 0;
                    self.dialogBackgroundView.alpha = 1.0;
                    self.container.gkTop = self.view.gkHeight - self.container.gkHeight - props.contentInsets.bottom - self.cancelButton.gkHeight - spacing;
                    self.cancelButton.gkTop = self.container.gkBottom + props.cancelButtonVerticalSpacing;
                }completion:completion];
            }
                break;
        }
    }

    - (void)didExecuteDialogDismissCustomAnimate:(void (^)(BOOL))completion
    {
        switch (_style){
            case GKAlertControllerStyleActionSheet : {
                [UIView animateWithDuration:0.25 animations:^(void){
                    
                    self.dialogBackgroundView.alpha = 0;
                    self.container.gkTop = self.view.gkHeight;
                    GKAlertProps *props = self.props;
                    self.cancelButton.gkTop = self.container.gkBottom + props.cancelButtonVerticalSpacing;
                    
                }completion:completion];
            }
                break;
            case GKAlertControllerStyleAlert : {
                [UIView animateWithDuration:0.25 animations:^(void){
                    
                    self.dialogBackgroundView.alpha = 0;
                    self.container.alpha = 0;
                    
                }completion:completion];
            }
                break;
        }
    }

    // MARK: - public method

    - (void)reloadButtonForIndex:(NSUInteger) index
    {
        if(index < self.actions.count){
            [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:index inSection:0]]];
        }
    }

    - (NSString*)buttonTitleForIndex:(NSUInteger) index
    {
        if(index < self.actions.count){
            GKAlertAction *action = self.actions[index];
            return action.title;
        }
        
        if(self.style == GKAlertControllerStyleActionSheet && index == self.actions.count){
            return self.cancelTitle;
        }
        
        return nil;
    }

    // MARK: - UITapGestureRecognizer delegate

    - (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
    {
        CGPoint point = [gestureRecognizer locationInView:self.dialogBackgroundView];
        point.y += self.dialogBackgroundView.gkTop;
        if(CGRectContainsPoint(self.container.frame, point)){
            return NO;
        }
        
        return YES;
    }

    - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
    {
        return touch.view == self.dialogBackgroundView;
    }

    // MARK: - UICollectionView delegate

    - (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
    {
        return self.actions.count;
    }

    - (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
    {
        if(self.header.gkHeight > 0){
            return UIEdgeInsetsMake(UIApplication.gkSeparatorHeight, 0, 0, 0);
        }else{
            return UIEdgeInsetsZero;
        }
    }

    - (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
    {
        GKAlertCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GKAlertCell" forIndexPath:indexPath];
        
        GKAlertAction *action = [self.actions objectAtIndex:indexPath.item];
        GKAlertProps *props = self.props;
        UIFont *font;
        UIColor *textColor;
        
        if(action.enable){
            BOOL isCancel = NO;
            if(self.style == GKAlertControllerStyleAlert && self.cancelTitle){
                isCancel = (indexPath.item == 0 && self.actions.count < 3) || (indexPath.item == self.actions.count - 1 && self.actions.count >= 3);
            }
            
            if(isCancel){
                textColor = action.textColor ? action.textColor : props.cancelButtonTextColor;
                font = action.font ? action.font : props.cancelButtonFont;
            }else if(indexPath.item == _destructiveButtonIndex){
                textColor = action.textColor ? action.textColor : props.destructiveButtonTextColor;
                font = action.font ? action.font : props.destructiveButtonFont;
            }else{
                textColor = action.textColor ? action.textColor : props.buttonTextColor;
                font = action.font ? action.font : props.butttonFont;
            }
        }else{
            textColor = props.disableButtonTextColor;
            font = props.disableButtonFont;
        }
        
        [cell.button setTitleColor:textColor forState:UIControlStateNormal];
        cell.button.titleLabel.font = font;
        
        [cell.button setTitle:action.title forState:UIControlStateNormal];
        [cell.button setImage:action.icon forState:UIControlStateNormal];
        cell.button.imagePadding = action.spacing;
        cell.button.imagePosition = action.imagePosition;
        cell.selectedBackgroundView.backgroundColor = self.props.highlightedBackgroundColor;
        
        if(indexPath.item == _destructiveButtonIndex && props.destructiveButtonBackgroundColor){
            cell.backgroundColor = props.destructiveButtonBackgroundColor;
        }else{
            cell.backgroundColor = props.mainColor;
        }
        
        return cell;
    }

    - (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
    {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        
        GKAlertAction *action = [self.actions objectAtIndex:indexPath.item];
        if(action.enable){
            if(self.dismissWhenSelectButton){
                
                void(^handler)(NSUInteger index) = self.selectionHandler;
                self.dialogDismissCompletionHandler = ^{
                    !handler ?: handler(indexPath.item);
                };
                [self dismiss];
            }else{
                !self.selectionHandler ?: self.selectionHandler(indexPath.item);
            }
        }
    }

    - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
    {
        GKAlertAction *action = [self.actions objectAtIndex:indexPath.item];
        return action.enable;
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
