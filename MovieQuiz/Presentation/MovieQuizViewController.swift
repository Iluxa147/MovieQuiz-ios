import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    private var currentQuestionIdx: Int = 0
    private var correctAnswersCount: Int = 0
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    @IBOutlet private weak var filmPosterImage: UIImageView!
    @IBOutlet private weak var questionCounterLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filmPosterImage.layer.masksToBounds = true
        filmPosterImage.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(delegate: self)
        
        questionFactory?.requestNextQuestion()
        
        //showQuizStep(quizStep: getQuizStep(questionIdx: currentQuestionIdx))
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.showQuizStep(quizStep: viewModel)
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let retVal = QuizStepViewModel(filmPosterImage: UIImage(named: model.filmPosterName) ?? UIImage(), question: model.question, questionCounterStr: "\(currentQuestionIdx + 1)/\(questionsAmount)")
        
        return retVal
    }
    
    /*
     private func getQuizStep(questionIdx: Int) -> QuizStepViewModel {
     let quizQuestion = questions[questionIdx]
     let retVal = QuizStepViewModel(filmPosterImage: UIImage(named: quizQuestion.filmPosterName) ?? UIImage(), question: quizQuestion.question, questionCounterStr: "\(currentQuestionIdx + 1)/\(questions.count)")
     
     return retVal
     }
     */
    
    private func showQuizStep(quizStep: QuizStepViewModel) {
        filmPosterImage.image = quizStep.filmPosterImage
        filmPosterImage.layer.borderWidth = 0
        questionLabel.text = quizStep.question
        questionCounterLabel.text = quizStep.questionCounterStr
        
        toggleAnswerButtonsUsability(isEnabled: true)
    }
    
    private func showQuizResultAlert(result: QuizResultsViewModel) {
        let alert = UIAlertController(title: result.title, message: result.text, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.currentQuestionIdx = 0
            self.correctAnswersCount = 0
            
            self.questionFactory?.requestNextQuestion()
            
            /*
            if let nextQuestion = self.questionFactory.requestNextQuestion() {
                self.currentQuestion = nextQuestion
                let viewModel = self.convert(model: nextQuestion)
                
                self.showQuizStep(quizStep: viewModel)
            }
             */
            
            //self.showQuizStep(quizStep: self.getQuizStep(questionIdx: self.currentQuestionIdx))
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIdx == questionsAmount - 1 {
            let resultText = "Your result: \(correctAnswersCount)/\(questionsAmount)"
            let result = QuizResultsViewModel(title: "This round is over!", text: resultText, buttonText: "Play again")
            showQuizResultAlert(result: result)
        } else {
            currentQuestionIdx += 1
            
            questionFactory?.requestNextQuestion()
            
            /*
            if let nextQuestion = questionFactory.requestNextQuestion() {
                currentQuestion = nextQuestion
                let viewModel = convert(model: nextQuestion)
                showQuizStep(quizStep: viewModel)
            }
             */
            
            //showQuizStep(quizStep: getQuizStep(questionIdx: currentQuestionIdx))
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
