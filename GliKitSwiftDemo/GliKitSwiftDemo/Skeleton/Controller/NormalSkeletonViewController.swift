//
//  NormalSkeletonViewController.swift
//  GliKitSwiftDemo
//
//  Created by 罗海雄 on 2020/10/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import GliKitSwift

class NormalSkeletonViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.gkShowSkeleton(duration: 2) {
            self.view.gkHideSkeleton(animate: true)
        }
    }

}
