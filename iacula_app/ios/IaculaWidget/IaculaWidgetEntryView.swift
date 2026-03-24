import SwiftUI
import WidgetKit

struct IaculaWidgetEntryView: View {
    var entry: QuoteEntry

    @Environment(\.widgetFamily) var family

    private var currentImage: UIImage? {
        switch family {
        case .systemSmall:  return entry.smallImage
        case .systemMedium: return entry.mediumImage
        case .systemLarge:  return entry.largeImage
        @unknown default:   return entry.mediumImage
        }
    }

    var body: some View {
        if #available(iOSApplicationExtension 17.0, *) {
            widgetContent(image: currentImage)
                .containerBackground(for: .widget) { Color.clear }
        } else {
            widgetContent(image: currentImage)
        }
    }

    @ViewBuilder
    private func widgetContent(image: UIImage?) -> some View {
        if let uiImage = image {
            GeometryReader { geo in
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
        } else {
            ZStack {
                Color(red: 0.110, green: 0.110, blue: 0.118)
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
        }
    }
}
