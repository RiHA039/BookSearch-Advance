//
//  File.swift
//  BookSearch-Advance
//
//  Created by 김리하 on 10/28/25.
//

import UIKit
import CoreData

// MARK: - 두 번째 탭 화면: 담은 책 리스트 화면
class SavedBooksViewController: UIViewController {
    
    // MARK: - UI 컴포넌트
    private let tableView = UITableView()
    
    // CoreData에서 불러온 책 데이터
    private var savedBooks: [BookEntity] = []
    
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "담은 책 리스트"
        
        setupTableView()       // 테이블뷰 설정 분리
        setupNavigationBar()   // 버튼 구성 분리
    }
    
    // 화면이 다시 나타날 때마다 최신 데이터 불러오기
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // CoreData에서 책 목록 불러오기
        savedBooks = CoreDataManager.shared.fetchBooks()
        tableView.reloadData()
    }
    
    
    // MARK: - UI 설정
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    private func setupNavigationBar() {
        // 오른쪽에 "추가", 왼쪽에 "전체 삭제" 배치
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "추가",
            style: .plain,
            target: self,
            action: #selector(moveToSearchTab)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "전체 삭제",
            style: .plain,
            target: self,
            action: #selector(deleteAllBooks)
        )
    }
    
    
    // MARK: - CoreData 관련 기능
    
    // 전체 삭제 버튼 기능
    @objc private func deleteAllBooks() {
        CoreDataManager.shared.deleteAllBooks()
        savedBooks.removeAll()
        tableView.reloadData()
    }
    
    // 첫 번째 탭(검색화면)으로 이동 + 서치바 활성화
    @objc private func moveToSearchTab() {
        tabBarController?.selectedIndex = 0
        
        // 안전하게 옵셔널 체이닝 처리
        guard let nav = tabBarController?.viewControllers?.first as? UINavigationController,
              let searchVC = nav.viewControllers.first as? BookSearchViewController else { return }
        
        searchVC.searchBar.becomeFirstResponder()
    }
}


// MARK: - UITableViewDataSource & UITableViewDelegate
extension SavedBooksViewController: UITableViewDataSource, UITableViewDelegate {
    // 행 개수 = 저장된 책 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedBooks.count
    }
    
    // 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = savedBooks[indexPath.row].title
        return cell
    }
    
    // 스와이프로 개별 삭제 기능
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { _, _, completion in
            let bookToDelete = self.savedBooks[indexPath.row]
            CoreDataManager.shared.deleteBook(bookToDelete)
            self.savedBooks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
