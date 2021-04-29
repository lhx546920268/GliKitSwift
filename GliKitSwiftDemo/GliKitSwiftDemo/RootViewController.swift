//
//  RootViewController.swift
//  GliKitSwiftDemo
//
//  Created by 罗海雄 on 2020/1/17.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import GliKitSwift

struct RowModel {
    var title: String
    var cls: UIViewController.Type
}

open class RootViewController: TableViewController {

    var models: [RowModel]!
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        style = .grouped
        title = "GliKitSwiftDemo"
        models = [
            RowModel(title: "空视图", cls: EmptyViewController.self),
            RowModel(title: "Alert", cls: AlertDemoController.self),
            RowModel(title: "骨架层", cls: SkeletonViewController.self),
            RowModel(title: "过渡动画", cls: TransitionViewController.self),
            RowModel(title: "Banner", cls: BannerViewController.self),
        ]

        let safe = SafeLayoutGuide.all
        print("contains", safe.contains(SafeLayoutGuide.left))
        
        registerClass(UITableViewCell.classForCoder())
        initViews()
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.gkNameOfClass, for: indexPath)
        cell.textLabel!.text = models[indexPath.row].title
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = models[indexPath.item]
        let vc = model.cls.init()
        vc.title = model.title
        navigationController?.pushViewController(vc, animated: true)
    }
}
