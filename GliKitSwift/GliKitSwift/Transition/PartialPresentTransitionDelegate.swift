//
//  PartialPresentTransitionDelegate.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/1/22.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///动画方式
public enum PartialPresentTransitionStyle {
    
    ///从底部进入
    case fromBottom
    
    ///从顶部进入
    case fromTop
    
    ///从左边进入
    case fromLeft
    
    ///从右边进入
    case fromRight
}

///
open class PartialPresentProps{
    
    ///部分显示大小
    public var contentSize = CGSize.zero

    ///部分显示区域 默认通过 contentSize 和动画样式计算
    private var _frame = CGRect.zero
    public var frame: CGRect{
        set{
            _frame = newValue
        }
        get{
            if _frame.size.width > 0 && _frame.size.height > 0 {
                return _frame
            }
            
            //弹窗大小位置
            var size = contentSize
            let parentSize = UIScreen.gkSize
            switch (transitionStyle) {
            case .fromTop :
                if frameUseSafeArea, let window = UIApplication.shared.gkKeyWindow {
                    size.height += window.gkSafeAreaInsets.top
                }
                return CGRect(x: (parentSize.width - size.width) / 2.0, y: 0, width: size.width, height: size.height)
                
            case .fromLeft :
                if frameUseSafeArea, let window = UIApplication.shared.gkKeyWindow {
                    size.width += window.gkSafeAreaInsets.left
                }
                return CGRect(x: size.width, y: (parentSize.height - size.height) / 2.0, width: size.width, height: size.height)
                
            case .fromBottom :
                if frameUseSafeArea, let window = UIApplication.shared.gkKeyWindow {
                    size.height += window.gkSafeAreaInsets.bottom
                }
                return CGRect(x: (parentSize.width - size.width) / 2.0, y: parentSize.height - size.height, width: size.width, height: size.height)
                
            case .fromRight :
                if self.frameUseSafeArea, let window = UIApplication.shared.gkKeyWindow {
                    size.width += window.gkSafeAreaInsets.right
                }
                return CGRect(x: parentSize.width - size.width, y: (parentSize.height - size.height) / 2.0, width: size.width, height: size.height)
            }
        }
    }

    ///是否需要自动加上安全区域
    public var frameUseSafeArea = true

    ///圆角
    public var cornerRadius: CGFloat = 0

    ///圆角位置 默认是左上角和右上角
    public var corners: UIRectCorner = [.topLeft, .topRight]

    ///样式
    public var transitionStyle: PartialPresentTransitionStyle = .fromBottom

    ///背景颜色
    public var backgroundColor = UIColor(white: 0, alpha: 0.5)
    
    ///是否可以滑动关闭 default is 'YES'
    public var interactiveDismissible: Bool = true

    ///点击背景是否会关闭当前显示的viewController
    public var cancelable: Bool = true

    ///动画时间
    public var transitionDuration: TimeInterval = 0.5

    ///点击半透明背景回调 设置这个时，弹窗不会关闭
    public var cancelCallback: (() -> Void)?

    ///消失时的回调
    public var dismissCallback: (() -> Void)?
}

/*
 ViewController 部分显示
 
 使用方法
 
 UIViewController *vc = [UIViewController new];
 vc.navigationItem.title = sender.currentTitle;
 vc.view.backgroundColor = UIColor.whiteColor;
 
 UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
 nav.partialContentSize = CGSizeMake(UIScreen.gkScreenWidth, 400);
 [nav partialPresentFromBottom];
 */
