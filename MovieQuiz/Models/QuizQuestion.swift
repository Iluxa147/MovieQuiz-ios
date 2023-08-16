import Foundation

struct QuizQuestion {
    let imageData: Data
    let question: String
    let correctAnswer: Bool
    
    init(imageData: Data, correctAnswer: Bool, question: String) {
        self.imageData = imageData
        self.question = question
        self.correctAnswer = correctAnswer
    }
}
