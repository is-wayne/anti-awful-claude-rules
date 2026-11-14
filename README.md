# anti awful Claude rules

基于 [Johnshall/Shadowrocket-ADBlock-Rules-Forever](https://github.com/Johnshall/Shadowrocket-ADBlock-Rules-Forever) 的 `sr_cnip_ad.conf`（国内外划分 + 广告过滤）优化，加入 **Claude / Anthropic / Persona(KYC) 全域名强制代理**，避免账号相关流量因规则漏配而直连、暴露真实 IP。

## 一键导入 / 扫码

- **GitHub Pages（推荐）**：<https://is-wayne.github.io/anti-awful-claude-rules/wayne-anti.conf>
- **Gitea（备用）**：<https://git.iswayne.com/wayne/anti-awful-claude-rules/raw/branch/main/wayne-anti.conf>
- **落地页（含二维码）**：<https://is-wayne.github.io/anti-awful-claude-rules/>

### 用法

1. 用 Safari 或 Shadowrocket 扫描落地页上的二维码；或
2. Shadowrocket →「配置」→ 右上角 **+** → 粘贴上面的 URL → 下载；
3. 导入后断开并重连一次，使规则生效。

> 建议把 DNS 设为 DoH（如 `https://1.1.1.1/dns-query`）或走代理，避免 DNS 泄露（`GEOIP,CN` 判定需要解析域名）。

## 为什么需要这个（真实翻车复盘）

- Mac 端用的是 GFWList 白名单式规则（`FINAL,DIRECT`），而 KYC 上传证件的域名 `withpersona.com` 未被收录 → **直连 → 暴露真实国内 IP**；
- 手机端用的是 `sr_cnip_ad`（`FINAL,proxy`）→ 同一域名走代理；
- 同一笔 KYC：电脑端国内 IP、手机端代理 IP，**双端 IP 不一致 → 秒封**。

**结论：规则要做「减法」——兜底 `FINAL,proxy`（默认走代理），再用规则把「国内网站」挑出来走直连；而不是只挑「国外网站」走代理、其余直连。**

- `FINAL,proxy`：未收录 / 难判定的流量默认**走代理**（fail-safe，安全）。
- `FINAL,DIRECT`：未收录的流量默认**直连**（fail-open，漏）。

对账号 / 隐私敏感场景（Claude、KYC、支付），必须选前者。

## 相对原规则的改动

1. 在 `[Rule]` **顶部置顶** Claude / Anthropic / Persona-KYC 强制代理（first-match-wins，优先于广告 `Reject` 与 `GEOIP,CN` 判定）。
2. 补回原 ip.net.coffee「可复制清单」里遗漏的 KYC 域名：`withpersona.com` / `frompersona.com` / `maps.googleapis.com`。
3. 增加 Anthropic 自有网段兜底：`IP-CIDR,160.79.104.0/21`、`IP-CIDR6,2607:6bc0::/32`（ASN 规则默认注释，兼容性考虑）。

原有「国内外划分 + 广告过滤 + `FINAL,proxy`」全部保留，未改动。

## 应用后验证

- 打开 `https://withpersona.com/cdn-cgi/trace` → 应显示代理节点地区（如 `SG`），而不是 `CN`；
- 手机与电脑都打开 `https://www.cloudflare.com/cdn-cgi/trace` → 两端 `ip=` 一致；
- 确认无误后再进行登录 / KYC。

## 文件

- `wayne-anti.conf`：完整 Shadowrocket 配置（基于 `sr_cnip_ad.conf`，约 5.3 万行）。
- `claude-kyc-proxy.snippet`：仅 Claude / KYC 的置顶规则块，便于粘贴到现有配置。
- `index.html` / `qr/`：GitHub Pages 落地页与二维码。
- `push-both.sh`：一键提交并同时推送到 GitHub + Gitea。

## 维护（双推）

```bash
./push-both.sh "提交说明"   # 提交并推送到 github 与 gitea
```

## 来源与许可

- 基于 [Johnshall/Shadowrocket-ADBlock-Rules-Forever](https://github.com/Johnshall/Shadowrocket-ADBlock-Rules-Forever) 的 `sr_cnip_ad.conf` 修改；
- Claude / Anthropic / KYC 域名清单参考 [ip.net.coffee](https://ip.net.coffee/claude/site.html)。

本作品采用 **CC BY-SA 4.0** 许可（与原项目一致），详见 [LICENSE](LICENSE)。