open class PartialPresentTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    ///部分显示属性
    public var props: PartialPresentProps!
    
    ///关联的scrollView GKPresentTransitionStyleFromBottom 有效，可以让滑动列表到顶部时触发手势交互的dismiss
    public weak var scrollView: UIScrollView? {
        didSet{
            if oldValue != scrollView {
                oldValue?.panGestureRecognizer.removeTarget(self, action: #selector(handlePan(_:)))
                scrollView?.panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
            }
        }
    }
    
    ///动画
    private lazy var animator: UIViewControllerAnimatedTransitioning = {
       
        return PartialPresentTransitionAnimator(props: self.props)
    }()
    
    ///不要 strong，因为该类会strong viewController，而viewController会strong当前类
    fileprivate weak var controller: PartialPresentationController?
    
    ///显示的viewController
    private weak var viewController: UIViewController?

    ///是否是直接dismiss
    private var dismissDirectly: Bool = false

    ///当前手势
    private weak var activedPanGestureRecognizer: UIPanGestureRecognizer?

    ///是否正在交互中
    private var interacting: Bool = false
    
    public init(props: PartialPresentProps) {
        self.props = props
        super.init()
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        dismissDirectly = true
        return animator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animator
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if !dismissDirectly {
            dismissDirectly = true
            return PartialPresentInteractiveTransition(delegate: self, panGestureRecognizer: activedPanGestureRecognizer!)
        }
        
        return nil
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        let controller = PartialPresentationController(presentedViewController: presented, presenting: presenting)
        controller.transitionDelegate = self
        self.controller = controller
        
        return controller
    }

    ///显示一个 视图
    public func show(_ viewController: UIViewController, completion: (() -> Void)? = nil){
        
        if viewController.presentingViewController != nil {
            return
        }

        viewController.modalPresentationStyle = .custom
        viewController.gkTransitioningDelegate = self
        self.viewController = viewController
        
        if let rootViewController = UIApplication.shared.delegate?.window??.rootViewController {
            
            if props.interactiveDismissible {
                viewController.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
                if props.transitionStyle == .fromBottom {
                    var vc = viewController
                    if viewController is UINavigationController {
                        let nav = viewController as! UINavigationController
                        vc = nav.viewControllers.first!
                    }
                    
                    if vc is ScrollViewController {
                        let scrollViewController = vc as! ScrollViewController
                        scrollView = scrollViewController.scrollView
                        
                        scrollViewController.scrollViewDidChange = { [weak self] (scrollView) in
                            self?.scrollView = scrollView
                        }
                    }
                }
            }
            
            rootViewController.gkTopestPresentedViewController.present(viewController, animated: true, completion: completion)
        }
    }
    
    ///平移手势
    @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began :
            if let scrollView = self.scrollView, pan == scrollView.panGestureRecognizer {
                if scrollView.contentOffset.y <= 0 {
                    scrollView.contentOffset = .zero
                    startInteractiveTransition(pan)
                }
            } else {
                startInteractiveTransition(pan)
            }
            
        case .changed :
            if !interacting, let scrollView = self.scrollView, pan == scrollView.panGestureRecognizer {
                if scrollView.contentOffset.y <= 0 {
                    scrollView.contentOffset = .zero
                    startInteractiveTransition(pan)
                }
            }
            
        default:
            interacting = false
        }
    }

    ///开始交互动画
    private func startInteractiveTransition(_ pan: UIPanGestureRecognizer) {
        interacting = true
        UIApplication.shared.gkKeyWindow?.endEditing(true)
        dismissDirectly = false
        activedPanGestureRecognizer = pan
        viewController?.dismiss(animated: true, completion: props.dismissCallback)
    }
}

