import SwiftUI
import WidgetKit

struct IaculaWidgetEntryView: View {
    var entry: QuoteEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                widgetContent(image: entry.smallImage)
            case .systemMedium:
                widgetContent(image: entry.mediumImage)
            case .systemLarge:
                widgetContent(image: entry.largeImage)
            @unknown default:
                widgetContent(image: entry.mediumImage)
            }
        }
        .containerBackground(for: .widget) {
            Color(red: 0.071, green: 0.071, blue: 0.071) // #121212
        }
    }

    @ViewBuilder
    private func widgetContent(image: UIImage?) -> some View {
        if let uiImage = image {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(ContainerRelativeShape())
        } else {
            // Fallback when no image is available yet
            ZStack {
                Color(red: 0.110, green: 0.110, blue: 0.118) // #1C1C1E
                VStack(spacing: 8) {
                    Text("Iacula")
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundColor(.white)
                    Text("Abra o app para carregar a frase do dia.")
                        .font(.system(size: 11, weight: .regular, design: .serif))
                        .foregroundColor(Color.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .clipShape(ContainerRelativeShape())
        }
    }
}
