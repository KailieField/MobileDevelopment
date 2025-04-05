//
//  Item.swift
//  lab08
//
//  Created by Kailie Field on 2025-03-21.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
