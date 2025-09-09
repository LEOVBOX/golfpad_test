//
//  PlayerScoreModel.swift
//  golfpad_test
//
//  Created by Леонид Шайхутдинов on 09.09.2025.
//

import Foundation

class PlayerModel: Identifiable, ObservableObject {
    let id = UUID()
    var name: String?
    @Published var scores = Array<Int?>(repeating: nil, count: 18)
    
    init(name: String? = nil, scores: [Int?] = Array<Int?>(repeating: nil, count: 18)) {
        self.name = name
        if (scores.count < 18) {
            for i in 0..<scores.count {
                self.scores[i] = scores[i]
            }
        }
        else {
            self.scores = scores
        }
    }
}
