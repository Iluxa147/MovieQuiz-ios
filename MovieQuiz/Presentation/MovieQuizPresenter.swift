import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    var questionFactory: QuestionFactoryProtocol?
    
    // MARK: - Private fields
    private let questionsAmount: Int = 10
    private var currentQuestionIdx: Int = 0
    private var correctAnswersCount: Int = 0
    
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - Lifecycle
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.viewController?.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convertToQuizStep(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showQuizStep(quizStep: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(errorMsg: error.localizedDescription)
    }
    
    // MARK: - Public members
    func resetGameData() {
        currentQuestionIdx = 0
        correctAnswersCount = 0
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
    
    // MARK: - Private members
    private func isLastQuestion() -> Bool {
        return currentQuestionIdx == questionsAmount - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIdx += 1
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        proceedWithAnswer(isCorrectAnswer: isYes == currentQuestion.correctAnswer)
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if(isCorrectAnswer) {
            correctAnswersCount += 1
        }
    }
    
    private func proceedWithAnswer(isCorrectAnswer: Bool) {
        didAnswer(isCorrectAnswer: isCorrectAnswer)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrectAnswer)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            proceedToNextQuestionOrResults()
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            guard let statisticService = statisticService else { return }
            
            statisticService.store(correctAnswersCount: correctAnswersCount, questionsCount: questionsAmount)
            let record = statisticService.bestGame
            let resultText = """
               Your result: \(correctAnswersCount)/\(questionsAmount)
               Total quiz played: \(statisticService.totalGamesPlayed)
               Record: \(record.correctAnswersCount)/\(record.questionsCount) (\(record.datePlayed.dateTimeString))
               Total accuracy \(String(format: "%.2f", statisticService.totalAccuracyPerсent))%
            """
            
            let result = QuizResultsViewModel(title: "This round is over!", text: resultText, buttonText: "Play again")
            viewController?.showQuizResultAlert(result: result)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
