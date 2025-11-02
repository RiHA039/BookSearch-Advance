//
//  RecentBooksStore.swift
//  BookSearch-Advance
//
//  Created by 김리하 on 11/2/25.
//

import Foundation


enum RecentBooksStore {
    
    // UserDefaults에 저장할 Key 이름
    private static let key = "recentBooks"
    
    // 최대 저장 개수 (10개까지만 저장)
    private static let limit = 10
    
    
    // MARK: - 최근 본 책 불러오기
    static func load() -> [Book] {
        // 디코더로 복원
        let decoder = JSONDecoder()
        guard let data = UserDefaults.standard.data(forKey: key),
              let books = try? decoder.decode([Book].self, from: data)
        else {
            return [] // 저장된 게 없으면 빈 배열 리턴
        }
        return books
    }
    
    
    // MARK: - 최근 본 책 저장하기
    static func save(_ books: [Book]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(books) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    
    // MARK: - 최근 본 책 추가하기 (중복 제거 + 10개 제한)
    static func add(_ book: Book) {
        var current = load()
        
        // 중복 제거
        if let idx = current.firstIndex(of: book) {
            current.remove(at: idx)
        }
        
        // 새 책을 맨 앞에 추가
        current.insert(book, at: 0)
        
        // 10개 초과 시 뒤쪽 삭제
        if current.count > limit {
            current.removeLast(current.count - limit)
        }
        
        // 저장
        save(current)
    }
}
