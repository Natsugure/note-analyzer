//
//  BackgroundClearProgressView.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/14.
//


                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        ProgressBarView(progress: $viewModel.progressValue)
                            .padding()
                            .presentationBackground(Color.clear)
                    }