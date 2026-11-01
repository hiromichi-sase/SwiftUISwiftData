//
//  PreviewMemoViewModel.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/07.
//

internal import Combine
import SwiftData

@Observable
@MainActor
final class PreviewMemoViewModel {
    private let memo: Memo
    private let userDefaultsRepository: UserDefaultsRepository

    init(
        memo: Memo,
        userDefaultsRepository: UserDefaultsRepository,
    ) {
        self.memo = memo
        self.userDefaultsRepository = userDefaultsRepository
    }

    var isContentEmpty: Bool {
        memo.content.isEmpty
    }

    var displayContent: String {
        isContentEmpty ? CommonString.noContent : memo.content
    }

    var contentFontSize: Float {
        userDefaultsRepository.getContentFontSize()
    }

    var contentLineSpacing: Float {
        userDefaultsRepository.getContentLineSpacing()
    }
}
