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

struct BookDocument: Codable, Equatable {
    let title: String
    let authors: [String]
    let contents: String
    let thumbnail: String?
    let price: Int?
}

// MARK: - 최근 본 책 셀 (컬렉션뷰 아이템)
final class RecentBookCell: UICollectionViewCell {
    static let id = "RecentBookCell"
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        
        titleLabel.font = .systemFont(ofSize: 10)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(70)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(4)
        }
    }
    
    func configure(with book: Book) {
        titleLabel.text = book.title
        
        if let urlString = book.thumbnail, let url = URL(string: urlString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
        } else {
            imageView.image = UIImage(systemName: "book.closed")
        }
    }
}

// MARK: - 책 검색 화면
class BookSearchViewController: UIViewController {
    
    // 최근 본 책 (UserDefaults)
    private var recentBooks: [Book] = []
    
    // 검색 중 여부
    private var isSearching = false
    
    // MARK: - UI 요소
    let searchBar: UISearchBar = {
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
        
        recentBooks = RecentBooksStore.load() // 최근 본 책 불러오기
        
        setupLayout()
        setupDelegate()
        
        // 최근 본 책용 셀 등록
        tableView.register(RecentBooksTableCell.self, forCellReuseIdentifier: RecentBooksTableCell.id)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.delegate = self
    }
    
    // MARK: - 오토레이아웃
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
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // MARK: - Delegate 설정
    private func setupDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Kakao API 호출
    private func fetchBooks(query: String) {
        let apiKey = Secret.kakaoAPIKey
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://dapi.kakao.com/v3/search/book?query=\(encodedQuery)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("KakaoAK \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            if let error = error {
                print("네트워크 오류:", error.localizedDescription)
                return
            }
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(KakaoBookResponse.self, from: data)
                DispatchQueue.main.async {
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
        isSearching = true
        fetchBooks(query: keyword)
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            tableView.reloadData()
        }
    }
}

// MARK: - UITableView
extension BookSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return recentBooks.isEmpty ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !recentBooks.isEmpty && section == 0 {
            return 1 // 최근 본 책은 항상 한 줄
        } else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !recentBooks.isEmpty && indexPath.section == 0 {
            return 140 // 최근 본 책 영역 높이
        }
        return 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !recentBooks.isEmpty && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: RecentBooksTableCell.id, for: indexPath) as! RecentBooksTableCell
            cell.collectionView.dataSource = self
            cell.collectionView.delegate = self
            cell.collectionView.register(RecentBookCell.self, forCellWithReuseIdentifier: RecentBookCell.id)
            cell.collectionView.reloadData()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath)
            let book = searchResults[indexPath.row]
            cell.textLabel?.text = book.title
                .replacingOccurrences(of: "<b>", with: "")
                .replacingOccurrences(of: "</b>", with: "")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedBook: Book
        if !recentBooks.isEmpty && indexPath.section == 0 {
            selectedBook = recentBooks[indexPath.row]
        } else {
            let item = searchResults[indexPath.row]
            selectedBook = Book(
                title: item.title.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: ""),
                authors: item.authors,
                contents: item.contents,
                thumbnail: item.thumbnail,
                price: item.price
            )
        }
        
        if let existingIndex = recentBooks.firstIndex(where: { $0.title == selectedBook.title }) {
            recentBooks.remove(at: existingIndex)
        }
        recentBooks.insert(selectedBook, at: 0)
        if recentBooks.count > 10 {
            recentBooks.removeLast()
        }
        
        RecentBooksStore.save(recentBooks)
        
        let detailVC = BookDetailViewController()
        detailVC.book = selectedBook
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true)
    }
}

// MARK: - UICollectionView
extension BookSearchViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recentBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentBookCell.id, for: indexPath) as! RecentBookCell
        cell.configure(with: recentBooks[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedBook = recentBooks[indexPath.row]
        let detailVC = BookDetailViewController()
        detailVC.book = selectedBook
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true)
    }
}
