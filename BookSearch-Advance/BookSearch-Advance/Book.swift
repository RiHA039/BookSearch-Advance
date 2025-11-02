//
//  Book.swift
//  BookSearch-Advance
//
//  Created by 김리하 on 10/29/25.
//

import Foundation

// 책 정보를 담는 데이터 모델
import Foundation

struct Book: Codable, Equatable {
    let title: String
    let authors: [String]
    let contents: String
    let thumbnail: String?
    let price: Int?
}

