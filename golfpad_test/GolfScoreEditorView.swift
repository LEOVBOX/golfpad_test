//
//  ContentView.swift
//  golfpad_test
//
//  Created by Леонид Шайхутдинов on 09.09.2025.
//

import SwiftUI

struct GolfScoreEditor: View {
    @StateObject private var viewModel = ScoreViewModel(
        firstPlayerScore: PlayerModelBuilder.shared.getRandomMockPlayer(),
        secondPlayerScore: PlayerModelBuilder.shared.getRandomMockPlayer()
    )
    
    @State private var showHint = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack {
                    // Table legend
                    VStack(alignment: .center, spacing: GolfEditorConstants.tableVerticalSpacting) {
                        Text("")
                        ForEach(viewModel.players) { player in
                            PlayerNameTextField(player: player, viewModel: viewModel)
                        }
                    }
                    
                                      
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: GolfEditorConstants.tableVerticalSpacting) {
                            // Hole indexes
                            HStack {
                                ForEach(1...18, id: \.self) { hole in
                                    Text("\(hole)")
                                        .frame(width: GolfEditorConstants.scoreCoumnWidth)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Players score
                            VStack(alignment: .leading) {
                                ForEach(viewModel.players) { player in
                                    PlayerRow(player: player, viewModel: viewModel)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                withAnimation {
                                    hideHint()
                                }
                            }
                    )
                    .scrollIndicators(.visible)
                    
                }
                .padding()
                
                if showHint {
                    Text("Hint: scroll the table")
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .onTapGesture {
                            withAnimation {
                                showHint = false
                            }
                        }
                }
                
                Spacer()
                
                // Final score section
                VStack(spacing: GolfEditorConstants.finalScoreSpacing) {
                    Text("Final score")
                        .fontWeight(.bold)
                        //.bold()
                        
                    
                    HStack {
                        ForEach(viewModel.players) { player in
                            Text("\(player.name ?? "Player"): \(viewModel.playerTotalSkins(player.id))")
                                .padding()
                                .multilineTextAlignment(.center)
                                .lineLimit(3)
                                .background(
                                    viewModel.isWinner(player.id) ?
                                        Color.green :
                                        Color.gray
                                )
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    
                    Button(action: {
                        viewModel.restart()
                    }) {
                        Text("Restart")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                .padding()
                
            }
            .navigationTitle("Golf skins")
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func hideHint() {
        self.showHint = false
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


/// Player scores row
struct PlayerRow: View {
    @ObservedObject var player: PlayerModel
    @ObservedObject var viewModel: ScoreViewModel
    
    var body: some View {
        HStack {
            ForEach(0..<18, id: \.self) { holeIndex in
                ScoreCell(player: player, holeIndex: holeIndex, viewModel: viewModel)
            }
        }
    }
}

enum GolfEditorConstants {
    static let verticalSpacing: CGFloat = 16
    static let tableVerticalSpacting: CGFloat = 12
    static let scoreCoumnWidth: CGFloat = 35
    static let playerNameWidth: CGFloat = 200
    static let finalScoreSpacing: CGFloat = 8
    static let playersScoreVerticalSpacing: CGFloat = 8
    static let scoreCellCornerRadius: CGFloat = 6
}

/// Score textfield
struct ScoreCell: View {
    @ObservedObject var player: PlayerModel
    let holeIndex: Int
    @ObservedObject var viewModel: ScoreViewModel
    
    var body: some View {
        TextField("", text: Binding(
            get: {
                let score = viewModel.getScore(for: player.id, hole: holeIndex)
                return score < 1 ? "" : "\(score)"
            },
            set: { newValue in
                if newValue == "" {
                    viewModel.updateScore(for: player.id, holeIndex: holeIndex, score: 0)
                } else if let intValue = Int(newValue) {
                    viewModel.updateScore(for: player.id, holeIndex: holeIndex, score: intValue)
                } else if newValue.isEmpty {
                    viewModel.updateScore(for: player.id, holeIndex: holeIndex, score: 0)
                }
            }
        ))
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .multilineTextAlignment(.center)
        .frame(width: GolfEditorConstants.scoreCoumnWidth)
        .keyboardType(.numberPad)
        .foregroundStyle(
            viewModel.isTie(at: holeIndex) ?
                Color.yellow :
                (viewModel.winnerForHole(holeIndex)?.id == player.id ?
                    Color.green : .black)
        )
        .cornerRadius(GolfEditorConstants.scoreCellCornerRadius)
    }
}


struct PlayerNameTextField: View {
    @ObservedObject var player: PlayerModel
    @ObservedObject var viewModel: ScoreViewModel
    
    var body: some View {
        TextField("", text: Binding(
            get: {
                let name = viewModel.getPlayerName(for: player.id)
                return name ?? "Player unknown"
            },
            set: { newValue in
                viewModel.setPlayerName(for: player.id, newValue: newValue)
            }
        ))
        .frame(maxWidth: GolfEditorConstants.playerNameWidth)
        .lineLimit(3)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .multilineTextAlignment(.center)
        
    }
}



#Preview {
    GolfScoreEditor()
}
