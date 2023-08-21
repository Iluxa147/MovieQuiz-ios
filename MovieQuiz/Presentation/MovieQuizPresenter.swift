import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    
    private var currentQuestionIdx: Int = 0
    
    func isLastQuestion() -> Bool {
        return currentQuestionIdx == questionsAmount - 1
    }
    
    func resetQuestionIdx() {
        currentQuestionIdx = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIdx += 1
    }
    
    func convertToQuizStep(model: QuizQuestion) -> QuizStepViewModel {
        let retVal = QuizStepViewModel(
            filmPosterImage: UIImage(data: model.imageData) ?? UIImage(),
            question: model.question,
            questionCounterStr: "\(currentQuestionIdx + 1)/\(questionsAmount)")
        
        return retVal
    }
}