///自定义Present类型的过度动画，用于用户滑动触发的过渡动画
class PartialPresentInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    ///关联的 PartialPresentTransitionDelegate
    public private(set) weak var delegate: PartialPresentTransitionDelegate?

    ///平滑手势
    public private(set) var panGestureRecognizer: UIPanGestureRecognizer!
    
    init(delegate: PartialPresentTransitionDelegate?, panGestureRecognizer: UIPanGestureRecognizer) {
        self.delegate = delegate
        self.panGestureRecognizer = panGestureRecognizer
        super.init()
        
        self.panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
    }
    
    deinit {
        self.panGestureRecognizer.removeTarget(self, action: #selector(handlePan(_:)))
    }
    
    // MARK: - super method
    
    private weak var transitionContext: UIViewControllerContextTransitioning?

    ///交互前的frame
    private var frame: CGRect?

    ///要交互的视图
    private weak var view: UIView?

    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        frame = delegate?.props.frame
        view = transitionContext.view(forKey: .from)
        super.startInteractiveTransition(transitionContext)
    }
    
    private func percentForTranslation(_ translation: CGPoint) -> CGFloat {
        
        var percent: CGFloat = 0
        if let view = self.view, let delegate = self.delegate {
            
            switch delegate.props.transitionStyle {
            case .fromTop :
                percent = translation.y / view.gkHeight
                
            case .fromBottom :
                percent = translation.y / view.gkHeight
                
            case .fromRight :
                percent = translation.x / view.gkWidth
                
            case .fromLeft :
                percent = translation.x / view.gkWidth
            }
        }
        return percent
    }

    ///平移手势
    @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
        
        if let view = self.view,
           let frame = self.frame,
           let containerView = self.transitionContext?.containerView,
           let delegate = self.delegate {
            
            switch pan.state {
            case .began, .changed :
                
                var percent = percentForTranslation(pan.translation(in: containerView))
                let cFrame = view.frame
                
                switch delegate.props.transitionStyle {
                case .fromTop :
                    var centerY = frame.minY + cFrame.height / 2 + cFrame.height * percent
                    if centerY > frame.midY {
                        centerY = frame.midY
                    }
                    view.gkCenterY = centerY
                    
                case .fromBottom :
                    if let scrollView = delegate.scrollView, scrollView.panGestureRecognizer == pan {
                        if percentComplete > 0 || scrollView.contentOffset.y <= 0 {
                            delegate.scrollView?.contentOffset = .zero
                        } else {
                            percent = 0
                        }
                    }
                    var centerY = frame.minY + cFrame.height / 2 + cFrame.height * percent
                    if centerY < frame.midY {
                        centerY = frame.midY
                    }
                    view.gkCenterY = centerY
                    
                case .fromRight :
                    var centerX = frame.minX + cFrame.width / 2 + cFrame.width * percent
                    if centerX > frame.midX {
                        centerX = frame.midX
                    }
                    view.gkCenterX = centerX
                    
                case .fromLeft :
                    var centerX = frame.minX + cFrame.width / 2 + cFrame.width * percent
                    if centerX > frame.midX {
                        centerX = frame.midX
                    }
                    view.gkCenterX = centerX
                }
                delegate.controller?.update(percent, animated: false)
                update(percent)
                
            default:
                interactiveComplete(pan)
            }
        }
    }

    private func interactiveComplete(_ pan: UIPanGestureRecognizer) {
        if let view = self.view,
           let delegate = self.delegate,
           let frame = self.frame,
           let containerView = transitionContext?.containerView {
            
            var translation = pan.translation(in: containerView)
            //快速滑动也算完成
            let velocity = pan.velocity(in: containerView)
            translation.x += velocity.x
            translation.y += velocity.y
            
            let finished = percentForTranslation(translation) >= 0.4
            if finished {
                delegate.controller?.update(1.0, animated: true)
                finish()
            } else {
                delegate.controller?.update(0, animated: true)
                cancel()
            }
            
            var duration = TimeInterval(self.duration)
            var center: CGPoint!
            if finished {
                switch delegate.props.transitionStyle {
                case .fromTop :
                    center = CGPoint(view.gkCenterX, -view.gkHeight / 2)
                    
                case .fromBottom :
                    center = CGPoint(view.gkCenterX, containerView.gkBottom + view.gkHeight / 2)
                    
                case .fromLeft :
                    center = CGPoint(-view.gkWidth / 2, view.gkCenterY)
                    
                case .fromRight :
                    center = CGPoint(containerView.gkRight + view.gkWidth / 2, view.gkCenterY)
                }
                switch delegate.props.transitionStyle {
                case .fromTop, .fromBottom :
                        duration *= TimeInterval(abs(view.gkCenterY - center.y) / view.gkHeight)
                        
                case .fromLeft, .fromRight :
                        duration *= TimeInterval(abs(view.gkCenterX - center.x) / view.gkHeight)
                }
            } else {
                center = CGPoint(frame.midX, frame.midY);
            }
            
            UIView.animate(withDuration: duration,
                           delay: 0,
                           usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 0,
                           options: .beginFromCurrentState) {
                view.center = center
            } completion: { (_) in
                self.transitionContext?.completeTransition(finished)
            }
        }
    }
}
