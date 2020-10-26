//
//  BannerViewController.swift
//  GliKitSwiftDemo
//
//  Created by 罗海雄 on 2020/10/26.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import GliKitSwift

class BannerViewController: BaseViewController, PageViewDelegate {
    
    var horizontalPageView: PageView!
    var verticalPageView: PageView!
    let colors: [UIColor] = [.red, .orange, .yellow, .green, .cyan, .blue, .purple]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        horizontalPageView = PageView()
        horizontalPageView.spacing = 20
        horizontalPageView.ratio = 0.8
        horizontalPageView.scale = 0.9
        horizontalPageView.delegate = self
        horizontalPageView.autoPlay = false
        horizontalPageView.registerClass(UIView.self)
        
        setTopView(horizontalPageView, height: 200)
        
        verticalPageView = PageView(scrollDirection: .vertical)
        verticalPageView.ratio = 0.8
        verticalPageView.scale = 0.9
        verticalPageView.delegate = self
        verticalPageView.autoPlay = false
        verticalPageView.registerClass(UIView.self)
        
        view.addSubview(verticalPageView)
        verticalPageView.snp.makeConstraints { (make) in
            make.top.equalTo(horizontalPageView.snp.bottom).offset(30)
            make.leading.trailing.equalTo(0)
            make.height.equalTo(200)
        }
        
        let btn = UIButton(type: .system)
        btn.setTitle("Scroll To Random", for: .normal)
        btn.addTarget(self, action: #selector(handleScroll), for: .touchUpInside)
        view.addSubview(btn)
        
        btn.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(verticalPageView.snp.bottom).offset(30)
        }
    }
    
    // MARK: - PageViewDelegate
    
    func numberOfItems(in pageView: PageView) -> Int {
        return colors.count
    }
    
    func pageView(_ pageView: PageView, cellForItemAt index: Int) -> UIView {
        let cell = pageView.dequeueCell(withClass: UIView.self, for: index)
        cell.backgroundColor = colors[index]
        
        return cell
    }
    
    func pageView(_ pageView: PageView, didSelectItemAt index: Int) {
        print("didSelectItemAt")
    }
    
    func pageView(_ pageView: PageView, didMiddleItemAt index: Int) {
        print("didMiddleItemAt")
    }
    
    @objc private func handleScroll() {
        
        let index = Int.random(in: 0 ..< colors.count)
        horizontalPageView.scrollTo(index, animated: true)
        verticalPageView.scrollTo(index, animated: true)
        
        print("Scroll to \(index)")
    }
}
