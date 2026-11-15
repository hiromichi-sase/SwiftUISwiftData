//
//  HomeViewModelTests.swift
//  SwiftUISwiftDataTests
//
//  Created by Hiromichi Sase on 2026/11/15.
//

import Testing
@testable import SwiftUISwiftData

struct HomeViewModelTests {
    @MainActor
    @Test
    func initSetsInitialSelectedSectionAndAppName() {
        let sut = HomeViewModel(
            selectedSection: .tags,
            appNameProvider: { "TestApp" }
        )

        #expect(sut.selectedSection == .tags)
        #expect(sut.appName == "TestApp")
    }

    @MainActor
    @Test
    func initCreatesMenuItemsInSectionOrder() {
        let sut = HomeViewModel(
            selectedSection: nil,
            appNameProvider: { "TestApp" }
        )

        let sections = sut.menuItems.map { $0.section }
        #expect(sections == [.memos, .tags, .settings])
    }

    @MainActor
    @Test
    func menuItemsHaveExpectedDisplayValues() {
        let sut = HomeViewModel(
            selectedSection: nil,
            appNameProvider: { "TestApp" }
        )

        #expect(sut.menuItems[0].title == "Memos")
        #expect(sut.menuItems[0].icon == "long.text.page.and.pencil")

        #expect(sut.menuItems[1].title == "Tags")
        #expect(sut.menuItems[1].icon == "tag")

        #expect(sut.menuItems[2].title == "Settings")
        #expect(sut.menuItems[2].icon == "gearshape")
    }

    @MainActor
    @Test
    func selectUpdatesSelectedSection() {
        let sut = HomeViewModel(
            selectedSection: nil,
            appNameProvider: { "TestApp" }
        )

        sut.select(.settings)
        #expect(sut.selectedSection == .settings)
    }

    @MainActor
    @Test
    func selectNilClearsSelectedSection() {
        let sut = HomeViewModel(
            selectedSection: .memos,
            appNameProvider: { "TestApp" }
        )

        sut.select(nil)
        #expect(sut.selectedSection == nil)
    }
}
