import UIKit

final class MovieQuizViewController: UIViewController {
            
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol? =  StatisticService()
    
    @IBOutlet weak var imageView: UIImageView!

    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFont()
        statisticService = StatisticService()

        imageView.layer.cornerRadius = 20
        imageView.backgroundColor = .clear
        questionLabel.text = nil
        
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
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
            presenter.updateCorrectAnswers()
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
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
                
                self.presenter.restartGame()
                
            }, accessibilityIdentifier: "Game results"
        )
        
        AlertPresenter.showAlert(model: alertModel, on: self)
}
    
    func showLoadingIndicator() {
    activityIndicator.startAnimating()
}
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    func showNetworkError(message: String) {
        
        let alertModel = AlertModel(
            title: "Error",
            message: message,
            buttonText: "Try to reload",
            completion: { [weak self] in
                guard let self = self else { return }
                
                hideLoadingIndicator()
                self.presenter.restartGame()
            }, accessibilityIdentifier: "Network Error"
        )
        
        AlertPresenter.showAlert(model: alertModel, on: self)
    }
}
