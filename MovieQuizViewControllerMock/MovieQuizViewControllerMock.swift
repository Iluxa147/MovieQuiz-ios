import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func showQuizStep(quizStep: QuizStepViewModel) {}
    func showQuizResultAlert(result: QuizResultsViewModel) {}
    func showNetworkError(errorMsg: String) {}
    func showLoadingIndicator() {}
    func hideLoadingIndicator() {}
    func highlightImageBorder(isCorrectAnswer: Bool) {}
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(imageData: emptyData, correctAnswer: true, question: "QuestionText")
        let viewModel = presenter.convertToQuizStep(model: question)
        
        XCTAssertNotNil(viewModel.filmPosterImage)
        XCTAssertEqual(viewModel.question, "QuestionText")
        XCTAssertEqual(viewModel.questionCounterStr, "1/10")
    }
}
