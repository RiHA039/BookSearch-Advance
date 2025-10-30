//
//  BookSearchViewController.swift
//  BookSearch-Advance
//
//  Created by 김리하 on 10/28/25.
//

import UIKit
import SnapKit

// MARK: - Kakao API 응답 모델
struct KakaoBookResponse: Codable {
    let documents: [BookDocument]
}

struct BookDocument: Codable {
    let title: String
    let contents: String
    let thumbnail: String?
}

// MARK: - 책 검색 화면
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
    
    // ✅ 이제 문자열이 아니라 BookDocument 배열로 변경
    private var searchResults: [BookDocument] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "검색"
        setupLayout()
        setupDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.delegate = self
    }
    
    // MARK: - 오토레이아웃 설정
    private func setupLayout() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Kakao API 호출 함수
    private func fetchBooks(query: String) {
        // plist에서 API 키 불러오기
        let apiKey = Secret.kakaoAPIKey
        
        // 검색어를 URL에 넣기
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://dapi.kakao.com/v3/search/book?query=\(encodedQuery)"
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        
        // 네트워크 요청
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else { return }
            do {
                let decoded = try JSONDecoder().decode(KakaoBookResponse.self, from: data)
                DispatchQueue.main.async {
                    self.searchResults = decoded.documents
                    self.tableView.reloadData()
                }
            } catch {
                print("디코딩 오류:", error)
            }
        }.resume()
    }
}

// MARK: - UISearchBarDelegate
extension BookSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        fetchBooks(query: keyword)
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableView
extension BookSearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath)
        let book = searchResults[indexPath.row]
        cell.textLabel?.text = book.title
            .replacingOccurrences(of: "<b>", with: "")
            .replacingOccurrences(of: "</b>", with: "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedBook = searchResults[indexPath.row]
        let detailVC = BookDetailViewController()
        detailVC.book = Book(
            title: selectedBook.title.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: ""),
            description: selectedBook.contents
        )
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true)
    }
}


//import UIKit
//import SnapKit
//
//// 첫 번째 탭 화면: 책 검색 화면
//class BookSearchViewController: UIViewController {
//    
//    // 검색창
//    private let searchBar: UISearchBar = {
//        let searchBar = UISearchBar()
//        searchBar.placeholder = "검색어를 입력하세요"
//        return searchBar
//    }()
//    
//    // 책 목록을 보여줄 테이블 뷰
//    private let tableView: UITableView = {
//        let tableView = UITableView()
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BookCell")
//        return tableView
//    }()
//    
//    private var searchResults: [String] = []
//    
//    private let allBooks = [
//        "해리포터",
//        "해리포터2",
//        "해리포터3",
//        "해리포터4"
//    ]
//    
//   
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        title = "검색" // 네비게이션 상단 제목
//        
//        setupLayout()
//        setupDelegate()
//        
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        searchBar.delegate = self
//    }
//    
//    
//    // 오토레이아웃 설정
//    private func setupLayout() {
//        view.addSubview(searchBar)
//        view.addSubview(tableView)
//        
//        searchBar.translatesAutoresizingMaskIntoConstraints = false
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        
//        searchBar.snp.makeConstraints {
//            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
//            $0.leading.trailing.equalToSuperview()
//            $0.height.equalTo(44)
//        }
//        
//        tableView.snp.makeConstraints {
//            $0.top.equalTo(searchBar.snp.bottom)
//            $0.leading.trailing.bottom.equalToSuperview()
//        }
//    }
//    
//    private func setupDelegate() {
//        tableView.dataSource = self
//        tableView.delegate = self
//        
//    }
//    
//}
//
//private func fetchBooks(query: String) {
//    // plist에서 API 키 불러오기
//    let apiKey = Secret.kakaoAPIKey
//    
//    // 검색어를 URL에 넣기
//    let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//    let urlString = "https://dapi.kakao.com/v3/search/book?query=\(encodedQuery)"
//    
//    guard let url = URL(string: urlString) else { return }
//    
//    // 요청 생성
//    var request = URLRequest(url: url)
//    request.setValue(apiKey, forHTTPHeaderField: "Authorization")
//    
//    // 네트워크 요청 보내기
//    URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//        guard let self = self, let data = data, error == nil else { return }
//        do {
//            let decoded = try JSONDecoder().decode(KakakoBookResponse.self, from: data)
//            dispatchQueue.main.async {
//                
//                self.searchResults = decoded.documents
//                self.tableView.reloadData()
//            }
//        } catch {
//            print("디코딩 오류", error)
//        }
//    }.resume()
//}
//
//// UISearchBarDelegate (검색 기능)
//extension BookSearchViewController: UISearchBarDelegate {
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        print("✅ searchBarTextDidEndEditing 실행됨")
//        guard let keyword = searchBar.text?.lowercased(), !keyword.isEmpty else { return }
//        
//        searchResults = allBooks.filter { $0.lowercased().contains(keyword) }
//        print("검색 결과:", searchResults)
//        
//        tableView.reloadData()
//        searchBar.resignFirstResponder() // 키보드 내리기
//        
//    }
//}
//
//
//
//// 테이블 뷰 데이터 설정 (추후 변경 예정)
//extension BookSearchViewController: UITableViewDataSource, UITableViewDelegate {
//    
//    
//    // 섹션 당 셀 개수
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return searchResults.count
//    }
//    
//    // 셀 내용 구성
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath)
//        cell.textLabel?.text = searchResults[indexPath.row] // 첵 제목 표시
//        return cell
//    }
//    
//    // 셀 탭 시 동작(책 상세 화면 모달로 띄우기)
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        let selectedTitle = searchResults[indexPath.row]
//        let detaiVC = BookDetailViewController()
//        detaiVC.book = Book(title: selectedTitle, description: "검색 결과 예시 설명")
//        detaiVC.modalPresentationStyle = .pageSheet // 아래에서 위로 올라오는 시트형 모달
//        present(detaiVC, animated: true)
//    }
//}
//
//
