import UIKit

final class MovieQuizViewController: UIViewController {
    //MARK: - Private fields
    private var presenter:  MovieQuizPresenter!
    private var alertPresenter: AlertPresenter?
    
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
        
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(viewController: self)
        
    }
    
    // MARK: - Private members
    func showLoadingIndicator() {
        filmImageLoadingIndicator.isHidden = false
        filmImageLoadingIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        filmImageLoadingIndicator.isHidden = true
        filmImageLoadingIndicator.stopAnimating()
    }
    
    func showNetworkError(errorMsg: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Error",
            message: errorMsg,
            buttonText: "Try again",
            accessibilityIdentifier: "NetworkError") {
                [weak self] in
                guard let self = self else { return }
                
                self.presenter.resetGameData()
                //self.currentQuestionIdx = 0
                //self.correctAnswersCount = 0
                presenter.questionFactory?.loadData()
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
    
    func showQuizResultAlert(result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            accessibilityIdentifier: "GameResults") {
                [weak self] in
                guard let self = self else { return }
                
                self.presenter.resetGameData()
                //self.currentQuestionIdx = 0
                //self.correctAnswersCount = 0
                presenter.questionFactory?.requestNextQuestion()
            }
        
        alertPresenter?.show(alertModel: alertModel)
    }
    
    
    /*
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
     */
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        filmPosterImage.layer.borderWidth = 8
        filmPosterImage.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        toggleAnswerButtonsUsability(isEnabled: false)
    }
    
    /*
    func showAnswerResult(isCorrectAnswer: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrectAnswer)
        
        /*
        if isCorrect {
            correctAnswersCount += 1
        }
        */
        
        //filmPosterImage.layer.borderWidth = 8
        //filmPosterImage.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        //
        //toggleAnswerButtonsUsability(isEnabled: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            //self.presenter.correctAnswersCount = self.correctAnswersCount
            //self.presenter.questionFactory = self.questionFactory
            //self.presenter.statisticService = self.statisticService
            self.presenter.showNextQuestionOrResult()
        }
    }
     */
    
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
