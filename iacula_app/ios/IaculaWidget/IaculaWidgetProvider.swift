import WidgetKit
import SwiftUI

#if canImport(UIKit)
import UIKit
typealias WidgetImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias WidgetImage = NSImage
#else
typealias WidgetImage = Data
#endif

struct IaculaWidgetProvider: TimelineProvider {
    private let appGroupId = "group.com.iacula.app"
    private let defaultIntervalMinutes = 15
    private let timelineHours = 24

    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: Date(), smallImage: nil, mediumImage: nil, largeImage: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> Void) {
        let intervalMinutes = loadIntervalMinutes()
        let entries = buildTimelineEntries(intervalMinutes: intervalMinutes)
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    private func loadIntervalMinutes() -> Int {
        let userDefaults = UserDefaults(suiteName: appGroupId)
        let stored = userDefaults?.integer(forKey: "interval_minutes") ?? defaultIntervalMinutes
        return max(5, stored)
    }

    private func buildTimelineEntries(intervalMinutes: Int) -> [QuoteEntry] {
        let now = Date()
        let seedEntry = loadEntry()
        let end = Calendar.current.date(byAdding: .hour, value: timelineHours, to: now) ?? now

        var entries = [QuoteEntry(date: now, smallImage: seedEntry.smallImage, mediumImage: seedEntry.mediumImage, largeImage: seedEntry.largeImage)]
        var cursor = nextBoundary(after: now, intervalMinutes: intervalMinutes)

        while cursor <= end {
            entries.append(
                QuoteEntry(
                    date: cursor,
                    smallImage: seedEntry.smallImage,
                    mediumImage: seedEntry.mediumImage,
                    largeImage: seedEntry.largeImage
                )
            )
            guard let next = Calendar.current.date(byAdding: .minute, value: intervalMinutes, to: cursor) else {
                break
            }
            cursor = next
        }

        return entries
    }

    private func nextBoundary(after date: Date, intervalMinutes: Int) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        components.second = 0
        components.nanosecond = 0
        guard let rounded = calendar.date(from: components) else { return date }

        let minute = components.minute ?? 0
        let remainder = minute % intervalMinutes
        let delta = remainder == 0 ? intervalMinutes : (intervalMinutes - remainder)
        return calendar.date(byAdding: .minute, value: delta, to: rounded) ?? date
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

    private func loadImage(from userDefaults: UserDefaults?, key: String) -> WidgetImage? {
        guard let path = userDefaults?.string(forKey: key) else { return nil }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        #if canImport(UIKit)
        return WidgetImage(data: data)
        #elseif canImport(AppKit)
        return WidgetImage(data: data)
        #else
        return data
        #endif
    }
}
