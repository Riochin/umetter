import SwiftUI
import Combine

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingNewPost = false
    @State private var now = Date()

    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.umeBackground.ignoresSafeArea()
                
                ScrollView {
                    // 休講情報バー
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                        Text("【重要】休講情報: SitesGoogleLink...")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .foregroundColor(.umeRed)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(red: 238/255, green: 220/255, blue: 211/255).opacity(0.5))
                    .overlay(
                        VStack {
                            Divider()
                            Spacer()
                            Divider()
                        }
                    )
                    
                    // タイムライン
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.posts) { post in
                            NewPostView(
                                post: post,
                                viewModel: viewModel,
                                now: now
                            )
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
                
                Button(action: {
                    showingNewPost = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.umeRed)
                        .clipShape(Circle())
                        .shadow(color: Color.umeRed.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        UmeIcon(isLiked: true)
                            .frame(width: 18, height: 18)
                        
                        Text("うめったー")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.umeRed)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .foregroundColor(.gray)
                    }
                }
            }
            .sheet(isPresented: $showingNewPost) {
                PostView { newPost in
                    viewModel.addPost(newPost)
                    showingNewPost = false
                }
                .presentationDetents([.fraction(0.9)])
                .presentationCornerRadius(40)
            }
        }
        .onReceive(timer) { date in
            now = date
        }
    }
}

