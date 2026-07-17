//
//  MemoSchemaV3.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/07/16.
//

import Foundation
import SwiftData

struct MemoSchemaV3: VersionedSchema {
    static var versionIdentifier = Schema.Version(3, 0, 0)
    static var models: [any PersistentModel.Type] {
        [
            Memo.self,
            Tag.self,
        ]
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
        /// タグ。
        @Relationship(deleteRule: .nullify, inverse: \Tag.memos)
        var tags: [Tag] = []

        /// イニシャライザ。
        /// - Parameters:
        ///   - title: タイトル
        ///   - content: 内容
        ///   - createdAt: 作成日時（デフォルトは現在日時）
        ///   - updatedAt: 更新日時（デフォルトは現在日時）
        ///   - order: 順番（デフォルトはゼロ）
        ///   - protected: 保護（デフォルトはfalse）
        ///   - tags: タグ
        init(
            title: String,
            content: String,
            createdAt: Date = Date(),
            updatedAt: Date = Date(),
            order: Int = .zero,
            protected: Bool = false,
            tags: [Tag] = []
        ) {
            self.title = title
            self.content = content
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.order = order
            self.protected = protected
            self.tags = tags
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

    @Model
    final class Tag: Identifiable, Hashable {
        /// UUIDを使用して一意の識別子を生成。
        @Attribute(.unique)
        var id: UUID = UUID()
        /// タイトル。
        var title: String
        /// 色。
        var color: String
        /// 作成日時。
        var createdAt: Date
        /// 更新日時。
        var updatedAt: Date
        /// 順番。
        var order: Int
        /// メモ。
        @Relationship(deleteRule: .nullify)
        var memos: [Memo] = []

        /// イニシャライザ。
        /// - Parameters:
        ///   - title: タイトル
        ///   - color: 色
        ///   - createdAt: 作成日時（デフォルトは現在日時）
        ///   - updatedAt: 更新日時（デフォルトは現在日時）
        ///   - order: 順番（デフォルトはゼロ）
        ///   - memos: メモ
        init(
            title: String,
            color: String,
            createdAt: Date = Date(),
            updatedAt: Date = Date(),
            order: Int = .zero,
            memos: [Memo] = []
        ) {
            self.title = title
            self.color = color
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.order = order
            self.memos = memos
        }

        /// Equatableプロトコルの実装。
        /// - Parameters:
        ///   - lhs: Tag(左側)
        ///   - rhs: Tag(右側)
        /// - Returns: 両方のTagのidが等しい場合にtrueを返す。
        static func == (lhs: Tag, rhs: Tag) -> Bool {
            lhs.id == rhs.id
        }

        /// Hashableプロトコルの実装。
        /// - Parameter hasher: Hasherオブジェクトにidを組み込む。
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
