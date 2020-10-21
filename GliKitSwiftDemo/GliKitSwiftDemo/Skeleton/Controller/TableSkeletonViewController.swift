//
//  TableSkeletonViewController.swift
//  GliKitSwiftDemo
//
//  Created by 罗海雄 on 2020/10/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import GliKitSwift

class TableSkeletonViewController: TableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style = .grouped
        registerNib(cls: TableViewSkeletonCell.self)
        registerClassForHeaderFooterView(TableViewSkeletonHeader.self)
        tableView.rowHeight = 80
        initViews()
        
        tableView.gkShowSkeleton(duration: 2) {
            self.tableView.gkHideSkeleton(animate: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: TableViewSkeletonHeader.gkNameOfClass)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: TableViewSkeletonCell.gkNameOfClass, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
