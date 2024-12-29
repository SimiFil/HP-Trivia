//
//  Gameplay.swift
//  HP Trivia
//
//  Created by Filip Simandl on 06.11.2024.
//

import SwiftUI
import AVKit

struct Gameplay: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var game: Game
    @Namespace private var namespace
    
    // Music
    @State private var musicPlayer: AVAudioPlayer!
    @State private var sfxPlayer: AVAudioPlayer!
    
    @State private var animateViewsIn: Bool = false
    @State private var hintAnimActive = false
    @State private var tappedCorrectAnswer = false
    @State private var wrongAnswersTapped: [Int] = []
    @State private var movePointsToScore = false
    @State private var revealHint = false
    @State private var revealBook = false
    
    let tempAnswers = [false, false, true, false]
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("hogwarts")
                    .resizable()
                    .frame(width: geo.size.width * 3, height: geo.size.height * 1.05)
                    .overlay(Rectangle().foregroundStyle(.black.opacity(0.8)))
                
                VStack {
                    // MARK: CONTROLS
                    HStack {
                        Button("End Game") {
                            game.endGame()
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red.opacity(0.5))
                        
                        Spacer()
                        
                        Text("Score: \(game.gameScore)")
                    }
                    .padding()
                    .padding(.vertical, 50)
                    
                    // MARK: QUESTION
                    VStack {
                        if animateViewsIn {
                            Text(game.currentQuestion.question)
                                .font(.custom(Constants.hpFont, size: 50))
                                .multilineTextAlignment(.center)
                                .padding()
                                .transition(.scale)
                                .opacity(tappedCorrectAnswer ? 0.1 : 1)
                        }
                    }
                    .animation(.easeInOut(duration: animateViewsIn ? 2 : 0), value: animateViewsIn)
                    
                    Spacer()
                    
                    // MARK: HINTS
                    if !tappedCorrectAnswer {
                        HStack {
                            VStack {
                                Image(systemName: "questionmark.app.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                                    .foregroundStyle(.cyan)
                                    .rotationEffect(.degrees(-15))
                                    .padding()
                                    .padding(.leading, 20)
                                    .onTapGesture {
                                        withAnimation(.easeOut(duration: 1)) {
                                            revealHint = true
                                        }
                                        
                                        playFlipSound()
                                        
                                        game.questionScore -= 1
                                    }
                                    .rotation3DEffect(.degrees(revealHint ? 1440 : 0), axis: (x: 0, y: 1, z: 0))
                                    .scaleEffect(revealHint ? 5 : 1)
                                    .opacity(revealHint ? 0 : 1)
                                    .offset(x: revealHint ? geo.size.width/2 : 0)
                                    .overlay(
                                        Text(game.currentQuestion.hint)
                                            .padding(.leading, 33)
                                            .minimumScaleFactor(0.5)
                                            .multilineTextAlignment(.center)
                                            .opacity(revealHint ? 1 : 0)
                                            .scaleEffect(revealHint ? 1.33 : 1)
                                        
                                    )
                            }
                            .animation(.easeOut(duration: 1.5).delay(2), value: animateViewsIn)
                        
                            Spacer()
                            
                            Image(systemName: "book.closed")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50)
                                .foregroundStyle(.black)
                                .frame(width: 100, height: 100)
                                .background(.cyan)
                                .clipShape(.rect(cornerRadius: 20))
                                .rotationEffect(.degrees(15))
                                .padding()
                                .padding(.trailing, 20)
                                .onTapGesture {
                                    withAnimation(.easeOut(duration: 1)) {
                                        revealBook = true
                                    }
                                    
                                    playFlipSound()
                                    
                                    game.questionScore -= 1
                                }
                                .rotation3DEffect(.degrees(revealBook ? 1440 : 0), axis: (x: 0, y: 1, z: 0))
                                .scaleEffect(revealBook ? 5 : 1)
                                .opacity(revealBook ? 0 : 1)
                                .offset(x: revealBook ? -geo.size.width/2 : 0)
                                .overlay(
                                    Image("hp\(game.currentQuestion.book)")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(.bottom, 10)
                                        .padding(.trailing, 33)
                                        .minimumScaleFactor(0.5)
                                        .multilineTextAlignment(.center)
                                        .opacity(revealBook ? 1 : 0)
                                        .scaleEffect(revealBook ? 1.33 : 1)
                                    
                                )
                                .animation(.easeOut(duration: 1.5).delay(2), value: animateViewsIn)
                        }
                        .onAppear {
                            startWiggleTimer(intervalTime: 10)
                        }
                        .symbolEffect(.wiggle, value: hintAnimActive)
                        .padding(.bottom)
                    }
                    
                    
                    // MARK: ANSWERS
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(Array(game.answers.enumerated()), id: \.offset) { i, answer in
                            if !tappedCorrectAnswer {
                                if game.currentQuestion.answers[answer] == true {
                                    Text(answer)
                                        .minimumScaleFactor(0.5)
                                        .multilineTextAlignment(.center)
                                        .padding(10)
                                        .frame(width: geo.size.width/2.15, height: 80)
                                        .background(.green.opacity(0.5))
                                        .clipShape(.rect(cornerRadius: 10))
                                        .matchedGeometryEffect(id: "answer", in: namespace)
                                        .onTapGesture {
                                            withAnimation(.easeOut(duration: 1)) {
                                                tappedCorrectAnswer = true
                                            }
                                            
                                            playCorrectSound()
                                            
                                            Task {
                                                try? await Task.sleep(for: .seconds(3.5))
                                                game.correct()
                                            }
                                        }
                                } else {
                                    Text(answer)
                                        .minimumScaleFactor(0.5)
                                        .multilineTextAlignment(.center)
                                        .padding(10)
                                        .frame(width: geo.size.width/2.15, height: 80)
                                        .background(wrongAnswersTapped.contains(i) ? .red.opacity(0.5) : .green.opacity(0.5))
                                        .clipShape(.rect(cornerRadius: 10))
                                        .transition(.scale)
                                        .onTapGesture {
                                            withAnimation(.easeOut(duration: 1)) {
                                                wrongAnswersTapped.append(i)
                                            }
                                            
                                            playWrongSound()
                                            giveWrongFeedback()
                                            game.questionScore -= 1
                                        }
                                        .scaleEffect(wrongAnswersTapped.contains(i) ? 0.8 : 1)
                                        .disabled(tappedCorrectAnswer || wrongAnswersTapped.contains(i)) // can't be tapped after being clicked on once
                                }
                                
                            }
                        }
                    }
                    
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .foregroundStyle(.white)
                
                // MARK: CELEBRATION
                VStack {
                    Spacer()
                    
                    VStack {
                        if tappedCorrectAnswer {
                            Text("\(game.questionScore)")
                                .font(.largeTitle)
                                .padding(.top, 50)
                                .transition(.offset(y: -geo.size.height/4))
                                .offset(x: movePointsToScore ? geo.size.width/2.3 : 0, y: movePointsToScore ? -geo.size.height/13 : 0)
                                .opacity(movePointsToScore ? 0 : 1)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 1).delay(3)) {
                                        movePointsToScore = true
                                    }
                                }
                        }
                    }
                    .animation(.easeInOut(duration: tappedCorrectAnswer ? 1 : 0).delay(tappedCorrectAnswer ? 2 : 0), value: tappedCorrectAnswer)
                    
                    Spacer()
                    
                    VStack{
                        if tappedCorrectAnswer {
                            Text("Brilliant!")
                                .font(.custom(Constants.hpFont, size: 100))
                                .transition(.scale.combined(with: .offset(y: -geo.size.height/2)))
                        }
                    }
                    .animation(.easeInOut(duration: 1).delay(1), value: tappedCorrectAnswer)
                    
                    
                    Spacer()
                    
                    if tappedCorrectAnswer {
                        Text(game.correctAnswer)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                            .padding(10)
                            .frame(width: geo.size.width/2.15, height: 80)
                            .background(.green.opacity(0.5))
                            .clipShape(.rect(cornerRadius: 25))
                            .scaleEffect(2)
                            .matchedGeometryEffect(id: "answer", in: namespace)
                    }
                    
                    Spacer()
                    
                    VStack{
                        if tappedCorrectAnswer {
                            Button("Next level ->") {
                                animateViewsIn = false
                                tappedCorrectAnswer = false
                                revealHint = false
                                revealBook = false
                                movePointsToScore = false
                                wrongAnswersTapped = []
                                game.newQuestion()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    animateViewsIn = true
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue.opacity(0.5))
                            .font(.largeTitle)
                            .transition(.offset(y: geo.size.height/3))
                        }
                    }
                    .animation(.easeInOut(duration: 2.7).delay(2.7), value: tappedCorrectAnswer)
                    
                    Spacer()
                    Spacer()
                }
                .foregroundStyle(.white)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .onAppear {
            animateViewsIn = true
            
            Task {
                try await Task.sleep(for: .seconds(3))
                playMusic()
            }
        }
    }
    
    private func playMusic() {
        let songs = ["let-the-mystery-unfold", "spellcraft", "hiding-place-in-the-forest", "deep-in-the-dell"]
        let i = Int.random(in: 0...3)
        
        let sound = Bundle.main.path(forResource: songs[i], ofType: "mp3")
        
        musicPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        
        musicPlayer.volume = 0.1
        musicPlayer.numberOfLoops = -1 // infinity
        musicPlayer.play()
    }
    
    private func playFlipSound() {
        let sound = Bundle.main.path(forResource: "page-flip", ofType: "mp3")
        sfxPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        sfxPlayer.play()
    }
    
    private func playCorrectSound() {
        let sound = Bundle.main.path(forResource: "magic-wand", ofType: "mp3")
        sfxPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        sfxPlayer.play()
    }
    
    private func playWrongSound() {
        let sound = Bundle.main.path(forResource: "negative-beeps", ofType: "mp3")
        sfxPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        sfxPlayer.play()
    }
    
    // shakes the real device
    private func giveWrongFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    private func startWiggleTimer(intervalTime: Double) {
        Timer.scheduledTimer(withTimeInterval: intervalTime, repeats: true) { _ in
            hintAnimActive.toggle()
        }
    }
}

#Preview {
    Gameplay()
        .environmentObject(Game())
}
