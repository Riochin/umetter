import SwiftUI

struct TabButtonView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 13))
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? .umeRed : .textGray)
                
                Rectangle()
                    .fill(isSelected ? Color.umeRed : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
