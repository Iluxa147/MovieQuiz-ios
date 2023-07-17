import UIKit

struct Actor : Codable {
    let id: String
    let image: String
    let name: String
    let asCharacter: String
}
struct Movie : Codable {
    enum CodingKeys: CodingKey {
        case id, title, year, image, releaseDate, runtimeMins, directors, actorList
    }
    
    enum ParseError: Error {
        case yearFailure
        case runtimeMinsFailure
    }
    
    let id: String
    let title: String
    let year: Int
    let image: String
    let releaseDate: String
    let runtimeMins: Int
    let directors: String
    let actorList: [Actor]
    
    //let codingKeys : CodingKeys
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        
        let year = try container.decode(String.self, forKey: .year)
        guard let yearInt = Int(year) else { throw ParseError.yearFailure }
        self.year = yearInt
        
        self.image = try container.decode(String.self, forKey: .image)
        self.releaseDate = try container.decode(String.self, forKey: .releaseDate)
        
        let runtimeMins = try container.decode(String.self, forKey: .runtimeMins)
        guard let runtimeMinsInt = Int(runtimeMins) else { throw ParseError.runtimeMinsFailure }
        self.runtimeMins = runtimeMinsInt
        
        self.directors = try container.decode(String.self, forKey: .directors)
        self.actorList = try container.decode([Actor].self, forKey: .actorList)
    }
}

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
    
    // !!
    private func tryGetMovieJsonString() -> String? {
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        //print("documentsURL.path:\n\(documentsURL.path)\n")
        let jsonFileNameExt = "inception.json"
        documentsURL.appendPathComponent(jsonFileNameExt)
        let jsonString = try? String(contentsOf: documentsURL)
        
        return jsonString
    }
    
    // !!
    func getMovie(from jsonString: String?) -> Movie? {
        guard let jsonString = jsonString else { return nil }
        
        var movie: Movie? = nil
        do {
            guard let data = jsonString.data(using: .utf8) else { return nil }
            movie = try JSONDecoder().decode(Movie.self, from: data)
        } catch {
            print("Failed to parse: \(error.localizedDescription)")
        }
        
        return movie
    }
    
    func tryGetMovieJsonData(movie : Movie?) -> Data {
        guard let movie = movie else { return Data() }
        
        var movieData : Data = Data()
        do {
            movieData = try JSONEncoder().encode(movie)
        } catch {
            print("Failed to encode: \(error.localizedDescription)")
        }
        
        return movieData
    }
    
    
    // !!
    /*
     func getMovie(from jsonString: String?) -> Movie? {
     guard let jsonString = jsonString else { return nil }
     
     var movie: Movie? = nil
     do {
     guard let data = jsonString.data(using: .utf8) else { return nil }
     let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
     
     guard let json = json,
     let id = json["id"] as? String,
     let title = json["title"] as? String,
     let jsonYear = json["year"] as? String,
     let year = Int(jsonYear),
     let image = json["image"] as? String,
     let releaseDate = json["releaseDate"] as? String,
     let jsonRuntimeMins = json["runtimeMins"] as? String,
     let runtimeMins = Int(jsonRuntimeMins),
     let directors = json["directors"] as? String,
     let actorList = json["actorList"] as? [Any]
     else { return nil }
     
     var actorsArr: [Actor] = []
     for actor in actorList {
     guard let actor = actor as? [String: Any],
     let id = actor["id"] as? String,
     let image = actor["image"] as? String,
     let name = actor["name"] as? String,
     let asCharacter = actor["asCharacter"] as? String
     else { return nil }
     
     let actorInst = Actor(id: id, image: image, name: name, asCharacter: asCharacter)
     actorsArr.append(actorInst)
     }
     
     movie = Movie(id: id, title: title, year: year, image: image, releaseDate: releaseDate, runtimeMins: runtimeMins, directors: directors, actorList: actorsArr)
     } catch {
     print("Failed to parse: \(jsonString)")
     }
     
     return movie
     }
     */
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //var movieJsonString = tryGetMovieJsonString()
        //var movie = getMovie(from: movieJsonString)
        //var movieData = tryGetMovieJsonData(movie: movie)
        //var movieDataStr = String(data: movieData, encoding: .utf8)
        
        // !!
        var a = 1;
        
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
        let alertModel = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIdx = 0
            self.correctAnswersCount = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.show(alertModel: alertModel)
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIdx == questionsAmount - 1 {
            statisticService.store(correctAnswers: correctAnswersCount, quizQuestions: questionsAmount)
            let record = statisticService.bestGame
            let resultText =
            "Your result: \(correctAnswersCount)/\(questionsAmount)\n" +
            "Total quiz played: \(statisticService.totalGamesPlayed)\n" +
            "Record: \(record.correctAnswers)/\(record.quizQuestions) (\(record.datePlayed.dateTimeString))\n" +
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
