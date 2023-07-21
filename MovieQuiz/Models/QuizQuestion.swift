import Foundation

struct QuizQuestion {
    private static let questionDefault: String = "Is this film rating greater than 6?"
    
    let filmPosterName: String
    let question: String
    let correctAnswer: Bool
    
    init(filmPosterName: String, correctAnswer: Bool, question: String = "") {
        self.filmPosterName = filmPosterName
        self.question = question.isEmpty ? QuizQuestion.questionDefault : question
        self.correctAnswer = correctAnswer
    }
}
