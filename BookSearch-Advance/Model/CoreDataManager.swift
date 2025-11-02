//
//  CoreDataManager.swift
//  BookSearch-Advance
//
//  Created by 김리하 on 11/2/25.
//

import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    // MARK: - Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "BookDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData 로드 실패: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - CRUD
    
    // 책 저장
    func addBook(_ book: Book) {
        let entity = BookEntity(context: context)
        entity.title = book.title
        entity.author = book.authors.joined(separator: ", ")
        entity.contents = book.contents
        entity.thumbnail = book.thumbnail
        entity.price = Int64(book.price ?? 0)
        saveContext()
        print("책 저장 완료:", book.title)
    }
    
    // 모든 책 불러오기
    func fetchBooks() -> [BookEntity] {
        let request: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        do {
            let result = try context.fetch(request)
            return result
        } catch {
            print("Fetch 실패:", error)
            return []
        }
    }
    
    // 개별 책 삭제
    func deleteBook(_ book: BookEntity) {
        context.delete(book)
        saveContext()
        print("개별 책 삭제 완료:", book.title ?? "")
    }
    
    // 전체 삭제
    func deleteAllBooks() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = BookEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            saveContext()
            print("전체 책 삭제 완료")
        } catch {
            print("전체 삭제 실패:", error)
        }
    }
    
    // 변경사항 저장
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("CoreData 저장 완료")
            } catch {
                print("CoreData 저장 실패:", error)
            }
        }
    }
}
