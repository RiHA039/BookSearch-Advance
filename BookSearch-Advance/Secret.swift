//
//  Secret.swift
//  BookSearch-Advance
//
//  Created by 김리하 on 10/30/25.
//

import Foundation


enum Secret {
    static var kakaoAPIKey: String {
        guard
            let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
            let key = dict["KAKAO_API_KEY"] as? String,
            !key.isEmpty
        else {
            #if DEBUG
            fatalError("KAKAO_API_KEY가 비어있거나 APIKey.plist를 찾을 수 없습니다. APIKeys.sample.plist를 복사해 채워주세요.")
            #else
            return ""
            #endif
        }
        return key
    }
}
