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

        private var item: (title: String, icon: String) {
            switch self {
                case .memosView:
                    ("Memos", "long.text.page.and.pencil")
                case .tagsView:
                    ("Tags", "tag")
                case .settingsView:
                    ("Settings", "gearshape")
            }
        }

        var title: String {
            item.title
        }

        var icon: String {
            item.icon
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
