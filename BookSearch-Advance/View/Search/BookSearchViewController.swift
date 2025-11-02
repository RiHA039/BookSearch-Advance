//
//  BookSearchViewController.swift
//  BookSearch-Advance
//
//  Created by 김리하 on 10/28/25.
//

import UIKit
import SnapKit

// MARK: - Kakao API 응답 모델 (그대로 둬도 됨)
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

// MARK: - 최근 본 책 셀
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

// MARK: - 책 검색 화면 (MVVM 적용)
class BookSearchViewController: UIViewController {
    
    // ViewModel 연결
    private let viewModel = BookSearchViewModel()
    
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
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "검색"
        
        setupLayout()
        setupDelegate()
        bindViewModel()
        
        // 최근 본 책용 셀 등록
        tableView.register(RecentBooksTableCell.self, forCellReuseIdentifier: RecentBooksTableCell.id)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.delegate = self
    }
    
    // MARK: - ViewModel 바인딩
    private func bindViewModel() {
        // ViewModel의 onUpdate가 호출되면 테이블뷰 리로드
        viewModel.onUpdate = { [weak self] in
            self?.tableView.reloadData()
        }
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
}

// MARK: - UISearchBarDelegate
extension BookSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text, !keyword.isEmpty else { return }
        viewModel.searchBooks(query: keyword) // ViewModel에 검색 위임
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            tableView.reloadData()
        }
    }
}

// MARK: - UITableView
extension BookSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.recentBooks.isEmpty ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !viewModel.recentBooks.isEmpty && section == 0 {
            return 1
        } else {
            return viewModel.books.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !viewModel.recentBooks.isEmpty && indexPath.section == 0 {
            return 140
        }
        return 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !viewModel.recentBooks.isEmpty && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: RecentBooksTableCell.id, for: indexPath) as! RecentBooksTableCell
            cell.collectionView.dataSource = self
            cell.collectionView.delegate = self
            cell.collectionView.register(RecentBookCell.self, forCellWithReuseIdentifier: RecentBookCell.id)
            cell.collectionView.reloadData()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath)
            let book = viewModel.books[indexPath.row]
            cell.textLabel?.text = book.title
                .replacingOccurrences(of: "<b>", with: "")
                .replacingOccurrences(of: "</b>", with: "")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedBook: Book
        if !viewModel.recentBooks.isEmpty && indexPath.section == 0 {
            selectedBook = viewModel.recentBooks[indexPath.row]
        } else {
            let item = viewModel.books[indexPath.row]
            selectedBook = Book(
                title: item.title.replacingOccurrences(of: "<b>", with: "").replacingOccurrences(of: "</b>", with: ""),
                authors: item.authors,
                contents: item.contents,
                thumbnail: item.thumbnail,
                price: item.price
            )
        }
        
        viewModel.saveRecent(selectedBook) // 최근 본 책 저장 로직 이동 완료
        
        let detailVC = BookDetailViewController()
        detailVC.viewModel = BookDetailViewModel(book: selectedBook) // ViewModel 전달
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true)

    }
}

// MARK: - UICollectionView
extension BookSearchViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.recentBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentBookCell.id, for: indexPath) as! RecentBookCell
        cell.configure(with: viewModel.recentBooks[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedBook = viewModel.recentBooks[indexPath.row]
        let detailVC = BookDetailViewController()
        detailVC.viewModel = BookDetailViewModel(book: selectedBook)
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true)
    }

}

