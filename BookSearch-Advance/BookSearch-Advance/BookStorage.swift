//
//  BookStorage.swift
//  BookSearch-Advance
//
//  Created by 김리하 on 10/29/25.
//

import Foundation

// 앱 내에서 선택한 책들을 임시로 저장하는 싱글톤 클래스
// 추후 변경 예정 (CoreData)
final class BookStorage {
    static let shared = BookStorage() // 전역에서 접근 가능
    private init() {}
    
    private var savedBooks: [Book] = [] // 저장된 책 배열
    
    // 책 추가
    func addBook(_ book: Book) {
        print("저장됨", book.title)
        savedBooks.append(book)
    }
    
    // 저장된 모든 책 가져오기
    func getAllBooks() -> [Book] {
        print("저장된 목록:", savedBooks.map { $0.title })
        return savedBooks
    }
}
