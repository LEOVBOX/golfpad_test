//
//  PlayerModelBuilder.swift
//  golfpad_test
//
//  Created by Леонид Шайхутдинов on 09.09.2025.
//

class PlayerModelBuilder {
    static let shared = PlayerModelBuilder()
    
    private var players: [PlayerModel] = [
        PlayerModel(name: "Петров Александр", scores: [12, 23, 45, 2, 3, 4]),
        PlayerModel(name: "Иванов Иван"),
        PlayerModel(name: "John Boe"),
        PlayerModel(name: "Аlice Nevermind")
    ]
    
    func getRandomMockPlayer() -> PlayerModel {
        let resultIdx = Int.random(in: 0...players.count-1)
        let result = players[resultIdx]
        players.remove(at: resultIdx)
        return result
    }
}
