//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Sofya Tarnalitskaya on 30/01/2025.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)?
    let accessibilityIdentifier: String?
}
