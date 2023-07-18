import UIKit

class AlertPresenter {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func show(alertModel: AlertModel) {
        guard let viewController = viewController else { return }
        
        let alert = UIAlertController(title: alertModel.title, message: alertModel.message, preferredStyle: .alert)
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }
        
        let actionReset = UIAlertAction(title: alertModel.resetButtonText, style: .default) { _ in
            UserDefaults.reset()
            alertModel.completion()
        }
        
        alert.addAction(action)
        alert.addAction(actionReset)
        viewController.present(alert, animated: true, completion: nil)
    }
}
