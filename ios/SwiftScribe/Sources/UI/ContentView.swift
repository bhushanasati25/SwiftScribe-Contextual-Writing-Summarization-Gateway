import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            SummarizerView()
                .tabItem {
                    Label("Summarize", systemImage: "text.quote")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
        }
    }
}

struct SummarizerView: View {
    @State private var textInput: String = ""
    @State private var summary: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextEditor(text: $textInput)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .frame(maxHeight: 250)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    )
                    .accessibilityLabel("Text to summarize")
                    .accessibilityHint("Enter the text you want the AI to summarize here")
                
                Button(action: {
                    impactFeedback.impactOccurred()
                    summarizeText()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Summarize")
                            .fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(textInput.isEmpty ? Color.secondary.opacity(0.3) : Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                .disabled(textInput.isEmpty || isLoading)
                .accessibilityLabel("Summarize Button")
                .accessibilityHint("Starts the AI summarization process")
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                if !summary.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Summary")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                UIPasteboard.general.string = summary
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .font(.subheadline)
                            }
                        }
                        
                        ScrollView {
                            Text(summary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemBlue).opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("SwiftScribe")
        }
    }
    
    private func summarizeText() {
        isLoading = true
        errorMessage = nil
        
        // Check local cache first
        if let cachedSummary = CacheManager.shared.get(for: textInput) {
            self.summary = cachedSummary
            self.isLoading = false
            return
        }
        
        Task {
            do {
                let response = try await NetworkManager.shared.summarize(text: textInput)
                await MainActor.run {
                    self.summary = response.summary
                    self.isLoading = false
                    // Save to local cache
                    CacheManager.shared.set(response.summary, for: textInput)
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to summarize: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}

struct HistoryView: View {
    var body: some View {
        NavigationView {
            List {
                Text("No history yet.")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("History")
        }
    }
}

struct ContentView: View {
    var body: some View {
        MainView()
    }
}

#Preview {
    ContentView()
}
