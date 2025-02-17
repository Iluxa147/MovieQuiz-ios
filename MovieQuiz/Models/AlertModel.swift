import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let accessibilityIdentifier: String
    
    let completion: () -> Void
}
