//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Sofya Tarnalitskaya on 06/03/2025.
//

import UIKit

final class MovieQuizPresenter {
    let questionsAmount: Int = 10
    var questionFactory: QuestionFactoryProtocol?
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var correctAnswers: Int = .zero
    
    private var currentQuestionIndex: Int = .zero
    private var statisticService: StatisticServiceProtocol? =  StatisticService()
    
    @IBAction func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    @IBAction func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = .zero
    }
    
    func switchToTheNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?){
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        
        viewController?.imageView.layer.borderWidth = .zero
        viewController?.rightButton.isEnabled = true
        viewController?.leftButton.isEnabled = true
        viewController?.rightButton.setTitleColor(UIColor(named: "YPBlack"), for: .normal)
        viewController?.leftButton.setTitleColor(UIColor(named: "YPBlack"), for: .normal)
        
        
        if self.isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: 10)
                        
            let gamesCount = statisticService?.gamesCount ?? 0
                    
            let correct = statisticService?.bestGame.correct ?? 0
            let total = statisticService?.bestGame.total ?? 0
            let date = statisticService?.bestGame.date.dateTimeString ?? ""
            let totalAccuracy = statisticService?.totalAccuracy ?? 0.0

            let text = "Ваш результат: \(correctAnswers)/10\nКоличество сыгранных квизов: \(gamesCount)\nРекорд: \(correct)/\(total) (\(String(describing: date)))\nСредняя точность: \(String(format: "%.2f", totalAccuracy))%"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            viewController?.show(quiz: viewModel)
            } else {
                self.switchToTheNextQuestion()
                viewController?.showLoadingIndicator()
                questionFactory?.requestNextQuestion()
            }
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
