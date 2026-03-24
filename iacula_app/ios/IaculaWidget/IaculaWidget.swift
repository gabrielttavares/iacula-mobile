import SwiftUI
import WidgetKit

@main
struct IaculaWidgetBundle: WidgetBundle {
    var body: some Widget {
        IaculaWidget()
    }
}

struct IaculaWidget: Widget {
    let kind: String = "IaculaWidget"

    var body: some WidgetConfiguration {
        let config = StaticConfiguration(kind: kind, provider: IaculaWidgetProvider()) { entry in
            IaculaWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Iacula")
        .description("Jaculatórias periódicas na tela inicial.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])

        if #available(iOSApplicationExtension 17.0, *) {
            return config.contentMarginsDisabled()
        } else {
            return config
        }
    }
}
