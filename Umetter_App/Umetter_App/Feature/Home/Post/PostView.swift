import SwiftUI
import Combine

struct PostView: View {
    @StateObject private var viewModel = PostViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var onPost: () -> Void

    init(onPost: @escaping () -> Void = {}) {
        self.onPost = onPost
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // --- 1. ヘッダー ---
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding(4)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    UmeIcon(isLiked: true)
                        .frame(width: 18, height: 18)
                    
                    Text("うめったー")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 139/255, green: 30/255, blue: 56/255))
                }
                
                Spacer()
                
                // 投稿ボタン
                Button(action: {
                    Task {
                        do {
                            try await viewModel.submitPost()
                            onPost()
                            dismiss()
                        } catch let error as APIError {
                            viewModel.errorMessage = error.localizedDescription
                        } catch {
                            viewModel.errorMessage = "投稿に失敗しました"
                        }
                    }
                }) {
                    Text("投稿")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.canSubmit
                            ? Color(red: 139/255, green: 30/255, blue: 56/255)
                            : Color.gray.opacity(0.5)
                        )
                        .clipShape(Capsule())
                }
                .disabled(!viewModel.canSubmit)
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            Divider()
            
            // --- 2. 本文入力エリア ＆ 追加されたタグ ---
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    if viewModel.content.isEmpty {
                        Text("いまどうしてる？ (完全匿名)")
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                    }
                    
                    TextEditor(text: $viewModel.content)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                }
                .padding(12)
                .frame(maxHeight: .infinity)
                
                if !viewModel.addedTags.isEmpty {
                    Divider()
                        .padding(.horizontal, 12)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        FlowLayoutModel(spacing: 8) {
                            ForEach(viewModel.addedTags, id: \.self) { tag in
                                HStack(spacing: 4) {
                                    Text(tag)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                    
                                    Image(systemName: "xmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(Color(red: 251/255, green: 113/255, blue: 133/255))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(red: 255/255, green: 241/255, blue: 242/255))
                                .foregroundColor(Color(red: 139/255, green: 30/255, blue: 56/255))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(red: 255/255, green: 228/255, blue: 230/255), lineWidth: 1)
                                )
                                .onTapGesture {
                                    viewModel.removeTag(tag)
                                }
                            }
                        }
                        .padding(12)
                    }
                    .frame(maxHeight: 120)
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .padding(16)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            // --- 3. ツールバー ---
            HStack(spacing: 12) {
                Button(action: {
                    // 画像追加アクション
                }) {
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
                
                HStack {
                    Text("#")
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    
                    TextField("タグを追加 (Enterで確定)", text: $viewModel.newTagText)
                        .onSubmit {
                            viewModel.addTag(viewModel.newTagText)
                        }
                        .submitLabel(.done)
                }
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            .padding(.horizontal, 16)
            
            // --- 4. おすすめタグ領域 ---
            VStack(alignment: .leading, spacing: 10) {
                Text("おすすめのタグ (タップで追加)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.suggestedTags, id: \.self) { tag in
                            Button(action: {
                                viewModel.addTag(tag)
                            }) {
                                Text(tag)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 48)
        }
        .background(Color(red: 248/255, green: 244/255, blue: 240/255).ignoresSafeArea())
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        Color.gray.opacity(0.4)
            .ignoresSafeArea()
            .sheet(isPresented: .constant(true)) {
                PostView()
                    .presentationDetents([.fraction(0.9)])
                    .presentationCornerRadius(40)
            }
    }
}
