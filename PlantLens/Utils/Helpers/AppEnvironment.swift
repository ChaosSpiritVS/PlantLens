//
//  AppEnvironment.swift
//  PlantLens
//
//  Created by 李杰 on 2025/7/4.
//

import Foundation

enum AppEnvironment {
    static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
}
