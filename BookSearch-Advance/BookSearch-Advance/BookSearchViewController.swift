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
    
    // MARK: - UI 요소
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "검색어를 입력하세요"
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BookCell")
        return tableView
    }()
    
    // MARK: - 데이터 저장
    private var searchResults: [BookDocument] = []   // 검색 결과 리스트
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "검색"
        
        setupLayout()     // 오토레이아웃 설정
        setupDelegate()   // delegate 연결
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.delegate = self // 서치바 델리게이트 연결
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
    
    // MARK: - Delegate 설정
    private func setupDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    // MARK: - Kakao API 호출 함수
    private func fetchBooks(query: String) {
        // plist에서 API 키 불러오기
        let apiKey = Secret.kakaoAPIKey
        print("불러온 API Key:", apiKey)

        // 검색어를 URL에 넣기
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://dapi.kakao.com/v3/search/book?query=\(encodedQuery)"
        print("요청 URL:", urlString)
        guard let url = URL(string: urlString) else { return }

        // 요청 준비
        var request = URLRequest(url: url)
        // Kakao API 인증 헤더 설정 (KakaoAK + APIKey)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

        // 네트워크 요청
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            // 에러 체크
            if let error = error {
                print("네트워크 오류:", error.localizedDescription)
                return
            }

            // HTTP 상태 코드 확인
            if let httpResponse = response as? HTTPURLResponse {
                print("상태 코드:", httpResponse.statusCode)
            }

            // 데이터 유무 확인
            guard let data = data else {
                print("데이터가 비어있음")
                return
            }

            // 원본 JSON 출력 (디버깅용)
            if let json = String(data: data, encoding: .utf8) {
                print("응답 데이터 원문:\n\(json)")
            }

            // 디코딩 시도
            do {
                let decoded = try JSONDecoder().decode(KakaoBookResponse.self, from: data)
                DispatchQueue.main.async {
                    // 결과 반영
                    self?.searchResults = decoded.documents
                    self?.tableView.reloadData()
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
        fetchBooks(query: keyword)          // 검색 실행
        searchBar.resignFirstResponder()    // 키보드 내리기
    }
}


// MARK: - UITableView Delegate & DataSource
extension BookSearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath)
        let book = searchResults[indexPath.row]
        
        // HTML 태그(<b>, </b>) 제거
        cell.textLabel?.text = book.title
            .replacingOccurrences(of: "<b>", with: "")
            .replacingOccurrences(of: "</b>", with: "")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 선택한 책 정보 전달
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

        // 모달로 상세화면 표시
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true)
    }
}
