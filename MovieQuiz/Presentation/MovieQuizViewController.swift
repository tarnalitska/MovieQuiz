import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
            
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol? =  StatisticService()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFont()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()

        imageView.layer.cornerRadius = 20
        imageView.backgroundColor = .clear
        questionLabel.text = nil
    
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?){
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didFailToLoadImage(with message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private functions
    
    private func setupFont() {
        leftButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        rightButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23.0)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        hideLoadingIndicator()
        imageView.image = step.image
        indexLabel.text = step.questionNumber
        questionLabel.text = step.question
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        rightButton.isEnabled = false
        rightButton.setTitleColor(UIColor.lightGray, for: .normal)
        leftButton.isEnabled = false
        leftButton.setTitleColor(UIColor.lightGray, for: .normal)
        
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        rightButton.isEnabled = true
        leftButton.isEnabled = true
        rightButton.setTitleColor(UIColor(named: "YPBlack"), for: .normal)
        leftButton.setTitleColor(UIColor(named: "YPBlack"), for: .normal)
        
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(correct: correctAnswers, total: 10)
            
            let gamesCount = statisticService?.gamesCount ?? 0
        
            let correct = statisticService?.bestGame.correct ?? 0
            let total = statisticService?.bestGame.total ?? 0
            let date = statisticService?.bestGame.date.dateTimeString ?? ""
            let totalAccuracy = statisticService?.totalAccuracy ?? 0.0
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/10\nКоличество сыгранных квизов: \(gamesCount)\nРекорд: \(correct)/\(total) (\(String(describing: date)))\nСредняя точность: \(String(format: "%.2f", totalAccuracy))%",
                buttonText: "Сыграть ещё раз"
            )
                show(quiz: viewModel)
            } else {
                currentQuestionIndex += 1
                showLoadingIndicator()
                self.questionFactory?.requestNextQuestion()
            }
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                questionFactory?.requestNextQuestion()
            }, accessibilityIdentifier: "Game results"
        )
        
        AlertPresenter.showAlert(model: alertModel, on: self)
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    private func showNetworkError(message: String) {
        
        let alertModel = AlertModel(
            title: "Error",
            message: message,
            buttonText: "Try to reload",
            completion: { [weak self] in
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                hideLoadingIndicator()
        
                questionFactory?.loadData()
            }, accessibilityIdentifier: "Network Error"
        )
        
        AlertPresenter.showAlert(model: alertModel, on: self)
    }
}
