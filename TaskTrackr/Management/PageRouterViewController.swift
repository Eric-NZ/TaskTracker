//
//  BasisRootViewController.swift
//  TaskTrackr
//
//  Created by Eric Ho on 5/09/18.
//  Copyright © 2018 LomoStudio. All rights reserved.
//

import UIKit
import Parchment

protocol ManageItemDelegate {
    func addItem(sender: Any?)      // if sender is RootPagingViewController, create a new item
    func editingMode(editing: Bool, animate: Bool)
}

class PageRouterViewController: UIViewController, PagingViewControllerDelegate, PagingViewControllerDataSource {
    
    var pagingViewController = PagingViewController<PagingIndexItem>()
    var viewControllers:[UIViewController] = []
    var currentViewController: UIViewController?
    
    var delegate: ManageItemDelegate?
    
    /*  PagingViewControllerDataSourceDataSource
     */
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, pagingItemForIndex index: Int) -> T where T : PagingItem, T : Comparable, T : Hashable {
        return PagingIndexItem(index: index, title: viewControllers[index].title!) as! T
    }
    
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, viewControllerForIndex index: Int) -> UIViewController where T : PagingItem, T : Comparable, T : Hashable {
        return viewControllers[index]
    }
    
    
    func numberOfViewControllers<T>(in pagingViewController: PagingViewController<T>) -> Int where T : PagingItem, T : Comparable, T : Hashable {
        return self.viewControllers.count
    }
    
    /* PagingViewControllerDelegate
     */
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, didScrollToItem pagingItem: T, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) where T : PagingItem, T : Comparable, T : Hashable {
        guard transitionSuccessful else {
            return
        }
        // update title for navigation bar
        updateNavigationBarTitle(to: destinationViewController.title!)
        // update value of currentViewController
        currentViewController = destinationViewController
        // set currentViewController as ManageItemDelegate
        delegate = currentViewController as? ManageItemDelegate
    }
    
    func updateNavigationBarTitle(to newTitle: String) {
        // remove emoji
        var title = newTitle
        if let index = title.range(of: " ")?.lowerBound {
            title.removeSubrange(..<index)
        }
        print(title)
        let newTitle = String(format: "Manage %@", title)
        
        self.navigationController?.navigationBar.topItem?.title = newTitle
        // reset the editing state
        setEditing(false, animated: true)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        viewControllers = [Static.getInstance(with: Static.page_service),
                           Static.getInstance(with: Static.page_worker),
                           Static.getInstance(with: Static.page_product),
                           Static.getInstance(with: Static.page_tool)] as! [UIViewController]
        
        initPagingViewController()
        pagingViewController.delegate = self
        pagingViewController.dataSource = self
        
        // initially set the first view controller to be the default page
        currentViewController = viewControllers[0]
        delegate = currentViewController as? ManageItemDelegate
        
        
        setLeftBarItem()
    }
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        delegate?.addItem(sender: self)
    }
    
    func initPagingViewController() {
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
    }
    
    func setLeftBarItem() {
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    /**
        Whenever Edit/Done button clicked, this method is called.
     */
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        delegate?.editingMode(editing: editing, animate: animated)
    }
}
