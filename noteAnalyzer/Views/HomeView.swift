//
//  HomeView.swift
//  noteAnalyzer
//
//  Created by 秋空 on 2024/07/27.
//

import SwiftUI
import RealmSwift

struct HomeView: View {
    @ObservedObject var networkManager = NetworkManager()
    @ObservedResults(Item.self) var items
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                VStack {
                    Text("全期間アクセス状況")
                    VStack {
                        VStack {
                            Text("ビュー")
                                .frame(alignment: .top)
                            Text(formattedString(from: totalCount(for: \.readCount)))
                                .font(.system(size: 24, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity, maxHeight: geometry.size.width / 4)
                        .background(K.BrandColor.read.opacity(0.5))
                        
                        HStack {
                            VStack {
                                Text("コメント")
                                Text(formattedString(from: totalCount(for: \.commentCount)))
                                    .font(.system(size: 24, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity, maxHeight: geometry.size.width / 4)
                            .background(K.BrandColor.comment.opacity(0.3))
                            
                            VStack {
                                Text("スキ")
                                Text(formattedString(from: totalCount(for: \.likeCount)))
                                    .font(.system(size: 24, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity, maxHeight: geometry.size.width / 4)
                            .background(K.BrandColor.likeBackground)
                        }
                        }
                    .padding()
                }
                .navigationTitle("note Analyzer")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    //更新ボタン
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            Task {
                                await networkManager.getStats()
                            }
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                        }
                    }
                }
            }
        }
    }
    
    private func totalCount<T: Numeric>(for keyPath: KeyPath<Stats, T>) -> T {
        items.map { $0.stats.last?[keyPath: keyPath] ?? 0 }.reduce(0, +)
    }
    
    private func formattedString(from number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "0"
    }
}

#Preview {
    HomeView()
}
