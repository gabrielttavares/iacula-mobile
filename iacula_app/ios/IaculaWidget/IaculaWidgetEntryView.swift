import SwiftUI
import WidgetKit

struct QuoteEntry: TimelineEntry {
    let date: Date
    let smallImage: WidgetImage?
    let mediumImage: WidgetImage?
    let largeImage: WidgetImage?
}

struct IaculaWidgetEntryView: View {
    var entry: QuoteEntry

    @Environment(\.widgetFamily) var family

    private var currentImage: WidgetImage? {
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
    private func widgetContent(image: WidgetImage?) -> some View {
        if let uiImage = image {
            GeometryReader { geo in
                #if canImport(UIKit)
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                #elseif canImport(AppKit)
                Image(nsImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                #else
                Color.clear
                #endif
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
