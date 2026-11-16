//
//  EditTagViewModelTests.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import SwiftData
import Testing

@testable import SwiftUISwiftData

struct EditTagViewModelTests {
    @MainActor
    @Test
    func initialState_newTag_usesDefaultColor() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let vm = dependency.makeTestTarget(tag: nil)

        #expect(vm.title == "")
        #expect(vm.colorString == dependency.userDefaultsRepository.getDefaultTagColor())
        #expect(vm.isTagUpdated == false)
        #expect(vm.canSave == false)
    }

    @MainActor
    @Test
    func initialState_existingTag_reflectsTagValues() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag = Tag(title: "Work", color: "#111111")
        let vm = dependency.makeTestTarget(tag: tag)

        #expect(vm.title == "Work")
        #expect(vm.colorString == "#111111")
        #expect(vm.isTagUpdated == false)
        #expect(vm.canSave == false)
    }

    @MainActor
    @Test
    func closeWithoutChanges_dismissesImmediately() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let vm = dependency.makeTestTarget(tag: nil)
        vm.onTapClose()

        #expect(vm.shouldDismiss == true)
        #expect(vm.currentAlert == nil)
    }

    @MainActor
    @Test
    func closeWithChanges_showsCloseAlert() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let vm = dependency.makeTestTarget(tag: nil)
        vm.title = "Changed"

        vm.onTapClose()

        #expect(vm.shouldDismiss == false)
        #expect(vm.currentAlert == .close)
    }

    @MainActor
    @Test
    func save_newTag_success() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let vm = dependency.makeTestTarget(tag: nil)
        vm.title = "Added Title"
        vm.colorString = "#000000"

        vm.saveTag()

        let tags = try dependency.tagRepository.tags()
        #expect(tags.count == 1)
        let newTag = try #require(tags.first)

        #expect(newTag.title == "Added Title")
        #expect(newTag.color == "#000000")
        #expect(vm.toastMessage == "Successfully saved!")
        #expect(vm.currentAlert == nil)
    }

    @MainActor
    @Test
    func save_existingTag_success() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let tag = Tag(title: "Old", color: "#123123")
        try dependency.tagRepository.add(tag)

        let vm = dependency.makeTestTarget(tag: tag)
        vm.title = "Updated Title"
        vm.colorString = "#000000"

        vm.saveTag()

        let tags = try dependency.tagRepository.tags()
        #expect(tags.count == 1)
        let updated = try #require(tags.first)

        #expect(updated.title == "Updated Title")
        #expect(updated.color == "#000000")
        #expect(vm.toastMessage == "Successfully saved!")
        #expect(vm.currentAlert == nil)
    }

    @MainActor
    @Test
    func canSave_falseWhenTitleIsWhitespace() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let vm = dependency.makeTestTarget(tag: nil)
        vm.title = "   "
        vm.colorString = "#111111"

        #expect(vm.canSave == false)
    }

    @MainActor
    @Test
    func showInfo_trueOnlyWhenEnabledAndExistingTag() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        dependency.userDefaultsRepository.setShowInfo(true)

        let vmNew = dependency.makeTestTarget(tag: nil)
        #expect(vmNew.showInfo == false)

        let vmExisting = dependency.makeTestTarget(tag: Tag(title: "T", color: "#000000"))
        #expect(vmExisting.showInfo == true)
    }

    @MainActor
    @Test
    func save_success_resetsDirtyState() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let vm = dependency.makeTestTarget(tag: nil)
        vm.title = "Added Title"
        vm.colorString = "#000000"
        #expect(vm.canSave == true)

        vm.saveTag()

        #expect(vm.isTagUpdated == false)
        #expect(vm.canSave == false)
    }

    @MainActor
    @Test
    func navigationTitle_newTag_isAddTag() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let vm = dependency.makeTestTarget(tag: nil)

        #expect(vm.navigationTitle == "Add Tag")
    }

    @MainActor
    @Test
    func navigationTitle_existingTag_isTagTitle() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let vm = dependency.makeTestTarget(tag: Tag(title: "Work", color: "#000000"))

        #expect(vm.navigationTitle == "Work")
    }

    @MainActor
    @Test
    func onConfirmClose_setsShouldDismissTrue() async throws {
        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let vm = dependency.makeTestTarget(tag: nil)
        #expect(vm.shouldDismiss == false)

        vm.onConfirmClose()

        #expect(vm.shouldDismiss == true)
    }

    @MainActor
    @Test
    func save_failure_setsErrorAlert() async throws {
        struct DummyError: Error {}

        final class FailingTagRepository: TagRepositoryProtocol {
            func add(_ tag: Tag) throws { throw DummyError() }
            func update(_ tag: Tag, title: String, color: String) throws { throw DummyError() }
        }

        let dependency = try Dependency()
        defer { dependency.removeUserDefaults() }

        let vm = EditTagViewModel(
            tag: nil,
            tagRepository: FailingTagRepository(),
            userDefaultsRepository: dependency.userDefaultsRepository
        )

        vm.title = "Added Title"
        vm.colorString = "#000000"
        vm.saveTag()

        #expect(vm.currentAlert == .error)
        #expect(vm.errorMessage.isEmpty == false)
    }
}

extension EditTagViewModelTests {
    struct Dependency {
        private let container: ModelContainer
        let tagRepository: TagRepository
        let userDefaultsRepository: UserDefaultsRepository
        private let support: TestDependencySupport

        @MainActor
        init() throws {
            let support = TestDependencySupport()
            self.support = support
            userDefaultsRepository = support.userDefaultsRepository

            container = try ModelContainer(
                for: Memo.self,
                Tag.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )

            tagRepository = .init(modelContext: container.mainContext)
        }

        @MainActor
        func makeTestTarget(tag: Tag?) -> EditTagViewModel {
            .init(
                tag: tag,
                tagRepository: tagRepository,
                userDefaultsRepository: userDefaultsRepository
            )
        }

        func removeUserDefaults() {
            support.removeUserDefaults()
        }
    }
}
