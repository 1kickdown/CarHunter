//
//  CarHunterWidgetLiveActivity.swift
//  CarHunterWidget
//
//  Created by kickdown on 19.02.2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct CarHunterWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct CarHunterWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CarHunterWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension CarHunterWidgetAttributes {
    fileprivate static var preview: CarHunterWidgetAttributes {
        CarHunterWidgetAttributes(name: "World")
    }
}

extension CarHunterWidgetAttributes.ContentState {
    fileprivate static var smiley: CarHunterWidgetAttributes.ContentState {
        CarHunterWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: CarHunterWidgetAttributes.ContentState {
         CarHunterWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: CarHunterWidgetAttributes.preview) {
   CarHunterWidgetLiveActivity()
} contentStates: {
    CarHunterWidgetAttributes.ContentState.smiley
    CarHunterWidgetAttributes.ContentState.starEyes
}
