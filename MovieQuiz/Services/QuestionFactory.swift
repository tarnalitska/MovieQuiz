import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    private var movies: [MostPopularMovie] = []
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let mostPopularMovies):
                    if let errorMessage = mostPopularMovies.errorMessage, !errorMessage.isEmpty {
                            let error = CustomError.apiError(message: errorMessage)
                            self.delegate?.didFailToLoadData(with: error)
                            return
                    }
                    
                    if mostPopularMovies.items.isEmpty {
                            let error = CustomError.emptyMovies
                            self.delegate?.didFailToLoadData(with: error)
                            return
                    }
                    
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                    
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
            }
          }
        }
    }
    
    
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
    
            let index = (0..<movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            
                let error = CustomError.imageLoadingFail
                
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didFailToLoadImage(with: error.localizedDescription)
                }
                return
            }
            
            let rating = Float(movie.rating) ?? 0 
        
            let randomRating = Float.random(in: 5...9)
            let isGreaterQuestion = Bool.random()
              
            let text = isGreaterQuestion
                  ? "Is this movie rated higher than \(Int(randomRating))?"
                  : "Is this movie rated less than \(Int(randomRating))?"
              
            let correctAnswer = isGreaterQuestion
                  ? rating > randomRating
                  : rating < randomRating
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
