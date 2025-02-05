//
//  MarkdownView.swift
//  AdvancedDashboard
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
                let processedLine = processLinks(in: String(line))
                attributedString.append(processedLine)
            }
            attributedString.append(AttributedString("\n"))
        }
        
        return attributedString
    }
    
    private func processLinks(in text: String) -> AttributedString {
            var result = AttributedString()
            let pattern = #"\[([^\]]+)\]\(([^\)]+)\)"#
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            let nsRange = NSRange(text.startIndex..., in: text)
            
            var lastIndex = text.startIndex
            
            regex.enumerateMatches(in: text, options: [], range: nsRange) { match, _, _ in
                guard let match = match else { return }
                
                let beforeLink = text[lastIndex..<text.index(text.startIndex, offsetBy: match.range.lowerBound)]
                if !beforeLink.isEmpty {
                    result.append(AttributedString(String(beforeLink)))
                }
                
                if let linkTextRange = Range(match.range(at: 1), in: text),
                   let urlRange = Range(match.range(at: 2), in: text) {
                    let linkText = String(text[linkTextRange])
                    let urlString = String(text[urlRange])
                    
                    var linkAttribute = AttributedString(linkText)
                    linkAttribute.foregroundColor = .blue
                    linkAttribute.underlineStyle = .single
                    
                    if let url = URL(string: urlString) {
                        linkAttribute.link = url
                    }
                    
                    result.append(linkAttribute)
                }
                
                lastIndex = text.index(text.startIndex, offsetBy: match.range.upperBound)
            }
            
            let remainingText = text[lastIndex...]
            if !remainingText.isEmpty {
                result.append(AttributedString(String(remainingText)))
            }
            
            return result
        }
}

#Preview {
    MarkdownView(filename: "term_of_service")
}

