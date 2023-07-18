import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    //MARK: - Private fields
    private let questionsAmount: Int = 10
    
    private var currentQuestionIdx: Int = 0
    private var correctAnswersCount: Int = 0
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService = StatisticServiceImplementation()
    
    @IBOutlet private weak var filmPosterImage: UIImageView!
    @IBOutlet private weak var questionCounterLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filmPosterImage.layer.masksToBounds = true
        filmPosterImage.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        
        alertPresenter = AlertPresenter(viewController: self)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convertToQuizStep(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.showQuizStep(quizStep: viewModel)
        }
    }
    
    // MARK: - Private members
    private func convertToQuizStep(model: QuizQuestion) -> QuizStepViewModel {
        let retVal = QuizStepViewModel(filmPosterImage: UIImage(named: model.filmPosterName) ?? UIImage(), question: model.question, questionCounterStr: "\(currentQuestionIdx + 1)/\(questionsAmount)")
        
        return retVal
    }
    
    private func showQuizStep(quizStep: QuizStepViewModel) {
        filmPosterImage.image = quizStep.filmPosterImage
        filmPosterImage.layer.borderWidth = 0
        questionLabel.text = quizStep.question
        questionCounterLabel.text = quizStep.questionCounterStr
        
        toggleAnswerButtonsUsability(isEnabled: true)
    }
    
    private func showQuizResultAlert(result: QuizResultsViewModel) {
        let alertModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) {
            [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIdx = 0
            self.correctAnswersCount = 0
            
            self.questionFactory?.generateRandom()
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.show(alertModel: alertModel)
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIdx == questionsAmount - 1 {
            statisticService.store(correctAnswersCount: correctAnswersCount, questionsCount: questionsAmount)
            let record = statisticService.bestGame
            let resultText =
            "Your result: \(correctAnswersCount)/\(questionsAmount)\n" +
            "Total quiz played: \(statisticService.totalGamesPlayed)\n" +
            "Record: \(record.correctAnswersCount)/\(record.questionsCount) (\(record.datePlayed.dateTimeString))\n" +
            "Total accuracy \(String(format: "%.2f", statisticService.totalAccuracyPerсent))%"
            
            let result = QuizResultsViewModel(title: "This round is over!", text: resultText, buttonText: "Play again")
            showQuizResultAlert(result: result)
        } else {
            currentQuestionIdx += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func show(isCorrect: Bool) {
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
        guard let currentQuestion = currentQuestion else { return }
        
        let correctAnswer = currentQuestion.correctAnswer
        show(isCorrect: !correctAnswer)
    }
    
    @IBAction private func yesButtonTap(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        
        let correctAnswer = currentQuestion.correctAnswer
        show(isCorrect: correctAnswer)
    }
}
