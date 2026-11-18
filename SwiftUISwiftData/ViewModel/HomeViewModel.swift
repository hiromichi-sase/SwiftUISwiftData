//
//  HomeViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/11/15.
//

import Foundation

@Observable
@MainActor
final class HomeViewModel {
    // MARK: - Nested Types

    enum Section: String, CaseIterable, Identifiable, Hashable {
        case memos
        case tags
        case settings

        var id: String { rawValue }

        var title: String {
            switch self {
                case .memos: return "Memos"
                case .tags: return "Tags"
                case .settings: return "Settings"
            }
        }

        var icon: String {
            switch self {
                case .memos: return "long.text.page.and.pencil"
                case .tags: return "tag"
                case .settings: return "gearshape"
            }
        }
    }

    struct MenuItem: Identifiable, Hashable {
        let section: Section
        var id: Section { section }
        var title: String { section.title }
        var icon: String { section.icon }
    }

    // MARK: - State

    var selectedSection: Section?
    let appName: String
    let menuItems: [MenuItem]

    // MARK: - Init

    init(
        selectedSection: Section? = nil,
        appNameProvider: () -> String = {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
        }
    ) {
        self.selectedSection = selectedSection
        self.appName = appNameProvider()
        self.menuItems = Section.allCases.map { MenuItem(section: $0) }
    }

    // MARK: - Intent

    func select(_ section: Section?) {
        selectedSection = section
    }
}
