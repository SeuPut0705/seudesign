<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/logo-dark.png">
    <img src="assets/logo.png" width="360" alt="seudesign">
  </picture>
</p>

<h1 align="center">seudesign</h1>

<p align="center">
  <em>システム設計は読むものではなく、実行するもの。</em><br>
  Claude Code 向けシステム設計スキル — 設計ドキュメント生成、アーキテクチャ診断、
  模擬面接、キャパシティ見積もり。
</p>

<p align="center">
  <img src="https://img.shields.io/github/stars/SeuPut0705/seudesign?style=flat-square&color=111111&label=stars" alt="Stars">
  <img src="https://img.shields.io/badge/skill-Claude%20Code-111111?style=flat-square" alt="Claude Code skill">
  <img src="https://img.shields.io/badge/cases-22-111111?style=flat-square" alt="22 case studies">
  <img src="https://img.shields.io/badge/works%20with-Claude%20Code%20%C2%B7%20Codex%20%C2%B7%20Copilot%20%C2%B7%20AGENTS.md-111111?style=flat-square" alt="Multi-agent">
  <img src="https://img.shields.io/github/actions/workflow/status/SeuPut0705/seudesign/ci.yml?style=flat-square&color=111111&label=ci" alt="CI">
  <img src="https://img.shields.io/badge/license-MIT-111111?style=flat-square" alt="MIT license">
</p>

<p align="center">
  <sub><a href="README.md">English</a> &middot; <a href="README.ko.md">한국어</a> &middot; 日本語 &middot; <a href="README.zh.md">中文</a></sub>
</p>

---

リファレンス文書ではなく、**動くスキル**です。4つのモードでエージェントが
設計し、診断し、面接官になります。回答は常に**会話の言語**で返されます —
日本語でそのまま使えます。

## モード

| コマンド | 動作 |
|---|---|
| `/sdp design チャットサービス` | 要件インタビュー → 見積もり → 図付き設計ドキュメント生成 |
| `/sdp review` | コードベースのアーキテクチャ診断 — SPOF、タイムアウト欠如、冪等性の穴を file:line で報告 |
| `/sdp interview` | 模擬システム設計面接 — 3段階ヒント、ルーブリック採点 |
| `/sdp estimate 画像サービス` | 対話型キャパシティ見積もり — RPS/ストレージ + 設計上の意味の解釈 |

## インストール

### Claude Code

```
/plugin marketplace add SeuPut0705/seudesign
```
```
/plugin install sdp@seudesign
```

(2つのコマンドは別々のプロンプトで送信してください)

### Codex

```bash
codex plugin marketplace add SeuPut0705/seudesign
codex plugin add sdp@seudesign
```

### GitHub Copilot CLI

```bash
copilot plugin marketplace add SeuPut0705/seudesign
copilot plugin install sdp@seudesign
```

### OpenCode / Cursor / AGENTS.md 系エージェント

リポジトリをクローンして開くと [AGENTS.md](AGENTS.md) が自動で読み込まれます。
グローバルインストールは下記スクリプトで。

### その他(汎用)

```bash
curl -fsSL https://raw.githubusercontent.com/SeuPut0705/seudesign/main/install.sh | sh
```

スキルディレクトリを読む任意のエージェントで動作。`DEST=パス` で対象変更可能。

## 収録内容

```
skills/sdp/
  SKILL.md                    # 4モードのワークフロー + 意思決定フレームワーク + 原則
  references/
    architecture.md           # LB、プロキシ、CDN、ゲートウェイ、モノリス vs マイクロサービス
    data.md                   # DB スケーリングの段階、シャーディング、consistent hashing、キャッシュ
    async.md                  # キュー、配信保証、冪等性、バックプレッシャー、outbox
    reliability.md            # 可用性の計算、サーキットブレーカー、レートリミット、可観測性
    streaming.md              # バッチ vs ストリーム、ウィンドウ、exactly-once 集計
    consensus.md              # クォーラム、Raft、線形化可能性、lease + fencing
    probabilistic.md          # Bloom filter、HyperLogLog、Count-Min sketch
    networking.md             # DNS、TCP/UDP、RPC vs REST、ポーリング/WebSocket/SSE
    patterns.md               # saga、イベントソーシング、CQRS、分散ロック、fan-out
    estimation.md             # レイテンシ目安、トラフィック/ストレージ見積もり手順
    interview.md              # 面接プレイブック、ルーブリック、頻出ミス6選
    checklists.md             # アーキテクチャ診断 + 本番準備チェックリスト
    cases/                    # 完成済み設計 5種
      url-shortener.md        #   ID 生成、キャッシュ、301 vs 302
      rate-limiter.md         #   token bucket、fail-open、Redis Lua
      chat-system.md          #   WebSocket の状態管理、メッセージ順序、プレゼンス
      news-feed.md            #   ハイブリッド fan-out、セレブリティ問題
      file-storage.md         #   チャンク分割、重複排除、差分同期、競合
      web-crawler.md          #   クロールフロンティア、politeness、Bloom filter
      search-autocomplete.md  #   上位K事前計算、時間減衰、デバウンス
      notification-system.md  #   チャネル別キュー、両端の冪等性、DLQ
      proximity-service.md    #   geohash/quadtree、セル境界、移動ドライバー
      video-streaming.md      #   セグメント並列トランスコード、adaptive bitrate
      payment-system.md       #   全区間の冪等性、複式簿記台帳
      kv-store.md             #   consistent hashing、クォーラム、hinted handoff
      collaborative-editing.md#   OT vs CRDT、操作ログ + スナップショット
      metrics-monitoring.md   #   カーディナリティ、pull vs push、ダウンサンプリング
      flash-sale.md           #   負荷遮断レイヤー、アトミック減算、hold TTL
      distributed-queue.md    #   ログ + オフセット、パーティション、acks/ISR
      unique-id-generator.md  #   Snowflake ビット設計、時計逆行処理
      search-engine.md        #   転置インデックス、2段階ランキング、セグメント
      ad-click-aggregation.md #   ストリーム+バッチ照合、課金級の重複排除
      stock-exchange.md       #   シングルスレッドマッチング、シーケンス後リプレイ
      email-service.md        #   受理即所有、メタ/ブロブ/索引分離
      maps-service.md         #   タイルピラミッド、経路階層事前計算、ライブ交通
    templates/
      design-doc.md           #   design モード出力スケルトン
agents/
  sdp-reviewer.md             # 同梱の読み取り専用アーキテクチャ診断サブエージェント
```

## サンプル

完全なサンプル出力は [examples/](examples/) に — 設計ドキュメントとアーキテクチャ診断。

## 設計哲学

- **早すぎるスケーリング禁止** — インフラパターンはボトルネックが証明されてから。
- **すべての選択はトレードオフのペア** — 何を得て、何を諦めるか。
- **数字なしに設計なし** — 概算でも数字から始める。
