                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        ProgressBarView(progress: $viewModel.progressValue)
                            .padding()
                            .presentationBackground(Color.clear)
                    }