import Foundation

struct GameRecord: Codable, Comparable {
    let correctAnswersCount: Int
    let questionsCount: Int
    let datePlayed: Date
    
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correctAnswersCount < rhs.correctAnswersCount
    }
}
