import Foundation

struct GameRecord: Codable, Comparable {
    let correctAnswersCount: Int
    let questionsCount: Int
    let datePlayed: Date
    
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        let lhsMetric = Float(lhs.correctAnswersCount) / Float(lhs.questionsCount)
        let rhsMetric = Float(rhs.correctAnswersCount) / Float(rhs.questionsCount)
        
        // empirical precision to avoid near equal game records
        // we can make a bit rude comparison here, since a high accuracy is not a point
        return lhsMetric - rhsMetric < 0.001
    }
}
