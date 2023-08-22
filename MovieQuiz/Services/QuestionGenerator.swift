import Foundation

class QuestionGenerator {
    private var randomRatings: [Float] = []
    
    init(rangeMin: Float, rangeMax: Float, rangeStep: Float) {
        for val in stride(from: rangeMin, through: rangeMax, by: rangeStep) {
            randomRatings.append(Float(val))
        }
    }
    
    func generateQuestion() -> GeneratedQuestionModel {
        let rating = randomRatings.randomElement() ?? 0
        let comparison = GeneratedQuestionComparison.allCases.randomElement() ?? GeneratedQuestionComparison.greater
        
        return GeneratedQuestionModel(rating: rating, comparison: comparison)
    }
}
