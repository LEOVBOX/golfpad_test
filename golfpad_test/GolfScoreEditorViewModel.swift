//
//  ScoreViewModel.swift
//  golfpad_test
//
//  Created by Леонид Шайхутдинов on 09.09.2025.
//

import Foundation

class ScoreViewModel: ObservableObject {
    @Published var players: [PlayerModel] = []
    
    func winnerForHole(_ holeIndex: Int) -> PlayerModel? {
        let scores = players.compactMap { ($0, $0.scores[holeIndex]) }
        guard scores.count == players.count else { return nil } // not all players finish hole
        
        let minScore = scores.compactMap { $0.1 }.min()
        guard let minScore = minScore, minScore > 0 else {
            return nil
        }
        
        // Tie
        if scores.count(where: {$0.1 == minScore}) > 1 {
            return nil
        }
        
        return scores.first { $0.1 == minScore }?.0
    }
    
    func isTie(at holeIndex: Int) -> Bool {
        let scores: [Int] = players.compactMap { $0.scores[holeIndex] }
        guard scores.count == players.count else { return false }
        return Set(scores).count == 1
    }
    
    func isWinner(_ playerId: UUID) -> Bool {
        var playersTotalSkins: [Int] = []
        
        for player in players {
            let playerTotals = playerTotalSkins(player.id)
            playersTotalSkins.append(playerTotals)
        }
        
        guard let maxTotals = playersTotalSkins.max(), maxTotals > 0 else {
            return false
        }
        
        return playerTotalSkins(playerId) == maxTotals
    }
    
    func playerTotalSkins(_ playerId: UUID) -> Int {
        var total = 0
        var carryOver = 0

        for hole in 0..<18 {
            if hole >= 18 {
                break
            }
            
            if let winner = winnerForHole(hole) {
                if winner.id == playerId {
                    total += 1 + carryOver
                    carryOver = 0
                } else {
                    carryOver = 0
                }
            } else if isTie(at: hole) {
                carryOver += 1
            }
        }

        return total
    }
    
    init(firstPlayerScore: PlayerModel, secondPlayerScore: PlayerModel) {
        players.append(firstPlayerScore)
        players.append(secondPlayerScore)
    }
    
    func getScore(for playerId: UUID, hole: Int) -> Int {
        if let playerIndex = players.firstIndex(where: { $0.id == playerId }) {
            guard hole < players[playerIndex].scores.count else {return 0 }
            return players[playerIndex].scores[hole] ?? 0
        }
        return 0
    }
    
    
    func getPlayerName(for playerId: UUID) -> String? {
        guard let playerIndex = players.firstIndex(where: { $0.id == playerId }) else {
            return nil
        }
        
        guard let name = players[playerIndex].name else {
            return "Player \(playerIndex)"
        }
        
        return name
    }
    
    func setPlayerName(for playerId: UUID, newValue: String) {
        objectWillChange.send()
        guard let playerIndex = players.firstIndex(where: { $0.id == playerId }) else {
            return
        }
        
        players[playerIndex].name = newValue
    }
    
    
    func updateScore(for playerId: UUID, holeIndex: Int, score: Int) {
        objectWillChange.send()
        guard let playerIndex = players.firstIndex(where: { $0.id == playerId }) else {
            return
        }
        
        players[playerIndex].scores[holeIndex] = score
        // For reactive update
        players[playerIndex].scores = players[playerIndex].scores
    }
    
    func restart() {
        objectWillChange.send()
        for player in players {
            player.scores = Array<Int?>(repeating: nil, count: 18)
        }
    }
}
