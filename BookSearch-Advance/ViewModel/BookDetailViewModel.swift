//
//  BookDetailViewModel.swift
//  BookSearch-Advance
//
//  Created by 김리하 on 11/2/25.
//

import Foundation

final class BookDetailViewModel {
    let book: Book
    init(book: Book) {
        self.book = book
    }
    
    func saveBook() {
        CoreDataManager.shared.addBook(book)
    }
}

