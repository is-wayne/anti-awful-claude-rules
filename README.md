# Shadowrocket Claude / KYC 安全分流规则（优化版）

在 [Johnshall/Shadowrocket-ADBlock-Rules-Forever](https://github.com/Johnshall/Shadowrocket-ADBlock-Rules-Forever) 的 `sr_cnip_ad.conf`（国内外划分 + 广告过滤）基础上，加入「Claude / Anthropic / Persona(KYC) 全域名强制走代理」，用于避免账号相关流量因规则漏配而直连、暴露真实 IP。

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

## 使用

- 将 `optimized-sr_cnip_ad-claude.conf` 作为 Shadowrocket 配置导入；**手机与电脑建议用同一份**，保证出口一致。
- 或：把 `claude-kyc-proxy.snippet` 里的规则粘贴到你现有配置 `[Rule]` 的最顶部。

> 建议把 DNS 设为 DoH（如 `https://1.1.1.1/dns-query`）或走代理，避免 DNS 泄露（`GEOIP,CN` 判定需要解析域名）。

## 应用后验证

- 打开 `https://withpersona.com/cdn-cgi/trace` → 应显示代理节点地区（如 `SG`），而不是 `CN`；
- 手机与电脑都打开 `https://www.cloudflare.com/cdn-cgi/trace` → 两端 `ip=` 一致；
- 确认无误后再进行登录 / KYC。

## 文件

- `optimized-sr_cnip_ad-claude.conf`：完整配置（基于 `sr_cnip_ad.conf`，约 5.3 万行）。
- `claude-kyc-proxy.snippet`：仅 Claude / KYC 的置顶规则块，便于自行粘贴。

## 来源与致谢

- 基于 [Johnshall/Shadowrocket-ADBlock-Rules-Forever](https://github.com/Johnshall/Shadowrocket-ADBlock-Rules-Forever) 的 `sr_cnip_ad.conf` 修改；
- Claude / Anthropic / KYC 域名清单参考 [ip.net.coffee](https://ip.net.coffee/claude/site.html)。

原项目未声明标准开源许可证（GitHub 标记为 `NOASSERTION`），本仓库仅作个人配置分享，请遵循原项目条款。
