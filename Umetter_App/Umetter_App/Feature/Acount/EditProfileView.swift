import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AccountViewModel
    
    @State private var draftName: String = ""
    @State private var draftDepartment: String = ""
    @State private var draftYear: String = ""
    @State private var draftBio: String = ""
    @State private var draftIconColor: Color = Color.borderColor
    @State private var draftVisibility: String = "private"

    let visibilityOptions: [(String, String)] = [
        ("private",  "非公開"),
        ("friends",  "友達のみ"),
        ("juniors",  "後輩まで"),
        ("all",      "全員に公開"),
    ]
    
    let availableColors: [Color] = [
        Color.borderColor, Color(hex: "FCA5A5"), Color(hex: "93C5FD"), Color(hex: "D8B4FE"), Color(hex: "FCD34D")
    ]
    let enrollmentYears = ["2023年度入学", "2024年度入学", "2025年度入学", "2026年度入学"]
    
    var body: some View {
        NavigationStack {
            Form {
      
                Section {
                    VStack(spacing: 12) {
                        Circle()
                            .fill(draftIconColor)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(20)
                                    .foregroundColor(.white)
                            )
                        
                        Text("アイコンの色を変更")
                            .font(.caption)
                            .foregroundColor(.textGray)
                        
                        HStack(spacing: 16) {
                            ForEach(availableColors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(draftIconColor == color ? Color.textDark : Color.clear, lineWidth: 2)
                                            .scaleEffect(1.15)
                                    )
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            draftIconColor = color
                                        }
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)
                

                Section(header: Text("基本情報")) {
                    HStack {
                        Text("名前")
                            .frame(width: 80, alignment: .leading)
                            .foregroundColor(.textGray)
                        TextField("名前を入力", text: $draftName)
                    }
                    
                    Picker("学部・学科", selection: $draftDepartment) {
                        if draftDepartment.isEmpty {
                            Text("選択してください").tag("")
                        }
                        Section(header: Text("学芸学部")) {
                            Text("英語英文学科").tag("学芸学部 英語英文学科")
                            Text("国際関係学科").tag("学芸学部 国際関係学科")
                            Text("多文化・国際協力学科").tag("学芸学部 多文化・国際協力学科")
                            Text("数学科").tag("学芸学部 数学科")
                            Text("情報科学科").tag("学芸学部 情報科学科")
                        }
                        Section(header: Text("総合政策学部")) {
                            Text("総合政策学科").tag("総合政策学部 総合政策学科")
                        }
                    }
                    
                    Picker("入学年度", selection: $draftYear) {
                        if draftYear.isEmpty {
                            Text("選択してください").tag("")
                        }
                        ForEach(enrollmentYears, id: \.self) { year in
                            Text(year).tag(year)
                        }
                    }
                }
 
                Section(header: Text("時間割の公開設定")) {
                    Picker("公開範囲", selection: $draftVisibility) {
                        ForEach(visibilityOptions, id: \.0) { value, label in
                            Text(label).tag(value)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section(header: Text("自己紹介")) {
                    ZStack(alignment: .topLeading) {
                        if draftBio.isEmpty {
                            Text("自己紹介を入力してください")
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $draftBio)
                            .frame(minHeight: 100)
                    }
                }
            }
            .navigationTitle("プロフィールを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.textGray)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        viewModel.saveProfile(
                            name: draftName,
                            department: draftDepartment,
                            enrollmentYear: draftYear,
                            bio: draftBio,
                            iconColor: draftIconColor
                        )
                        viewModel.saveVisibility(draftVisibility)
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.umeRed)
                }
            }
            .onAppear {
                draftName = viewModel.userProfile.name
                draftDepartment = viewModel.userProfile.department
                draftYear = viewModel.userProfile.enrollmentYear
                draftBio = viewModel.userProfile.bio
                draftIconColor = viewModel.userProfile.iconColor
                draftVisibility = viewModel.userProfile.timetableVisibility
            }
        }
    }
}
