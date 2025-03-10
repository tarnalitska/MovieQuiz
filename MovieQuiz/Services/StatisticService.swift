import Foundation

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correct
        case total
        case date
        case bestGame
        case gamesCount
        case totalCorrect
        case totalQuestions
    }
    
    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let total = storage.integer(forKey: Keys.total.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let totalCorrect = storage.integer(forKey: Keys.totalCorrect.rawValue)
        let totalQuestions = storage.integer(forKey: Keys.gamesCount.rawValue) * 10
        
        guard totalQuestions > 0 else { return 0.0 }
        
        return Double(totalCorrect) / Double(totalQuestions) * 100
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        let totalCorrect = storage.integer(forKey: Keys.totalCorrect.rawValue) + count
        let currentBest = storage.integer(forKey: Keys.correct.rawValue)
        
        storage.set(totalCorrect, forKey: Keys.totalCorrect.rawValue)
        
        if count >= currentBest {
            bestGame = GameResult(correct: count, total: amount, date: Date())
        }
    }
}
