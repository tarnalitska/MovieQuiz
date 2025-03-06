import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
            
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers: Int = .zero
    private var questionFactory: QuestionFactoryProtocol?
    private let presenter = MovieQuizPresenter()
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol? =  StatisticService()
    
    @IBOutlet weak var imageView: UIImageView!

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFont()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()

        imageView.layer.cornerRadius = 20
        imageView.backgroundColor = .clear
        questionLabel.text = nil
    
        presenter.viewController = self
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?){
        presenter.didReceiveNextQuestion(question: question)
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
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Private functions
    
    private func setupFont() {
        leftButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        rightButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23.0)
    }
    
    func show(quiz step: QuizStepViewModel) {
    hideLoadingIndicator()
    imageView.image = step.image
    indexLabel.text = step.questionNumber
    questionLabel.text = step.question
}
    
    func showAnswerResult(isCorrect: Bool) {
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
        self.presenter.correctAnswers = self.correctAnswers
        self.presenter.questionFactory = self.questionFactory
        self.presenter.showNextQuestionOrResults()
    }
}
    
    func show(quiz result: QuizResultsViewModel) {
    
    let alertModel = AlertModel(
        title: result.title,
        message: result.text,
        buttonText: result.buttonText,
        completion: { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            questionFactory?.requestNextQuestion()
        }, accessibilityIdentifier: "Game results"
    )
    
    AlertPresenter.showAlert(model: alertModel, on: self)
}
    
    func showLoadingIndicator() {
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
                
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                hideLoadingIndicator()
        
                questionFactory?.loadData()
            }, accessibilityIdentifier: "Network Error"
        )
        
        AlertPresenter.showAlert(model: alertModel, on: self)
    }
}
