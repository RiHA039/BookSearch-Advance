//
//  BookDetailViewController.swift
//  BookSearch-Advance
//
//  Created by 김리하 on 10/28/25.
//

import UIKit
import SnapKit

class BookDetailViewController: UIViewController {
    
    var book: Book? // 전달받은 책 정보
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let saveButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        
        descriptionLabel.font = .systemFont(ofSize: 17)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        
        saveButton.setTitle("담기", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.tintColor = .white
        saveButton.layer.cornerRadius = 8
        saveButton.addTarget(self, action: #selector(saveBook), for: .touchUpInside)
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(saveButton)
        
        // 오토레이아웃 설정 (추후 수정 예정)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(30)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(120)
            $0.height.equalTo(44)
        }
        
        titleLabel.text = book?.title
        descriptionLabel.text = book?.description
    }
    
    // 담기 버튼 동작
    @objc private func saveBook() {
        guard let book = book else { return }
        BookStorage.shared.addBook(book)
        dismiss(animated: true)
    }
}
