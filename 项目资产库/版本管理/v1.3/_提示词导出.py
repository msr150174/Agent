#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
从画布导出「可直接上线」的提示词包。

为什么不手工复制：画布是唯一的真相来源，提示词一改，导出物必须跟着变。
本脚本不维护任何提示词副本，每次运行都从 canvas 现读，避免两份内容漂移。

产出（默认写到 canvas 同目录的 prompts/ 下）：
  prompts/提示词合集_v1.3.md      —— 人读：总表 + 部署顺序 + 逐条提示词
  prompts/prompts_v1.3.json       —— 机读：给平台批量导入
  prompts/00_AGENT-57-MAIN.txt    —— 单条：一次粘贴一个，按部署顺序编号
用法：
  python3 _提示词导出.py [canvas路径]
"""
import json
import os
import re
import sys

CANVAS = sys.argv[1] if len(sys.argv) > 1 else "路书_2026-11-13 v1.3.canvas"

# 部署顺序：主智能体先建，子智能体后建（子智能体需要主智能体的转交目标存在）
DEPLOY_ORDER = [
    "AGENT-57-MAIN", "AGENT-58-COUNSEL", "AGENT-60-OFFICIAL",
    "AGENT-61-AFFAIR", "AGENT-62-LIFE",
    "AGENT-63-COL-XX", "AGENT-64-COL-JG", "AGENT-65-COL-RW",
    "AGENT-66-COL-WJ", "AGENT-67-COL-SJ", "AGENT-68-COL-ICT",
    "AGENT-59-JUDGE",
]


def parse(node_text):
    """把画布节点正文拆成 (meta, body)。meta 是 〔META〕头 + 字段行。"""
    head, _, body = node_text.partition("\n---\n")
    meta = {}
    lines = head.split("\n")
    # id 可能是多段（如 AGENT-63-COL-XX），字符类要含连字符
    m = re.match(r"〔META〕([A-Z]+-\d+-[A-Za-z0-9-]+)\s*｜\s*([A-Z]+)\s*｜\s*(.+)", lines[0])
    if m:
        meta["id"], meta["type"], meta["name"] = m.group(1), m.group(2), m.group(3).strip()
    for ln in lines[1:]:
        if ":" in ln:
            k, _, v = ln.partition(":")
            meta[k.strip()] = v.strip()
    return meta, body.strip("\n")


def main():
    with open(CANVAS, encoding="utf-8") as f:
        canvas = json.load(f)

    agents = []
    for n in canvas["nodes"]:
        if n["type"] != "text" or not n["id"].startswith("AGENT"):
            continue
        meta, body = parse(n["text"])
        meta.setdefault("id", n["id"])
        agents.append({"meta": meta, "body": body, "node": n})

    by_id = {a["meta"]["id"]: a for a in agents}
    order = [i for i in DEPLOY_ORDER if i in by_id] + \
            [i for i in by_id if i not in DEPLOY_ORDER]
    agents = [by_id[i] for i in order]

    out_dir = os.path.join(os.path.dirname(os.path.abspath(CANVAS)), "prompts")
    os.makedirs(out_dir, exist_ok=True)

    # ---------- 单条 txt ----------
    for idx, a in enumerate(agents, 1):
        fn = "%02d_%s.txt" % (idx, a["meta"]["id"])
        with open(os.path.join(out_dir, fn), "w", encoding="utf-8") as f:
            f.write(a["body"].rstrip() + "\n")

    # ---------- 机读 json ----------
    payload = [{
        "order": i,
        "id": a["meta"]["id"],
        "name": a["meta"].get("name", ""),
        "mount": a["meta"].get("mount", ""),
        "io_in": a["meta"].get("in", ""),
        "io_out": a["meta"].get("out", ""),
        "fail": a["meta"].get("fail", ""),
        "verify": a["meta"].get("verify", ""),
        "impl": a["meta"].get("impl", ""),
        "prompt": a["body"],
    } for i, a in enumerate(agents, 1)]
    with open(os.path.join(out_dir, "prompts_v1.3.json"), "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)

    # ---------- 人读合集 ----------
    L = []
    w = L.append
    w("# 路书 v1.3 提示词合集（可直接上线）\n")
    w("> 由 `_提示词导出.py` 从 `%s` 自动生成，**不要手改**。\n" % os.path.basename(CANVAS))
    w("> 改提示词请改画布节点，再跑一次导出，避免画布与线上两份内容不一致。\n")
    w("共 **%d** 个智能体。每条提示词都自带版本号与生效月份，便于线上回溯。\n" % len(agents))

    w("## 一、部署顺序（照这个顺序建，别倒着来）\n")
    w("| # | id | 名称 | 角色 | 挂载 |")
    w("|---|---|---|---|---|")
    for i, a in enumerate(agents, 1):
        mt = a["meta"].get("mount", "")
        role = "路由（不查库）" if "**无**" in mt else "查库作答"
        w("| %d | `%s` | %s | %s | %s |" % (
            i, a["meta"]["id"], a["meta"].get("name", ""), role,
            mt.replace("|", "／")[:70]))
    w("")
    w("先建主智能体，是因为它的转交话术里要写子智能体的名字；")
    w("先建终审（AGENT-59-JUDGE），是因为它是唯一出口，其他节点都往它送。\n")

    w("## 二、三个必须先想清楚的问题\n")
    w("1. **主智能体不挂知识库**。它的职责只有一件事：判断该转给谁。让它查库会绕开所有边界控制。")
    w("2. **终审是唯一出口**。任何子智能体的输出都要经过 `AGENT-59-JUDGE` 才能到学生眼前，")
    w("   这样「未覆盖不得补、金额必须注来源」才有唯一执行点。")
    w("3. **学院节点六个同构，只换专业范围**。改一处就要六处同改，否则会出现「信息学院答得出、")
    w("   卫生健康学院答不出」这类不一致。\n")

    w("---\n")
    w("## 三、逐条提示词\n")
    for i, a in enumerate(agents, 1):
        m = a["meta"]
        w("### %d. %s　`%s`\n" % (i, m.get("name", ""), m["id"]))
        w("| 项 | 内容 |")
        w("|---|---|")
        for label, key in [("挂载", "mount"), ("输入", "in"), ("输出", "out"),
                           ("失败处理", "fail"), ("验收", "verify"), ("实现节点", "impl")]:
            if key in m and m[key]:
                w("| %s | %s |" % (label, m[key].replace("|", "／")))
        w("")
        # 正文含反引号（学院节点有 22 个），用四反引号围栏保证不被截断
        w("````text")
        w(a["body"].rstrip())
        w("````\n")

    md = "\n".join(L).rstrip() + "\n"
    md_path = os.path.join(out_dir, "提示词合集_v1.3.md")
    with open(md_path, "w", encoding="utf-8") as f:
        f.write(md)

    print("agents:", len(agents))
    print("md:", md_path, len(md), "chars")
    print("json:", os.path.join(out_dir, "prompts_v1.3.json"))
    print("txt:", len(agents), "个（按部署顺序编号）")


if __name__ == "__main__":
    main()
