import Foundation

protocol StatisticService {
    var totalGamesPlayed: Int { get }
    var totalCorrectAnswers: Int { get }
    var bestGame: GameRecord { get }
    
    func store(correctAnswersCount: Int, questionsCount amount: Int)
}
