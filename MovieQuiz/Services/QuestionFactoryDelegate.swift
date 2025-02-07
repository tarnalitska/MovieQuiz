//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Sofya Tarnalitskaya on 30/01/2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}


