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
    let authors: [String]
    let contents: String
    let thumbnail: String?
    let price: Int?
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
    
    // 
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
            title: selectedBook.title
                .replacingOccurrences(of: "<b>", with: "")
                .replacingOccurrences(of: "</b>", with: ""),
            authors: selectedBook.authors,
            contents: selectedBook.contents,
            thumbnail: selectedBook.thumbnail,
            price: selectedBook.price
        )



        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true)
    }
}


