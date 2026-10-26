//
//  PreviewMemoViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/08.
//

import Foundation
import Testing

@testable import SwiftUISwiftData

struct PreviewMemoViewModelTests {
    @MainActor
    @Test
    func getContentFontSize() {
        let contentFontSize = Float(16.0)
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setContentFontSize(contentFontSize)
        #expect(dependency.testTarget.getContentFontSize() == contentFontSize)
    }

    @MainActor
    @Test
    func getContentLineSpacing() {
        let contentLineSpacing = Float.zero
        let dependency = Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setContentLineSpacing(contentLineSpacing)
        #expect(dependency.testTarget.getContentLineSpacing() == contentLineSpacing)
    }
}

extension PreviewMemoViewModelTests {
    struct Dependency {
        let testTarget: PreviewMemoViewModel
        private let userDefaults: UserDefaults
        let userDefaultsRepository: UserDefaultsRepository
        private let suiteName = UUID().uuidString

        @MainActor
        init() {
            guard let userDefaults = UserDefaults(suiteName: suiteName) else {
                fatalError("Could not create UserDefaults")
            }
            self.userDefaults = userDefaults
            userDefaultsRepository = .init(userDefaults: userDefaults)
            testTarget = .init(
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            userDefaults.removePersistentDomain(forName: suiteName)
        }
    }
}
