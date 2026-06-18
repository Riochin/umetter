import SwiftUI

struct TimetableView: View {
    // Controllerと連携
    @StateObject private var controller = TimetableModelView()
    
    var body: some View {
        // MainTabView側でNavigationStackが使われているため、ここはVStackから開始
        VStack(spacing: 0) {
            headerView
            alertBarView
            
            ScrollView(showsIndicators: false) {
                timetableGrid
                    .padding(.horizontal, 8)
                    .padding(.bottom, 20)
            }
        }
        // 👇 背景色をアプリ全体のアイボリー色（umeBackground）に統一し、画面全体に広げる
        .background(Color.umeBackground.ignoresSafeArea())
        //.navigationTitle("時間割")
        .navigationBarTitleDisplayMode(.inline)
        // 👇 画面が表示された瞬間に通知データを取得する
        .onAppear {
            controller.fetchActiveAlert()
        }
        .task {
            await controller.loadTimetable()
        }
        .sheet(isPresented: $controller.showingPicker) {
            pickerSheet.presentationDetents([.height(250)])
        }
        .sheet(isPresented: $controller.showingSettings) {
            settingsSheet.presentationDetents([.height(300)])
        }
        .sheet(isPresented: $controller.showingEditSheet) {
            editSlotSheet.presentationDetents([.fraction(0.6)])
        }
        .sheet(isPresented: $controller.showingClassSearch) {
            ClassSearchView(termKey: controller.currentTermKey)
        }
    }
    
    // MARK: - UIコンポーネント
    
    private var headerView: some View {
        HStack {
            Spacer().frame(width: 44)
            Spacer()
            Button(action: { controller.showingPicker = true }) {
                HStack(spacing: 6) {
                    Text("\(controller.selectedYear) \(controller.selectedTerm)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Button(action: { controller.showingSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 22))
                    .foregroundColor(Color.gray.opacity(0.8))
                    .frame(width: 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.umeBackground)
    }
    
    @ViewBuilder
    private var alertBarView: some View {
        // バックエンドから緊急通知が来ている（nilじゃない）時だけ表示する
        if let alertText = controller.activeAlert {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.umeRed)
                Text(alertText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.umeRed)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.umeRed.opacity(0.1))
            .overlay(
                Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.2)), alignment: .bottom
            )
        }
    }
    
    private var timetableGrid: some View {
        let activeDays = controller.showWeekend ? controller.allDays : Array(controller.allDays.prefix(5))
        let activePeriods = controller.showPeriod6 ? controller.allPeriods : Array(controller.allPeriods.prefix(5))
        
        let weekdayIndex = Calendar.current.component(.weekday, from: Date())
                let weekdaySymbols = ["", "日", "月", "火", "水", "木", "金", "土"]
                let todayString = weekdaySymbols[weekdayIndex]
        
        return Grid(horizontalSpacing: 4, verticalSpacing: 4) {
            // 曜日ヘッダー
            GridRow {
                Color.clear.frame(width: 36, height: 30)
                ForEach(activeDays, id: \.self) { day in
                    let isToday = day == todayString
                    Text(day)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isToday ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background(isToday ? Color.umeRed : Color.clear)
                        .clipShape(Circle())
                }
            }
            .padding(.top, 8)
            
            // 通常のコマ
            ForEach(activePeriods, id: \.0) { period in
                GridRow {
                    VStack(spacing: 2) {
                        Text("\(period.0)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.gray)
                        Text(period.1)
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 36)
                    
                    ForEach(activeDays, id: \.self) { day in
                        let key = "\(day)-\(period.0)"
                        // 現在の学期のコマを取得
                        let slot = controller.getTimetableSlot(key: key)
                        
                        SlotView(slot: slot, isOndemand: false, showPeriod6: controller.showPeriod6) {
                            controller.openEditSheet(key: key, isOndemand: false, slot: slot)
                        }
                    }
                }
            }
            
            GridRow {
                Color.clear.frame(height: 8)
                ForEach(activeDays, id: \.self) { _ in Color.clear.frame(height: 8) }
            }
            
            // オンデマンド行
            GridRow {
                Text("オンデ\nマンド")
                    .font(.system(size: 8, weight: .heavy))
                    .foregroundColor(.umeRed)
                    .frame(width: 36)
                    .multilineTextAlignment(.center)
                
                ForEach(activeDays, id: \.self) { day in
                    // 現在の学期のオンデマンドコマを取得
                    let slot = controller.getOndemandSlot(key: day)
                    
                    SlotView(slot: slot, isOndemand: true, showPeriod6: controller.showPeriod6) {
                        controller.openEditSheet(key: day, isOndemand: true, slot: slot)
                    }
                }
            }
        }
    }
    
    // MARK: - 各種シート UI
    private var editSlotSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text(controller.isOndemandEdit ? "オンデマンド授業" : "通常授業")) {
                    TextField("科目名 (必須)", text: $controller.editSubject)
                    if !controller.isOndemandEdit {
                        TextField("教室名 (任意)", text: $controller.editRoom)
                    }
                }
                
                Section(header: Text("カラーテーマ")) {
                    Picker("色を選択", selection: $controller.editColor) {
                        ForEach(SlotColor.allCases, id: \.self) { color in
                            HStack {
                                Circle().fill(color.background).frame(width: 16, height: 16)
                                Text(color.rawValue)
                            }
                            .tag(color)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section {
                    Button(action: {
                        controller.showingEditSheet = false
                        controller.showingClassSearch = true
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("科目を検索して追加")
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.umeRed)
                    }
                }

                Section {
                    Button(action: { controller.saveSlot() }) {
                        Text("保存する")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.umeRed)
                    
                    let hasExistingSlot = controller.isOndemandEdit
                        ? (controller.getOndemandSlot(key: controller.editKey) != nil)
                        : (controller.getTimetableSlot(key: controller.editKey) != nil)
                    
                    // 既にデータがある場合のみ削除ボタンを表示
                    if hasExistingSlot {
                        Button(action: { controller.deleteSlot() }) {
                            Text("この授業を削除")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle(controller.editSubject.isEmpty ? "新規登録" : "授業の編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") { controller.showingEditSheet = false }
                        .foregroundColor(.umeRed)
                }
            }
        }
    }
    
    private var pickerSheet: some View {
        VStack {
            HStack {
                Spacer()
                Button("完了") { controller.showingPicker = false }
                    .font(.headline)
                    .foregroundColor(.umeRed)
                    .padding()
            }
            HStack(spacing: 0) {
                Picker("年", selection: $controller.selectedYear) {
                    ForEach(controller.years, id: \.self) { Text($0) }
                }.pickerStyle(.wheel)
                
                Picker("ターム", selection: $controller.selectedTerm) {
                    ForEach(controller.terms, id: \.self) { Text($0) }
                }.pickerStyle(.wheel)
            }
            Spacer()
        }
    }
    
    private var settingsSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("表示のカスタマイズ")) {
                    Toggle("土・日の表示", isOn: $controller.showWeekend)
                        .tint(.umeRed)
                    Toggle(isOn: $controller.showPeriod6) {
                        VStack(alignment: .leading) {
                            Text("6限の表示")
                            Text("18:00 - 19:30")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .tint(.umeRed)
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") { controller.showingSettings = false }
                        .foregroundColor(.umeRed)
                }
            }
        }
    }
}

// プレビュー用
struct TimetableView_Previews: PreviewProvider {
    static var previews: some View {
        // NavigationStackでラップして、MainTabView内の挙動を再現
        NavigationStack {
            TimetableView()
        }
    }
}
