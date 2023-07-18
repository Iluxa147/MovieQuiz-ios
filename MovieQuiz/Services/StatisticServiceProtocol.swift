import Foundation

protocol StatisticServiceProtocol {
    var totalGamesPlayed: Int { get }
    var totalCorrectAnswers: Int { get }
    var totalAccuracyPerсent: Double { get }
    var bestGame: GameRecord { get }
    
    func store(correctAnswersCount: Int, questionsCount amount: Int)
}
