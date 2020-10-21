//
//  EmptyTableViewController.swift
//  GliKitSwiftDemo
//
//  Created by 罗海雄 on 2020/10/19.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import GliKitSwift

class TableEmptyModel: RowHeightModel {
   
    var rowHeight: CGFloat?
    var title: String = "\(arc4random())"
}

class TableEmptyCell: UITableViewCell, TableConfigurableItem {
    
    typealias Model = TableEmptyModel
    
    public private(set) var titleLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.top.equalTo(25)
            make.bottom.equalTo(-25)
        }
    }
    
    var model: TableEmptyModel?{
        didSet{
            titleLabel.text = model?.title
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EmptyTableViewController: TableViewController {
    
    var count: Int = 10
    var models = [TableEmptyModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style = .grouped
        for _ in 0..<count {
            models.append(TableEmptyModel())
        }
     
        registerClass(TableEmptyCell.self)
        initViews()
        tableView.gkShouldShowEmptyView = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.gkRowHeight(forType: TableEmptyCell.self, model: models[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableEmptyCell.gkNameOfClass) as! TableEmptyCell
        
        cell.model = models[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        count = 0
        tableView.reloadData()
    }
    
    override func emptyViewWillAppear(_ view: EmptyView) {
        super.emptyViewWillAppear(view)
        if view.gestureRecognizers?.count ?? 0 == 0 {
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapEmpty)))
        }
    }
    
    @objc private func handleTapEmpty() {
        count = 10
        tableView.reloadData()
    }
}
