//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Sofya Tarnalitskaya on 30/01/2025.

import UIKit

final class AlertPresenter {
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    static func showAlert(model: AlertModel, on viewController: UIViewController){
        
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default
        ) { _ in
            model.completion?()
        }
        
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
