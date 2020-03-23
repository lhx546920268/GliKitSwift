//
//  BaseNavigationController.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/3/20.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///基础导航控制视图
public class BaseNavigationController: UINavigationController {
    
    ///是否是手势交互返回
    public private(set) var isInteractivePop: Bool = false

    ///pop 或者 push 完成回调，执行后会 变成nil
    public transitionCompletion: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
