//
//  Term.swift
//  zhinese
//
//  Created by Aadish Verma on 12/24/24.
//

import CoreGraphics
import Foundation
import SwiftData
import SwiftUI

enum StrokesErrors: Error {
    case missingCharacterData
    case pinyinParsingError
}

enum PinyinError: Error {

}

let spaceCharacter = CharacterData(
    medians: [[CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 500)]], strokes: [""])

@Model
class Term {
    init(english: String, pinyin: Pinyin, character: String, srsState: SRSTermInfo = SRSTermInfo.new, tags: [String] = []) {
        self.english = english
        self.pinyin = pinyin
        self.character = character
        self.srsState = srsState
        self.tags = tags
    }
    
    var english: String
    var pinyin: Pinyin
    var character: String
    var srsState = SRSTermInfo.new
    var tags: [String] = []
    

    var id: String {
        character + pinyin.getNumberedString() + english
    }

    func getCharacterData() throws -> [Stroke] {
        do {
            let fileURL = Bundle.main.url(forResource: "characterdata", withExtension: "json")!
            let data = try Data(contentsOf: fileURL)
            let loadedData = try JSONDecoder().decode([String: CharacterData].self, from: data)

            let adjustedCharacter = character.contains(" ") ? character : character + " "

            let characterData =
                adjustedCharacter
                .compactMap { loadedData[String($0)] }
                .map { $0.getStrokes() }

            return calculateCombinedStrokes(from: characterData)
        } catch {
            throw StrokesErrors.missingCharacterData
        }
    }

    private func calculateCombinedStrokes(from characterData: [[Stroke]]) -> [Stroke] {
        let combinedStrokes = (0..<characterData.count).map { index in
            let totalWidthPrevChars = calculateTotalWidth(upTo: index, in: characterData)
            return characterData[index].map { stroke in
                Stroke(
                    path: stroke.path.offsetBy(dx: totalWidthPrevChars, dy: 0),
                    medianPath: stroke.medianPath.offsetBy(dx: totalWidthPrevChars, dy: 0)
                )
            }
        }
        return combinedStrokes.reduce([], +)
    }

    private func calculateTotalWidth(upTo index: Int, in data: [[Stroke]]) -> CGFloat {
        (0..<index).map { i in
            data[i].map { $0.path.boundingRect }.reduce(CGRect.zero, { $0.union($1) }).width
        }.reduce(0, +)
    }

    static let ni = Term(english: "you", pinyin: Pinyin("ni3"), character: "你")
    static let empty = Term(english: "", pinyin: Pinyin(""), character: "")
}

struct Pinyin: Codable {
    let words: [String]
    let tones: [Int]

    init(_ s: String) {
        let numberedString = s.lowercased().replacingOccurrences(of: "v", with: "ü")
        let regex = try! Regex("[a-zü]+[0-5]?")
        let matches = numberedString.ranges(of: regex).map { String(numberedString[$0]) }
        words = matches.map { $0.filter { !("012345".contains($0)) } }
        let intRegex = try! Regex("[0-5]")
        tones = matches.map { match in
            if let range = try? intRegex.firstMatch(in: match)?.range {
                return Int(match[range])!
            }
            return 0
        }
    }

    func getNumberedString() -> String {
        zip(words, tones).map { word, tone in
            word.replacingOccurrences(of: "ü", with: "v") + String(tone)
        }.joined(separator: " ")
    }

    func render() throws -> String {
        let toneMap = PinyinToneMap()
        var final = ""

        for (word, tone) in zip(words, tones) {
            final += try renderSyllable(word: word, tone: tone, toneMap: toneMap)
        }

        return final
    }

    private func renderSyllable(word: String, tone: Int, toneMap: PinyinToneMap) throws -> String {
        let vowels = word.indices.filter { "aeiouü".contains(word[$0]) }

        guard let bestVowelIndex = try findBestVowelIndex(in: word, vowels: vowels),
            let replacements = toneMap.map[String(word[bestVowelIndex])],
            tone >= 0 && tone < replacements.count
        else {
            throw StrokesErrors.pinyinParsingError
        }

        return buildSyllable(word: word, at: bestVowelIndex, with: replacements[tone])
    }

    private func findBestVowelIndex(in word: String, vowels: [String.Index]) throws -> String.Index?
    {
        let precedence = ["a", "o", "e", "i", "u", "ü"]
        return try vowels.min { a, b in
            guard let firstIndex = precedence.firstIndex(of: String(word[a])),
                let secondIndex = precedence.firstIndex(of: String(word[b]))
            else {
                throw StrokesErrors.pinyinParsingError
            }
            return firstIndex < secondIndex
        }
    }

    private func buildSyllable(word: String, at index: String.Index, with replacement: String)
        -> String
    {
        let first = String(word[..<index])
        let end = String(word[word.index(after: index)...])
        return first + replacement + end + " "
    }
}

private struct PinyinToneMap {
    let map = [
        "a": ["a", "ā", "á", "ǎ", "à", "a"],
        "e": ["e", "ē", "é", "ě", "è", "e"],
        "i": ["i", "ī", "í", "ǐ", "ì", "i"],
        "o": ["o", "ō", "ó", "ǒ", "ò", "o"],
        "u": ["u", "ū", "ú", "ǔ", "ù", "u"],
        "ü": ["ü", "ǖ", "ǘ", "ǚ", "ǜ", "ü"],
    ]
}

struct CharacterData: Codable {
    var medians: [[CGPoint]]
    var strokes: [String]
    var radStrokes: [Int]?

    init(medians: [[[Int]]], strokes: [String]) {
        self.medians = medians.map { points in
            points.map { CGPoint(x: $0[0], y: $0[1]) }
        }
        self.strokes = strokes
    }

    init(medians: [[CGPoint]], strokes: [String]) {
        self.medians = medians
        self.strokes = strokes
    }

    func getStrokes() -> [Stroke] {
        (0..<strokes.count).map {
            Stroke(svgString: strokes[$0], medians: medians[$0])
        }
    }
}
typealias TermSet = [Term]
