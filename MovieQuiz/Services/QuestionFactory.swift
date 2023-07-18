import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    weak var delegate: QuestionFactoryDelegate?
    
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
    
    private var shuffledQuestionsIdxs: [Int]?
    
    init(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    func generateRandom() {
        let sequence = 0..<self.questions.count
        shuffledQuestionsIdxs = sequence.shuffled()
    }
    
    func requestNextQuestion() {
        guard shuffledQuestionsIdxs != nil, !shuffledQuestionsIdxs!.isEmpty else { return }
        let idx = shuffledQuestionsIdxs!.removeLast()
        
        let question = questions[safe: idx]
        delegate?.didReceiveNextQuestion(question: question)
    }
}
