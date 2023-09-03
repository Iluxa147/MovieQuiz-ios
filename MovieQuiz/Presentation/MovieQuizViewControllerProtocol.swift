import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func showQuizStep(quizStep: QuizStepViewModel)
    func showQuizResultAlert(result: QuizResultsViewModel)
    
    func showNetworkError(errorMsg: String)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func highlightImageBorder(isCorrectAnswer: Bool)
}
