//
//  BrowseTagViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftData

@Observable
@MainActor
final class BrowseTagViewModel {
    let tag: Tag
    private let userDefaultsRepository: UserDefaultsRepository
    private(set) var showingEditTag = false

    init(
        tag: Tag,
        userDefaultsRepository: UserDefaultsRepository
    ) {
        self.tag = tag
        self.userDefaultsRepository = userDefaultsRepository
    }

    var showInfo: Bool {
        userDefaultsRepository.getShowInfo()
    }

    func editButtonTapped() {
        showingEditTag = true
    }

    func dismissEdit() {
        showingEditTag = false
    }
}
