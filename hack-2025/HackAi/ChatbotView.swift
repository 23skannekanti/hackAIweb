//
//  ChatbotView.swift
//  HackAi
//
//  Created by Satvik Kannekanti on 2/21/25.
//

import SwiftUI

struct ChatbotView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var userInput: String = ""
    @State private var messages: [Message] = []
    private let chatGPTService = ChatGPTService()

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding()
                }
                Spacer()
                Text("Chat with Jeek")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color.blue)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages) { message in
                        HStack {
                            if message.role == .user {
                                Spacer()
                                Text(message.content)
                                    .padding()
                                    .background(Color.blue.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .frame(maxWidth: 250, alignment: .trailing)
                            } else {
                                Text(message.content)
                                    .padding()
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(10)
                                    .frame(maxWidth: 250, alignment: .leading)
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }

            HStack {
                TextField("Ask a question...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: sendMessage) {
                    Text("Send")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(userInput.isEmpty)
                .padding()
            }
        }
    }

    private func sendMessage() {
        let trimmed = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let userMessage = Message(role: .user, content: trimmed)
        messages.append(userMessage)
        userInput = ""

        chatGPTService.sendMessage(prompt: trimmed) { response in
            let botMessage = Message(role: .bot, content: response)
            messages.append(botMessage)
        }
    }
}

#Preview {
    ChatbotView()
}
