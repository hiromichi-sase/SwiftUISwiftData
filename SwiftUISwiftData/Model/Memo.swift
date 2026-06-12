//
//  Memo.swift
//  SwiftUISwiftData
//
//  Created by Hiromichi Sase on 2026/05/04.
//

import Foundation
import SwiftData

/// メモのモデル
@Model
final class Memo: Identifiable, Hashable {
    /// UUIDを使用して一意の識別子を生成
    @Attribute(.unique)
    var id: UUID = UUID()
    /// タイトル
    var title: String
    /// 内容
    var content: String
    /// 作成日時
    var createdAt: Date
    /// 更新日時
    var updatedAt: Date
    /// 順番
    var order: Int

    /// イニシャライザ
    /// - Parameters:
    ///   - title: タイトル
    ///   - content: 内容
    ///   - createdAt: 作成日時（デフォルトは現在日時）
    ///   - updatedAt: 更新日時（デフォルトは現在日時）
    ///   - order: 順番（デフォルトはゼロ）
    init(title: String, content: String, createdAt: Date = Date(), updatedAt: Date = Date(), order: Int = .zero) {
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.order = order
    }

    /// Equatableプロトコルの実装
    /// - Parameters:
    ///   - lhs: Memo(左側)
    ///   - rhs: Memo(右側)
    /// - Returns: 両方のMemoのidが等しい場合にtrueを返す
    static func == (lhs: Memo, rhs: Memo) -> Bool {
        lhs.id == rhs.id
    }

    /// Hashableプロトコルの実装
    /// - Parameter hasher: Hasherオブジェクトにidを組み込む
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
