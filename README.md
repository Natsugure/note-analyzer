#  Advanced Dashboard for note
Advanced Dashboard for noteは、noteというブログサイトから各記事のアクセス状況を取得し、データをユーザーが見やすい形にして提供する非公式のサービスです。

## 機能
- noteのAPIを使用して記事のアクセスデータを取得
- グラフやリストを用いたデータの視覚化
- 期間別のアクセス分析（近日実装予定）

## 対応プラットフォーム
- iOS17.0以上を搭載したiPhone

## インストール

1. XcodeでこのリポジトリをCloneします。
```
https://github.com/Natsugure/note-analyzer.git
```

2. Swift Package Manaerを使用して、以下の依存関係をインストールします。
- [RealmSwift](https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/install/)

3. PROJECT > Signing & Capabilities から、ご自身のBundle IdentifierとTeamを設定します。

4. シミュレータまたは実機でビルドします。

## ユーザーガイド
アプリの詳細な使い方については[こちら](USAGE.md)をご覧ください。

## 技術スタック
- Swift
- SwiftUI
- RealmSwift（ローカルデータ保存用）
- Charts（データ可視化）

## 連絡先
質問や提案がある場合、またバグや指摘事項を発見した場合は、GitHubのIssuesまたは[こちらのGoogleフォーム](https://forms.gle/Tceg32xcH8avj8qy5)からご連絡ください。

## ライセンス
"note-analyzer" is under [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

## 免責事項
このアプリケーションは非公式のファンメイドサービスであり、noteとは直接の関係は一切ありません。
