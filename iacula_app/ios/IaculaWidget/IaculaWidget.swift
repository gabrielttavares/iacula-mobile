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
        StaticConfiguration(kind: kind, provider: IaculaWidgetProvider()) { entry in
            IaculaWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Iacula")
        .description("Frase do dia na tela inicial.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
