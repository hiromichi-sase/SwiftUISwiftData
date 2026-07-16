//
//  TagListView.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/10.
//

import SwiftUI

struct TagListView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content
    let viewHeight: (CGFloat) -> Void

    var body: some View {
        GeometryReader { geometory in
            tagListView(in: geometory)
                .onGeometryChange(
                    for: CGFloat.self,
                    of: \.size.height
                ) { newValue in
                    viewHeight(newValue)
                }
        }
    }

    private func tagListView(in geometory: GeometryProxy) -> some View {
        let horizontalSpacing: CGFloat = 4.0
        let verticalSpacing: CGFloat = 4.0

        var width: CGFloat = .zero
        var height: CGFloat = .zero
        var lastHeight: CGFloat = .zero

        return ZStack(alignment: .topLeading) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                content(item)
                    .padding(.horizontal, horizontalSpacing)
                    .padding(.vertical, verticalSpacing)
                    .alignmentGuide(.leading) { dimensions in
                        if abs(width - dimensions.width) > geometory.size.width {
                            width = 0
                            height -= lastHeight
                        }

                        lastHeight = dimensions.height
                        let result = width

                        if index == items.count - 1 {
                            width = 0
                        }
                        else {
                            width -= dimensions.width
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height

                        if index == items.count - 1 {
                            height = 0
                        }
                        return result
                    }
            }
        }
    }
}
