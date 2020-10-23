//
//  AlertDemoController.swift
//  GliKitSwiftDemo
//
//  Created by 罗海雄 on 2020/10/20.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import GliKitSwift

class AlertDemoController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Alert"
        
        var btn: UIButton = UIButton(type: .system)
        btn.setTitle("Alert", for: .normal)
        btn.addTarget(self, action: #selector(handleAlert), for: .touchUpInside)
        view.addSubview(btn)
        
        btn.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(180)
        }
        
        btn = UIButton(type: .system)
        btn.setTitle("ActionSheet", for: .normal)
        btn.addTarget(self, action: #selector(handleActionSheet), for: .touchUpInside)
        view.addSubview(btn)
        
        btn.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(250)
        }
    }
    
    @objc private func handleAlert() {
        AlertUtils.showConfirmAlert(title: "标题", message: "信息", icon: UIImage(named: "swift")) {
            self.gkShowSuccessText("确定了")
        }
    }
    
    @objc private func handleActionSheet() {
        AlertUtils.showActionSheet(title: "标题", message: "信息", icon: UIImage(named: "swift"), buttonTitles: ["第一个", "第二个"], cancelButtonTitle: "取消", destructiveButtonIndex: 1) { (index, title) in
            self.gkShowSuccessText("点击\(title)")
        }
    }
}
