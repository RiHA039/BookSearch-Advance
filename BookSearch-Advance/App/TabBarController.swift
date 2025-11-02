//
//  TabBarController.swift
//  BookSearch-Advance
//
//  Created by 김리하 on 10/28/25.
//

import UIKit

// MARK: - 앱 전체 탭 구성을 담당하는 컨트롤러
class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs() // 탭 구성 실행
    }
    
    // MARK: - 각 탭 구성 설정 (검색, 담은 책)
    private func setupTabs() {
        // 첫 번째 탭: 책 검색 화면
        let searchVC = UINavigationController(rootViewController: BookSearchViewController())
        searchVC.tabBarItem = UITabBarItem(
            title: "검색",
            image: UIImage(systemName: "magnifyingglass"),
            tag: 0
        )
        
        // 두 번째 탭: 담은 책 목록 화면
        let savedVC = UINavigationController(rootViewController: SavedBooksViewController())
        savedVC.tabBarItem = UITabBarItem(
            title: "담은 책",
            image: UIImage(systemName: "book"),
            tag: 1
        )
        
        // 탭 순서 설정
        viewControllers = [searchVC, savedVC]
    }
}
