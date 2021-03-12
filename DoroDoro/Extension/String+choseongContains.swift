//
//  String+choseongContains.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/4/21.
//

import Foundation

extension String {
    internal func choseongContains(_ text: String) -> Bool {
        guard text.count > 0 else { return true }
        
        let chosung = self
            // 자모 분리
            .map { str in
                return Jamo.getJamo(String(str))
            }
            
            // 초성 분리
            .compactMap { str -> String? in
                guard let firstJamo = str.first,
                      Jamo.CHO.contains(String(firstJamo)) else {
                    return nil
                }
                return String(firstJamo)
            }
            .joined(separator: "")
        
        let processedSearchText: String = text
            .map { String($0) }
            .filter { $0 != " " }
            .joined(separator: "")
        
        return chosung.contains(processedSearchText)
    }
}

/* https://github.com/hyunsoogo/Jamo-swift */

fileprivate final class Jamo {
    // UTF-8 기준
    fileprivate static let INDEX_HANGUL_START:UInt32 = 44032  // "가"
    fileprivate static let INDEX_HANGUL_END:UInt32 = 55199    // "힣"
    
    fileprivate static let CYCLE_CHO :UInt32 = 588
    fileprivate static let CYCLE_JUNG :UInt32 = 28
    
    fileprivate static let CHO = [
        "ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ",
        "ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
    ]
    
    fileprivate static let JUNG = [
        "ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ","ㅕ", "ㅖ", "ㅗ", "ㅘ",
        "ㅙ", "ㅚ","ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ",
        "ㅣ"
    ]
    
    fileprivate static let JONG = [
        "","ㄱ","ㄲ","ㄳ","ㄴ","ㄵ","ㄶ","ㄷ","ㄹ","ㄺ",
        "ㄻ","ㄼ","ㄽ","ㄾ","ㄿ","ㅀ","ㅁ","ㅂ","ㅄ","ㅅ",
        "ㅆ","ㅇ","ㅈ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"
    ]
    
    fileprivate static let JONG_DOUBLE = [
        "ㄳ":"ㄱㅅ","ㄵ":"ㄴㅈ","ㄶ":"ㄴㅎ","ㄺ":"ㄹㄱ","ㄻ":"ㄹㅁ",
        "ㄼ":"ㄹㅂ","ㄽ":"ㄹㅅ","ㄾ":"ㄹㅌ","ㄿ":"ㄹㅍ","ㅀ":"ㄹㅎ",
        "ㅄ":"ㅂㅅ"
    ]
    
    // 주어진 "단어"를 자모음으로 분해해서 리턴하는 함수
    fileprivate class func getJamo(_ input: String) -> String {
        var jamo = ""
        //let word = input.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .punctuationCharacters)
        for scalar in input.unicodeScalars{
            jamo += getJamoFromOneSyllable(scalar) ?? ""
        }
        return jamo
    }
    
    // 주어진 "코드의 음절"을 자모음으로 분해해서 리턴하는 함수
    private class func getJamoFromOneSyllable(_ n: UnicodeScalar) -> String?{
        if CharacterSet(charactersIn: ("가".unicodeScalars.first!)...("힣".unicodeScalars.first!)).contains(n){
            let index = n.value - INDEX_HANGUL_START
            let cho = CHO[Int(index / CYCLE_CHO)]
            let jung = JUNG[Int((index % CYCLE_CHO) / CYCLE_JUNG)]
            var jong = JONG[Int(index % CYCLE_JUNG)]
            if let disassembledJong = JONG_DOUBLE[jong] {
                jong = disassembledJong
            }
            return cho + jung + jong
        }else{
            return String(UnicodeScalar(n))
        }
    }
}
