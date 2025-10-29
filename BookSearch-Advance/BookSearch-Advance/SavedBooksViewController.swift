//
//  File.swift
//  BookSearch-Advance
//
//  Created by 김리하 on 10/28/25.
//

import UIKit

// 두 번째 탭 화면: 담은 책 리스트 화면
class SavedBooksViewController: UIViewController {
    
    private let tableView = UITableView()
    private var savedBooks: [Book] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "담은 책 리스트" // 네비게이션 상단 제목
        
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    // 화면이 다시 나타날 때마다 최신 데이터 불러오기
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        savedBooks = BookStorage.shared.getAllBooks() // 저장소에서 불러오기
        tableView.reloadData() // 화면 새로고침
    }
}
    // UITableviewDataSource (테이블뷰에 데이터 표시 관련 기능)
    extension SavedBooksViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return savedBooks.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            // 해당 인덱스의 책 제목 표시
            cell.textLabel?.text = savedBooks[indexPath.row].title
            return cell
        }
    }
    

