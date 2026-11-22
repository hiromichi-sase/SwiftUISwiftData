//
//  TagsViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftData
import SwiftUI
import Testing

@testable import SwiftUISwiftData

@MainActor
struct TagsViewModelTests {
    // MARK: - Delete / Move

    @Test
    func confirmDelete_inInactiveMode_deletesTagToDelete() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag1 = Tag(title: "A", color: "#111111", order: 1)
        let tag2 = Tag(title: "B", color: "#222222", order: 2)
        let tag3 = Tag(title: "C", color: "#333333", order: 3)

        try dependency.tagRepository.add(tag1)
        try dependency.tagRepository.add(tag2)
        try dependency.tagRepository.add(tag3)

        dependency.testTarget.onTapDone()
        dependency.testTarget.selectedTag = tag2
        dependency.testTarget.tagToDelete = tag2
        dependency.testTarget.confirmDelete()

        let tags = try dependency.tagRepository.tags()
        #expect(tags.count == 2)
        #expect(tags[0].title == "A")
        #expect(tags[0].order == 1)
        #expect(tags[1].title == "C")
        #expect(tags[1].order == 2)

        #expect(dependency.testTarget.selectedTag == nil)
        #expect(dependency.testTarget.tagToDelete == nil)
        #expect(dependency.testTarget.selection.isEmpty)
        #expect(dependency.testTarget.toastMessage == "Successfully deleted!")
    }

    @Test
    func confirmDelete_inEditMode_deletesSelectedTags() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag1 = Tag(title: "A", color: "#111111", order: 1)
        let tag2 = Tag(title: "B", color: "#222222", order: 2)
        let tag3 = Tag(title: "C", color: "#333333", order: 3)

        try dependency.tagRepository.add(tag1)
        try dependency.tagRepository.add(tag2)
        try dependency.tagRepository.add(tag3)

        dependency.testTarget.onTapEdit()
        dependency.testTarget.selection = [tag2.id]
        dependency.testTarget.confirmDelete()

        let tags = try dependency.tagRepository.tags()
        #expect(tags.count == 2)
        #expect(tags[0].title == "A")
        #expect(tags[1].title == "C")
        #expect(tags[0].order == 1)
        #expect(tags[1].order == 2)
        #expect(dependency.testTarget.selection.isEmpty)
    }

    @Test
    func confirmDelete_withNoTargets_doesNothing() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag1 = Tag(title: "A", color: "#111111", order: 1)
        try dependency.tagRepository.add(tag1)

        dependency.testTarget.onTapDone()
        dependency.testTarget.tagToDelete = nil
        dependency.testTarget.confirmDelete()

        let tags = try dependency.tagRepository.tags()
        #expect(tags.count == 1)
        #expect(tags[0].title == "A")
    }

    @Test
    func moveTag_reordersTags() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag1 = Tag(title: "A", color: "#111111", order: 1)
        let tag2 = Tag(title: "B", color: "#222222", order: 2)
        let tag3 = Tag(title: "C", color: "#333333", order: 3)

        try dependency.tagRepository.add(tag1)
        try dependency.tagRepository.add(tag2)
        try dependency.tagRepository.add(tag3)

        dependency.testTarget.moveTag(from: IndexSet(integer: 2), to: 1)

        let tags = try dependency.tagRepository.tags()
        #expect(tags.map(\.title) == ["A", "C", "B"])
        #expect(tags.map(\.order) == [1, 2, 3])
    }

    // MARK: - Intents / State

    @Test
    func onTapEdit_clearsSelectedTag_andActivatesEditMode() {
        let dependency = try! Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.testTarget.selectedTag = Tag(title: "X", color: "#000000", order: 1)
        dependency.testTarget.onTapEdit()

        #expect(dependency.testTarget.selectedTag == nil)
        #expect(dependency.testTarget.editMode == .active)
    }

    @Test
    func onTapDone_clearsSelection_andInactivatesEditMode() {
        let dependency = try! Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.testTarget.editMode = .active
        dependency.testTarget.selection = [UUID(), UUID()]
        dependency.testTarget.onTapDone()

        #expect(dependency.testTarget.editMode == .inactive)
        #expect(dependency.testTarget.selection.isEmpty)
    }

    @Test
    func onTapAdd_setsShowingAddTagTrue() {
        let dependency = try! Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.testTarget.showingAddTag = false
        dependency.testTarget.onTapAdd()

        #expect(dependency.testTarget.showingAddTag == true)
    }

    @Test
    func onTapDelete_setsTargetAndAlert() {
        let dependency = try! Dependency()
        defer { dependency.removeUserDefaults() }

        let tag = Tag(title: "X", color: "#000000", order: 1)
        dependency.testTarget.onTapDelete(tag: tag)

        #expect(dependency.testTarget.tagToDelete?.id == tag.id)
        #expect(dependency.testTarget.currentAlert == .delete)
    }

    @Test
    func onTapRowInEditMode_togglesSelection() {
        let dependency = try! Dependency()
        defer { dependency.removeUserDefaults() }

        let tag = Tag(title: "X", color: "#000000", order: 1)

        dependency.testTarget.onTapRowInEditMode(tag)
        #expect(dependency.testTarget.selection.contains(tag.id))

        dependency.testTarget.onTapRowInEditMode(tag)
        #expect(!dependency.testTarget.selection.contains(tag.id))
    }

    @Test
    func onTapRowInNormalMode_and_onTapPreview_setSelectedTag() {
        let dependency = try! Dependency()
        defer { dependency.removeUserDefaults() }

        let tag = Tag(title: "X", color: "#000000", order: 1)

        dependency.testTarget.onTapRowInNormalMode(tag)
        #expect(dependency.testTarget.selectedTag?.id == tag.id)

        dependency.testTarget.selectedTag = nil
        dependency.testTarget.onTapPreview(tag)
        #expect(dependency.testTarget.selectedTag?.id == tag.id)
    }

    @Test
    func onTapSelectAll_and_onTapDeselectAll_work() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag1 = Tag(title: "A", color: "#111111", order: 1)
        let tag2 = Tag(title: "B", color: "#222222", order: 2)
        try dependency.tagRepository.add(tag1)
        try dependency.tagRepository.add(tag2)

        // fetch更新を待たず、直接再読込トリガとして change を通す
        let old = dependency.testTarget.tags
        let new = try dependency.tagRepository.tags()
        dependency.testTarget.onTagsChanged(oldTags: old, newTags: new)

        dependency.testTarget.onTapSelectAll()
        #expect(dependency.testTarget.selection == Set([tag1.id, tag2.id]))

        dependency.testTarget.onTapDeselectAll()
        #expect(dependency.testTarget.selection.isEmpty)
    }

    @Test
    func onCloseAllPresentedViews_resetsTransientStates() {
        let dependency = try! Dependency()
        defer { dependency.removeUserDefaults() }

        let tag = Tag(title: "X", color: "#000000", order: 1)
        dependency.testTarget.showingAddTag = true
        dependency.testTarget.selectedTag = tag
        dependency.testTarget.selection = [tag.id]
        dependency.testTarget.editMode = .active
        dependency.testTarget.tagToDelete = tag
        dependency.testTarget.currentAlert = .delete

        dependency.testTarget.onCloseAllPresentedViews()

        #expect(dependency.testTarget.showingAddTag == false)
        #expect(dependency.testTarget.selectedTag == nil)
        #expect(dependency.testTarget.selection.isEmpty)
        #expect(dependency.testTarget.editMode == .inactive)
        #expect(dependency.testTarget.tagToDelete == nil)
        #expect(dependency.testTarget.currentAlert == nil)
    }

    // MARK: - Derived values

    @Test
    func navigationTitle_inInactiveMode() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag1 = Tag(title: "A", color: "#111111", order: 1)
        let tag2 = Tag(title: "B", color: "#222222", order: 2)
        try dependency.tagRepository.add(tag1)
        try dependency.tagRepository.add(tag2)

        dependency.testTarget.onTapDone()
        dependency.testTarget.onTagsChanged(oldTags: dependency.testTarget.tags, newTags: try dependency.tagRepository.tags())

        #expect(dependency.testTarget.navigationTitle.contains("Tags ("))
    }

    @Test
    func canDeleteInEditMode_and_canSelectAll() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag1 = Tag(title: "A", color: "#111111", order: 1)
        let tag2 = Tag(title: "B", color: "#222222", order: 2)
        try dependency.tagRepository.add(tag1)
        try dependency.tagRepository.add(tag2)

        dependency.testTarget.onTapEdit()
        dependency.testTarget.onTagsChanged(oldTags: dependency.testTarget.tags, newTags: try dependency.tagRepository.tags())

        #expect(dependency.testTarget.canDeleteInEditMode == false)
        #expect(dependency.testTarget.canSelectAll == true)

        dependency.testTarget.onTapSelectAll()
        #expect(dependency.testTarget.canDeleteInEditMode == true)
        #expect(dependency.testTarget.canSelectAll == false)
    }

    // MARK: - Tags change / scroll target

    @Test
    func onTagsChanged_inActive_withEmptyNewTags_turnsInactiveAndClearsSelection() {
        let dependency = try! Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.testTarget.editMode = .active
        dependency.testTarget.selection = [UUID()]
        dependency.testTarget.onTagsChanged(oldTags: [Tag(title: "A", color: "#111111", order: 1)], newTags: [])

        #expect(dependency.testTarget.editMode == .inactive)
        #expect(dependency.testTarget.selection.isEmpty)
    }

    @Test
    func onTagsChanged_inInactive_withAddedTag_selectsAndSetsScrollTarget() {
        let dependency = try! Dependency()
        defer { dependency.removeUserDefaults() }

        let old = [Tag(title: "A", color: "#111111", order: 1)]
        let added = Tag(title: "B", color: "#222222", order: 2)

        dependency.testTarget.editMode = .inactive
        dependency.testTarget.onTagsChanged(oldTags: old, newTags: old + [added])

        #expect(dependency.testTarget.selectedTag?.id == added.id)
        #expect(dependency.testTarget.consumeScrollTargetID() == added.id)
        #expect(dependency.testTarget.consumeScrollTargetID() == nil)
    }

    // MARK: - UserDefaults getters

    @Test
    func getTitleLineLimit() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleLineLimit(3)
        #expect(dependency.testTarget.getTitleLineLimit() == 3)
    }

    @Test
    func getTitleFontSize() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleFontSize(16.0)
        #expect(dependency.testTarget.getTitleFontSize() == 16.0)
    }

    @Test
    func getTitleLineSpacing() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setTitleLineSpacing(0)
        #expect(dependency.testTarget.getTitleLineSpacing() == 0)
    }

    @Test
    func getShowInfo() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setShowInfo(false)
        #expect(dependency.testTarget.getShowInfo() == false)
    }

    @Test
    func makeEditTagViewModel_usesInjectedPreferences() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setDefaultTagColor("#FF0000")

        let editViewModel = dependency.testTarget.makeEditTagViewModel()

        // 新規作成用 ViewModel として初期化される。
        #expect(editViewModel.tag == nil)
        #expect(editViewModel.title == "")
        #expect(editViewModel.colorString == "#FF0000")
        #expect(!editViewModel.canSave)

        // 生成後の設定変更も参照できる。
        editViewModel.title = "Test Tag"
        editViewModel.saveTag()

        dependency.userDefaultsRepository.setShowInfo(true)
        #expect(editViewModel.showInfo)
    }

    @Test
    func makeEditTagViewModel_savesToInjectedRepository() throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let editViewModel = dependency.testTarget.makeEditTagViewModel()
        editViewModel.title = "New Tag"
        editViewModel.colorString = "#00FF00"

        #expect(editViewModel.canSave)

        editViewModel.saveTag()

        let tags = try dependency.tagRepository.tags()
        let savedTag = try #require(tags.first)

        #expect(tags.count == 1)
        #expect(savedTag.title == "New Tag")
        #expect(savedTag.color == "#00FF00")
        #expect(editViewModel.tag?.id == savedTag.id)
        #expect(editViewModel.currentAlert == nil)
        #expect(editViewModel.toastMessage == "Successfully saved!")
        #expect(!editViewModel.canSave)
    }
}

extension TagsViewModelTests {
    struct Dependency {
        private let container: ModelContainer
        let testTarget: TagsViewModel
        let tagRepository: TagRepository
        let userDefaultsRepository: UserDefaultsRepository
        private let support: TestDependencySupport

        @MainActor
        init() throws {
            let support = TestDependencySupport()
            self.support = support
            self.userDefaultsRepository = support.userDefaultsRepository

            self.container = try ModelContainer(
                for: Memo.self,
                Tag.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            self.tagRepository = TagRepository(modelContext: container.mainContext)
            self.testTarget = TagsViewModel(
                tagRepository: tagRepository,
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            support.removeUserDefaults()
        }
    }
}
