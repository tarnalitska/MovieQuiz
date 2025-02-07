//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Sofya Tarnalitskaya on 03/02/2025.
//

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}
