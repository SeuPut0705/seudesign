<h1 align="center">seudesign</h1>

<p align="center">
  <em>系统设计不是用来读的，是用来运行的。</em><br>
  面向 Claude Code 的系统设计技能 — 生成设计文档、架构诊断、模拟面试、容量估算。
</p>

<p align="center">
  <img src="https://img.shields.io/github/stars/SeuPut0705/seudesign?style=flat-square&color=111111&label=stars" alt="Stars">
  <img src="https://img.shields.io/badge/skill-Claude%20Code-111111?style=flat-square" alt="Claude Code skill">
  <img src="https://img.shields.io/badge/cases-5-111111?style=flat-square" alt="5 case studies">
  <img src="https://img.shields.io/badge/works%20with-Claude%20Code%20%C2%B7%20Codex%20%C2%B7%20Copilot%20%C2%B7%20AGENTS.md-111111?style=flat-square" alt="Multi-agent">
  <img src="https://img.shields.io/github/actions/workflow/status/SeuPut0705/seudesign/ci.yml?style=flat-square&color=111111&label=ci" alt="CI">
  <img src="https://img.shields.io/badge/license-MIT-111111?style=flat-square" alt="MIT license">
</p>

<p align="center">
  <sub><a href="README.md">English</a> &middot; <a href="README.ko.md">한국어</a> &middot; <a href="README.ja.md">日本語</a> &middot; 中文</sub>
</p>

---

这不是一份参考文档，而是一个**能运行的技能**。四种模式让你的智能体替你设计、
诊断、当面试官。参考文件用韩语编写，但回答始终使用**你的对话语言** —
中文可直接使用。

## 模式

| 命令 | 功能 |
|---|---|
| `/sdp design 聊天服务` | 需求访谈 → 估算 → 带图的完整设计文档 |
| `/sdp review` | 代码库架构诊断 — 单点故障、缺失超时、幂等性漏洞，按 file:line 报告 |
| `/sdp interview` | 模拟系统设计面试 — 三级提示、评分表打分 |
| `/sdp estimate 图片服务` | 交互式容量估算 — RPS/存储量 + 数字对设计的含义 |

## 安装

### Claude Code

```
/plugin marketplace add SeuPut0705/seudesign
```
```
/plugin install sdp@seudesign
```

(两条命令需分别发送)

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

### OpenCode / Cursor / AGENTS.md 类智能体

克隆仓库并打开即可 — [AGENTS.md](AGENTS.md) 会被自动加载。
全局安装请用下面的脚本。

### 其他(通用)

```bash
curl -fsSL https://raw.githubusercontent.com/SeuPut0705/seudesign/main/install.sh | sh
```

适用于任何读取技能目录的智能体。用 `DEST=路径` 更改安装目标。

## 内容

```
skills/sdp/
  SKILL.md                    # 4 种模式工作流 + 决策框架 + 原则
  references/
    architecture.md           # 负载均衡、代理、CDN、网关、单体 vs 微服务
    data.md                   # 数据库扩展阶梯、分片、一致性哈希、缓存策略
    async.md                  # 队列、投递保证、幂等性、背压、outbox
    reliability.md            # 可用性计算、熔断器、限流、可观测性
    patterns.md               # saga、事件溯源、CQRS、分布式锁、fan-out
    estimation.md             # 延迟参考值、流量/存储估算流程
    interview.md              # 面试手册、评分表、6 个高频错误
    checklists.md             # 架构诊断 + 生产就绪检查表
    cases/                    # 5 个完整设计案例
      url-shortener.md        #   ID 生成、缓存、301 vs 302
      rate-limiter.md         #   令牌桶、fail-open、Redis Lua
      chat-system.md          #   WebSocket 状态、消息顺序、在线状态
      news-feed.md            #   混合 fan-out、名人问题
      file-storage.md         #   分块、去重、增量同步、冲突处理
```

## 设计哲学

- **禁止过早扩展** — 基础设施模式只在瓶颈被证明后引入。
- **每个选择都是一对权衡** — 得到什么，放弃什么。
- **没有数字就没有设计** — 哪怕是粗略估算，也要从数字开始。
