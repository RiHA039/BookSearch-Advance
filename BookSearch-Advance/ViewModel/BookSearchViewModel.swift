//
//  BookSearchViewModel.swift
//  BookSearch-Advance
//
//  Created by 김리하 on 11/2/25.
//

import Foundation

final class BookSearchViewModel {
    private(set) var books: [BookDocument] = []
    private(set) var recentBooks: [Book] = RecentBooksStore.load()
    
    var onUpdate: (() -> Void)?
    
    func searchBooks(query: String) {
        let apiKey = Secret.kakaoAPIKey
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        guard let url = URL(string: "https://dapi.kakao.com/v3/search/book?query=\(encodedQuery)") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("KakaoAK \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            if let error = error {
                print("네트워크 오류:", error)
                return
            }
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(KakaoBookResponse.self, from: data)
                self?.books = decoded.documents
                DispatchQueue.main.async { self?.onUpdate?() }
            } catch {
                print("디코딩 오류:", error)
            }
        }.resume()
    }
    
    func saveRecent(_ book: Book) {
        RecentBooksStore.add(book)
        recentBooks = RecentBooksStore.load()
    }
}

