import UIKit

struct QuizStepViewModel {
    let filmPosterImage: UIImage
    let question: String
    let questionCounterStr: String
    
    init(filmPosterImageData: Data, question: String, questionCounterStr: String) {
        self.filmPosterImage = UIImage(data: filmPosterImageData) ?? UIImage()
        self.question = question
        self.questionCounterStr = questionCounterStr
    }
}
