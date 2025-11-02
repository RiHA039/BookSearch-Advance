//
//  SavedBooksViewModel.swift
//  BookSearch-Advance
//
//  Created by 김리하 on 11/2/25.
//

import Foundation
import CoreData

final class SavedBooksViewModel {
    private(set) var savedBooks: [BookEntity] = []
    var onUpdate: (() -> Void)?
    
    func fetchBooks() {
        savedBooks = CoreDataManager.shared.fetchBooks()
        onUpdate?()
    }
    
    func deleteBook(at index: Int) {
        CoreDataManager.shared.deleteBook(savedBooks[index])
        fetchBooks()
    }
    
    func deleteAllBooks() {
        CoreDataManager.shared.deleteAllBooks()
        fetchBooks()
    }
}

