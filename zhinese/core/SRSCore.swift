//
//  SRSCore.swift
//  zhinese
//
//  Created by Aadish Verma on 12/27/24.
//
import Foundation

/// # HOW EVALUATIONS WILL DETERMINE THE NEXT REVIEW
/// actual n/calced n = quality of response
/// 5/6 = all perfect
/// 4/5 = one good, one perfect
/// 3/4 = both good
/// 2/3 = one good, one bad
/// 1/2 = both bad
///
/// Range between
/// Perfect: 3 and Bad: 1
///
/// Characters: 2.5-3 is varying levels of correct stroke order, 2-2.5 is varying levels of correct character, 1-2 is varying levels of MCQs
/// Pinyin: 2-3 is varying levels of correct tones, 1.5-2 is varying levels of correct syllables, 1-1.5 is varying levels of MCQs
///
/// Add character and pinyin scores together, then subtract 1 to get total score (between 1.0 and 5.0, inclusive)
struct SRSTermInfo: Codable {  // all times in days
    static var new = SRSTermInfo(history: [], efactor: 2.5, interval: 30.0 * 1.0 / (24.0 * 60.0))
    let history: [SRSEvaluation]  // history of evaluations
    var n: Int {  // number of correct reviews in a row
        history.filter { $0.score >= 3 }.count
    }
    let efactor: Double  // easiness factor
    let interval: Double  // interval until next review
    // honestly I don't know much about this, but the algo works (thanks Fresh Cards!)

    struct SRSEvaluation: Codable {
        let score: Double  // score in this evaluation
        let lateness: Double  // lateness of review
        let date: Date  // date of review
    }

    private func calculateInitialInterval(n: Int) -> Double {
        switch n {
        case 0: return 30.0 * 1.0 / (24.0 * 60.0)
        case 1: return 0.5
        default: return 1.0
        }
    }

    private func calculateFutureInterval(n: Int, efactor: Double) -> Double {
        switch n {
        case 0: return 1.0
        case 1: return 6.0
        default: return ceil(efactor * efactor)
        }
    }

    func update(eval: SRSEvaluation) -> SRSTermInfo {
        // This algorithm is a transpiled version of the FC-3 algorithm (currently in use at Fresh Cards) from JavaScript to Swift.
        // The original algorithm can be found at https://freshcardsapp.com/srs/simulator/ ,
        // with helpful tidbits at https://freshcardsapp.com/srs/write-your-own-algorithm.html

        // previous is self
        // another big thing is that since n is a calculated variable we don't need to explicit create it
        var newEf: Double
        var newInterval: Double

        if self.n < 3 {
            newEf = self.efactor

            if eval.score < 3 {
                newInterval = 30 * 1.0 / (24.0 * 60.0)
            } else {
                newInterval = calculateInitialInterval(n: self.n)
                newInterval = newInterval * (1.0 + Double.random(in: 0.0...0.10))
            }
        } else {
            if eval.score < 3 {
                newInterval = 30 * 1.0 / (24.0 * 60.0)
                newEf = max(1.3, self.efactor - 0.20)
            } else {
                if eval.lateness >= -0.10 {
                    let (latenessScoreBonus, intervalAdjustment) = calculateBonusAndAdjustment(
                        eval: eval)
                    let adjustedScore = latenessScoreBonus + eval.score
                    newEf = max(
                        1.3,
                        self.efactor
                            + (0.1 - (5 - adjustedScore) * (0.08 + (5 - adjustedScore) * 0.02)))
                    newInterval =
                        calculateFutureInterval(n: self.n, efactor: self.efactor)
                        * intervalAdjustment
                } else {
                    let earliness = (1.0 + eval.lateness)
                    let futureWeight = min(pow(M_E, pow(earliness, 2.0)) - 1.0, 1.0)
                    let currentWeight = 1.0 - futureWeight
                    let predictedFutureScore = currentWeight * eval.score + futureWeight * 3.0
                    let futureEf = max(
                        1.3,
                        self.efactor
                            + (0.1 - (5 - predictedFutureScore)
                                * (0.08 + (5 - predictedFutureScore) * 0.02))
                    )
                    let futureInterval = calculateFutureInterval(n: self.n, efactor: self.efactor)

                    newEf = self.efactor * currentWeight + futureEf * futureWeight
                    newInterval = self.efactor * currentWeight + futureInterval * futureWeight
                }
                newInterval = newInterval * (1.0 + Double.random(in: 0.0...0.05))
            }
        }
        return SRSTermInfo(history: self.history + [eval], efactor: newEf, interval: newInterval)
    }

    private func calculateBonusAndAdjustment(eval: SRSEvaluation) -> (Double, Double) {
        var latenessScoreBonus: Double = 0.0
        var intervalAdjustment: Double = 1.0

        if eval.lateness >= 0.10 && eval.score >= 3.0 {
            let latenessFactor = min(1.0, eval.lateness)
            let scoreFactor = 1.0 + (eval.score - 3.0) / 4.0
            latenessScoreBonus = 1.0 * latenessFactor * scoreFactor
        } else if eval.score >= 3.0 && eval.score < 4 {
            intervalAdjustment = 0.8
        }

        return (latenessScoreBonus, intervalAdjustment)
    }
}
