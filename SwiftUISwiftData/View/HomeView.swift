//
//  HomeView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/05.
//

import SwiftUI

struct HomeView: View {
    @Binding
    var section: Section?
    private let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""

    enum Section: CaseIterable, Identifiable {
        case memosView
        case tagsView
        case settingsView
        var id: Section { self }

        var title: String {
            switch self {
                case .memosView:
                    return "Memos"
                case .tagsView:
                    return "Tags"
                case .settingsView:
                    return "Settings"
            }
        }

        var icon: String {
            switch self {
                case .memosView:
                    "long.text.page.and.pencil"
                case .tagsView:
                    "tag"
                case .settingsView:
                    "gearshape"
            }
        }
    }

    init(section: Binding<Section?>) {
        _section = section
    }

    var body: some View {
        VStack {
            List(Section.allCases, selection: $section) { section in
                HStack {
                    Image(systemName: section.icon)
                        .frame(maxWidth: 24.0)
                    Text(section.title)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            }
            .navigationTitle(appName)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    HomeView(section: .constant(.memosView))
}
