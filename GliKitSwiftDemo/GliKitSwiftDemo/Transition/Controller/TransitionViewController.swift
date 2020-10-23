//
//  TransitionViewController.swift
//  GliKitSwiftDemo
//
//  Created by 罗海雄 on 2020/10/22.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import GliKitSwift

class TransitionViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btn = UIButton(type: .system)
        btn.setTitle("从下到上", for: .normal)
        btn.addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)
        view.addSubview(btn)
        
        btn.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
    }
    
    @objc private func handleTap(_ btn: UIButton) {
        
        let vc = RootViewController()
        vc.navigationItem.title = btn.currentTitle
        
        let nav = vc.gkCreateWithNavigationController
        nav.partialPresentProps.contentSize = CGSize(UIScreen.gkWidth, 400)
        nav.partialPresentProps.cornerRadius = 10
        nav.partialPresentFromBottom()
    }
}
