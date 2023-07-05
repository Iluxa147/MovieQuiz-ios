import UIKit

extension UIAlertController {
    func setTitleFont(font: UIFont?) {
        guard let title = self.title, let font = font else { return }
        if title.isEmpty { return }
        
        let attributeString = NSMutableAttributedString(string: title)
        attributeString.addAttributes([NSAttributedString.Key.font : font],
                                      range: NSMakeRange(0, title.count))
        self.setValue(attributeString, forKey: "attributedTitle")
    }
    
    func setMessageFont(font: UIFont?) {
        guard let message = self.message, let font = font else { return }
        if message.isEmpty { return }
        
        let attributeString = NSMutableAttributedString(string: message)
        attributeString.addAttributes([NSAttributedString.Key.font : font],
                                      range: NSMakeRange(0, message.count))
        self.setValue(attributeString, forKey: "attributedMessage")
    }
}

struct QuizStepViewModel {
    let filmPosterImage: UIImage
    let question: String
    let questionCounterStr: String
}

struct QuizQuestion {
    private static let questionDefault: String = "Is this film rating greater than 6?"
    
    let filmPosterName: String
    let question: String
    let correctAnswer: Bool
    
    init(filmPosterName: String, correctAnswer: Bool, question: String = "") {
        self.filmPosterName = filmPosterName
        self.question = question.isEmpty ? QuizQuestion.questionDefault : question
        self.correctAnswer = correctAnswer
    }
}

struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

final class MovieQuizViewController: UIViewController {
    private let questions: [QuizQuestion] = [
        QuizQuestion(filmPosterName: "The Godfather", correctAnswer: true),
        QuizQuestion(filmPosterName: "The Dark Knight", correctAnswer: true),
        QuizQuestion(filmPosterName: "Kill Bill", correctAnswer: true),
        QuizQuestion(filmPosterName: "The Avengers", correctAnswer: true),
        QuizQuestion(filmPosterName: "Deadpool", correctAnswer: true),
        QuizQuestion(filmPosterName: "The Green Knight", correctAnswer: true),
        QuizQuestion(filmPosterName: "Old", correctAnswer: false),
        QuizQuestion(filmPosterName: "The Ice Age Adventures of Buck Wild", correctAnswer: false),
        QuizQuestion(filmPosterName: "Tesla", correctAnswer: false),
        QuizQuestion(filmPosterName: "Vivarium", correctAnswer: false)
    ]
    
    private var alertTitleFont : UIFont?
    private var alertTextFont : UIFont?
    
    private var currentQuestionIdx: Int = 0
    private var correctAnswersCount: Int = 0
    
    @IBOutlet private weak var filmPosterImage: UIImageView!
    @IBOutlet private weak var questionCounterLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertTitleFont = UIFont(name: "SFProText-Bold1", size: 17.0)
        alertTextFont = UIFont(name: "SFProText-Regular1", size: 13.0)
        
        filmPosterImage.layer.masksToBounds = true
        filmPosterImage.layer.cornerRadius = 20
        
        showQuizStep(quizStep: getQuizStep(questionIdx: currentQuestionIdx))
    }
    
    private func getQuizStep(questionIdx: Int) -> QuizStepViewModel {
        let quizQuestion = questions[questionIdx]
        let retVal = QuizStepViewModel(filmPosterImage: UIImage(named: quizQuestion.filmPosterName) ?? UIImage(), question: quizQuestion.question, questionCounterStr: "\(currentQuestionIdx + 1)/\(questions.count)")
        
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
        let alert = UIAlertController(title: result.title, message: result.text, preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIdx = 0
            self.correctAnswersCount = 0
            
            self.showQuizStep(quizStep: self.getQuizStep(questionIdx: self.currentQuestionIdx))
        }
        
        alert.addAction(action)
        alert.setTitleFont(font: alertTitleFont)
        alert.setMessageFont(font: alertTextFont)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIdx == questions.count - 1 {
            let resultText = "Your result: \(correctAnswersCount)/\(questions.count)"
            let result = QuizResultsViewModel(title: "This round is over!", text: resultText, buttonText: "Play again")
            showQuizResultAlert(result: result)
        } else {
            currentQuestionIdx += 1
            showQuizStep(quizStep: getQuizStep(questionIdx: currentQuestionIdx))
        }
    }
    
    private func show(isCorrect: Bool) {
        if isCorrect {
            correctAnswersCount += 1
        }
        
        filmPosterImage.layer.borderWidth = 8
        filmPosterImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        toggleAnswerButtonsUsability(isEnabled: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: showNextQuestionOrResult)
    }
    
    private func toggleAnswerButtonsUsability(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    @IBAction private func noButtonTap(_ sender: UIButton) {
        let correctAnswer = questions[currentQuestionIdx].correctAnswer
        show(isCorrect: !correctAnswer)
    }
    
    @IBAction private func yesButtonTap(_ sender: UIButton) {
        let correctAnswer = questions[currentQuestionIdx].correctAnswer
        show(isCorrect: correctAnswer)
    }
}
