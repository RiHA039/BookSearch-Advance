//
//  TabBarController.swift
//  BookSearch-Advance
//
//  Created by 김리하 on 10/28/25.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        let searchVC = UINavigationController(rootViewController: BookSearchViewController())
        searchVC.tabBarItem = UITabBarItem(title: "검색", image: UIImage(systemName: "magnifyingglass"), tag: 0)
        
        let savedVC = UINavigationController(rootViewController: SavedBooksViewController())
        savedVC.tabBarItem = UITabBarItem(title: "담은 책", image: UIImage(systemName: "book"), tag: 1)
        
        viewControllers = [searchVC, savedVC]
    }
}
