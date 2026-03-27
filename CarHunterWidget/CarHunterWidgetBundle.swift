//
//  CarHunterWidgetBundle.swift
//  CarHunterWidget
//
//  Created by kickdown on 19.02.2026.
//

import WidgetKit
import SwiftUI

@main
struct CarHunterWidgetBundle: WidgetBundle {
    var body: some Widget {
        CarHunterWidget()
        CarHunterWidgetControl()
        CarHunterWidgetLiveActivity()
    }
}
