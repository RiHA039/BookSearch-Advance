//
//  RecentBooksCollectionCell.swift
//  BookSearch-Advance
//
//  Created by 김리하 on 11/2/25.
//

import UIKit
import SnapKit

final class RecentBooksCollectionCell: UICollectionViewCell {
    static let id = "RecentBooksCollectionCell"
    
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
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        imageView.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
            $0.width.height.equalTo(60)   // 동그라미 크기
        }
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemGray5
        
        titleLabel.font = .systemFont(ofSize: 11)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(2)
        }
    }
    
    func configure(with book: Book) {
        titleLabel.text = book.title
        
        if let urlStr = book.thumbnail, let url = URL(string: urlStr) {
            // 간단한 썸네일 로딩
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url),
                   let img = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.imageView.image = img
                    }
                }
            }
        } else {
            // 썸네일 없을 때 대체 이미지
            imageView.image = UIImage(systemName: "book.fill")
            imageView.tintColor = .systemGray2
        }
    }
}

