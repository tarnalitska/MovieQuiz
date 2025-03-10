import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenter?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFont()

        imageView.layer.cornerRadius = 20
        imageView.backgroundColor = .clear
        questionLabel.text = nil
        
        presenter = MovieQuizPresenter(viewController: self)
        showLoadingIndicator()
    }
    
    func show(quiz step: QuizStepViewModel) {
        hideLoadingIndicator()
        imageView.image = step.image
        indexLabel.text = step.questionNumber
        questionLabel.text = step.question
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
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func removeHighlightImageBorder() {
        imageView.layer.borderWidth = .zero
    }
    
    func blockButtons(){
        rightButton.isEnabled = false
        rightButton.setTitleColor(UIColor.lightGray, for: .normal)
        leftButton.isEnabled = false
        leftButton.setTitleColor(UIColor.lightGray, for: .normal)
    }
    
    func unblockButtons(){
        rightButton.isEnabled = true
        leftButton.isEnabled = true
        rightButton.setTitleColor(UIColor(named: "YPBlack"), for: .normal)
        leftButton.setTitleColor(UIColor(named: "YPBlack"), for: .normal)
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
}
