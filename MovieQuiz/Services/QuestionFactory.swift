import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    private let questions: [QuizQuestion] = [
        QuizQuestion(filmPosterName: "The Godfather", correctAnswer: true),
        QuizQuestion(filmPosterName: "The Dark Knight", correctAnswer: true),
        QuizQuestion(filmPosterName: "Kill Bill", correctAnswer: true),
        QuizQuestion(filmPosterName: "The Avengers", correctAnswer: true),
        QuizQuestion(filmPosterName: "Deadpool", correctAnswer: true),
        QuizQuestion(filmPosterName: "The Green Knight", correctAnswer: true),
        QuizQuestion(filmPosterName: "Old", correctAnswer: false),
        QuizQuestion(filmPosterName: "The Ice Age Adventures of Buck Wild", correctAnswer: false),
        QuizQuestion(filmPosterName: "Tesla", correctAnswer: false),
        QuizQuestion(filmPosterName: "Vivarium", correctAnswer: false)
    ]
    
    func requestNextQuestion() -> QuizQuestion? {
        guard let idx = (0..<questions.count).randomElement() else { return nil }
        
        return questions[safe: idx]
    }
}
