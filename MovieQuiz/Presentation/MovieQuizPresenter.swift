import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    func removeHighlightImageBorder()
    
    func blockButtons()
    func unblockButtons()
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var statisticService: StatisticServiceProtocol!
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = .zero
    private var currentQuestionIndex: Int = .zero
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    @IBAction func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    @IBAction func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didFailToLoadImage(with message: String) {
        let alertModel = AlertModel(
            title: "Error",
            message: message,
            buttonText: "Reload",
            completion: { [weak self] in
                guard let self = self else { return }
                
                viewController?.hideLoadingIndicator()
                restartGame()
            }, accessibilityIdentifier: "Image Load Error"
        )
        
        AlertPresenter.showAlert(model: alertModel, on: self.viewController as! UIViewController)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = .zero
        correctAnswers = .zero
        questionFactory?.requestNextQuestion()
    }
    
    func switchToTheNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func updateCorrectAnswers() {
        correctAnswers += 1
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
    
    private func proceedToNextQuestionOrResults() {
        viewController?.removeHighlightImageBorder()
        viewController?.unblockButtons()
        
        guard self.isLastQuestion() else {
            self.switchToTheNextQuestion()
            viewController?.showLoadingIndicator()
            questionFactory?.requestNextQuestion()
            return
        }
        
        statisticService?.store(correct: correctAnswers, total: 10)
        let gamesCount = statisticService?.gamesCount ?? 0
        let correct = statisticService?.bestGame.correct ?? 0
        let total = statisticService?.bestGame.total ?? 0
        let date = statisticService?.bestGame.date.dateTimeString ?? ""
        let totalAccuracy = statisticService?.totalAccuracy ?? 0.0

        let text = "Your result: \(correctAnswers)/10\nNumber of games: \(gamesCount)\nBest game: \(correct)/\(total) (\(String(describing: date)))\nAccuracy: \(String(format: "%.2f", totalAccuracy))%"
        let viewModel = QuizResultsViewModel(
            title: "The round is over!",
            text: text,
            buttonText: "Play again"
        )
        viewController?.show(quiz: viewModel)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        if isCorrect {
            updateCorrectAnswers()
        }
        
        viewController?.blockButtons()
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
