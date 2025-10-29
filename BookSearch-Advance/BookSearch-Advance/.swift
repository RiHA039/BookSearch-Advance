//
//  InMemoryBookRepository.swift
//  BookSearch-Advance
//
//  Created by 김리하 on 10/29/25.
//

import Foundation

protocol BookRepository {
    var item: [Book] { get }
    func add(_ book: Book)
    func remove(at index: Int)
    func ovserve(_ handler: @escaping) ([Book]) -> Void)
}

