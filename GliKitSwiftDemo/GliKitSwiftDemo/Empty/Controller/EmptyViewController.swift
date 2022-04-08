//
//  EmptyViewController.swift
//  GliKitSwiftDemo
//
//  Created by 罗海雄 on 2020/10/20.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import GliKitSwift

class EmptyViewController: TableViewController {
    
    var models: [RowModel]!
    var value: Int = 0
    open override func viewDidLoad() {
        super.viewDidLoad()
        style = .grouped
        models = [
            RowModel(title: "普通视图", cls: EmptyNormalViewController.self),
            RowModel(title: "CollectionView", cls: EmptyCollectionViewController.self),
            RowModel(title: "TableView", cls: EmptyTableViewController.self),
        ];
        
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
