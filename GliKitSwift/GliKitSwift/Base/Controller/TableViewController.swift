//
//  TableViewController.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///section header footer 不显示时的高度 estimatedHeightForHeaderInSection 不能小于1 否则会ios9,10闪退
public let TableViewMinHeaderFooterHeight: CGFloat = 0.00001;

///基础列表视图控制器
open class TableViewController: ScrollViewController, UITableViewDataSource, UITableViewDelegate {
    
    ///信息列表
    public private(set) lazy var tableView: UITableView = {
        
        let cls = self.tableViewClass as? UITableView.Type
        assert(cls != nil, "\(self.gkNameOfClass).tableViewClass 必须是UITableView 或者 其子类");
        let tableView = cls!.init(frame: .zero, style: self.style)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundView = nil
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        if self.style == .grouped {
            tableView.backgroundColor = UIColor.gkGrayBackgroundColor
        }
        
        //TODO: EmptyView
        //        tableView.gkEmptyViewDelegate = self
        
        tableView.separatorInset = self.separatorEdgeInsets
        tableView.layoutMargins = self.separatorEdgeInsets
        self.scrollView = tableView
        
        return tableView
    }()
    
    ///列表风格
    public var style: UITableView.Style = .plain
    
    ///分割线位置
    public var separatorEdgeInsets = UIEdgeInsets(0, 15, 0, 0)
    
    ///tableView类，必须是UITableView 或者其子类
    public var tableViewClass: AnyClass{
        UITableView.self
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isInit {
            tableView.separatorInset = separatorEdgeInsets
            tableView.layoutMargins = separatorEdgeInsets
        }
    }
    
    open override func reloadListData() {
        if isInit {
            tableView.reloadData()
        }
    }
    
    // MARK: - Register Cell
    
    ///注册cell
    public func registerNib(cls: AnyClass){
        tableView.registerNib(cls)
    }
    
    public func registerClass(_ cls: AnyClass){
        tableView.registerClass(cls)
    }
    
    ///注册header footer
    public func registerNibForHeaderFooterView(_ cls: AnyClass){
        tableView.registerNibForHeaderFooterView(cls)
    }
    
    public func registerClassForHeaderFooterView(_ cls: AnyClass){
        tableView.registerClassForHeaderFooterView(cls)
    }
    
    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableViewMinHeaderFooterHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return TableViewMinHeaderFooterHeight
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("\(self.gkNameOfClass) 必须实现 \(#function)")
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.separatorInset = separatorEdgeInsets
        cell.layoutMargins = separatorEdgeInsets
        
        // TODO: rowHeight
    }
    
    
    
    //    - (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
    //    {
    //        [tableView gkSetHeaderHeight:@(view.gkHeight) forSection:section];
    //    }
    //
    //    - (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
    //    {
    //        [tableView gkSetFooterHeight:@(view.gkHeight) forSection:section];
    //    }
    
    // MARK: - 屏幕旋转
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if isInit {
            tableView.reloadData()
        }
    }
}
