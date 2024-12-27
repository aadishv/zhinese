//
//  Term.swift
//  zhinese
//
//  Created by Aadish Verma on 12/24/24.
//

import Foundation
import CoreGraphics
import SwiftUI
enum StrokesErrors: Error {
    case missingCharacterData
    case pinyinParsingError
}
enum PinyinError: Error {
    
}
let spaceCharacter = CharacterData(medians: [[CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 500)]], strokes: [""])
struct Term: Codable, Identifiable {
    var english: String
    var pinyin: Pinyin
    var character: String
    var id: UUID = UUID()
    func getCharacterData() throws -> [Stroke]  {
        // load in all characters from assets
        do {
            let fileURL = Bundle.main.url(forResource: "characterdata", withExtension: "json")!
            let data = try Data(contentsOf: fileURL)
            let loadedData = try JSONDecoder().decode([String: CharacterData].self, from: data)
            //loadedData[" "] = spaceCharacter
            
            
            
            let adjustedCharacter = self.character.contains(" ") ? self.character : self.character + " "
            
            let characterData = adjustedCharacter
                .compactMap { return loadedData[String($0)] }
                .map { $0.getStrokes() }
            
            let combinedStrokes = (0..<characterData.count).map {
                let totalWidthPrevChars = (0..<$0).map {
                    characterData[$0].map { $0.path.boundingRect }.reduce(CGRect.zero, { $0.union($1) }).width
                }.reduce(0, +)
                return characterData[$0].map {
                    Stroke(path: $0.path.offsetBy(dx: totalWidthPrevChars, dy: 0), medianPath: $0.medianPath.offsetBy(dx: totalWidthPrevChars, dy: 0))
                }
            }
            return combinedStrokes.reduce([], +)
        }
        catch {
            throw StrokesErrors.missingCharacterData
        }
    }
    static let ni = Self(english: "you", pinyin: Pinyin("ni3"), character: "你")
    static let empty = Self(english: "", pinyin: Pinyin(""), character: "")
}
struct Pinyin: Codable {
    let words: [String]
    let tones: [Int]
    init(_ numberedString: String) {
        let regex = /[a-z]+[0-5]?/ // this should work for syllables (according to gemini...?)
        let matches2 = numberedString.ranges(of: regex).map { String( numberedString[$0] ) }
        words = matches2.map { a in
            return a.filter { return !("012345".contains($0)) }
        }
        let intRegex = /[0-5]/
        
        tones = matches2.map { m in
            let match = try! intRegex.firstMatch(in: m)?.range
            if let range = match {
                return Int(m[range])!
            } else { return 0 }
        }
    }
    func getNumberedString() -> String {
        return (0..<words.count).map { words[$0] + String(tones[$0]) }.joined(separator: " ")
    }
    func render() throws -> String {
        let toneMap: [String: [String]] = [
            "a": ["a", "ā", "á", "ǎ", "à", "a"],
            "e": ["e", "ē", "é", "ě", "è", "e"],
            "i": ["i", "ī", "í", "ǐ", "ì", "i"],
            "o": ["o", "ō", "ó", "ǒ", "ò", "o"],
            "u": ["u", "ū", "ú", "ǔ", "ù", "u"],
            "ü": ["ü", "ǖ", "ǘ", "ǚ", "ǜ", "ü"]
        ]
        let precedence = ["a", "o", "e", "i", "u", "ü"]
        var final = ""

        for (word, tone) in zip(words, tones) {
            let vowels = word.indices.filter { "aeiouü".contains(word[$0]) }

            guard let bestVowelIndex = try vowels.min(by: {
                guard let firstIndex = precedence.firstIndex(of: String(word[$0])),
                      let secondIndex = precedence.firstIndex(of: String(word[$1])) else {
                          throw StrokesErrors.pinyinParsingError
                      }
                return firstIndex < secondIndex
            }) else {
                throw StrokesErrors.pinyinParsingError
            }

            guard let replacements = toneMap[String(word[bestVowelIndex])], tone >= 0, tone < replacements.count else {
                throw StrokesErrors.pinyinParsingError
            }

            let replacement = replacements[tone]
            let first = String(word[..<bestVowelIndex])
            let middle = String(replacement)
            let end = String(word[word.index(after: bestVowelIndex)...])
            final += first + middle + end + " "
        }

        return final
    }
}
struct CharacterData: Codable {
    var medians: [[CGPoint]]
    var strokes: [String]
    var radStrokes: [Int]? // Optional to handle missing 'radStrokes'

    init(medians: [[[Int]]], strokes: [String]) {
        self.medians = medians.map { a in a.map { CGPoint(x: $0[0], y: $0[1]) } }
        self.strokes = strokes
    }
    init(medians: [[CGPoint]], strokes: [String]) {
        self.medians = medians
        self.strokes = strokes
    }
    func getStrokes() -> [Stroke] {
        return (0..<strokes.count).map {
            Stroke(svgString: strokes[$0], medians: medians[$0])
        }
    }
}

typealias TermSet = [Term]
