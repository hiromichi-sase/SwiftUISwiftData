//
//  MemoSchemaV2.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/06/22.
//

import Foundation
import SwiftData

struct MemoSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [Memo.self]
    }

    /// メモのモデル。
    @Model
    final class Memo: Identifiable, Hashable {
        /// UUIDを使用して一意の識別子を生成。
        @Attribute(.unique)
        var id: UUID = UUID()
        /// タイトル。
        var title: String
        /// 内容。
        var content: String
        /// 作成日時。
        var createdAt: Date
        /// 更新日時。
        var updatedAt: Date
        /// 順番。
        var order: Int
        /// 保護。
        var protected: Bool = false

        /// イニシャライザ。
        /// - Parameters:
        ///   - title: タイトル
        ///   - content: 内容
        ///   - createdAt: 作成日時（デフォルトは現在日時）
        ///   - updatedAt: 更新日時（デフォルトは現在日時）
        ///   - order: 順番（デフォルトはゼロ）
        ///   - protected: 保護（デフォルトはfalse）
        init(
            title: String,
            content: String,
            createdAt: Date = Date(),
            updatedAt: Date = Date(),
            order: Int = .zero,
            protected: Bool = false
        ) {
            self.title = title
            self.content = content
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.order = order
            self.protected = protected
        }

        /// Equatableプロトコルの実装。
        /// - Parameters:
        ///   - lhs: Memo(左側)
        ///   - rhs: Memo(右側)
        /// - Returns: 両方のMemoのidが等しい場合にtrueを返す。
        static func == (lhs: Memo, rhs: Memo) -> Bool {
            lhs.id == rhs.id
        }

        /// Hashableプロトコルの実装。
        /// - Parameter hasher: Hasherオブジェクトにidを組み込む。
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
