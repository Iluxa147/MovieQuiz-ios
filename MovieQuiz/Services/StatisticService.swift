import Foundation

struct GameRecord: Codable, Comparable {
    let correctAnswers: Int
    let quizQuestions: Int
    let datePlayed: Date
    
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correctAnswers < rhs.correctAnswers
    }
    
    //static func == (lhs: GameRecord, rhs: GameRecord) -> Bool {
    //    return lhs.correctAnswers == rhs.correctAnswers
    //}
}

protocol StatisticService {
    var totalGamesPlayed: Int { get }
    var totalCorrectAnswers: Int { get }
    //var totalAccuracy: Double { get }
    var bestGame: GameRecord { get }
    
    func store(correctAnswers: Int, quizQuestions amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
    private enum Keys: String {
        case totalAccuracyPerсent, totalQuestionsAnswered, totalGamesPlayed, totalCorrectAnswers, bestGame
    }
    
    var totalAccuracyPerсent: Double {
        get {
            userDefaults.double(forKey: Keys.totalAccuracyPerсent.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.totalAccuracyPerсent.rawValue)
        }
    }
    
    var totalQuestionsAnswered: Int {
        get {
            userDefaults.integer(forKey: Keys.totalQuestionsAnswered.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.totalQuestionsAnswered.rawValue)
        }
    }
    
    var totalGamesPlayed: Int {
        get {
            userDefaults.integer(forKey: Keys.totalGamesPlayed.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.totalGamesPlayed.rawValue)
        }
    }
    
    var totalCorrectAnswers: Int {
        get {
            userDefaults.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correctAnswers: 0, quizQuestions: 0, datePlayed: Date())
            }
            
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Error") // TODO useless?
                return
            }
            
            userDefaults.setValue(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    private let userDefaults = UserDefaults.standard
    
    func store(correctAnswers: Int, quizQuestions: Int) {
        totalGamesPlayed += 1
        totalQuestionsAnswered += quizQuestions
        totalCorrectAnswers += correctAnswers
        totalAccuracyPerсent = 100 * Double(totalCorrectAnswers) / Double(totalQuestionsAnswered)
        
        let potentialRecord = GameRecord(correctAnswers: correctAnswers, quizQuestions: quizQuestions, datePlayed: Date())
        if bestGame < potentialRecord {
            bestGame = potentialRecord
        }
    }
}
