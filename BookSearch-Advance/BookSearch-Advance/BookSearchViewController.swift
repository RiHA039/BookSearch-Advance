//
//  BookSearchViewController.swift
//  BookSearch-Advance
//
//  Created by 김리하 on 10/28/25.
//
import UIKit
import SnapKit

// 첫 번째 탭 화면: 책 검색 화면
class BookSearchViewController: UIViewController {
    
    // 검색창
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "검색어를 입력하세요"
        return searchBar
    }()
    
    // 책 목록을 보여줄 테이블 뷰
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BookCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "검색" // 네비게이션 상단 제목
        
        setupLayout()
        
        //
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    // 오토레이아웃 설정
    private func setupLayout() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
}

// 테이블 뷰 데이터 설정 (추후 변경 예정)
extension BookSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    // 임시로 넣은 데이터
    private var dummyBooks: [String] {
        return ["해리포터", "어려워용", "힘내보자"]
    }
    
    // 섹션 당 셀 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyBooks.count
    }
    
    // 셀 내용 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath)
        cell.textLabel?.text = dummyBooks[indexPath.row] // 첵 제목 표시
        return cell
    }
    
    // 셀 탭 시 동작(책 상세 화면 모달로 띄우기)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedBook = Book(title: dummyBooks[indexPath.row], description: "테스트용 설명")
        let detaiVC = BookDetailViewController()
        detaiVC.book = selectedBook
        detaiVC.modalPresentationStyle = .pageSheet // 아래에서 위로 올라오는 시트형 모달
        present(detaiVC, animated: true)
    }
}

