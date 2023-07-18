import Foundation

final class StatisticServiceImplementation: StatisticServiceProtocol {
    // MARK: - StatisticServiceProtocol
    private (set) var totalGamesPlayed: Int {
        get {
            userDefaults.integer(forKey: Keys.totalGamesPlayed.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.totalGamesPlayed.rawValue)
        }
    }
    
    var totalAccuracyPerсent: Double {
        get {
            if totalQuestionsAnswered == 0 { return 0 }
            return 100 * Double(totalCorrectAnswers) / Double(totalQuestionsAnswered)
        }
    }
    
    private (set) var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correctAnswersCount: 0, questionsCount: 0, datePlayed: Date())
            }
            
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Unable to save result")
                return
            }
            
            userDefaults.setValue(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    // MARK: - Private fields
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case totalGamesPlayed, bestGame, totalQuestionsAnswered, totalCorrectAnswers
    }
    
    private var totalQuestionsAnswered: Int {
        get {
            userDefaults.integer(forKey: Keys.totalQuestionsAnswered.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.totalQuestionsAnswered.rawValue)
        }
    }
    
    private var totalCorrectAnswers: Int {
        get {
            userDefaults.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    
    // MARK: - StatisticServiceProtocol
    func store(correctAnswersCount: Int, questionsCount: Int) {
        totalGamesPlayed += 1
        totalQuestionsAnswered += questionsCount
        totalCorrectAnswers += correctAnswersCount
        
        let potentialRecord = GameRecord(correctAnswersCount: correctAnswersCount, questionsCount: questionsCount, datePlayed: Date())
        if bestGame < potentialRecord {
            bestGame = potentialRecord
        }
    }
}
