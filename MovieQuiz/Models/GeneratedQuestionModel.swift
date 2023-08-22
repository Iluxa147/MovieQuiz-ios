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
    
    init(rating: Float, comparison: GeneratedQuestionComparison) {
        self.rating = rating
        self.comparison = comparison
    }
    
    func getCorrectAnswer(ratingToCheck: Float) -> Bool {
        switch comparison {
        case GeneratedQuestionComparison.lesser:
            return ratingToCheck < rating
        case GeneratedQuestionComparison.equals:
            return abs(ratingToCheck - rating) <= 0.001
        default:
            return ratingToCheck > rating
        }
    }
}
