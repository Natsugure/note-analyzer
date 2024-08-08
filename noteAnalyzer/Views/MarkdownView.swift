//
//  MarkdownView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2024/08/06.
//

import SwiftUI

struct MarkdownView: View {
    let filename: String
    @State private var attributedString = AttributedString()
    
    var body: some View {
        ScrollView {
            Text(attributedString)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
        }
        .onAppear {
            loadMarkdownContent()
        }
    }
    
    private func loadMarkdownContent() {
        if let fileURL = Bundle.main.url(forResource: filename, withExtension: "md"),
           let content = try? String(contentsOf: fileURL) {
            attributedString = parseMarkdown(content)
        }
    }
    
    private func parseMarkdown(_ markdown: String) -> AttributedString {
        var attributedString = AttributedString()
        
        let lines = markdown.split(separator: "\n", omittingEmptySubsequences: false)
        for line in lines {
            if line.starts(with: "# ") {
                var header = AttributedString(String(line.dropFirst(2)))
                header.font = .system(size: 24, weight: .bold)
                attributedString.append(header)
            } else if line.starts(with: "## ") {
                var header = AttributedString(String(line.dropFirst(3)))
                header.font = .system(size: 20, weight: .bold)
                attributedString.append(header)
            } else if line.starts(with: "### ") {
                var header = AttributedString(String(line.dropFirst(4)))
                header.font = .system(size: 18, weight: .bold)
                attributedString.append(header)
            } else {
                let text = AttributedString(line)
                attributedString.append(text)
            }
            attributedString.append(AttributedString("\n"))
        }
        
        return attributedString
    }
}

#Preview {
    MarkdownView(filename: "term_of_service")
}

