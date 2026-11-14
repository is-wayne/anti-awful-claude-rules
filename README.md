<div align="center">

# wayne-anti · 白名单机制

**Claude / Anthropic / Persona(KYC) 安全分流规则 · Shadowrocket**

`FINAL,proxy` 默认走代理 · 未收录即走代理 · fail-safe

</div>

---

## ✨ 这是什么

一份面向 **Shadowrocket** 的分流配置。基于 [Johnshall/Shadowrocket-ADBlock-Rules-Forever](https://github.com/Johnshall/Shadowrocket-ADBlock-Rules-Forever) 的 `sr_cnip_ad.conf`（国内外划分 + 广告过滤），在其之上把 **Claude、Anthropic、Persona(KYC) 全域名钉死走代理**。

它采用的是**白名单机制**：兜底 `FINAL,proxy`，只用规则把「国内网站」挑出来**直连**，其余未收录 / 难判定的流量**默认走代理**。这样即使漏配了某个小众域名（例如 KYC 的 `withpersona.com`），也只会走代理，而不会裸奔直连、暴露真实 IP。

> **黑名单 vs 白名单**
> \- **黑名单**：默认直连，只把「被墙站」挑出来走代理 —— 漏一个域名就暴露真实 IP。
> \- **白名单**：默认代理，只把「国内站」挑出来直连 —— 未收录即走代理，安全。
>
> 账号 / 隐私敏感场景（Claude、KYC、支付），请务必用**白名单**。

---

## 📦 一键导入

| GitHub Pages（推荐） | Gitea（备用） |
|:---:|:---:|
| ![GitHub Pages 二维码](qr/wayne-anti-github.png) | ![Gitea 二维码](qr/wayne-anti-gitea.png) |
| <https://is-wayne.github.io/anti-awful-claude-rules/wayne-anti-whitelist.conf> | <https://git.iswayne.com/wayne/anti-awful-claude-rules/raw/branch/main/wayne-anti-whitelist.conf> |

**导入方式**

1. 用 Safari 或 Shadowrocket 扫描上方二维码；或
2. Shadowrocket →「配置」→ 右上角「+」→ 粘贴上面的 URL → 下载；
3. 导入后**断开并重连一次**，使规则生效。

> 图形化落地页（同样含二维码）：<https://is-wayne.github.io/anti-awful-claude-rules/>

---

## 🧩 规则划分

### ① 顶部 · 账号相关强制代理（优先级最高）

- **核心**：`anthropic.com`、`claude.ai`、`claude.com`、`clau.de`、`claudemcpclient.com`、`claudemcpcontent.com`、`claudeusercontent.com`
- **KYC 核验**：`withpersona.com`、`frompersona.com`、`maps.googleapis.com`
- **认证 / CDN / 监控**：`anthropic.auth0.com`、`sentry.io`、`statsig*`、`datadog`、`sift`、`intercom*`
- **IP 兜底**：`160.79.104.0/21`、`2607:6bc0::/32`（ASN 规则默认注释）

### ② 顶部 · 局域网直连

`127/8`、`10/8`、`172.16/12`、`192.168/16`、`169.254/16`、`::1`、`fc00::/7`、`fe80::/10`（均 `no-resolve`），内网流量不经过代理。

### ③ 主体 · 国内外划分 + 广告过滤（继承 sr_cnip_ad）

- 广告 / 追踪域名 → `REJECT`
- `GEOIP,CN`（中国大陆 IP）→ 直连
- 其余 → **`FINAL,proxy` 兜底走代理**

---

## 🛡️ 防泄漏设置（务必配合）

### DNS

走代理的域名，其 DNS 查询在**节点侧**解析；只要目标域名与 IP 都在规则里（本规则已覆盖 Claude / KYC），就不会漏。若担心漏网之鱼，本规则的**白名单兜底 `FINAL,proxy`** 会让未知流量默认走代理。

- 验证：[dnsleaktest.com](https://www.dnsleaktest.com/) —— 只显示节点 DNS、无本地运营商才算过。
- 教程：<https://youtu.be/gRpViKi23jQ?is=YXyQr71mzQsTHgiv>

### WebRTC（禁用 STUN）

- **Shadowrocket：`设置 → UDP → 禁用 STUN`（打开）**
- 桌面端：Firefox 在 `about:config` 关闭 `media.peerconnection.enabled`；Chrome 安装 *WebRTC Control* 扩展。
- 验证：[browserleaks.com/webrtc](https://browserleaks.com/webrtc) —— 只暴露节点 IP、无本地 IP 才算过。
- 教程：<https://youtu.be/ONd_rAYLji0?is=utzTbZvGeMZJp7pa>

### STUN / UDP 端口

STUN 走 UDP 端口 `3478 / 5349 / 19302`。Shadowrocket 用上面的「禁用 STUN」即可；若使用 sing-box / clash 内核，可把 STUN 协议与这些 UDP 端口路由到代理：

```json
{ "action": "sniff", "sniffer": ["tls","http","quic","stun","dns"], "timeout": "300ms" },
{ "protocol": "stun", "outbound": "🚀 默认代理" },
{ "port": [3478, 5349, 19302], "network": "udp", "outbound": "🚀 默认代理" }
```

---

## ✅ 应用后验证

| 检查项 | 期望结果 |
|:--|:--|
| `https://withpersona.com/cdn-cgi/trace` | 显示节点地区（如 `SG`），不是 `CN` |
| 手机 / 电脑 `https://www.cloudflare.com/cdn-cgi/trace` | 两端 `ip=` 完全一致 |
| [dnsleaktest.com](https://www.dnsleaktest.com/) | 只显示节点 DNS，无本地运营商 |
| [browserleaks.com/webrtc](https://browserleaks.com/webrtc) | 只暴露节点 IP，无本地 IP |

> 全部通过后，再进行登录 / KYC。

---

## 📁 文件结构

| 文件 | 说明 |
|:--|:--|
| `wayne-anti-whitelist.conf` | 完整 Shadowrocket 配置（白名单机制，约 5.37 万行） |
| `claude-kyc-proxy.snippet` | 仅 Claude / KYC 的置顶规则块，便于粘贴到现有配置 |
| `index.html` · `qr/` | GitHub Pages 落地页与二维码 |
| `push-both.sh` | 一键提交并同时推送到 GitHub + Gitea |

---

## 🔧 维护

```bash
./push-both.sh "提交说明"
```

---

## 📜 来源与许可

- 规则基底：[Johnshall/Shadowrocket-ADBlock-Rules-Forever](https://github.com/Johnshall/Shadowrocket-ADBlock-Rules-Forever)（`sr_cnip_ad.conf`）
- 域名清单：[ip.net.coffee](https://ip.net.coffee/claude/site.html)
- 出口 IP 选型 / KYC 风控方法论：[NexIP 博客](https://nexip.net/blog/289.html)、NodeSeek 讨论帖

本作品采用 **CC BY-SA 4.0** 许可（与原项目一致），详见 [LICENSE](LICENSE)。感谢原作者。

