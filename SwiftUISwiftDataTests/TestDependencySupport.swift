//
//  TestDependencySupport.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/10/26.
//

import Foundation

@testable import SwiftUISwiftData

struct TestDependencySupport {
    let suiteName: String
    let userDefaults: UserDefaults
    let userDefaultsRepository: UserDefaultsRepository

    @MainActor
    init(fileID: String = #fileID) {
        suiteName = "\(fileID).\(UUID().uuidString)"

        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            fatalError("Could not create UserDefaults for suite: \(suiteName)")
        }

        self.userDefaults = userDefaults
        userDefaultsRepository = .init(userDefaults: userDefaults)
    }

    func removeUserDefaults() {
        userDefaults.removePersistentDomain(forName: suiteName)
    }
}
