import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
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
    
    // MARK: - MovieQuizViewControllerProtocol
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
                presenter.questionFactory?.requestNextQuestion()
            }
        
        alertPresenter?.show(alertModel: alertModel)
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
                presenter.questionFactory?.loadData()
            }
        
        alertPresenter?.show(alertModel: alertModel)
    }
    
    func showLoadingIndicator() {
        filmImageLoadingIndicator.isHidden = false
        filmImageLoadingIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        filmImageLoadingIndicator.isHidden = true
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        filmPosterImage.layer.borderWidth = 8
        filmPosterImage.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        toggleAnswerButtonsUsability(isEnabled: false)
    }
    
    // MARK: - Private members
    private func toggleAnswerButtonsUsability(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    // MARK: - Actions
    @IBAction private func noButtonTap(_ sender: UIButton) {
        presenter.noButtonTap()
    }
    
    @IBAction private func yesButtonTap(_ sender: UIButton) {
        presenter.yesButtonTap()
    }
}
