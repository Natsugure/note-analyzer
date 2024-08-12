#  noteAnalyzer
noteAnalyzerは、noteというブログサイトから各記事のアクセス状況を取得し、データをユーザーが見やすい形にして提供する非公式のサービスです。

## 機能

noteのAPIを使用して記事のアクセスデータを取得
データの視覚化（グラフ、チャートなど）
カスタマイズ可能なダッシュボード
期間別のアクセス分析
お気に入り記事のトラッキング

## 対応プラットフォーム
- iOS16.0以上を搭載したiPhone
※iPadではビルドできるように設定してありますが、現時点では最適化が不十分です。

## インストール

1. Xcodeで以下のこのリポジトリをクローンします。
Copygit clone https://github.com/Natsugure/note-analyzer.git

2. Swift Package Manaerを使用して、以下の依存関係をインストールします。
- [RealmSwift](https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/install/)

3. PROJECT > Signing & Capabilities から、ご自身のBundle IdentifierとTeamを設定します。

4. シミュレータまたは実機でビルドします。

## 使用方法

アプリを起動し、設定タブのログインボタンを押します。noteのログイン画面が出たら、noteのアカウント情報でログインします。
ダッシュボードタブへ移り、画面右上の「↺」ボタンをタップしてダッシュボードを取得します。
※現在はまだ更新中の待機画面やオンボーディング画面が未実装です。近日中に追加予定です。

## 技術スタック

Swift
SwiftUI
RealmSwift（ローカルデータ保存用）
Charts（データ可視化）

## 連絡先
質問や提案がある場合、またバグや指摘事項を発見した場合は、GitHubのIssuesまたはnoteのコメントでお知らせください。

## ライセンス
"note-analyzer" is under [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

## 免責事項
このアプリケーションは非公式のファンメイドサービスであり、noteとは直接の関係は一切ありません。
