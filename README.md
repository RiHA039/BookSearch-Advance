# 📚 BookSearch-Advance  
**Kakao API 기반 도서 검색 & CoreData 저장 앱 (MVVM 구조)**  

---

## 🧭 프로젝트 개요  

> 사용자가 책을 검색하고, 상세 정보를 확인하며,  
> 원하는 책을 **담기/저장**할 수 있는 iOS 앱입니다.  
>  
> Kakao Book REST API를 통해 데이터를 받아오고,  
> Core Data를 활용하여 담은 책 정보를 영구 저장합니다.  

---

## 🧩 개발 환경  
| 항목 | 내용 |
|------|------|
| **UI 프레임워크** | UIKit + SnapKit |
| **데이터 저장소** | Core Data + UserDefaults |
| **아키텍처 패턴** | MVVM (Model–View–ViewModel) |
| **API** | Kakao Developers Book Search API |

---

## 🧱 프로젝트 구조 (폴더별 역할)



---

## ⚙️ 핵심 기능

### 1️⃣ 도서 검색 (Kakao REST API)
- `BookSearchViewModel`에서 API 통신 및 디코딩 담당  
- `BookSearchViewController`는 결과를 테이블뷰로 표시  

```swift
func searchBooks(query: String) {
    let apiKey = Secret.kakaoAPIKey
    let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
    guard let url = URL(string: "https://dapi.kakao.com/v3/search/book?query=\(encodedQuery)") else { return }
    
    var request = URLRequest(url: url)
    request.setValue("KakaoAK \(apiKey)", forHTTPHeaderField: "Authorization")
    
    URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
        if let data = data {
            let decoded = try? JSONDecoder().decode(KakaoBookResponse.self, from: data)
            self?.books = decoded?.documents ?? []
            DispatchQueue.main.async { self?.onUpdate?() }
        }
    }.resume()
}
```
- 네트워크 로직을 ViewModel로 분리하여 ViewController의 코드 복잡도를 줄임
- 비동기 호출 후 `onUpdate` 클로저로 UI 갱신 트리거

### 2️⃣ 최근 본 책 관리 (UserDefaults)
- `RecentBooksStore` 구조체로 구현
- 검색 결과 클릭 시 최근 본 책 목록에 자동 추가
```swift
static func add(_ book: Book) {
    var current = load()
    if let idx = current.firstIndex(of: book) {
        current.remove(at: idx)
    }
    current.insert(book, at: 0)
    if current.count > 10 { current.removeLast() }
    save(current)
}
```
- 간단한 데이터이므로 UserDefaults로 관리
- 최근 검색 내역 최대 10개까지만 저장하도록 제한

### 3️⃣ 책 상세 화면 (BookDetailViewController + BookDetailViewModel)
- `BookDetailViewModel`이 CoreData 저장 담당
- ViewController는 UI 렌더링과 버튼 액션만 담당

```swift
@objc private func saveBook() {
    viewModel?.saveBook()   // ViewModel에 저장 로직 위임
    dismiss(animated: true)
}
```
- CoreData 접근을 ViewModel로 분리 -> ViewController의 책임 최소화
- MVVM 패턴에 맞게 단방향 데이터 흐름 유지

### 4️⃣ 담은 책 리스트 (SavedBooksViewController + SavedBooksViewModel)
- CoreData에 저장된 책들을 리스트로 표시
- 스와이프 삭제 및 전체 삭제 기능
```swift
func deleteBook(at index: Int) {
    CoreDataManager.shared.deleteBook(savedBooks[index])
    fetchBooks()
}
```
- CoreData 연산을 ViewModel로 옮겨 코드 중복 방지
- View는 단순히 ViewModel 데이터를 표시만 함

- ---

## 🧠 MVVM 구조 요약

| 계층 | 담당 역할 | 주요 파일 |
|------|------------|-----------|
| **Model** | 데이터 구조 정의, CoreData 및 UserDefaults 관리 | `Book.swift`, `CoreDataManager.swift`, `BookDataModel.xcdatamodeld` |
| **ViewModel** | 비즈니스 로직 처리, View 업데이트 트리거 | `BookSearchViewModel.swift`, `BookDetailViewModel.swift`, `SavedBooksViewModel.swift` |
| **View** | UI 표시, 사용자 입력 처리 | `BookSearchViewController.swift`, `BookDetailViewController.swift`, `SavedBooksViewController.swift` |

> ✅ **핵심 아이디어:**  
> - View는 ViewModel이 제공하는 데이터만 표시  
> - ViewModel은 Model에 직접 접근하여 데이터 조작  
> - Controller가 단순해지고 테스트/유지보수가 용이함  

---

## 💾 Core Data 구조

**Entity: BookEntity**

| Attribute | Type | 설명 |
|------------|------|------|
| title | String | 책 제목 |
| author | String | 저자 이름 |
| contents | String | 책 설명 |
| thumbnail | String (Optional) | 썸네일 이미지 URL |
| price | Integer 64 | 책 가격 |

> CoreDataManager에서 CRUD(저장, 불러오기, 삭제, 전체삭제)를 관리  

---

## 🧰 사용한 주요 기술 및 이유

| 기술 | 역할 | 사용 이유 |
|------|------|-----------|
| **UIKit** | 화면 UI 구성 | 명시적인 View 계층 제어 및 세밀한 레이아웃 조정 가능 |
| **SnapKit** | AutoLayout DSL | 제약조건을 간결하게 작성하고 코드 가독성 향상 |
| **CoreData** | 데이터 영구 저장 | 담은 책 정보를 로컬 DB로 관리 |
| **UserDefaults** | 최근 본 책 캐시 | 간단한 Key-Value 저장소로 빠른 접근 |
| **MVVM 패턴** | 구조화된 아키텍처 | View와 비즈니스 로직을 분리하여 유지보수성 강화 |
| **Kakao REST API** | 외부 데이터 통신 | 도서 검색 기능 구현 |
| **Codable** | JSON 직렬화 | API 응답을 Swift 객체로 간단히 디코딩 |

---

## 📊 데이터 흐름 구조

**데이터의 이동 방향**

> 사용자 입력에서 Model까지의 흐름을 단방향으로 표현

**Flow:**

사용자 입력 ⮕ **ViewController**  
↕ *(bind / update)*  
**ViewModel**  
↕  
**Model**

---

**예시 흐름: 책 검색**

1. 사용자가 검색어 입력  
2. `BookSearchViewController` → `BookSearchViewModel.searchBooks()` 호출  
3. Kakao API 호출 후 JSON 디코딩  
4. ViewModel의 `books` 배열 갱신  
5. `onUpdate` 클로저 실행 → ViewController에서 `tableView.reloadData()` 수행



