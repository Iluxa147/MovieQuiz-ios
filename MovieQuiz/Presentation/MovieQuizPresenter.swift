import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    
    private var currentQuestionIdx: Int = 0
    weak var viewController: MovieQuizViewController?
    var currentQuestion: QuizQuestion?
    
    func isLastQuestion() -> Bool {
        return currentQuestionIdx == questionsAmount - 1
    }
    
    func resetQuestionIdx() {
        currentQuestionIdx = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIdx += 1
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convertToQuizStep(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showQuizStep(quizStep: viewModel)
        }
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        viewController?.showAnswerResult(isCorrect: isYes == currentQuestion.correctAnswer)
    }
    
    func convertToQuizStep(model: QuizQuestion) -> QuizStepViewModel {
        let retVal = QuizStepViewModel(
            filmPosterImage: UIImage(data: model.imageData) ?? UIImage(),
            question: model.question,
            questionCounterStr: "\(currentQuestionIdx + 1)/\(questionsAmount)")
        
        return retVal
    }
    
    func noButtonTap() {
       didAnswer(isYes: false)
    }
    
    func yesButtonTap() {
        didAnswer(isYes: true)
    }
}
