//
//  BookDetailViewController.swift
//  BookSearch-Advance
//
//  Created by 김리하 on 10/28/25.
//

//import UIKit
//import SnapKit
//

import UIKit
import SnapKit

// MARK: - 책 상세 화면
final class BookDetailViewController: UIViewController {
    
    // MARK: - ViewModel 연결
    var viewModel: BookDetailViewModel?   // ViewModel 추가
    
    // MARK: - UI 요소
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let thumbnailImageView = UIImageView()
    private let priceLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let saveButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupLayout()
        configureBookData()   // ViewModel의 데이터로 UI 구성
    }
    
    // MARK: - UI 설정
    private func setupUI() {
        // 제목
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        // 저자
        authorLabel.font = .systemFont(ofSize: 16, weight: .medium)
        authorLabel.textAlignment = .center
        authorLabel.textColor = .darkGray
        authorLabel.numberOfLines = 0
        
        // 썸네일
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.layer.cornerRadius = 8
        thumbnailImageView.clipsToBounds = true
        
        // 가격
        priceLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        priceLabel.textAlignment = .center
        priceLabel.textColor = .black
        
        // 설명
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.textColor = .gray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .left
        
        // 담기 버튼
        saveButton.setTitle("담기", for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        saveButton.backgroundColor = .systemBlue
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 10
        saveButton.addTarget(self, action: #selector(saveBook), for: .touchUpInside)
        
        // 닫기 버튼
        closeButton.setTitle("X", for: .normal)
        closeButton.tintColor = .darkGray
        closeButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        closeButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
        
        [titleLabel, authorLabel, thumbnailImageView, descriptionLabel, priceLabel, saveButton, closeButton].forEach {
            view.addSubview($0)
        }
    }
    
    // MARK: - 오토레이아웃
    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        thumbnailImageView.snp.makeConstraints {
            $0.top.equalTo(authorLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(180)
            $0.height.equalTo(350)
        }
        
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(thumbnailImageView.snp.bottom).offset(-20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(thumbnailImageView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(300)
            $0.height.equalTo(60)
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(saveButton)
            $0.trailing.equalTo(saveButton.snp.leading).offset(10)
            $0.width.equalTo(saveButton.snp.width).multipliedBy(0.33)
            $0.height.equalTo(saveButton)
        }
    }
    
    // MARK: - 데이터 표시
    private func configureBookData() {
        guard let book = viewModel?.book else { return }
        
        titleLabel.text = book.title
        
        // 저자
        if !book.authors.isEmpty {
            authorLabel.text = "저자: " + book.authors.joined(separator: ", ")
        } else {
            authorLabel.text = "저자 정보 없음"
        }
        
        // 가격
        if let price = book.price {
            priceLabel.text = "가격: \(price)원"
        } else {
            priceLabel.text = "가격 정보 없음"
        }
        
        // 설명
        if !book.contents.isEmpty {
            descriptionLabel.text = book.contents
        } else {
            descriptionLabel.text = "책 설명이 없습니다."
        }
        
        // 썸네일
        if let urlString = book.thumbnail, let url = URL(string: urlString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.thumbnailImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }

    
    // MARK: - 버튼 액션
    @objc private func saveBook() {
        viewModel?.saveBook()   // ViewModel을 통해 CoreData 저장
        dismiss(animated: true)
    }
    
    @objc private func closeModal() {
        dismiss(animated: true)
    }
}

