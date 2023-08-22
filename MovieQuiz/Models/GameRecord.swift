import Foundation

struct GameRecord: Codable, Comparable {
    let correctAnswersCount: Int
    let questionsCount: Int
    let datePlayed: Date
    
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        let lhsMetric = Float(lhs.correctAnswersCount) / Float(lhs.questionsCount)
        let rhsMetric = Float(rhs.correctAnswersCount) / Float(rhs.questionsCount)
        return lhsMetric < rhsMetric
    }
}
