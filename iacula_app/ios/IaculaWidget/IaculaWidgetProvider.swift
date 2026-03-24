import WidgetKit
import SwiftUI

struct QuoteEntry: TimelineEntry {
    let date: Date
    let smallImage: UIImage?
    let mediumImage: UIImage?
    let largeImage: UIImage?
}

struct IaculaWidgetProvider: TimelineProvider {
    private let appGroupId = "group.com.iacula.app"

    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: Date(), smallImage: nil, mediumImage: nil, largeImage: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> Void) {
        let entry = loadEntry()
        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadEntry() -> QuoteEntry {
        let userDefaults = UserDefaults(suiteName: appGroupId)

        let smallImage = loadImage(from: userDefaults, key: "widget_image_small")
        let mediumImage = loadImage(from: userDefaults, key: "widget_image_medium")
        let largeImage = loadImage(from: userDefaults, key: "widget_image_large")

        return QuoteEntry(
            date: Date(),
            smallImage: smallImage,
            mediumImage: mediumImage,
            largeImage: largeImage
        )
    }

    private func loadImage(from userDefaults: UserDefaults?, key: String) -> UIImage? {
        guard let path = userDefaults?.string(forKey: key) else { return nil }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        return UIImage(data: data)
    }
}
