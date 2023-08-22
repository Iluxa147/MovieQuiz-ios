import Foundation

enum GeneratedQuestionComparison: String, CaseIterable {
    case greater = "greater than"
    case lesser = "lesser than"
    case equals = "equals to"
}

class GeneratedQuestionModel {
    var rating: Float
    var comparison: GeneratedQuestionComparison
    
    lazy var questionString: String = {
        "Is this film rating \(comparison.rawValue) \(rating)?"
    }()
    
    // since the film rating is rounded to tenths and we are taking value with some reserve
    private let precisionToRatingCheck: Float = 0.001
    
    init(rating: Float, comparison: GeneratedQuestionComparison) {
        self.rating = rating
        self.comparison = comparison
    }
    
    func getCorrectAnswer(ratingToCheck: Float) -> Bool {
        switch comparison {
        case GeneratedQuestionComparison.lesser:
            return ratingToCheck.isLess(than: rating, precision: precisionToRatingCheck)
        case GeneratedQuestionComparison.equals:
            return ratingToCheck.isEqual(other: rating, precision: precisionToRatingCheck)
        default:
            return ratingToCheck.isGreater(than: rating, precision: precisionToRatingCheck)
        }
    }
}
