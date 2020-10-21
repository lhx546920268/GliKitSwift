//
//  EmptyCollectionViewController.swift
//  GliKitSwiftDemo
//
//  Created by 罗海雄 on 2020/10/20.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import GliKitSwift

class CollectionEmptyModel: ItemSizeModel {
   
    var itemSize: CGSize?
    var title: String = "\(arc4random())"
}

class CollectionEmptyCell: UICollectionViewCell, CollectionConfigurableItem {
    
    typealias Model = CollectionEmptyModel
    
    public private(set) var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel = UILabel()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 20
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
            make.top.equalTo(15)
            make.bottom.equalTo(-15)
        }
    }
    
    var model: CollectionEmptyModel?{
        didSet{
            titleLabel.text = model?.title
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class EmptyCollectionViewController: CollectionViewController {
    
    var count: Int = 10
    var models = [CollectionEmptyModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for _ in 0..<count {
            models.append(CollectionEmptyModel())
        }
     
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.sectionInset = UIEdgeInsets(15, 15, 15, 15)
        collectionView.backgroundColor = UIColor.gkGrayBackgroundColor
        
        registerClass(CollectionEmptyCell.self)
        initViews()
        collectionView.gkShouldShowEmptyView = true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.gkItemSize(forType: CollectionEmptyCell.self, model: models[indexPath.item])
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionEmptyCell.gkNameOfClass, for: indexPath) as! CollectionEmptyCell
        
        cell.model = models[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        count = 0
        collectionView.reloadData()
    }
    
    override func emptyViewWillAppear(_ view: EmptyView) {
        super.emptyViewWillAppear(view)
        if view.gestureRecognizers?.count ?? 0 == 0 {
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapEmpty)))
        }
    }
    
    @objc private func handleTapEmpty() {
        count = 10
        collectionView.reloadData()
    }
}
