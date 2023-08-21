import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    //MARK: - Private fields
    private let presenter =  MovieQuizPresenter()
    //private let questionsAmount: Int = 10
    
    //private var currentQuestionIdx: Int = 0
    private var correctAnswersCount: Int = 0
    
    private var questionFactory: QuestionFactoryProtocol?
    //private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    
    @IBOutlet private weak var filmPosterImage: UIImageView!
    @IBOutlet private weak var questionCounterLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var filmImageLoadingIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filmPosterImage.layer.masksToBounds = true
        filmPosterImage.layer.cornerRadius = 20
        
        presenter.viewController = self
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
        
        alertPresenter = AlertPresenter(viewController: self)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(errorMsg: error.localizedDescription)
    }
    
    // MARK: - Private members
    private func showLoadingIndicator() {
        filmImageLoadingIndicator.isHidden = false
        filmImageLoadingIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        filmImageLoadingIndicator.isHidden = true
        filmImageLoadingIndicator.stopAnimating()
    }
    
    private func showNetworkError(errorMsg: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Error",
            message: errorMsg,
            buttonText: "Try again",
            accessibilityIdentifier: "NetworkError") {
                [weak self] in
                guard let self = self else { return }
                
                self.presenter.resetQuestionIdx()
                //self.currentQuestionIdx = 0
                self.correctAnswersCount = 0
                self.questionFactory?.loadData()
            }
        
        alertPresenter?.show(alertModel: alertModel)
    }
    
    /*
    private func convertToQuizStep(model: QuizQuestion) -> QuizStepViewModel {
        let retVal = QuizStepViewModel(
            filmPosterImage: UIImage(data: model.imageData) ?? UIImage(),
            question: model.question,
            questionCounterStr: "\(currentQuestionIdx + 1)/\(questionsAmount)")
        
        return retVal
    }
     */
    
    func showQuizStep(quizStep: QuizStepViewModel) {
        filmPosterImage.image = quizStep.filmPosterImage
        filmPosterImage.layer.borderWidth = 0
        questionLabel.text = quizStep.question
        questionCounterLabel.text = quizStep.questionCounterStr
        
        toggleAnswerButtonsUsability(isEnabled: true)
    }
    
    private func showQuizResultAlert(result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            accessibilityIdentifier: "GameResults") {
                [weak self] in
                guard let self = self else { return }
                
                self.presenter.resetQuestionIdx()
                //self.currentQuestionIdx = 0
                self.correctAnswersCount = 0
                self.questionFactory?.requestNextQuestion()
            }
        
        alertPresenter?.show(alertModel: alertModel)
    }
    
    private func showNextQuestionOrResult() {
        if presenter.isLastQuestion() {
            guard let statisticService = statisticService else { return }
            
            statisticService.store(correctAnswersCount: correctAnswersCount, questionsCount: presenter.questionsAmount)
            let record = statisticService.bestGame
            let resultText = """
               Your result: \(correctAnswersCount)/\(presenter.questionsAmount)
               Total quiz played: \(statisticService.totalGamesPlayed)
               Record: \(record.correctAnswersCount)/\(record.questionsCount) (\(record.datePlayed.dateTimeString))
               Total accuracy \(String(format: "%.2f", statisticService.totalAccuracyPerсent))%
            """
            
            let result = QuizResultsViewModel(title: "This round is over!", text: resultText, buttonText: "Play again")
            showQuizResultAlert(result: result)
        } else {
            presenter.switchToNextQuestion()
            //currentQuestionIdx += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswersCount += 1
        }
        
        filmPosterImage.layer.borderWidth = 8
        filmPosterImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        toggleAnswerButtonsUsability(isEnabled: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.showNextQuestionOrResult()
        }
    }
    
    private func toggleAnswerButtonsUsability(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    // MARK: - Actions
    @IBAction private func noButtonTap(_ sender: UIButton) {
        //presenter.currentQuestion = currentQuestion
        presenter.noButtonTap()
    }
    
    @IBAction private func yesButtonTap(_ sender: UIButton) {
        //presenter.currentQuestion = currentQuestion
        presenter.yesButtonTap()
    }
}
