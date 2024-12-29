//
//  Instructions.swift
//  HP Trivia
//
//  Created by Filip Simandl on 06.11.2024.
//

import SwiftUI

struct Instructions: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            InfoBackgroundView()
            
            VStack {
                Image("appiconwithradius")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .padding(.top, 25)
                
                ScrollView {
                    Text("How to play")
                        .font(.largeTitle)
                        .padding()
                    
                    VStack(alignment: .leading) {
                        Text("1. Select a category")
                            .padding()
                        
                        Text("2. Start the game")
                            .padding()
                        
                        Text("3. Answer the questions")
                            .padding()
                        
                        Text("Each Question is worth 5 points, but if you guess a wrong answer you lose 1 points")
                            .padding([.horizontal, .bottom])
                        
                        Text("If you are struggling with a question, there is an option to reveal a hint or reveal the book that answers the question. But beware, if you reveal a hint you will lose 1 point.")
                            .padding([.horizontal, .bottom])
                        
                        Text("When you select the correct anwer, you iwll be awarded all the points left for that question and the will be added to your total score.")
                            .padding([.horizontal, .bottom])
                            
                    }
                    .font(.title2)
                    
                    Text("Good Luck!")
                        .font(.title)
                }
                .foregroundStyle(.black)
                
                Button("Done") {
                    dismiss()
                }
                .doneButtonStyle()
            }
        }
    }
}

#Preview {
    Instructions()
}
