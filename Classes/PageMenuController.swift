//
//  PageMenuController.swift
//  PageMenu
//
//  Created by Grayson Webster on 3/31/2017.
//  Copyright © 2017 Center for Advanced Public Safety. All rights reserved.
//

import UIKit

public enum ScrollDirection {
    case none
    case right
    case left
    case up
    case down
}

open class PageMenuController : UIViewController {
    
    // MARK: - Properties
    var reuseIdentifier = "PageCell"
    var pages: [UIViewController] = []
    var offset: CGFloat = 0
    
    open var collectionView: UICollectionView?
    
    public var pageMenuBar: PageMenuBar!
    
    // MARK: - Setup
    override open func viewDidLoad() {
        super.viewDidLoad()
        pageMenuBar = PageMenuBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44.0), controller: self)
        setDefaultCollectionView()
        view.addSubview(pageMenuBar!)
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Configure Collection View
    func setDefaultCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = view.bounds.size
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.view.addSubview(collectionView!)
        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView!.isPagingEnabled = true
        collectionView!.isScrollEnabled = true
        collectionView!.showsHorizontalScrollIndicator = false
    }
    
    // MARK: - Add/Remove Pages
    
    public func addPage(_ controller: UIViewController, title: String, at: Int) {
        pages.insert(controller, at: at)
        pageMenuBar.addItem(title: title, at: at)
    }
    
    public func addPage(_ controller: UIViewController, image: UIImage, at: Int) {
        pages.insert(controller, at: at)
        pageMenuBar.addItem(image: image, at: at)
    }
    
    public func addPage(_ controller: UIViewController, title: String) {
        addPage(controller, title: title, at: pages.count)
    }
    
    public func addPage(_ controller: UIViewController, image: UIImage) {
        addPage(controller, image: image, at: pages.count)
    }
    
    public func removePage(at: Int) {
        pages.remove(at: at)
        pageMenuBar.removeItem(at: at)
    }
    
    public func removeLastPage() {
        removePage(at: pages.count - 1)
    }
    
    // MARK: - Navigation Bar
    public func useNavigationBar() {
        self.navigationItem.titleView = pageMenuBar.collectionView
        let leftMargin = self.navigationController!.navigationBar.layoutMargins.left
        pageMenuBar.collectionView!.frame = CGRect(x: leftMargin, y: 0, width: navigationItem.titleView!.frame.width - (leftMargin*2), height: pageMenuBar.collectionView!.frame.height)
        pageMenuBar.frame = CGRect(x: leftMargin, y: 0, width: pageMenuBar.frame.width - (leftMargin*2), height: 0)
        pageMenuBar.setIsInNavigationBar(margin: leftMargin)
        pageMenuBar.adjustAlignment()
    }
    
    // MARK: - Scrolling
    public func scrollToPage(_ indexPath: IndexPath) {
        collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

// MARK: - Private
private extension PageMenuController {
    func pageForIndexPath(_ indexPath: IndexPath) -> UIView {
        return pages[(indexPath as NSIndexPath).section].view
    }
}


// MARK: - UICollectionViewDataSource
extension PageMenuController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return pages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as UICollectionViewCell
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        cell.contentView.addSubview(pageForIndexPath(indexPath))
        return cell
    }
}

extension PageMenuController: UICollectionViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.offset = scrollView.contentOffset.x
        let pageIndex = Int(round(offset / self.view.frame.width))
        self.pageMenuBar.pageMenuScroll(index: pageIndex)
        pageMenuBar.moveIndicator(offset, false)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.offset = scrollView.contentOffset.x
        //pageMenuBar.moveIndicator(offset, true)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.offset = scrollView.contentOffset.x
        //pageMenuBar.moveIndicator(offset, true)
    }
}