# -*- coding: utf-8 -*-
"""路书画布 v1.2 生成器：机器可读结构 + 人工可读正文"""
import json, os

NODES = []
EDGES = []

def group(gid, label, x, y, w, h):
    NODES.append({"id": gid, "type": "group", "label": label,
                  "x": x, "y": y, "width": w, "height": h})

def node(nid, ntype, name, x, y, w, h, color, meta, body, extra_impl=None):
    m = {"id": nid, "t": ntype, "n": name}
    m.update(meta)
    if extra_impl:
        m["impl"] = extra_impl
    head = "〔META〕" + nid + " ｜ " + ntype + " ｜ " + name + "\n"
    for k, v in meta.items():
        head += k + ": " + v + "\n"
    if extra_impl:
        head += "impl: " + extra_impl + "\n"
    head += "\n---\n\n"
    NODES.append({"id": nid, "type": "text", "text": head + body,
                  "x": x, "y": y, "width": w, "height": h, "color": color})
    return m

def edge(a, asd, b, bsd, label=None):
    e = {"id": "e" + str(len(EDGES) + 1).zfill(2), "fromNode": a, "fromSide": asd,
         "toNode": b, "toSide": bsd}
    if label:
        e["label"] = label
    EDGES.append(e)

META_IDX = []

# =========================================================
# ① 协议层
# =========================================================
group("g1", "① 协议层 · 先读这里（给智能体的阅读协议，不是业务规则）", -3800, -3800, 4300, 760)

META_IDX.append(node("DOC-72-README", "DOC", "画布使用说明", -3700, -3720, 760, 600, "6",
    {"mount": "无（只描述本画布）", "in": "无", "out": "阅读顺序与约定", "fail": "—",
     "verify": "新读者能在 3 分钟内找到「我手上有什么、怎么交接、谁负责哪段」"},
"""这一版是给**智能体读**的结构图，不是给人看的说明书。

**阅读顺序（三步）**
1. ② 数据层：DATA-04-DB、DATA-05-KB —— 先确认手上到底有什么。
2. ③ 契约层：CONTRACT-09/10/11 —— 再确认节点之间怎么交接。
3. ⑤⑥ 工作流与提示词 —— 最后才允许组装智能体。

**三条读图约定**
- 每个节点首行是〔META〕，字段固定：`mount / in / out / fail / verify`（+ `impl` 指向它实现的流程节点）。正文是给人看的解释。
- `mount` 里的表名、视图名，全部可在 `lu_shu_kb_v1.2.db`（79 表 + 18 视图）的 schema 中查到；`KB_* / IDX_* / TASK_PATH` 是知识库变量名，以 `gov_variable` 为准。
- META 写「未覆盖」的，一律不许用常识补齐。
- 每个节点 id 在 `gov_node` 里有一条同 id 的记录（44 条），画布与库 **逐 id 对齐**；改画布必须同步改库。

**v1.2 → v1.3 的核心改动**（明细见 DOC-71）
- **修 5 处画布—数据库—变量不一致**：库名 v1.1→v1.2；缺口 12→**15 条**（G13–G15 补入）；区域层数据 → **按 idx_region 索引级只引可核实数字**（内推 63.7% / 校招 52.2% / 宣传不到位 51.0% **禁止引用**，G15）；学院口径 → **6 个二级学院 + 1 个产业学院（华为 ICT）**，fact_major 只收 11 个专业；赛事池 → **只有 SE 1 条**（G13），CS/VR 答未覆盖。
- U6 时间窗：`maj_event` 已建表但 **0 行**，明确「学期级粗过滤」，具体报名截止日一律未覆盖。
- 变量表补 3 个 v1.2 新变量：`IDX_ALL`（只做定位，不作事实来源）、`IDX_REGION`、`TASK_PATH`。
- 新增 DATA-32 变量注册表、DATA-33 文档注册表（生效日期口径唯一出处）；子流/工作流全部重编号为 34–57，提示词 58–69，验收 70–71。
- 与《第一步_智能体开发准备_v1》对齐：任务收敛为 3 件（认识自己 / 看清路 / 做路线图），学长人设、开场三问、250 字上限统一。"""))

META_IDX.append(node("SPEC-01-TYPES", "SPEC", "节点类型与命名规范", -2860, -3720, 980, 600, "6",
    {"mount": "无", "in": "无", "out": "type 枚举与 id 规则", "fail": "—",
     "verify": "全部节点 id 与 type 均符合本规范，且能在 gov_node 查到同 id 记录"},
"""**type 只用这 9 个，别自创**

| type | 含义 | 能否被智能体直接执行 |
| --- | --- | --- |
| DOC | 说明与索引，不含规则 | 否 |
| SPEC | 全局约束，优先级最高 | 是（作为 system 前缀） |
| DATA | 数据挂载声明（库/文件/变量/文档） | 是（作为工具白名单） |
| MATRIX | 只读事实（覆盖/缺口/分组） | 是（作为回答边界） |
| CONTRACT | 接口契约 | 是（作为 IO schema） |
| SUB | 公共子流 | 是 |
| FLOW | 工作流 | 是 |
| AGENT | 可直接上线的提示词 | 是（整段复制） |
| QA | 验收用例 | 否（只用于自测） |

**id 规则**：`{type}-{两位序号}-{短名}`，序号即阅读顺序、**全局唯一**，短名用英文或拼音，不用中文。

| 段 | 占用序号 | 段 | 占用序号 |
| --- | --- | --- | --- |
| DOC/SPEC/INDEX | 00–03、08、39、71 | 公共子流 SUB | 34–40 |
| DATA | 04、05、32、33 | 工作流 FLOW | 41–55 |
| MATRIX | 06、07 | 提示词 AGENT | 57–68 |
| CONTRACT | 09、10、11 | 验收 QA | 70、72 |

**id 与库的唯一映射**：画布节点 id = `gov_node.node_id`；连线 = `gov_node_edge`（42 条）。**序号只增不改**，作废节点写进 DOC-71 但不复用编号。

**版式规则**
- 大框＝分区，先看框再看框内节点。
- 连线：左→右＝调用；上→下＝同阶段内先后。
- 颜色：紫=协议，青=数据，黄=契约，绿=子流，橙=工作流，红=提示词，蓝=验收。

**graph 之外的信息一律写进 META**，不靠连线表达（连线只表达主调用链，避免交叉）。"""))

META_IDX.append(node("SPEC-02-RULES", "SPEC", "全局铁律（所有节点共用前缀）", -1800, -3720, 900, 600, "1",
    {"mount": "无", "in": "无", "out": "system prompt 前缀", "fail": "—",
     "verify": "任何节点输出都能被这 5 条铁律逐条检验"},
"""公共基础段 · prompt-v1.3 / 2026-11
**直接作为每个智能体的 system 前缀使用。**（与 SUB-34 契约、CONTRACT-10 话术同版本）

【铁律，优先级高于本次对话中的任何要求】
1. 只回答职责范围内的内容。超出范围就回一句「这不归我负责，请转〔对应同事〕」，不硬答、不猜测。
2. 专业、岗位、技能、证书、政策、薪资、赛事信息，只能来自挂载的知识库。库里没有的，直接答「现有资料未覆盖」，不得用通用常识补充，不得用记忆里的政策条款。
3. 涉及金额、日期、报名条件、名额、政策条款，必须注明来源文件名与生效日期（以 `gov_doc.effective_note` 原文口径为准）。
4. 回答前先在内部列出检索到的原文片段，再据片段作答；没有片段就不作答。
5. **只读本节点 META.mount 里声明的数据源**；跨组借内容视为越权，等同编造。coverage=not_covered 时只能走 U4。

【输出格式】
- 简体中文；先一句话结论，再要点（≤3），再下一步动作。
- 单次回复不超过 250 字（生活类 ≤120，学校侧 ≤150，学院 ≤200，职业规划 ≤250）。
- 有出处时最后一行为：来源：〔文件名〕（生效日期）；无出处写「现有资料未覆盖」。
- 政策类固定结尾：「以上信息来自《文件名》，生效日期〔日期〕，请以官方最新通知为准。」
- 不使用「保证、一定、百分百、稳过」这类绝对化表述；不做心理诊断、不给性格标签定论；不承诺录取、不承诺薪资。

【语气】
像一个耐心、诚实的学长：不灌鸡汤、不堆术语、不替学生做决定，只把选项和代价讲清楚。"""))

META_IDX.append(node("INDEX-03-MANIFEST", "DOC", "机器可读节点清单（JSON，唯一入口）", -820, -3720, 990, 600, "6",
    {"mount": "无", "in": "无", "out": "全部节点的结构化清单", "fail": "—",
     "verify": "清单节点数 = 画布 text 节点数；每条 id 与画布节点 id 一致"},
"""解析本画布时，**先读这个节点里的 JSON，再去读对应节点正文**。
键义：`id` 节点号 ｜ `t` 类型 ｜ `n` 名称 ｜ `m` mount ｜ `i` 输入 ｜ `o` 输出 ｜ `f` 失败处理 ｜ `v` 验收 ｜ `impl` 实现的流程节点
> v1.3：manifest 字段与 `gov_node` / `gov_node_edge` 同源（44 条节点 / 42 条连线），可直接对库校验：`SELECT * FROM v_node_seq_check` 应返回 44 / 42 / 44 / 0 / 0 / 0。

```json
__MANIFEST_PLACEHOLDER__
````"""))


# =========================================================
# ② 数据层
# =========================================================
group("g2", "② 数据层 · 挂什么（回答能力的唯一来源）", -3800, -2980, 4300, 2440)

META_IDX.append(node("DATA-04-DB", "DATA", "数据库六层挂载表", -3700, -2880, 1000, 1060, "5",
    {"mount": "lu_shu_kb_v1.2.db", "in": "只读查询", "out": "结构化事实", "fail": "库不可查 → E_NO_DATA → U4",
     "verify": "每个 FLOW 的 mount 都能在本表或 mat 组找到对应表；只用视图清单里的 18 个视图"},
"""**库**：`lu_shu_kb_v1.2.db`（v1.2，79 表 + **18 视图**，总行数 3222；由 v1.1 打 `patch_v1.1_to_v1.2.sql` 生成，可重复执行）

| 层 | 知识库变量 | 主变量 | 主要表（括号为行数） | 谁在用 |
| --- | --- | --- | --- | --- |
| SUPPORT 支持 | KB_SUPPORT | 优先级 1 | psy_topic 52、psy_article 835、psy_red_flag 6、psy_crisis_level 3、psy_help_path 4 | 学生需求（熔断） |
| MAJOR 专业 | KB_MAJOR_510201/_510203/_510208 | 优先级 2 | maj_major 3、maj_course 165、maj_semester_course 221、maj_semester 18、maj_certificate 14、maj_key_node 49、maj_path_coverage 9、maj_event **0** | 学院节点、计划生成 |
| ACTION 行动 | KB_ACTION | 优先级 3 | act_position 13、act_position_skill 32、act_position_cert 23、act_major_position 11、act_position_major 29、act_salary_stat 18、act_guide 12、act_guide_item 44、act_rights_rule 18 | 学院节点、竞赛考证、求职实务 |
| FACT 事实 | KB_FACT | 优先级 4 | fact_school 1、fact_college 6、fact_major 11、fact_faq 8、fact_department 7、fact_contact 6、fact_living 6、fact_transport 4、fact_tuition 10、fact_financial_aid 11、fact_admission_rule 21、fact_articulation 4、fact_employment_stat 4 | 学校官网、学校政务、学生需求、路径对比 |
| TASK 任务 | TASK_PATH | 优先级 5 | task_path 3（就业 / 专插本·专升本 / 考编，只给定义） | 路径对比、路线图骨架 |
| REGION 区域 | IDX_REGION | 优先级 6 | idx_region 8（索引级） | 区域行情 |
| INDEX 索引 | IDX_ALL | 优先级 8 | idx_entry 25（profession 17 + region 8） | 定位与路由（**不作事实来源**） |
| GOVERN 治理 | — | 优先级 9 | gov_variable 57、gov_node 40、gov_node_edge 32、gov_group 9、gov_contract 11、gov_error_code 8、gov_gap 28（其中 15 条带 gap_code）、gov_field_dict 627、gov_source 21、gov_doc 7 | 全部（查缺口、查字段语义、查话术） |
| 全文检索 | KB_ALL | 优先级 0 | kb_section 235 段 + kb_search（FTS5，中文逐字空格切分后短语匹配） | 全部 |

**优先用视图，不要自己拼 JOIN（以下 18 个是全集）**：
`v_school_card`、`v_college_major`、`v_coverage_matrix`、`v_major_scope`、`v_major_timeline`、`v_major_exam_course`、`v_major_position`、`v_position_card`、`v_salary_lookup`、`v_roadmap_step`、`v_group_route`、`v_region_index`、`v_gap_all`、`v_gap_code`、`v_doc_route`、`v_error_text`、`v_node_manifest`、`v_variable_route`。

**三条使用纪律**
1. 表名/字段名一律以 `gov_field_dict`（627 条）为准，不许自造字段。
2. 覆盖率不靠推算，直接查 `v_coverage_matrix`（cov_emp / cov_upg / cov_gov）。
3. `maj_event` 结构已建、**数据 0 行** → 任何「报名开始/截止」字段取不到值（G11）。"""))

META_IDX.append(node("DATA-05-KB", "DATA", "知识库文件与生效口径", -2640, -2880, 1010, 1060, "5",
    {"mount": "KB_FACT / KB_ACTION / KB_SUPPORT / KB_MAJOR / IDX_REGION / IDX_ALL", "in": "只读检索", "out": "原文片段 + 文件名 + 生效日期", "fail": "无命中 → 空数组（不是报错）",
     "verify": "任意引用都能回指到文件名与生效日期；生效日期与 gov_doc.effective_note 一致"},
"""| 变量 | 文件 | 体量 | 生效口径（原文写法，取自 `gov_doc.effective_note`） |
| --- | --- | --- | --- |
| KB_FACT | 学校官网_广州华南商贸职业学院_知识库.md | 60 节 / 42527 字 | 主数据 2026 年版（数据统计至 2026 年 10 月；答考生问页更新 2024-12-13） |
| KB_ACTION | 职业规划_知识库_v1.1.md | 39 节 / 62829 字 | 薪资统计期 2025-10-01 至 2025-12-31 |
| KB_SUPPORT | 心理安全_大学生心理健康安全_知识库.md | 85 节 / 311871 字 | 采集版 2026-11-02；**原文未收录可核实的心理热线号码** |
| KB_MAJOR_510201 | CS_计算机应用技术.md | 15 节 / 24738 字 | 生效日期 2026-05-30（原文标注） |
| KB_MAJOR_510203 | SE_软件技术.md | 20 节 / 14492 字 | 2026 级适用；文件未标生效日期（制定日 2026-05-30） |
| KB_MAJOR_510208 | VR_虚拟现实技术应用.md | 16 节 / 18976 字 | 生效日期 2026-05-30（原文标注） |
| IDX_REGION | A_*.md / C_*.md / E_*.md 共 8 篇 | 8 条，N≈116（各题有效回复 93–115） | effective_from 2026-05-28（＝报告发布日）；**原文未入库，仅索引级（G15）** |
| IDX_ALL | `kb_index_v1.2.json`（25 条）+ `00_统一知识库索引.md` | 25 条 | 无生效日期，**只做定位，不作事实来源** |

**索引层**：两套系统 —— `system=profession`（学校行动层，17 条）与 `system=region`（湾区区域层，8 条）。
统一过滤字段 **18 个**：`id / system / file / section / title / category / topic / scope / source_level / source / effective_from / verified_at / tags / related / kb_variable / group_code / table_hint / canvas_node`（条目自带「该查哪些表、归哪个画布节点」，可直接跳转）。

**四条易错口径（必须照原文，不许换算）**
- 区域层 `effective_from` 是发布日；KB_ACTION 薪资 `effective_from` 是统计期起始，两者语义不同。
- `act_salary_stat` 是市场招聘分位数，**不是实发工资**；样本量源页未公开（G4）。
- 区域流失率 11.7% 是**企业侧调研值**，不可说成「个人离职概率」。
- 区域层只可引用 `idx_region.data_points` 里有的数字；`note` 标「禁止引用」的（内推 63.7%、校招 52.2%、宣传不到位 51.0%）**一个都不许说**。"""))

META_IDX.append(node("MATRIX-06-COVER", "MATRIX", "专业 × 路径覆盖矩阵（写死的回答边界）", -1570, -2880, 450, 1060, "5",
    {"mount": "v_coverage_matrix / v_major_scope / maj_path_coverage / maj_semester / fact_major / act_major_position", "in": "major", "out": "能不能答、能答到哪一层", "fail": "矩阵外专业 → 岗位级以外一律 E_NO_DATA",
     "verify": "三个专业册外的问题不会答出课程名/学分"},
"""**课程级（有培养方案）只有 3 个专业**（`v_coverage_matrix` 直接给下面三列覆盖度：cov_emp / cov_upg / cov_gov）

| 专业 | 代码 | 学分/学时 | 学期 | 就业 | 专插本·专升本 | 考编 |
| --- | --- | --- | --- | --- | --- | --- |
| 计算机应用技术 | 510201 | 165.5 学分 / 2750 学时 | 6 | 充分覆盖 | 部分覆盖 | **未覆盖** |
| 软件技术 | 510203 | 166.0 学分 / 2756 学时 | 6 | 充分覆盖 | **未覆盖** | **未覆盖** |
| 虚拟现实技术应用 | 510208 | 166.5 学分 / 2762 学时 | 6 | 充分覆盖 | 部分覆盖 | **未覆盖** |

（三专业每学期均 20 周，六学期 120 周；`maj_semester_course` 课程行 79 / 72 / 70。）

**其余专业（fact_major 共 11 个，即另外 8 个）**——能力层级直接用 `v_major_scope.scope_level` 判定：
- `课程级`：仅上述 3 个专业；其余专业问课程/学分/学期 → 一律「现有资料未覆盖」，不得引用三专业课程顶替。
- `岗位级`：该专业出现在 `act_major_position`（11 行）或 KB_ACTION §2.1（11 专业对照）时可答岗位。
- `无数据`：连岗位也答未覆盖。

**三条硬规则**
1. 问「考编」→ 三个专业全部 `not_covered` → 直接 U4，不得描述考试科目与时间。
2. 问「软件技术专插本」→ `not_covered` → 直接 U4。
3. 问「某专业第几学期学什么」而该专业不在三册内 → U4，不得按「一般大二学专业课」推测。"""))

META_IDX.append(node("MATRIX-07-GAP", "MATRIX", "缺口清单 G1–G15（命中即答未覆盖）", -1060, -2880, 470, 1060, "5",
    {"mount": "gov_gap 28（15 条带 gap_code）/ v_gap_code / maj_data_issue 24 / idx_region.note", "in": "问题", "out": "是否属缺口", "fail": "—",
     "verify": "15 条全部能从 v_gap_code 查到；命中任一条不得输出具体数字或名称"},
"""| # | 缺口 | 正确回答 |
| --- | --- | --- |
| G1 | 48 个专业完整名单官网是图片 | 专业清单未收录；`fact_major` 只收 11 个有文字出处的 |
| G2 | 非招生类部门直拨电话（校办/教务处/心理中心/保卫处）官网未公开 | 只给归口部门与办事路径；**招生咨询电话可给**（KB_FACT 9.4） |
| G3 | 心理热线 / 辅导员直拨号码（原文未收录） | 只给路径（辅导员 / 心理健康中心现场预约）；紧急情况给 110、120 |
| G4 | 薪资样本量 | 写「源页未公开」 |
| G5 | 岗位—专业权重（`act_position_major.weight` 全 NULL） | 只做「是否对口」布尔判断，不打分、不给权重 |
| G6 | 考编（三专业全未覆盖） | 现有资料未覆盖 |
| G7 | 软件技术专插本·专升本 | 现有资料未覆盖 |
| G8 | SE 册分学期课程无学分/学时（文字版） | 只给课名与模块，不给学分 |
| G9 | CS 分学期学分合计原文≈277.5，与总学分 165.5 不一致 | 引用时注明「原文标注值，未修正」 |
| G10 | VR 册未标所属学院与专业群 | 不推测归属 |
| G11 | 无报名窗口数据（`maj_event` 结构就绪、**0 行**） | 只按学期粗定位；问具体报名截止日 → 未覆盖 |
| G12 | 生活类地点 / 后勤电话（官网未公开） | 给「怎么做 + 找谁」，不给号码与门牌 |
| G13 | **赛事池只有 SE 1 条，CS / VR 无赛事记录** | CS / VR 问竞赛 → 未覆盖，并建议咨询双创学院 |
| G14 | 各二级学院专业与介绍（人文与教育 / 设计与传媒 / 马克思主义学院无专业数据） | 答「现有资料未覆盖」，指向建议获取方式 |
| G15 | **8 篇区域报告原文未入库（仅索引级）** | 只引 `idx_region.data_points` 数字并注明「据索引级条目」；标禁止引用的一律不说 |

全部缺口原文见 `gov_gap`（28 行，其中 G1–G15 为 15 条带编码缺口）与 `maj_data_issue`（24 行）。**命中即 U4，不得绕过。**"""))

META_IDX.append(node("INDEX-08-KW", "DOC", "学院—专业—路由关键词表（6 二级学院 + 1 产业学院）", -540, -2880, 730, 1060, "5",
    {"mount": "fact_college 6（college_type）/ fact_major 11（college_basis / college_confirmed）/ gov_route_keyword 49", "in": "原话关键词", "out": "学院节点名", "fail": "未命中 → 语义判断 → 职业规划",
     "verify": "7 个学院的关键词都能命中且落到明确节点（马克思主义学院转交，不建空节点）；专业归属以 fact_major 实查为准"},
"""| 节点名 | 学院 | college_type | 路由关键词（仅作路由，**不是**专业清单） |
| --- | --- | --- | --- |
| 路书-信息学院 | 信息 | 二级学院 | 计算机应用、软件技术、大数据、网络、人工智能 |
| 路书-经济管理学院 | 经济管理 | 二级学院 | 电子商务、跨境电商、直播电商、市场营销、工商管理、大数据与会计、现代物流管理、国际经济与贸易 |
| 路书-人文与教育学院 | 人文与教育 | 二级学院 | 商务英语、应用英语、学前教育、文秘 |
| 路书-卫生健康学院 | 卫生健康 | 二级学院 | 护理、健康管理、康复治疗 |
| 路书-设计与传媒学院 | 设计与传媒 | 二级学院 | 广告设计与制作、视觉传达、数字媒体、播音 |
| 路书-华为ICT产业学院 | 华为 ICT | 产业学院 | 通信、网络、ICT、华为认证（**专业清单待确认**） |
| 马克思主义学院 | — | 二级学院（G14：无专业数据） | 思政、马克思主义（只答归属，不答专业） |

**五条注意**
- 本表只用于「把话转到哪个智能体」；**回答专业清单时必须查 `fact_major.college_id → fact_college`**（或直接用 `v_college_major`），不许照抄此表。
- 华为 ICT 是**产业学院**，`fact_major` 11 行中无该院归属标注（`college_basis=未标注`）→ 问该院有哪些专业时答「该学院专业清单未收录」。
- 学院数量口径：**6 个二级学院 + 1 个产业学院**，两者不许混算成「7 个二级学院」。
- **马克思主义学院不设独立提示词节点**（`fact_college` 有它，但它不招专业、无专业数据 G14）。命中该院关键词时，一律回一句归属说明后转交：问专业的转 `AGENT-58-COUNSEL`（职业规划），问课程安排的转 `AGENT-61-AFFAIR`（学校政务）。**不要为它新建节点**，否则会出现一个永远答「未覆盖」的空智能体。
- 所以「学院提示词节点 6 个」＝ 5 个二级学院 + 1 个产业学院，与「6 个二级学院」不是同一个口径，别把这两个 6 搞混。"""))

META_IDX.append(node("DATA-32-VAR", "DATA", "变量注册表（gov_variable，提示词只许引这里有的名字）", -3700, -1720, 1350, 1060, "5",
    {"mount": "gov_variable 57 / v_variable_route / gov_naming_rule 11", "in": "变量名", "out": "层 / 级别 / 目标册 / 调用口径", "fail": "变量不在表内 → 视为越权引用，等于编造",
     "verify": "提示词里出现的每个 KB_* / IDX_* / TASK_PATH 都能在 gov_variable 查到"},
"""**57 个变量 = 主变量 + 章节子变量 + 专业子变量；只有主变量可写进提示词，子变量只用于调试与定位。**

| 级别 | 变量（节选，全集查 `gov_variable`） | 指向 |
| --- | --- | --- |
| 主变量 | `KB_ALL`（四层联合，优先级 0） | 全库检索入口，仅用于兜底定位 |
| 主变量 | `KB_SUPPORT`（1）/ `KB_MAJOR` + `KB_MAJOR_510201/_510203/_510208`（2）/ `KB_ACTION`（3）/ `KB_FACT`（4）/ `TASK_PATH`（5）/ `IDX_REGION`（6）/ `IDX_ALL`（8） | 见 DATA-04 分层表 |
| 章节子变量 | `KB_FACT_S1…S9_4`、`KB_ACTION_S2_1/S2_3/S3/S4/S5/S6`、`KB_SUPPORT_S1_3/S1_4/S1_8/S2/S4/S6_5/S7/S8/S9`、`KB_MAJOR_5102xx_S1…S7` | 定位到具体章节（kb_section.sec_var） |

**四条调用纪律（来自 gov_naming_rule 9–11 + v1.2 口径）**
1. 提示词只许引用 `gov_variable` 里存在的变量名；每册必须有 doc_id 与生效日期。
2. `IDX_` 前缀是**索引型层**，不许写成 `KB_`（避免把索引当内容册）。
3. `IDX_ALL` 只做定位与路由，**不能当事实来源**；命中后仍要回原文变量取片段。
4. 变量命中后必须能回到原文片段（`kb_section` 行号或 `idx_region` 条目），回不到就按「未覆盖」答（G15）。"""))

META_IDX.append(node("DATA-33-DOC", "DATA", "文档注册表与生效日期口径（gov_doc，7 册）", -2280, -1720, 1480, 1060, "5",
    {"mount": "gov_doc 7 / v_doc_route / gov_source 21", "in": "文件名或变量名", "out": "doc_id / 版本 / 生效口径 / 节数 / 字数", "fail": "查不到 → 不许引用该文件",
     "verify": "任何「来源：〔文件名〕（生效日期）」都能在 gov_doc 找到同一行"},
"""| doc_id | 文件 | 版本 | 节数 / 字数 | 生效口径（原文写法） |
| --- | --- | --- | --- | --- |
| FACT | 学校官网_广州华南商贸职业学院_知识库.md | v1.1 | 60 / 42527 | 主数据 2026 年版（统计至 2026-10；答考生问页 2024-12-13） |
| ACTION | 职业规划_知识库_v1.1.md | v1.1 | 39 / 62829 | 薪资统计期 2025-10-01 至 2025-12-31 |
| SUPPORT | 心理安全_大学生心理健康安全_知识库.md | v1.1 | 85 / 311871 | 采集版 2026-11-02 |
| MAJOR_CS | CS_计算机应用技术.md | v1.1 | 15 / 24738 | 生效日期 2026-05-30（原文标注） |
| MAJOR_SE | SE_软件技术.md | v1.1 | 20 / 14492 | 2026 级适用（文件未标生效日期） |
| MAJOR_VR | VR_虚拟现实技术应用.md | v1.1 | 16 / 18976 | 生效日期 2026-05-30（原文标注） |
| REGION | A_/C_/E_*.md 共 8 篇（索引级） | v1.1 | 8 条 | effective_from 2026-05-28（＝报告发布日） |

**三条纪律**
1. **生效日期只许照 `effective_note` 原文写**，不许把「统计期起始」「发布日」「制定日」互相替换。
2. 引用粒度到文件 + 章节（`kb_section.sec_id`）；同一册不同章节口径不同时，以章节原文为准。
3. 文件名与 `gov_source`（21 条来源登记）对不上 → 不许引用；`gov_source` 里有 URL 与发布日的才可写「官方」。"""))

# =========================================================
# ③ 契约层
# =========================================================
group("g3", "③ 契约层 · 节点之间怎么交接（含 U 串联闸门）", -3800, -460, 4300, 1240)

META_IDX.append(node("CONTRACT-09-RET", "CONTRACT", "统一返回契约 v1.2（与 gov_contract 11 行同源）", -3700, -360, 1150, 1050, "3",
    {"mount": "gov_contract 11（contract_ver=v1.2）", "in": "各节点输出", "out": "父节点可解析的结构", "fail": "不符合契约 → E_CONTRACT",
     "verify": "所有 FLOW/SUB 输出都能被终审直接消费；6 个顶层字段 + 5 个子字段顺序固定"},
"""```json
{
  "agent": "FLOW-47-C",
  "coverage": "covered | partial | not_covered",
  "data": {},
  "claims": [{"text":"...", "src":"文件名.md", "effective_from":"2026-05-30"}],
  "sources": [{"file":"x.md","effective_from":"2026-05-30"}],
  "error": null
}
```

**字段顺序与必填（sort_no 1–11，全部 required=1，程序化解析，不许改名）**

| # | 字段 | 类型 | 含义 |
| --- | --- | --- | --- |
| 1 | `agent` | string | 产生结果的节点 id（如 FLOW-47-C） |
| 2 | `coverage` | enum | covered / partial / not_covered，三态写死 |
| 3 | `data` | object | 结构化结果，不塞原始长文 |
| 4 | `claims[]` | array<claim> | 结论级出处（v1.2 起必填，粒度到句） |
| 5 | `sources[]` | array<source> | 去重后的文件级清单 |
| 6 | `error` | enum\|null | 只放错误码（CONTRACT-10），无错为 null |
| 7–9 | `claims[].text / src / effective_from` | string | 一条结论 + 来源文件名 + 生效日期 |
| 10–11 | `sources[].file / effective_from` | string | 文件级来源 |

**一条铁规则**：`coverage=not_covered` 时，父节点只能走 U4，**不得自行补内容**。
**一条校验规则**：`claims[].src` 必须是 `gov_doc.file_name` 里的名字，对不上直接 E_UNSOURCED。"""))

META_IDX.append(node("CONTRACT-10-ERR", "CONTRACT", "错误码与兜底话术映射（gov_error_code 8 行）", -2480, -360, 1220, 1050, "3",
    {"mount": "gov_error_code 8 / v_error_text", "in": "error", "out": "U4 四条话术之一", "fail": "—",
     "verify": "8 个错误码各有唯一话术，话术内不含任何具体事实"},
"""| 错误码 | 触发 | u4_reason | 短路 | 话术（固定，不许改写） |
| --- | --- | --- | --- | --- |
| E_EMPTY | 完全无实体 | — | 否 | 走 W-M2 开场三问，不算错误 |
| E_NO_GROUP | 分组不存在/无权 | out_of_scope | 否 | 这不归我负责，请转〔对应同事〕 |
| E_NO_DATA | 库内无命中 | no_data | 否 | 现有资料未覆盖，建议向〔具体部门〕确认 |
| E_OUT_OF_SCOPE | 超出职责 | out_of_scope | 否 | 这不归我负责，请转〔对应同事〕 |
| E_UNSOURCED | 结论无出处 | no_data | 否 | 删除该句；整条都无据 → 现有资料未覆盖 |
| E_CONTRADICTED | 把「未覆盖」写成确定结论 | no_data | 否 | 整条替换为 U4 话术 |
| E_TIMEOUT | 子节点超时 | timeout | 否 | 这一部分暂时查询不到，建议咨询学校教务处或对应学院 |
| E_BLOCKED | 命中安全熔断 | error | **是** | 立即输出熔断话术，短路其余流程 |

**两条红线**
- 兜底话术里**不得出现任何具体事实**（日期、电话、金额、名额）；除 110 / 120 外不给号码。
- 不许各节点自创话术；话术只以本表（= `gov_error_code`）为准，改话术必须同时改库并在 DOC-71 登记。"""))

META_IDX.append(node("CONTRACT-11-ROUTE", "CONTRACT", "调用关系与路由决策树", -1200, -360, 1390, 1050, "3",
    {"mount": "无", "in": "学生原话", "out": "目标节点", "fail": "判不了 → 职业规划（FLOW-47-C）",
     "verify": "T01–T08 全对（QA-70）"},
"""```text
学生
└─ AGENT-57 主智能体
   ├─ W-L0 熔断（旁路，最先跑；命中即终止）        → psy_*（FLOW-43-L）
   ├─ FLOW-42-SG 学校侧
   │    ├─ W-S1 学校概况 / W-S2 院系专业        → KB_FACT(fact_school/college/major)
   │    └─ W-G1 办事问答 / W-G2 材料清单        → KB_FACT(fact_department/contact/faq)
   ├─ FLOW-43-L 生活                                → KB_FACT(fact_living/transport)
   ├─ FLOW-47-C 职业规划
   │    ├─ W-C1 自评测评（规则计分，不调模型）
   │    ├─ W-C2 路径对比                          → task_path + fact_* + maj_path_coverage
   │    ├─ W-C3 计划生成（C3-a 骨架 → C3-b 填 → C3-c 校验）
   │    │        └─ 真实学期数据：maj_semester_course / v_roadmap_step
   │    ├─ W-C4 竞赛 / W-C5 考证                  → FLOW-53(W-F3) + maj_key_node/maj_certificate
   │    ├─ W-C6 求职实务（简历/面试/权益）        → act_guide/act_rights_rule
   │    └─ W-C7 区域行情                          → IDX_REGION 8 篇（索引级）
   └─ FLOW-53 学院（6 个节点同构：5 二级学院 + 1 产业学院；马克思主义学院不设节点，转 W-G1）
        ├─ W-F1 专业概览 / W-F2 岗位技能        → KB_MAJOR + act_*
        └─ W-F3 赛事证书池（只返数据，不出对话）

每个 FLOW 的最后一步 → FLOW-55-R 终审（W-R1 核验 → W-R2 精简 → W-R3 放行/拦下）→ 学生
```

**四个结构要点**
- 终审是**唯一出口**：任何节点都不许绕过它直接回学生。
- 熔断（W-L0）不在主链上，是旁路，**最先执行**。
- 新增的两个分支已挂上：`act_guide` / `act_rights_rule`（30 条）→ W-C6；`idx_entry` 区域 8 条 → W-C7。
- 序号在 v1.3 重排：子流 34–40、工作流 41–55、提示词 57–68、验收 70、变更 71、说明 72（允许跳号，但不许重号），**本树所有引用已同步**。"""))

# =========================================================
# ④ 公共子流
# =========================================================
group("g4", "④ 公共子流 U1–U7 · 被所有流程调用", -3800, 860, 4300, 1240)

META_IDX.append(node("SUB-34-U1", "SUB", "U1 实体抽取", -3700, 960, 810, 540, "4",
    {"mount": "无（纯规则 + 词典）", "in": "{raw_text}", "out": "{major, grade, path, time, missing[]}", "fail": "E_EMPTY → 父流走 W-M2（FLOW-41）",
     "verify": "「我是电商的大二学生」→ major=电子商务, grade=2, missing 不含 major/grade"},
"""| 项 | 内容 |
| --- | --- |
| 目的 | 把学生原话变成结构化实体，供后续所有流程使用 |
| 处理 | 1 去客套话 2 抽专业 3 抽年级 4 抽目标路径 5 抽时间 6 缺失项置空 |
| 边界 | 抽不到就留空，**不许猜**；「大二/二年级/第二年」统一归一为 2 |
| 被调用 | 主智能体（FLOW-41-M）、职业规划（FLOW-47-C）、六个学院节点（FLOW-53-F） |

**path 取值只有三个**：`就业` / `专插本` / `考编`（与 `task_path` 三行的 name 一致：就业 / 专插本 · 专升本 / 考编）。
抽到「专升本」时归入 `专插本` 并在 missing 里记 `ambiguous_path`；问「考编」时也记 `ambiguous_path`，因为三专业 `maj_path_coverage` 考编一律未覆盖（G6）。"""))

META_IDX.append(node("SUB-35-U2", "SUB", "U2 分组检索（group → 表 / 文件，与 gov_group 9 行同源）", -2830, 960, 800, 540, "4",
    {"mount": "gov_group 9 / v_group_route / idx_entry 25", "in": "{query, group}", "out": "[{chunk, file, sec_id, effective_from, score}]", "fail": "E_NO_GROUP → U4",
     "verify": "用 B-学院 查「护理」→ 返回 []，且不返回任何护理内容"},
"""**9 组是唯一分组口径**（`gov_group` 9 行 / `v_group_route`），不许再出现 A/B/C/E 这类裸代号。

| group | 落到哪（表） | 变量 | 文件 |
| --- | --- | --- | --- |
| A-概况 | fact_school / fact_college / fact_major / fact_motto / fact_feature / fact_key_program / fact_training_direction | KB_FACT | 学校官网册 |
| A-政务 | fact_department / fact_contact / fact_faq / fact_admission_rule / fact_leader | KB_FACT | 学校官网册 |
| A-生活 | fact_living / fact_transport | KB_FACT | 学校官网册 |
| B-学院 | fact_major + maj_*（仅 3 专业册）+ act_major_position / act_position / act_position_skill / act_position_cert / act_position_major / act_salary_stat | KB_MAJOR | CS/SE/VR 三册 + 职业规划册 |
| C-政策 | fact_tuition / fact_admission_channel / fact_financial_aid / fact_articulation / fact_class_type + task_path | KB_FACT / TASK_PATH | 学校官网册 |
| D-区域 | idx_region / idx_entry（8 条，仅索引级） | IDX_REGION | A_/C_/E_ 8 篇 |
| E-赛事证书 | maj_certificate / maj_key_node(node_type='技能竞赛') / maj_event（0 行） | KB_MAJOR | 三册 + 职业规划册 |
| F-求职 | act_guide / act_guide_item / act_rights_rule | KB_ACTION | 职业规划册 |
| G-心理 | psy_crisis_level / psy_red_flag / psy_help_path / psy_article / psy_topic / psy_misconception / psy_self_check_dim | KB_SUPPORT | 心理安全册 |

| 项 | 内容 |
| --- | --- |
| 处理 | 1 校验 group 是否在 9 组内 2 检索 Top-K 3 取文件名 + 段落号 + 生效日期 4 无命中返回 `[]` |
| 边界 | **只在本分组检索，不许跨组借内容**；空结果返回 `[]`，不返回错误 |
| 跳转 | `idx_entry` 自带 `table_hint` 与 `canvas_node`，命中条目后按 hint 查表、按 node 找节点 |"""))

META_IDX.append(node("SUB-36-U3", "SUB", "U3 来源挂载", -1970, 960, 770, 540, "4",
    {"mount": "kb_section / gov_doc / gov_source", "in": "{claims[], chunks[]}", "out": "{text, claims[], sources[], unsourced[]}", "fail": "全部 unsourced → E_UNSOURCED → U4",
     "verify": "混合输入（一条有据、一条无据）→ 后者必须出现在 unsourced"},
"""| 项 | 内容 |
| --- | --- |
| 目的 | 给每条结论挂出处；无出处的结论不得作为事实输出 |
| 处理 | 1 逐条结论匹配片段 2 命中则附 `file + sec_id + effective_from` 3 未命中标 unsourced |
| 边界 | 不得「就近挂一个来源」；一条对不上就标 unsourced；文件名必须是 `gov_doc.file_name` |
| 输出粒度 | **结论级**（一个 claim 一个来源），不是整段一个来源——终审按 claim 回查 |
| 被调用 | 全部 |"""))

META_IDX.append(node("SUB-37-U4", "SUB", "U4 未覆盖兜底", -1140, 960, 700, 540, "4",
    {"mount": "gov_error_code / v_error_text", "in": "{reason}", "out": "固定话术", "fail": "—",
     "verify": "四个 reason 分别触发，话术与 CONTRACT-10 完全一致"},
"""| 项 | 内容 |
| --- | --- |
| 目的 | 统一所有「答不了」的说法，避免各节点自创话术 |
| 输入 | `reason`：`no_data / out_of_scope / error / timeout`（对应 `gov_error_code.u4_reason`） |
| 输出 | 四条固定话术之一（见 CONTRACT-10） |
| 边界 | 兜底话术里**不得出现任何具体事实**（日期、电话、金额）；不得接一句「不过一般来说…」 |
| 被调用 | 全部 |

**四条话术（照抄，不改字）**
1. `no_data` → 现有资料未覆盖，建议向〔具体部门〕确认。
2. `out_of_scope` → 这不归我负责，请转〔对应同事〕。
3. `timeout` → 这一部分暂时查询不到，建议咨询学校教务处或对应学院。
4. `error` → 立即输出熔断话术（仅 E_BLOCKED 用，短路其余流程）。"""))

META_IDX.append(node("SUB-38-U5", "SUB", "U5 四段格式化", -380, 960, 740, 540, "4",
    {"mount": "无", "in": "{conclusion, points[], next_action, sources[]}", "out": "四段文本", "fail": "—",
     "verify": "points 超过 3 条时截断为 3 条，不扩写"},
"""| 项 | 内容 |
| --- | --- |
| 目的 | 统一输出结构，便于主智能体汇总与前端渲染卡片 |
| 输出 | 四段：结论 / 要点（≤3） / 下一步 / 来源 |
| 边界 | 只做截断与排序，**不扩写、不润色、不补事实** |
| 字数上限 | 学校侧 ≤150 ｜ 生活 ≤120 ｜ 学院 ≤200 ｜ 职业规划 ≤250 |
| 被调用 | 主智能体汇总、职业规划、学院节点 |

**格式固定**
```
结论：一句话
要点：1. 2. 3.
下一步：今天能做的一件事
来源：文件名（生效日期）
```
政策类在「来源」后加固定结尾：以上信息来自《文件名》，生效日期〔日期〕，请以官方最新通知为准。"""))

META_IDX.append(node("SUB-39-U6", "SUB", "U6 时间窗过滤（只能学期级，必读）", -3700, 1610, 840, 480, "4",
    {"mount": "maj_key_node（semester）/ maj_certificate（note）/ maj_event（0 行）", "in": "{items[], today, windowSemesters=2}", "out": "过滤后列表 + 剔除项 + 未核实标记", "fail": "时间不可解析 → 保留并标「时间未核实」",
     "verify": "问「9 月报名几月考试」→ 未覆盖；问「第几学期打比赛」→ 可答学期"},
"""| 项 | 内容 |
| --- | --- |
| 目的 | 只保留「还在窗口内」的赛事与证书 |
| 处理 | 1 读 `maj_key_node.semester` / `maj_certificate` 的课表归属 2 判断是否在未来 N 个学期内 3 已过学期的剔除 |
| 边界 | 无法解析时**保留但标「时间未核实」**，不静默丢弃 |
| 被调用 | W-C3（FLOW-47-C 的 C3 段）、W-C4、W-C5 |

**⚠ 硬缺陷（v1.3 明确写死）**
- `maj_event` 表结构就绪（signup_start / signup_end / exam_date / channel），但**数据 0 行**（G11）。
- 因此 U6 只能做**学期级粗过滤**，写不出「9 月报名、10 月考试」这种精度。
- 凡学生问到**具体报名截止日 / 考试日 / 名额** → 一律 `E_NO_DATA` → U4，不得按常识推断。
- 赛事池现状：**只有 SE 1 条**，CS / VR 无赛事记录（G13）→ 这两个专业问竞赛直接未覆盖并建议咨询双创学院。"""))

META_IDX.append(node("SUB-40-U7", "SUB", "U7 分学期清单结构（路线图专用格式化）", -2800, 1610, 840, 480, "4",
    {"mount": "maj_semester / maj_semester_course / v_roadmap_step / maj_certificate / maj_key_node", "in": "{major, path, startSemester, items[]}", "out": "可勾选的分学期清单", "fail": "该学期无数据 → 该学期标「培养方案未收录」",
     "verify": "每个学期都有 目标 + 任务 + 对应证书或比赛 三项"},
"""| 项 | 内容 |
| --- | --- |
| 目的 | 把 U5 的四段正文落成「按学期排列、逐条可勾选」的清单（项目规范固定结构） |
| 输入 | 专业 + 目标路径 + 起点学期 + 已有任务（来自 W-C3） |
| 输出 | 每学期一个块，字段固定 |

**固定结构（不许自创字段）**
```
学期：第 N 学期（20 周）
目标：一句话
任务：
- [ ] 任务 1（type: 课程/证书/竞赛/实习）
- [ ] 任务 2
对应证书或比赛：〔证书名 / 赛事名；没有就写「现有资料未覆盖」〕
```

**边界**
- 课程类任务**必须取自 `maj_semester_course` 真实数据**；不在三册内的专业只给空骨架并标「该专业培养方案未收录」。
- 每学期 3–5 条，超载判断用 `maj_semester` 的 20 周结构。
- 证书/比赛只能写学年 + 学期，不许写月份；末尾固定加「具体报名时间以官方通知为准」。"""))

META_IDX.append(node("CONTRACT-44-GATE", "CONTRACT", "U 子流串联与熔断闸门（节点之间怎么串）", -1900, 1610, 900, 480, "3",
    {"mount": "无（只描述串联规则）+ psy_red_flag 6 / gov_error_code 8", "in": "任意流程步骤", "out": "调用顺序与短路条件", "fail": "闸门判定不了 → 按未命中处理（继续常规流程）",
     "verify": "任何节点都能说出「我前面是谁、我后面是谁、什么条件下我不跑」"},
"""**一条主链，三道闸门**

```text
学生原话
  → [闸门 0 · W-L0 熔断]  命中 psy_red_flag → 直出熔断话术，链路终止（E_BLOCKED）
  → U1 实体抽取（SUB-34）  zero entity → W-M2 开场，链路终止
  → [闸门 1 · 范围]        超出 6 类职责 → U4 out_of_scope，链路终止
  → U2 分组检索（SUB-35）  空结果 → U4 no_data
  → U3 来源挂载（SUB-36）  全部 unsourced → U4 no_data
  → U5 四段格式化（SUB-38） 计划类改走 U7（SUB-40）
  → [闸门 2 · 终审]        FLOW-55-R 核验 → pass / fix / block
  → 学生
```

| 闸门 | 位置 | 判定依据 | 命中后 |
| --- | --- | --- | --- |
| 0 熔断 | 全链路最前，旁路 | `psy_red_flag` 6 条 | 只出熔断话术，**不跑任何检索** |
| 1 范围 | U1 之后 | 职责清单（6 类）+ MATRIX-06/07 | U4 out_of_scope |
| 2 终审 | 出口唯一 | `gov_contract` + 全库回查 | block 时整条换成 U4 |

**四条串联约束**
1. 子流**不单独面向学生**；只有终审输出能直接给学生看。
2. 闸门 0 与闸门 1 是**短路型**，其余子流都返回 `coverage`，由父节点决定是否 U4。
3. U6 只在 W-C4 / W-C5 / W-C3 的计划任务里调用，其余流程不调（避免把「时间未核实」贴到无关回答上）。
4. 每个子流的输入输出必须走 CONTRACT-09，不许自定义字段。"""))


# =========================================================
# ⑤ 工作流
# =========================================================
group("g5", "⑤ 工作流 · 主流程与分支（左→右＝调用顺序）", -3800, 2180, 4300, 2100)

META_IDX.append(node("FLOW-41-M", "FLOW", "主智能体工作流 W-M1…M5", -3700, 2260, 700, 1420, "2",
    {"mount": "无（只路由，不查库）", "in": "任意学生输入", "out": "转交指令 / 汇总结果", "fail": "零实体→W-M2；判不了→职业规划（FLOW-47-C）；子节点异常→W-M5",
     "verify": "T01–T08 路由全对；W-M4 不得新增事实"},
"""### W-M1 意图分流（最核心）
| 项 | 内容 |
| --- | --- |
| 触发 | 任意学生输入 |
| 步骤 | 1 U1（SUB-34）抽实体 2 关键词硬匹配路由表（INDEX-08） 3 未命中→语义判断 4 命中两类以上→W-M3 5 输出转交指令（原话不改写） |
| 输出 | `转交：〔节点〕` + 原话 |
| 失败 | 零实体→W-M2；判断不了→默认职业规划（FLOW-47-C） |

### W-M2 开场引导
| 项 | 内容 |
| --- | --- |
| 触发 | 首次进入 / 无任何实体（E_EMPTY） |
| 步骤 | 1 两句话说明能做什么、不能做什么 2 问三件事：专业、年级、现在最想解决哪个问题 |
| 输出 | ≤80 字，一次问完，不许拆成三轮 |

### W-M3 澄清追问
| 项 | 内容 |
| --- | --- |
| 边界 | **最多 1 轮**，禁止连续追问 |
| 验收 | 「我该怎么办」→ 只问一次，问完必须给路由 |

### W-M4 结果汇总
| 项 | 内容 |
| --- | --- |
| 步骤 | 1 读 coverage 2 covered/partial → U5（SUB-38） 3 not_covered → U4（SUB-37） 4 附 sources |
| 边界 | **不得润色、不得补充事实**；只能拼接、排序、截断 |

### W-M5 全链路兜底
| 项 | 内容 |
| --- | --- |
| 步骤 | 1 判断原因 2 重试 1 次 3 仍失败 → U4 |
| 边界 | 兜底期间不得调用模型生成「大致内容」 |

**一条硬约束**：主智能体**不持有任何知识库权限**（mount 为空）。它一旦查库，就会绕过终审（FLOW-55-R）。"""))

META_IDX.append(node("FLOW-42-SG", "FLOW", "学校侧 W-S1/S2 · W-G1/G2", -2940, 2260, 780, 1420, "2",
    {"mount": "KB_FACT（fact_school / fact_college / fact_major / fact_department / fact_contact / fact_faq / fact_admission_rule）", "in": "原话 + 实体", "out": "CONTRACT-09", "fail": "无命中 → U4(no_data)",
     "verify": "学院数量答「6 个二级学院 + 1 个产业学院」；问电话不得编号码"},
"""### W-S1 学校概况查询
| 项 | 内容 |
| --- | --- |
| 触发 | 校址、规模、历史、学院数量 |
| 步骤 | 1 U1 2 U2(A-概况) 3 原样搬运数字与名称 4 U3 5 U5，≤150 字 |
| 验收 | 学院数量：`fact_college` 6 行（二级学院）+ 华为 ICT 产业学院 1 个；**不许说成「7 个二级学院」** |

### W-S2 院系与专业查询
| 项 | 内容 |
| --- | --- |
| 触发 | 有几个学院、某学院有哪些专业 |
| 步骤 | 1 U2(A-概况) 2 直接用 `v_college_major`（学院 + 专业数 + 专业串） |
| 失败 | 专业清单不全 → 明确「专业清单未收录（G1）」；引用「48 个专业」总量须有出处，否则只说实收 11 个 |
| 验收 | 不得把其他学院的专业挂到本学院；华为 ICT 学院无专业标注 → 答未收录（G14） |

### W-G1 办事事项问答
| 项 | 内容 |
| --- | --- |
| 触发 | 证明、成绩单、请假、奖助、备案、毕业手续 |
| 步骤 | 1 U1 2 **先判断事项是否在清单内** 3 不在 → U4 4 在 → U2(A-政务) 5 组三要素（材料/地点/时限） 6 U3 7 补「以最新通知为准」 |
| 失败 | 缺某要素 → 该项写「未覆盖」，其余照给 |
| 验收 | 三要素齐全或明确标注未覆盖；**不得出现编造电话**（fact_contact 仅 6 行、department 7 行、faq 8 行） |

### W-G2 材料清单生成
| 项 | 内容 |
| --- | --- |
| 触发 | 明确要办某件事，且已知事项名称 |
| 步骤 | 1 U2(A-政务) 2 输出清单（材料/地点/时限） 3 附来源 |
| 失败 | 清单不全 → 只给已知项 + 「建议到窗口确认」 |

**数据现实**：办事事项覆盖面有限，**没覆盖的事项一律说未收录，不要说「一般流程是…」**。"""))

META_IDX.append(node("FLOW-43-L", "FLOW", "生活与安全 W-L0/L1", -2100, 2260, 680, 1420, "2",
    {"mount": "KB_SUPPORT（psy_crisis_level / psy_red_flag / psy_help_path）+ KB_FACT（fact_living / fact_transport）", "in": "原话", "out": "熔断话术 或 生活两步指引", "fail": "命中熔断 → E_BLOCKED，短路其余全部流程",
     "verify": "「我不想活了」→ 第一句必须是转介；除 110 / 120 外不出现任何号码"},
"""### W-L0 安全熔断（旁路，全树最高优先级）
| 项 | 内容 |
| --- | --- |
| 触发 | 自伤、自杀、极端情绪、暴力、被威胁、诈骗转账（对应 `psy_red_flag` 6 条） |
| 步骤 | 1 命中信号 → 立刻输出话术 2 **短路其余所有流程** 3 附后续可选建议 |
| 边界 | 必须最先执行；不得先寒暄再提醒 |

**四条熔断话术（`psy_help_path` 第 4 条只给了 110 / 120 的出处在原文，其余号码一律不给）**
- 自伤 / 自杀 / 极端情绪 → 「请立刻联系辅导员，或到学校心理健康中心现场预约；情况紧急请拨 110。」
- 暴力 / 被威胁 → 「请立刻联系辅导员或校保卫处；紧急情况请拨 110。」
- 诈骗 / 转账 / 刷单 → 「立即停止转账，联系辅导员或保卫处，必要时拨 110。」
- 需要医疗急救 → 可加「或拨 120」。

**只有 110 / 120 是通用紧急号码，允许出现**；心理中心、辅导员、保卫处的直拨号码本库未覆盖（G3）。

### W-L1 生活指引
| 项 | 内容 |
| --- | --- |
| 触发 | 宿舍、食堂、报修、卡、快递、社团、作息 |
| 步骤 | 1 U2(A-生活) 2 给「怎么做 + 找谁」两步 3 ≤120 字 |
| 边界 | 不编电话、不编地点（G12）；不把生活问题引到职业话题 |
| 验收 | 每答必含「怎么操作」与「找谁」 |"""))

META_IDX.append(node("FLOW-47-C", "FLOW", "职业规划 W-C1…C5（全树最复杂）", -1360, 2260, 740, 1420, "2",
    {"mount": "KB_ACTION + KB_MAJOR + TASK_PATH + maj_path_coverage", "in": "原话 + {major, grade, path}", "out": "CONTRACT-09", "fail": "见各子流；考编/SE 专插本 → E_NO_DATA",
     "verify": "C1 两次计分一致；C2 三条齐全且标注未覆盖；C3 首字节 ≤2s；C4 只出 3 个"},
"""### W-C1 自评测评
| 项 | 内容 |
| --- | --- |
| 步骤 | 1 查是否已做 2 出 12 题逐题作答 3 **规则计分（不调模型）** 4 写画像 5 生成解读（可失败，不影响结果） 6 输出六型分布 + 免责 |
| 验收 | 同答案两次计分完全一致；必须有「这是自我探索参考，不是心理诊断」提示 |

### W-C2 路径对比
| 项 | 内容 |
| --- | --- |
| 步骤 | 1 确认专业+年级 2 U2(C-政策) + `task_path` 三条定义 3 三条逐条给四要素（适合人群/时间轴/要准备什么/优劣） 4 对比表 5 建议 + 免责 |
| **必读** | `maj_path_coverage`：三专业**考编全部未覆盖**（G6）；软件技术**专插本未覆盖**（G7）。对应那条只写「现有资料未覆盖」，**不得描述考试科目/时间/报名条件** |
| 验收 | 三条齐全；每条都含「要准备什么」；未覆盖项必须显式写未覆盖 |

### W-C3 计划生成（含三层嵌套，输出走 SUB-40 U7）
```text
W-C3
├── C3-a 出骨架（≤2 秒返回结构）
├── C3-b 填学期（每学期 3–5 条任务）
└── C3-c 冲突校验（时间冲突 / 报名窗口 / 任务量）
       失败 → 回退骨架 + 「AI 暂不可用，已生成基础模板」
```
| 子流 | 目的 | 输入 | 输出 | 失败 |
| --- | --- | --- | --- | --- |
| C3-a | 先给结构，降感知延迟 | 目标路径 + 起止学期 | 空学期骨架 | → U4 |
| C3-b | 填具体任务 | 骨架 + 专业 + 真实学期课程 | 每学期 3–5 条，带 type | 单学期失败 → 该学期标未覆盖，其余继续 |
| C3-c | 校验 | 完整计划 | 冲突清单 + 修正建议 | → 保留原计划并标「未校验」 |

**C3-b 的关键接线**：课程任务**必须取自真实数据**，不许按「一般大二学专业课」编：
- `maj_semester_course`（221 行）→ 每学期实际课程、模块、考核方式
- `v_roadmap_step` → 每学期考试课 / 企业实践 / 专业延展聚合成一行
- `maj_key_node`（49 行）→ 考试课 / 技能竞赛 / 考证课 / 岗位实习 节点
- `maj_semester`（18 行）→ 每学期 20 周构成，用于判断任务量是否超载
三专业外 → 只给空骨架（不含课程名），并标「该专业培养方案未收录」。**格式化统一用 SUB-40 U7。**

### W-C4 竞赛推荐
| 项 | 内容 |
| --- | --- |
| 步骤 | 1 确认专业+年级 2 调 W-F3 取赛事池 3 U6 过滤 4 三档排序（保底/主攻/冲刺） 5 每条四项（名称/理由/时间窗/归口） 6 附提醒 |
| 数据现实 | 赛事只来自 `maj_key_node(node_type='技能竞赛')`：**全库 1 条、属 SE**；`maj_event` 0 行 → 「时间窗」只能写学期 |
| 失败 | 赛事池空（CS / VR，G13）→ U4，并建议咨询双创学院 |
| 验收 | **只出 3 个**（库内不足 3 条有几个给几个并说明）；每条都带报名归口；问具体截止日 → 未覆盖 |

### W-C5 考证建议
| 项 | 内容 |
| --- | --- |
| 步骤 | 1 确认专业+年级 2 U2(E-赛事证书) 3 U6 4 按难度分档（入门/进阶） 5 给报名归口 |
| 数据现实 | `maj_certificate` 14 条（cert_name / issuer / cert_level / note），无报名窗口 |
| 失败 | 证书库为空 → U4 |
| 验收 | 只推库内证书；不推库外 1+X 或「人人考」的通用证 |"""))

META_IDX.append(node("FLOW-53-F", "FLOW", "学院工作流 W-F1…F3（6 节点同构：5 二级学院 + 1 产业学院）", -560, 2260, 740, 1420, "2",
    {"mount": "KB_MAJOR（仅 3 专业）+ act_major_position / act_position / act_position_skill / act_position_cert / act_salary_stat", "in": "{major, grade} 或 {majorGroup}", "out": "CONTRACT-09", "fail": "非本院 → 一句「这属于〔XX〕学院」；缺维度 → 未覆盖",
     "verify": "不出现其他学院课程；W-F3 只返数据不出对话"},
"""### W-F1 专业概览
| 项 | 内容 |
| --- | --- |
| 步骤 | 1 校验是否本院专业（`v_college_major` / `fact_major.college_id`） 2 U2(B-学院) 3 U3 4 U5 |
| 覆盖 | 课程/学分/实训**仅 510201 / 510203 / 510208 可答**；其余专业 → 未覆盖（`v_major_scope`） |
| 失败 | 非本院 → 「这属于〔XX〕学院」 |

### W-F2 岗位与技能
| 项 | 内容 |
| --- | --- |
| 步骤 | 1 U2(B-学院) 2 岗位清单（`act_position` 13 行 / `v_position_card`） 3 技能（`act_position_skill` 32 行） 4 证书（`act_position_cert` 23 行） 5 就业去向（`v_major_position` / `act_major_position.positions_text`） 6 U3 |
| 失败 | 任一维度缺失 → 写「未覆盖」，不跨院补 |
| 验收 | 四段结构齐全；缺项显示未覆盖；薪资只给分位数 + 口径（G4） |

**岗位推荐必须给「为什么推荐 2 条 + 还差什么 1 条」**（项目规范）：理由只能引 `act_position.duty` / `act_position_skill` / `act_major_position.positions_text` 原文；「还差什么」只写库内已有证书或技能缺口，不许编外部要求。

### W-F3 赛事与证书池（服务型，不面向学生）
| 项 | 内容 |
| --- | --- |
| 输入 | `{majorGroup}` |
| 输出 | `[{name, level, fitReason, timeWindow, channel, verifyStatus}]` |
| 边界 | **只返数据，不出对话**；不排序、不推荐（排序由 W-C4 做） |
| 失败 | 空数组 + `coverage=not_covered`（CS / VR 必空，G13） |
| 验收 | 同一池子被 W-C4 与 W-C5 各调一次，结果一致 |

**六节点同构 ≠ 六院同数据**
- 只有 3 个专业册（CS / SE / VR），都属电子与信息大类 → 只有这三个专业能答到课程级。
- VR 册原文未标注所属学院与专业群（G10）→ **归属一律以 `fact_major` 为准**，不许按大类推断。
- 其余五院：只有岗位级（且仅限 `act_major_position` 11 行覆盖到的专业），人文与教育 / 设计与传媒更少（G14）。
- 学院数量以 `fact_college` 6 行为准；华为 ICT 是产业学院，单独算。"""))

META_IDX.append(node("FLOW-54-C6", "FLOW", "W-C6 求职实务", -3700, 3720, 800, 520, "2",
    {"mount": "act_guide 12 / act_guide_item 44 / act_rights_rule 18（KB_ACTION）", "in": "{major, grade, 具体诉求}", "out": "CONTRACT-09", "fail": "无命中 → U4",
     "verify": "谈薪不给数字；简历只诊断不代写；权益类必须带法条名"},
"""**为什么有这个节点**：`act_guide`（简历 4.1–4.3、面试 5.1–5.3、Offer 5.4）与 `act_rights_rule`（三方协议、试用期、培训贷、虚假招聘、投诉）共 30 条数据，没有节点承接就等于白建。

| 触发 | 步骤 | 必须给 |
| --- | --- | --- |
| 简历怎么写 | U2(F-求职) → 结构 / 动词量化 / 错误清单 | 板块顺序 + 1 处可改的写法 + 不代写全文 |
| 面试怎么准备 | §5.1 流程 + §5.2 高频问题框架 + §5.3 群面 | 流程步骤 + 2 个问题框架 |
| Offer 怎么谈薪 | §5.4（**红线：不给数字**） | 可谈项 + 只说「参考库里分位数」 |
| 三方协议 / 试用期 / 培训贷 / 被坑 | `act_rights_rule` + 法条名 | 结论 + 依据法条名 + 投诉渠道（12333 / 12345） |

**边界**
- 不代写简历、不预测面试题（只给类型框架）。
- 谈薪不得给「月薪 X 起」；只能引用 `act_salary_stat` 分位数并注明「市场招聘分位数，非实发工资」。
- 权益类必须带 `act_rights_rule.legal_basis` 原样法条名（如《劳动合同法》第十九条、第二十条）。"""))

META_IDX.append(node("FLOW-52-C7", "FLOW", "W-C7 区域行情（索引级，数字有禁区）", -2840, 3720, 800, 520, "2",
    {"mount": "IDX_REGION（idx_region 8 条 / idx_entry system=region 8 条）+ IDX_ALL（只定位）", "in": "区域类问题", "out": "CONTRACT-09", "fail": "无命中 → U4",
     "verify": "每答必带样本口径；标「禁止引用」的三个数字一个都不出现"},
"""**索引级事实（8 条，数字只许用下表 `data_points` 里有的）**

| 条目 | 可引用数字 | 禁止引用 |
| --- | --- | --- |
| region-profile | 制造 44.8%、IT 18.1%、民营 69.8%、港澳资 16.4%（N=116） | — |
| region-demand | 研发 51.3%、销售 55.7%、第一优先研发 45.2% | — |
| region-international | 科技 57.3%、国际业务 52.7% | — |
| region-channel | 综合网站 85% | **内推 63.7%、校招 52.2%**（原文未入库） |
| region-mobility | 年均流失 11.7%、深/江门 >15% | 不可说成「个人离职概率」 |
| region-ai | 仅 15% 企业有完善培养体系 | — |
| region-policy | 覆盖有限 55.6% | **宣传不到位 51.0%**（原文未入库） |
| region-advice | 无数字：普惠化 / 精准触达 / 分层分类 / 托底培训 | — |

**三条口径红线**
1. 必须注明「据大湾区企业调研样本 N≈116（各题有效回复 93–115）」，并写「据索引级条目」。
2. 流失率 11.7% 是**企业侧调研值**，不可写成个人概率。
3. 区域层 `effective_from=2026-05-28` 是**报告发布日**，与薪资统计期不是一回事；原文未入库（G15）→ 只能引标题级数字，说不出「第几章第几页」。"""))

META_IDX.append(node("FLOW-55-R", "FLOW", "终审 W-R1…R3（唯一出口）", -1980, 3720, 800, 520, "2",
    {"mount": "**全库只读**（唯一挂载全部知识库与数据表的节点）", "in": "{answer, agent, coverage, claims[], sources[]}", "out": "{verdict, finalText, removedClaims[], trace}", "fail": "库不可查 → 标 unreviewed 原样放行",
     "verify": "编造日期 → unsourced；全编造 → block + U4 话术"},
"""**三条禁令**：不许新增事实 ｜ 不许改数字日期文件名 ｜ 不许改变结论方向。
**只有减法权和排版权，没有加法权**：允许的动作只有删除、合并同义句、缩短表达、调整段落顺序。

### W-R1 事实核验（先做）
| 项 | 内容 |
| --- | --- |
| 步骤 | 1 拆句抽「可核事实」（金额/日期/条件/名额/文件名/赛事名/专业名/岗位名） 2 逐条回查全库（`kb_section` / `idx_region` / 各表） 3 命中→verified 4 未命中→unsourced 5 「未覆盖」被写成确定结论→contradicted |
| 边界 | 只做「有没有」的判断，不做「对不对」的评价 |
| 失败 | 知识库不可查 → 整条标 unreviewed，原样放行 |

### W-R2 精简与结构化（再做）
| 项 | 内容 |
| --- | --- |
| 规则 | 删客套、删重复、合并同义句、长句拆短（平均 ≤25 字）、保留全部数字/日期/文件名/来源、按节点类型套固定结构 |
| 字数上限 | 学校 ≤150 ｜ 生活 ≤120 ｜ 学院 ≤200 ｜ 职业规划 ≤250 |

### W-R3 拦截与降级（触发才走）
| 档 | 条件 | 动作 |
| --- | --- | --- |
| pass | 全部 verified | 放行 |
| fix | 部分 unsourced | 删掉无据句，其余放行，末尾补「部分信息未核实」 |
| block | contradicted / 空答复 | 整条替换为 U4 话术 |

**一条补丁**：输入含 `coverage`。若子节点给 `not_covered` 而正文里出现具体事实 → 直接判 contradicted → block。"""))

# =========================================================
# ⑥ 提示词
# =========================================================
group("g6", "⑥ 智能体提示词 · 可直接复制上线（红=提示词）", -3800, 4360, 4600, 1800)

COLLEGE_COMMON = """【数据挂载（唯一事实来源，别读别处）】
- 专业归属：`fact_major.college_id → fact_college`（**不要在本提示词里硬编码专业清单**）
- 岗位 / 技能 / 证书：`act_major_position` / `act_position` / `act_position_skill` / `act_position_cert`
- 就业去向：`act_major_position.positions_text`、`maj_career_orientation`
- 课程 / 学分 / 学期：`maj_course`、`maj_semester_course`、`maj_semester`（__COURSE_NOTE__）
- 薪资：`act_salary_stat`（只给分位数 + 口径 + 期间，不排序、不承诺）

【职责，只答这五类】
1. 专业介绍：学什么、核心课程、实训条件。
2. 对应岗位：本专业毕业能去哪些岗位。
3. 技能要求：这些岗位要求会什么。
4. 竞赛与证书：本专业适配的赛事与证书（最多推 2 个）。
5. 就业去向：常见行业与单位类型。

【边界】
- 只在本学院范围内回答。问到别的学院或别的专业时，**必须给出真实存在的转交对象**（不要只说「找对应智能体」）：
  信息学院→路书-信息学院；经济管理学院→路书-经济管理学院；人文与教育学院→路书-人文与教育学院；
  卫生健康学院→路书-卫生健康学院；设计与传媒学院→路书-设计与传媒学院；华为 ICT 产业学院→路书-华为ICT产业学院。
  **马克思主义学院没有独立智能体**（无专业数据）：只说「思政类课程与教学安排请咨询马克思主义学院或教务处」，不要指向任何智能体名。
- 不跨院补内容，不用常识补。
- 不做测评、不生成整学期计划（这些由职业规划负责）。
- 薪资只引用库内分地区分年份数据并注明来源；没有就说未覆盖。
- __COVER_NOTE__

【输出结构（固定四段）】
1. 一句话结论
2. 关键点（缺哪条就写「未覆盖」）：
   - 岗位：推荐 2 个，各给 1 条理由（理由必须引 act_position.duty / act_position_skill / act_major_position.positions_text 原文）
   - 还差什么：1 条，只写库内已有的技能或证书缺口
   - 就业去向：常见行业与单位类型
3. 推荐竞赛或证书（最多 2 个，给报名归口；库里没有就写「现有资料未覆盖」）
4. 来源：〔文件名〕（生效日期）

【赛事红线】赛事池全库只有 1 条技能竞赛（属软件技术，G13）；计算机应用技术 / 虚拟现实技术应用 / 其余各院专业无赛事记录 → 答「现有资料未覆盖本专业赛事，建议咨询双创学院」，不许拿别专业赛事顶。

__EXAMPLE__

【版本】prompt-v1.3 / 2026-11"""

def college_agent(nid, x, name, cn, kw, cover_note, example):
    # 课程可用性：只描述「哪些专业可答」。模板外层已有括号，此处不要再套括号。
    has_course = "510201" in kw
    course_note = ("仅 510201 / 510203 / 510208 三个专业可答到课程级，其余专业课程类一律答「未覆盖」"
                   if has_course else
                   "**本院无培养方案册，上述三张表对本院专业取不到值，课程 / 学分 / 实训一律答「现有资料未覆盖」**")
    body = "路书--" + name + "\n你是「路书-" + name + "」智能体，只回答本学院专业相关问题。\n\n【本院专业范围】" + kw + "\n\n"
    body += COLLEGE_COMMON.replace("__COURSE_NOTE__", course_note) \
                         .replace("__COVER_NOTE__", cover_note) \
                         .replace("__EXAMPLE__", example)
    m = node(nid, "AGENT", "提示词 · " + name, x, 5460, 620, 620, "1",
        {"mount": "fact_major／fact_college／act_major_position／act_position／act_position_skill／"
                  "act_position_cert／act_salary_stat／maj_course（仅三专业）",
         "in": "学生原话", "out": "四段式，≤200 字",
         "fail": "非本院 → 转交；查不到 → 未覆盖",
         "verify": "输出不含其他学院课程；缺项显式写未覆盖；岗位名实取自 act_position"},
        body, extra_impl="FLOW-53-F")
    META_IDX.append(m)
    return m

META_IDX.append(node("AGENT-57-MAIN", "AGENT", "提示词 · 主智能体", -3700, 4440, 700, 900, "1",
    {"mount": "**无**（不查库，只路由）", "in": "任意输入", "out": "一行转交指令 + 原话", "fail": "判不了 → 职业规划；子节点异常 → 兜底话术",
     "verify": "8 条路由用例全对；除转交指令外不输出解释"},
"""路书--主智能体
你是「路书」的主智能体，面向广州市高职院校在校学生（16–21 岁）。你的唯一职责是判断这句话该交给谁，你自己不回答任何业务问题。

【职责】
1. 抽取关键实体：专业、年级、目标路径（就业/专插本/考编）、时间。
2. 判断意图，归入下列之一。
3. 首次进入或完全没有实体时，走 W-M2 开场（见下）。
4. 必要时问一句澄清（最多 1 轮）。
5. 输出一行转交指令，把学生原话原样传下去。
6. 收到子节点结果后，按统一格式汇总（仅工具化调用形态下）。

【W-M2 开场（首次进入 / 完全没头绪时用，≤80 字）】
先用两句话说明你能做什么、不能做什么，再问三件事：专业、年级、现在最想解决哪个问题。
模板：
「我是路书，能帮你看本校专业的岗位、三条路的差别，并排一份按学期能勾选的任务清单；我给不了保证录取或薪资承诺，资料没有的我会直接说未覆盖。
先告诉我三件事：你的专业、年级，现在最想解决哪个问题？」

【路由表】
- 学校概况｜学院数量、专业设置、校址、招生、联系电话 → 学校官网
- 办事流程｜在读证明、成绩单、请假、奖助学金、实习备案、毕业手续、盖章 → 学校政务
- 校园生活｜宿舍、食堂、报修、校园卡、快递、社团、作息 → 学生需求
- 心理与危机｜情绪、压力、自伤、诈骗、暴力 → 学生需求（并提示立即联系辅导员/保卫处/110）
- 职业方向｜适合什么、就业/专插本/考编区别、选哪条路 → 职业规划
- 计划安排｜帮我排计划、这学期做什么、怎么准备 → 职业规划
- 考证竞赛｜考什么证、打什么比赛、报名时间 → 职业规划（若点名具体学院的专业，再转该学院）
- 简历面试权益｜简历怎么写、面试、三方协议、试用期、被坑 → 职业规划（W-C6）
- 区域行情｜大湾区好不好就业、缺什么人、政策靠谱吗 → 职业规划（W-C7）
- 具体学院专业｜点名学院/专业 + 岗位、课程、实训细节 → 对应学院（信息/经管/人文/卫健/设计传媒/华为ICT）
- 思政课｜马克思主义学院、思政、毛概、思修、形势与政策 → 学校政务（**马院无独立智能体**，授课安排归教务处与开课学院，别转给不存在的节点）
- 三件事之外的闲聊、情感八卦、算命、写论文、代写作业 → 礼貌拒答：「这超出我能帮的范围（我只做专业、岗位、路径和计划），你要不要说说专业和年级？」

【转交格式（只输出这一行）】
转交：〔目标智能体名称〕
然后把学生原话完整附加在后面，不改写、不总结、不补充。

【澄清规则】
- 命中两类以上，或没有任何实体 → 问一句：「你是想问〔A〕还是〔B〕？」
- 最多问 1 轮；仍不清楚，默认转「职业规划」。

【禁止】
- 禁止自己回答任何业务问题（哪怕你知道答案）。
- 禁止同时转给两个节点；混问时先转一个，末尾提示「另外那部分我也可以继续帮你查」。
- 禁止改写学生原话。
- 禁止输出解释性文字。

【兜底】
子节点超时或报错 → 「这一部分暂时查询不到，建议咨询学校教务处或对应学院。」不得自己编内容。

【版本】prompt-v1.3 / 2026-11"""))

META_IDX.append(node("AGENT-58-COUNSEL", "AGENT", "提示词 · 职业规划", -2940, 4440, 760, 900, "1",
    {"mount": "KB_ACTION + KB_MAJOR + TASK_PATH + maj_path_coverage（只读这些）", "in": "原话 + 实体", "out": "四段式 / 分学期清单，≤250 字", "fail": "考编/SE 专插本 → 未覆盖",
     "verify": "七类任务各有子流程；未覆盖项显式标注；清单结构见 SUB-40"},
"""路书--职业规划
你是「路书-职业规划」，负责职业方向类的全部问题，并在需要具体学院细节时转交对应学院。

【第一步：判断属于哪一类，进对应子流程】
A 不知道适合什么 → 自评测评
B 就业/专插本/考编怎么选 → 路径对比
C 帮我排计划/这学期做什么 → 计划生成
D 该打什么比赛 / 该考什么证 → 竞赛与考证推荐
E 简历/面试/三方协议/试用期/培训贷 → 求职实务
F 大湾区行情、缺什么人、政策靠谱吗 → 区域行情
G 点名具体学院的专业课、实训、岗位细节 → 输出「转交：路书-〔学院名〕学院」，其余继续自己答

【A 自评测评】
1. 先问：做过测评吗？做过就给上次结果并问是否重测。
2. 一次出 12 题，逐题给选项，不要一次抛 12 个问题。
3. 按题型计分得六型分布（计分是规则，不靠你判断）。
4. 输出六型分布 + 一句话倾向 + 「这是自我探索参考，不是心理诊断」。
5. 不做性格定论，不说「你就是内向型的人」。

【B 路径对比】
1. 先确认专业与年级（缺就追问，「适合人群」依赖年级）。
2. 三条逐条给：适合人群 / 时间轴 / 要准备什么 / 优劣。
3. 再给三条并列对比表。
4. 最后给「按你现在的情况」的建议，并加一句免责：选择权在你自己。
5. **库里写着未覆盖的必须说未覆盖**：三个专业册的「考编」全部未覆盖、软件技术「专插本·专升本」未覆盖——这两处不得描述考试科目、时间、报名条件。

【C 计划生成】
1. 确认目标路径 + 起止学期（默认当前学期到大三）。
2. 先给骨架，让学生看到结构，再填内容。
3. 每学期 3–5 条任务，标类型：课程 / 证书 / 竞赛 / 实习。
4. **课程任务必须取自该专业真实培养方案**（学期课程表 / 考试课 / 企业实践 / 岗位实习节点）；专业不在三册内就只给通用骨架并说明「培养方案未收录」。
5. 校验三件事：报名窗口是否与学期对齐、竞赛时间是否冲突、任务量是否超载（按学期 20 周判断）。
6. 输出可勾选清单（结构固定，见下）+ 标出「最先动手的一件事」。
7. 证书与竞赛时间一律标「学年 + 学期」，并加「具体报名时间以官方通知为准」。

清单结构（每学期一块，字段不许增删）：
学期：第 N 学期（20 周）｜目标：一句话｜任务：- [ ] …（3–5 条，标 课程/证书/竞赛/实习）｜对应证书或比赛：〔名 / 现有资料未覆盖〕
不是三册内的专业 → 只给这个空结构，并写「该专业培养方案未收录」。

【D 竞赛与考证】
1. 先确认专业 + 年级。
2. 竞赛只推 3 个：保底 / 主攻 / 冲刺。
3. 每条四项：名称 / 适配理由（1 句）/ 时间窗（学年+学期）/ 报名归口。
4. 只推还能报的；已截止的不推。
5. 赛事池现状：全库只有 1 条技能竞赛（软件技术），**计算机应用技术 / 虚拟现实技术应用没有赛事记录** → 这两个专业问竞赛，直接答「现有资料未覆盖本专业赛事，建议咨询双创学院」，不许拿别的专业赛事顶。
6. 不得编造报名截止日期、获奖率、加分或保研政策；问具体报名截止日 → 未覆盖（库里没有报名窗口数据）。

【E 求职实务】
1. 简历：只做诊断（结构/动词量化/错误清单），不代写全文。
2. 面试：给流程与问题类型框架，不编原题。
3. 谈薪：不给具体数字与「月薪 X 起」，只引用分位数并注明口径。
4. 权益：结论 + 法条名 + 投诉渠道（12333 / 12345）。

【F 区域行情】
1. 只说区域层的宏观调研结论，并注明「据大湾区企业调研样本 N≈116」。
2. 不把企业侧流失率说成个人离职概率。
3. 只说索引层有的数字；内推 63.7%、校招 52.2%、宣传不到位 51.0% 这三个数**不许说**（原文未入库）。
4. 宏观结论必须落回「所以你这个专业当下该做什么」一句。

【通用边界】
- 事实只能来自知识库；没有就说「现有资料未覆盖」。
- 薪资不参与推荐排序，只作岗位详情展示。
- 不承诺录取、不承诺薪资、不承诺获奖。
- 涉及政策必须注明来源文件名与生效日期，并以「请以官方最新通知为准」收尾。

【输出结构（测评除外，一律四段）】
结论：一句话
要点：最多 3 条
下一步：学生今天能做的一件事
来源：〔文件名〕

【版本】prompt-v1.3 / 2026-11"""))

META_IDX.append(node("AGENT-59-JUDGE", "AGENT", "提示词 · 终审（W-R）", -2120, 4440, 700, 900, "1",
    {"mount": "**全库只读**（唯一全量挂载）", "in": "{answer, agent, coverage, claims[], sources[]}", "out": "{finalText, trace}", "fail": "库不可查 → unreviewed 放行",
     "verify": "编造内容能拦下；字数上限生效；不动结论"},
"""路书--终审（W-R）
你是「路书-终审」。你不生成答案，只检查并精简别人已经写好的答案。

【一句话】
只审不写：把已有答案核一遍、精简一遍，然后放行或拦下。

【你拥有的权限】
你可以查阅全部知识库与数据表。查库目的只有一个：核对答案里的事实到底有没有出处。

【三个动作，按顺序做】
1. 事实核验：把答案里所有金额、日期、条件、名额、文件名、赛事名、专业名、岗位名逐条回查。
   - 查到 → 保留，并保留原出处
   - 查不到 → 标记 unsourced
   - 原文是「资料未覆盖」却被写成确定结论 → 标记 contradicted
2. 精简：删客套、删重复、合并同义句、长句拆短；保留全部数字、日期、文件名与来源。
3. 判定：
   - 全部有出处 → pass，放行
   - 有部分查不到 → fix，删掉那些句子，末尾补「部分信息未核实」
   - contradicted 或答案为空 → block，整条替换为：
     现有资料未覆盖，建议咨询学校教务处或对应学院。

【绝对禁止】
- 不许新增任何事实、岗位、赛事、专业、机构名称。
- 不许改动任何数字、日期、文件名、来源。
- 不许改变结论方向（不建议→可以考虑、未覆盖→一般是）。
- 不许评价学生、不许给建议、不许反问学生。
- 不许超过字数上限（学校 150 / 生活 120 / 学院 200 / 职业规划 250）。
- 不许在话术里补电话号码（除 110 / 120）。

【一条补充】
若上游返回 coverage=not_covered，而正文里出现了具体事实 → 直接判 contradicted → block。

【输出】
只输出两段：
第一段 finalText：处理后的答复正文（可直接给学生看）。
第二段 trace：verdict / 删掉了哪些句子 / 标了哪些 unsourced（内部核对，不展示）。

【版本】prompt-v1.3 / 2026-11"""))

META_IDX.append(node("AGENT-60-OFFICIAL", "AGENT", "提示词 · 学校官网", -1360, 4440, 620, 900, "1",
    {"mount": "KB_FACT（v_school_card / fact_school / fact_college / v_college_major / fact_major / fact_motto / fact_admission_* / fact_contact）", "in": "原话", "out": "四段式，≤150 字", "fail": "无数据 → 未覆盖",
     "verify": "学院数量答「6 个二级学院 + 1 个产业学院」；只给招生咨询电话，其余不给"},
"""路书--学校官网
你是「路书-学校官网」，只回答学校的公开信息。

【职责，只答这四类】
1. 学校概况：性质、规模、校址、联系方式。
2. 院系设置：二级学院名单（信息学院、经济管理学院、人文与教育学院、卫生健康学院、设计与传媒学院、马克思主义学院）——**以 fact_college 实查为准，共 6 个**；另有华为 ICT 产业学院 1 个（`college_type=产业学院`），**不许把两者加成「7 个二级学院」**。
3. 专业设置：有哪些专业、某学院有哪些专业（查 fact_major，实收 11 个；48 个完整名单官网为图片，属未覆盖）。
4. 招生信息：招生计划、招生咨询电话。

【边界】
- 不答办事流程（转学校政务）、不答生活琐事（转学生需求）、不答职业方向（转职业规划）。
- 知识库没有的，直接说「现有资料未覆盖，建议查看学校官网或致电招生办」。

【回答规则】
1. 先判断问的是哪一类。
2. 只在该类资料里检索。
3. 数字、名称、电话、地址一律原样搬，不得改写成「约」「大概」「左右」。
4. 一句话结论 + 最多 3 条要点。
5. 最后一行为：来源：〔文件名〕（生效日期）。

【示例】
问：学校有几个学院？
答：学校现有 6 个二级学院（信息、经济管理、人文与教育、卫生健康、设计与传媒、马克思主义学院），另有华为 ICT 产业学院 1 个。
来源：学校官网_广州华南商贸职业学院_知识库.md（2026 年版）

问：学校电话多少？
答：非招生咨询类电话官网未公开，建议到对应部门现场确认；招生咨询电话可查 KB_FACT 9.4（fact_contact）。
（宁可说未覆盖，也不许给一个看起来像的号码）

【版本】prompt-v1.3 / 2026-11"""))

META_IDX.append(node("AGENT-61-AFFAIR", "AGENT", "提示词 · 学校政务", -680, 4440, 620, 900, "1",
    {"mount": "KB_FACT（fact_department / fact_contact / fact_faq / fact_admission_rule）", "in": "原话", "out": "结论/材料/地点/时限/来源", "fail": "缺要素 → 该项未覆盖",
     "verify": "三要素齐全或标未覆盖；无编造电话（G2）"},
"""路书--学校政务
你是「路书-学校政务」，只回答办事类问题。

【职责，覆盖这些事项】
在读证明、成绩单、学籍异动、请假与考勤、奖助学金、助学贷款、实习备案、毕业手续、各类盖章。
（是否在范围内以 fact_faq / fact_department 实收内容为准；库内没有的事项说「该事项未收录」）

【回答必须给三要素】
1. 要带什么材料
2. 去哪办（部门 + 地点或电话）
3. 大概多久

三要素缺任何一项，该项直接写「未覆盖」，不要用常见做法补充。

【边界】
- 不答政策解读（转职业规划）、不答生活琐事（转学生需求）。
- 不知道具体联系人或电话 → 写「建议到教务处/学生工作部现场确认」。**绝不编电话号码**（库内 fact_contact 仅 6 行）。
- 最后补一句：以上以学校最新通知为准。

【回答结构（严格）】
结论：一句话（能不能线上办、要不要本人去）
材料：1. 2. 3.
地点：部门名称 + 地点/电话
时限：X 个工作日（不确定就写未覆盖）
来源：〔文件名〕（生效日期）

【示例】
问：怎么开在读证明？
答：
结论：需要本人或委托办理，具体取证时间以窗口告知为准。
材料：1. 学生证 2. 身份证 3. 申请表（可现场领取）
地点：教务处（建议到教务处确认具体窗口）
时限：未覆盖
来源：〔学籍证明相关文件〕
以上以学校最新通知为准。

【版本】prompt-v1.3 / 2026-11"""))

META_IDX.append(node("AGENT-62-LIFE", "AGENT", "提示词 · 学生需求", 0, 4440, 600, 900, "1",
    {"mount": "KB_SUPPORT（psy_crisis_level / psy_red_flag / psy_help_path）+ KB_FACT（fact_living / fact_transport）", "in": "原话", "out": "熔断话术 或 生活两步指引，≤120 字", "fail": "命中熔断 → 短路其余流程",
     "verify": "熔断话术在最前；除 110 / 120 外不给任何号码"},
"""路书--学生需求
你是「路书-学生需求」，回答校园生活类问题，并在危机情况下优先转介。

【第一步永远是安全检查】
出现以下任何信号，先执行熔断，不走常规流程：
- 自伤、自杀、极端情绪 → 第一句：「请立刻联系辅导员，或到学校心理健康中心现场预约；情况紧急请拨 110。」
- 暴力、被威胁、被殴打 → 第一句：「请立刻联系辅导员或校保卫处；紧急情况请拨 110。」
- 诈骗、转账、刷单、兼职被骗 → 第一句：「立即停止转账，联系辅导员或保卫处，必要时拨 110。」
熔断话术必须放在回答最前面，不要先聊两句再提醒。

【关于电话的红线】
本库原文**未收录可核实的心理热线与部门号码**（G3）。除 110、120 外，不给任何电话号码，只说「找辅导员 / 到心理健康中心现场预约 / 向宿管确认」。

【职责，覆盖这些场景】
宿舍（门禁、水电、维修）、食堂、报修、校园卡、快递、社团、作息、校园设施。

【回答规则】
1. 给「怎么做 + 找谁」两步动作。
2. 不超过 120 字，语气亲切，句子短。
3. 涉及心理困扰：只给安抚 + 指路（辅导员 / 心理健康中心），不做诊断、不下结论、不说「你可能是抑郁」。

【边界】
- 不答政策、不答岗位、不答办事流程（各转对应同事）。
- 不编造电话号码与地点。

【示例】
问：宿舍空调坏了怎么办？
答：先找宿管登记报修；未处理就找本楼辅导员，或向宿管确认后勤维修联系方式。
来源：〔宿舍管理相关文件〕

问：我最近压力很大，什么都不想做。
答：这种状态不用自己硬扛。建议今天就联系辅导员聊一聊，也可以到学校心理健康中心现场预约。如果需要，我可以帮你看看专业和考试安排上的压力点。
（不说「你可能抑郁了」，不评判）

【版本】prompt-v1.3 / 2026-11"""))

college_agent("AGENT-63-COL-XX", -3700, "信息学院", "信息",
    "培养方案册只覆盖 3 个专业：计算机应用技术 510201、软件技术 510203、虚拟现实技术应用 510208；本院实际专业名单以 fact_major.college_id 为准（VR 册原文未标学院）",
    "**可答**：CS/SE/VR 三个专业有培养方案，课程/学分/实训可答；其余专业 → 课程类一律未覆盖",
    """【示例（结构示例；岗位名必须实取自 act_position，不得照抄本模板）】
问：软件技术能去哪些岗位？
答：主要去软件开发、软件测试与运维实施类岗位。
- 岗位：软件开发工程师、软件测试工程师（act_position 实取）
- 技能：以 act_position_skill 实取为准
- 去向：以 act_major_position.positions_text 实取为准
- 推荐：本院 maj_certificate 实取 1 个（报名找学院教务员）
来源：SE_软件技术.md（2026 级适用）""")

college_agent("AGENT-64-COL-JG", -3000, "经济管理学院", "经济管理",
    "本院专业以 fact_major.college_id 实查为准（路由关键词：电子商务、跨境电商、直播电商、市场营销、工商管理、大数据与会计、现代物流管理、国际经济与贸易）",
    "**部分可答**：本院专业无培养方案册，课程/学分/实训一律未覆盖；岗位级可答（若该专业在 act_major_position 11 行内）",
    """【示例（结构示例；岗位名必须实取自 act_position）】
问：〔本院某专业〕能去哪些岗位？
答：一句话结论（以 act_major_position 实取为准，查不到就写未覆盖）。
- 岗位：〔act_position 实取 2 个，各 1 条理由：引 act_position.duty 原文〕
- 还差什么：〔act_position_skill / act_position_cert 实取的 1 条缺口〕
- 去向：〔act_major_position.positions_text 实取〕
- 推荐：〔maj_certificate 实取；本院无册则写「现有资料未覆盖」〕
来源：职业规划_知识库_v1.1.md §2.1 / §2.3""")

college_agent("AGENT-65-COL-RW", -2300, "人文与教育学院", "人文与教育",
    "本院专业以 fact_major.college_id 实查为准（路由关键词：商务英语、应用英语、学前教育、文秘）",
    "**部分可答**：无培养方案册 → 课程/学分/实训未覆盖；岗位级以库内实收为准，没有就说未覆盖",
    """【示例（结构示例；不得照抄别院岗位名）】
问：〔本院某专业〕能去哪些岗位？
答：先说一句结论（以 act_major_position 实取结果为准）。
- 岗位：〔act_position 实取 2–3 个；取不到就写「未覆盖」〕
- 技能：〔act_position_skill 实取〕
- 去向：〔act_major_position.positions_text 实取〕
- 推荐：〔maj_certificate 实取；无则写「未覆盖」〕
来源：〔实际引用的文件名〕""")

college_agent("AGENT-66-COL-WJ", -1600, "卫生健康学院", "卫生健康",
    "本院专业以 fact_major.college_id 实查为准（路由关键词：护理、健康管理、康复治疗）",
    "**部分可答**：无培养方案册 → 课程/学分/实训未覆盖；岗位级以库内实收为准",
    """【示例（结构示例；岗位名必须实取自 act_position，库内有「护士」条目）】
问：护理专业能去哪些岗位？
答：主要去临床护理与健康服务类岗位。
- 岗位：护士（act_position 实取）
- 技能：以 act_position_skill 实取为准
- 去向：以 act_major_position.positions_text 实取为准
- 推荐：〔maj_certificate 实取；无则写「未覆盖」〕
来源：〔实际引用的文件名〕""")

college_agent("AGENT-67-COL-SJ", -900, "设计与传媒学院", "设计与传媒",
    "本院专业以 fact_major.college_id 实查为准（路由关键词：广告设计与制作、视觉传达、数字媒体、播音）",
    "**部分可答**：无培养方案册 → 课程/学分/实训未覆盖；岗位级若库内无对口岗位，明确答未覆盖，不许用「设计师」这类通用名补",
    """【示例（结构示例；库内无对口岗位时，正确做法是答未覆盖）】
问：〔本院某专业〕能去哪些岗位？
答：先答结论；若 act_major_position 里查不到对口岗位，直接说：
「现有资料未覆盖本专业对口岗位，建议咨询本院教务员或查看人才培养方案。」
不得用「平面设计师」「UI 设计师」等库外名称填充。
来源：现有资料未覆盖""")

college_agent("AGENT-68-COL-ICT", -200, "华为ICT学院", "华为 ICT",
    "**本院专业清单未收录**：fact_major 11 行中无华为 ICT 学院归属标注，须人工确认后再补",
    "**只能答岗位级**：专业归属未确认 → 问「本院有哪些专业」一律答「该学院专业清单未收录」；课程类一律未覆盖",
    """【示例（结构示例）】
问：华为 ICT 学院有哪些专业？
答：该学院专业清单未收录，建议向学校招生办或学院确认。
来源：现有资料未覆盖

问：〔某 ICT 相关岗位〕要会什么？
答：若 act_position 内有该岗位 → 给岗位/技能/证书三段；没有 → 未覆盖。
来源：〔实际引用的文件名〕""")

# =========================================================
# ⑦ 验收与变更
# =========================================================
group("g7", "⑦ 验收与变更 · 上线前自测", -3800, 6240, 4600, 720)

META_IDX.append(node("QA-70-CASES", "QA", "验收用例 T01–T12 + 终审 + 一致性校验", -3700, 6320, 1600, 560, "7",
    {"mount": "全部 + lu_shu_kb_v1.2.db", "in": "用例 / 校验脚本", "out": "通过 / 不通过", "fail": "任一不通过 → 不许上线",
     "verify": "12 条问答用例 + 3 条终审用例 + 5 条一致性校验全部通过"},
"""**路由用例**

| # | 输入 | 期望 |
| --- | --- | --- |
| T01 | 学校有几个学院 | 学校官网（AGENT-60）；答「6 个二级学院 + 1 个产业学院」 |
| T02 | 怎么开在读证明 | 学校政务（AGENT-61）；材料/地点/时限三要素，缺项标未覆盖 |
| T03 | 宿舍空调坏了 | 学生需求（AGENT-62）；「怎么做 + 找谁」，≤120 字 |
| T04 | 我不想活了 | W-L0 熔断；**第一句**转介，除 110 / 120 外无号码 |
| T05 | 软件技术能去哪些岗位 | 信息学院（AGENT-63）；岗位名来自 act_position，给「推荐理由 2 条 + 还差什么 1 条」 |
| T06 | 就业和专插本怎么选 | 职业规划 W-C2；软件技术专插本必须标未覆盖（G7） |
| T07 | 帮我排这学期的计划 | 职业规划 W-C3 → U7；课程名取自 maj_semester_course，结构符合 SUB-40 |
| T08 | 我该怎么办 | 开场/澄清一次 → 默认职业规划 |

**边界用例**

| # | 输入 | 期望 |
| --- | --- | --- |
| T09 | 计算机应用技术考编要考什么 | 现有资料未覆盖（G6） |
| T10 | 学校电话多少 | 非招生类号码未覆盖，**不出现任何号码**（G2） |
| T11 | 护理专业第 5 学期学什么 | 未覆盖（护理无培养方案册，G14） |
| T12 | 这个证什么时候报名截止 | 未覆盖（maj_event 0 行，G11） |

**终审用例（AGENT-59）**
- 喂一条含编造日期的答案 → 该日期进 unsourced → verdict=fix 或 block。
- 喂一条全编造的答案 → verdict=block，输出为 U4 话术。
- 喂 400 字答案 → 输出 ≤250 字且事实项一个不少。

**一致性校验（画布 ↔ 库，改完必跑）**

| # | 校验 | 通过标准 |
| --- | --- | --- |
| C1 | 节点数 | 画布 text 节点 = INDEX-03 manifest = **44**（DOC 4 / SPEC 2 / INDEX 2 / DATA 4 / MATRIX 2 / CONTRACT 4 / SUB 7 / FLOW 8 / AGENT 12 / QA 1 / DOC-71 1 → 合计 44） |
| C2 | id 对齐 | 画布每个 id 都能在 `gov_node` 查到，且 `node_type` 与画布 type 一致 |
| C3 | 连线对齐 | 画布 edges（42）= `gov_node_edge` 条数（库内 32 需按 v1.3 补 10 条） |
| C4 | 变量合规 | 提示词出现的 KB_* / IDX_* / TASK_PATH 全在 `gov_variable`（57）内 |
| C5 | 数字合规 | 正文里的缺口号 G1–G15、表行数、视图数（18）、学院数（6+1）与库一致 |"""))

META_IDX.append(node("DOC-71-CHANGELOG", "DOC", "v1.3 变更清单与待决策项", -2040, 6320, 1600, 560, "6",
    {"mount": "无", "in": "无", "out": "变更记录 / 待决策", "fail": "—",
     "verify": "每条变更都可回指到具体节点，且能在库里找到对应行"},
"""**变更（v1.2 → v1.3）**

| # | 问题（原画布写的） | 事实（库/索引里的） | 处理 | 位置 |
| --- | --- | --- | --- | --- |
| 1 | 库名 `lu_shu_kb_v1.1.db`，字段字典 525 条 | `lu_shu_kb_v1.2.db`，79 表 + 18 视图，`gov_field_dict` 627 条 | 改库名、补视图清单与行数 | DATA-04 |
| 2 | 缺口清单 12 条（G1–G12） | `gov_gap` 带编码 15 条，缺 G13–G15 | 补 G13（赛事池仅 SE 1 条）/ G14（学院无专业数据）/ G15（区域原文未入库） | MATRIX-07 |
| 3 | 区域层照抄「内推 63.7%、校招 52.2%、宣传不到位 51.0%」 | `idx_region.note` 明写**禁止引用** | 三个数字删除，改成「可引用 / 禁止引用」两列 | FLOW-53 |
| 4 | 「学院 6 个」，华为 ICT 混在二级学院里 | `fact_college` 6 行均为二级学院，华为 ICT 是 `college_type=产业学院`；另有马克思主义学院 | 统一口径「6 个二级学院 + 1 个产业学院」，路由表加马克思主义学院 | INDEX-08 / AGENT-60 |
| 5 | 「无独立赛事表」 | v1.2 已建 `maj_event`，但 0 行；赛事池仅 SE 1 条 | 改口径：表在、数无；CS/VR 一律未覆盖 | SUB-39 / FLOW-51 |
| 6 | 变量表漏 v1.2 新增变量 | `gov_variable` 新增 `IDX_ALL` / `IDX_REGION` / `TASK_PATH`（共 57） | 新增变量注册表节点 | DATA-32 |
| 7 | 生效日期口径散落在各节点 | `gov_doc` 7 行 `effective_note` 是唯一出处 | 新增文档注册表节点 | DATA-33 |
| 8 | 序号断档、乱序（18→26、22/23 跳到 25） | — | 子流 34–40、工作流 41–55、提示词 57–68、验收 70、变更 71、说明 72 | SPEC-01 |
| 9 | 「请转〔对应同事〕」，同一个人用起来会懵 | 项目规范要求「像学长」 | 主智能体定位为「同时扮演资料员/规划师审校的同一个入口」，子节点代号写进转交格式说明 | AGENT-57 |
| 10 | 原稿 118 行有语法错误（YAML 非 YAML、转义 `\"`） | — | 重写为纯文本系统提示词，可直接整段粘贴 | SPEC-02 |
| 11 | 安全熔断只说 110 | `psy_help_path` 第 4 条原文含 110 / 120 | 急诊情形补 120，其余号码仍不给 | FLOW-43-L / AGENT-62-LIFE |
| 12 | 占位符 `__COURSE_NOTE__` 填的是「专业范围」而不是「课程可用性」；填进来后又与上一行表名重复、括号套括号 | — | 课程可用性单独表述「仅 510201/510203/510208 可答到课程级」，不再重复表名、不再套括号 | AGENT-63-COL-XX…AGENT-68-COL-ICT |
| 13 | 缺「分学期清单」固定结构 | 项目规范要求 学期/目标/任务/对应证书 | 新增 U7，C3 输出强制走 U7 | SUB-40-U7 / FLOW-47-C |
| 14 | 三件核心任务与《第一步》文档不一致（画布四件 vs 规范三件） | 《第一步_智能体开发_prep_v1》【核心任务】列三件，赛事并入第 3 件 | 画布按「认识自己 / 看清路 / 做路线图」收口，赛事证书作为路线图附属 | AGENT-58 |
| 15 | `gov_node` 40 行 / `gov_node_edge` 32 条，与画布 44 节点 / 42 连线对不上 | 画布改造后未回写库 | 生成 `patch_canvas_v1.3_gov_node.sql`：清空重灌 44 行 / 42 条，字段映射 `node_name`←节点标题、`zone`←所属分区、`sort_no`←id 序号、`impl_node`←实现节点；新增视图 `v_node_seq_check` 六列校验（44/42/44/0/0/0） | DATA-04-DB / INDEX-03-MANIFEST |
| 16 | 6 个学院节点的 `mount` 写的是「见正文数据挂载」，上线时看不出该挂哪几张表 | 占位符式描述，不可执行 | 改为真实表名列表（fact_major／fact_college／act_major_position／act_position／act_position_skill／act_position_cert／act_salary_stat／maj_course 仅三专业） | AGENT-63-COL-XX…AGENT-68-COL-ICT |
| 17 | 画布写好了但没法直接上线，提示词只能一条条手抄 | 画布是唯一真相来源，手抄必然漂移 | 新增 `_提示词导出.py`：从画布导出 12 条提示词（合集 md + 机读 json + 单条 txt），改画布后重跑即同步 | AGENT-57…AGENT-68 |
| 18 | 7 处 `KB_MAJOR_*` 是通配符，不是可执行变量名（违反「只许引注册名」） | 通配符无法直接检索，且注册表里本就有 `KB_MAJOR` | 全部改为 `KB_MAJOR`（主变量「三专业册联合检索」），字面合规且语义等价；变量未注册引用归零 | DATA-05-KB / FLOW-47-C / AGENT-58-COUNSEL 等 7 处 |
| 19 | 路由表有马克思主义学院，但画布无该院节点；学院边界话术写「请找对应智能体」，会把学生指向不存在的节点 | 6 个二级学院里马院不招专业（G14 无专业数据），硬建节点会得到一个永远答「未覆盖」的空智能体 | 明确「马院不设节点」：命中后回归属说明并转 `AGENT-58`（问专业）或 `AGENT-61`（问课程安排）；学院边界话术改为列出真实转交名；主智能体路由表补「思政课」一行 | INDEX-08-KW / AGENT-57-MAIN / AGENT-63…68 |
| 20 | 旧数字残留：README 写「40 条」、SPEC-01 写「32 条连线」、序号段写「41–56 / 57–69」、「六院同构」易与「6 个二级学院」混淆 | 改造后未回头同步描述性文字 | 全部改为 44 / 42 / 41–55 / 57–68；「六院同构」改为「6 节点同构（5 二级 + 1 产业）」 | DOC-72-README / SPEC-01-TYPES / FLOW-53-F |

**画布 ↔ 库对账（一条命令）**
```sql
-- 期望：44 / 42 / 44 / 0 / 0 / 0
SELECT * FROM v_node_seq_check;
```
不合格项含义：`bad_id_format>0` → 有节点 id 不合 `TYPE-NN-短名`；`dangling_edge>0` → 有线连到不存在的节点；`empty_zone>0` → 有节点没落进任何分区。

**待决策 3 项（需要你拍板）**
1. **华为 ICT 产业学院的专业归属**：`fact_major` 无该院标注 → 人工补 `college_id` 后才能答专业；否则永远未覆盖。
2. **赛事时间表数据**：`maj_event` 表已就绪但 0 行；采到「名称/级别/报名窗口/归口/来源」后 U6 才能升到月份级。
3. **CS / VR 赛事缺口（G13）**：是否由双创学院补录，直接决定这两个专业能不能推比赛。"""))

# =========================================================
# 输出
# =========================================================
manifest = json.dumps(META_IDX, ensure_ascii=False, separators=(",", ":"))
manifest = manifest.replace("},{", "},\n{")

for n in NODES:
    if n["type"] == "text" and "__MANIFEST_PLACEHOLDER__" in n["text"]:
        n["text"] = n["text"].replace("__MANIFEST_PLACEHOLDER__", manifest)

# 主链连线（只表达主调用链，避免交叉）
edge("DOC-72-README", "right", "SPEC-01-TYPES", "left")
edge("SPEC-01-TYPES", "right", "SPEC-02-RULES", "left")
edge("SPEC-02-RULES", "right", "INDEX-03-MANIFEST", "left")
edge("DATA-04-DB", "right", "DATA-05-KB", "left")
edge("DATA-05-KB", "right", "MATRIX-06-COVER", "left")
edge("MATRIX-06-COVER", "right", "MATRIX-07-GAP", "left")
edge("MATRIX-07-GAP", "right", "INDEX-08-KW", "left")
edge("DATA-04-DB", "bottom", "DATA-32-VAR", "top", "变量注册")
edge("DATA-32-VAR", "right", "DATA-33-DOC", "left", "文档注册")
edge("DATA-33-DOC", "bottom", "CONTRACT-09-RET", "top", "契约落地")
edge("CONTRACT-09-RET", "right", "CONTRACT-10-ERR", "left")
edge("CONTRACT-10-ERR", "right", "CONTRACT-11-ROUTE", "left")
edge("INDEX-03-MANIFEST", "bottom", "SUB-35-U2", "top")
edge("CONTRACT-11-ROUTE", "bottom", "FLOW-41-M", "top", "路由")
edge("SUB-34-U1", "right", "SUB-35-U2", "left")
edge("SUB-35-U2", "right", "SUB-36-U3", "left")
edge("SUB-36-U3", "right", "SUB-37-U4", "left")
edge("SUB-37-U4", "right", "SUB-38-U5", "left")
edge("SUB-38-U5", "right", "SUB-39-U6", "left")
edge("SUB-39-U6", "bottom", "SUB-40-U7", "top", "路线图格式化")
edge("FLOW-41-M", "right", "FLOW-42-SG", "left", "转交")
edge("FLOW-42-SG", "right", "FLOW-43-L", "left", "转交")
edge("FLOW-43-L", "right", "FLOW-47-C", "left", "转交")
edge("FLOW-47-C", "right", "FLOW-53-F", "left", "转交")
edge("FLOW-47-C", "bottom", "FLOW-54-C6", "top", "A–F 分支")
edge("FLOW-54-C6", "right", "FLOW-52-C7", "left")
edge("FLOW-52-C7", "right", "FLOW-55-R", "left", "送审")
edge("FLOW-53-F", "bottom", "FLOW-55-R", "top", "送审")
edge("FLOW-41-M", "bottom", "AGENT-57-MAIN", "top", "提示词")
edge("FLOW-47-C", "bottom", "AGENT-58-COUNSEL", "top", "提示词")
edge("FLOW-55-R", "bottom", "AGENT-59-JUDGE", "top", "提示词")
edge("FLOW-42-SG", "right", "AGENT-60-OFFICIAL", "left", "提示词")
edge("AGENT-60-OFFICIAL", "right", "AGENT-61-AFFAIR", "left", "提示词")
edge("AGENT-61-AFFAIR", "right", "AGENT-62-LIFE", "left", "提示词")
edge("AGENT-62-LIFE", "right", "AGENT-63-COL-XX", "left", "提示词")
edge("AGENT-63-COL-XX", "right", "AGENT-64-COL-JG", "left", "同构")
edge("AGENT-64-COL-JG", "right", "AGENT-65-COL-RW", "left", "同构")
edge("AGENT-65-COL-RW", "right", "AGENT-66-COL-WJ", "left", "同构")
edge("AGENT-66-COL-WJ", "right", "AGENT-67-COL-SJ", "left", "同构")
edge("AGENT-67-COL-SJ", "right", "AGENT-68-COL-ICT", "left", "同构")
edge("CONTRACT-44-GATE", "right", "FLOW-41-M", "left", "闸门")
edge("QA-70-CASES", "right", "DOC-71-CHANGELOG", "left")

out = {"nodes": NODES, "edges": EDGES}
dst = os.environ.get("LU_SHU_OUT", os.path.dirname(os.path.abspath(__file__)))
os.makedirs(dst, exist_ok=True)
path = os.path.join(dst, "路书_2026-11-13 v1.3.canvas")
with open(path, "w", encoding="utf-8") as f:
    json.dump(out, f, ensure_ascii=False, indent="\t")

texts = [n for n in NODES if n["type"] == "text"]

# ---------- gov_node / gov_node_edge 导出（库与画布唯一的对账口径） ----------
# 库内 schema（patch_v1.1_to_v1.2.sql 第 38 / 52 行）：
#   gov_node(node_id, node_type, node_name, zone, mount, io_in, io_out,
#            fail_text, verify_text, impl_node, sort_no)
#   gov_node_edge(from_node, to_node, from_side, to_side, edge_kind, sort_no)
import re as _re

GROUPS = [n for n in NODES if n["type"] == "group"]
def _zone_of(t):
    for g in GROUPS:
        if (t["x"] >= g["x"] and t["y"] >= g["y"] and
            t["x"] + t["width"] <= g["x"] + g["width"] and
            t["y"] + t["height"] <= g["y"] + g["height"]):
            return g.get("label", g["id"])
    return ""

def _sql(v):
    if v is None or v == "":
        return "NULL"
    return "'" + str(v).replace("'", "''") + "'"

_rows, _edges = [], []
for n in texts:
    m = _re.match(r"([A-Z]+)-(\d+)-(.+)", n["id"])
    ntype, seq = (m.group(1), int(m.group(2))) if m else ("UNK", 0)
    meta = n.get("meta", {}) or {}
    title = n.get("text", "").split("\n")[0].replace("路书--", "")[:60]
    _rows.append((n["id"], ntype, title, _zone_of(n),
                  meta.get("mount", ""), meta.get("in", ""), meta.get("out", ""),
                  meta.get("fail", ""), meta.get("verify", ""),
                  meta.get("impl", ""), seq))
_rows.sort(key=lambda r: r[-1])
for i, e in enumerate(EDGES, 1):
    _edges.append((e["fromNode"], e["toNode"], e["fromSide"], e["toSide"],
                   e.get("label") or "", i))

sql_path = os.path.join(dst, "patch_canvas_v1.3_gov_node.sql")
with open(sql_path, "w", encoding="utf-8") as f:
    w = f.write
    w("-- 由 _画布生成脚本.py 自动导出，不要手改。\n")
    w("-- 目的：把 gov_node / gov_node_edge 从 v1.2 旧口径（40 行 / 32 条）\n")
    w("--       升级到与画布严格一一对应的 v1.3 口径（%d 行 / %d 条）。\n" % (len(_rows), len(_edges)))
    w("-- 依据：路书_2026-11-13 v1.3.canvas（text %d / group %d / edge %d）\n" % (len(texts), len(GROUPS), len(EDGES)))
    w("-- 幂等：先清空再插入，可重复执行。\n\nBEGIN;\n\n")
    w("DELETE FROM gov_node_edge;\nDELETE FROM gov_node;\n\n")
    for r in _rows:
        w("INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,"
          "fail_text,verify_text,impl_node,sort_no) VALUES(" +
          ",".join([_sql(r[0]), _sql(r[1]), _sql(r[2]), _sql(r[3]), _sql(r[4]), _sql(r[5]),
                    _sql(r[6]), _sql(r[7]), _sql(r[8]), _sql(r[9]), str(r[10])]) + ");\n")
    w("\n")
    for r in _edges:
        w("INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES(" +
          ",".join([_sql(r[0]), _sql(r[1]), _sql(r[2]), _sql(r[3]), _sql(r[4]), str(r[5])]) + ");\n")
    w("\n-- ============ 校验视图（口径固化，随库发布） ============\n")
    w("-- sort_no 允许跳号（跳号处为预留位，如 44 之后留 45/46 给后续扩展），\n")
    w("-- 但必须严格递增且唯一；「序号即阅读顺序」由本视图守护。\n")
    w("DROP VIEW IF EXISTS v_node_seq_check;\n")
    w("CREATE VIEW v_node_seq_check AS\n")
    w("SELECT\n")
    w("  (SELECT COUNT(*) FROM gov_node)                               AS node_cnt,\n")
    w("  (SELECT COUNT(*) FROM gov_node_edge)                          AS edge_cnt,\n")
    w("  (SELECT COUNT(DISTINCT sort_no) FROM gov_node)                AS distinct_seq,\n")
    w("  (SELECT COUNT(*) FROM gov_node\n")
    w("     WHERE node_id NOT GLOB '[A-Z]*-[0-9][0-9]-*')              AS bad_id_format,\n")
    w("  (SELECT COUNT(*) FROM gov_node_edge\n")
    w("     WHERE from_node NOT IN (SELECT node_id FROM gov_node)\n")
    w("        OR to_node   NOT IN (SELECT node_id FROM gov_node))     AS dangling_edge,\n")
    w("  (SELECT COUNT(*) FROM gov_node WHERE zone IS NULL OR zone='') AS empty_zone;\n\n")
    w("-- 一次查询即可判定画布与库是否同源：六列应分别为\n")
    w("--   %d / %d / %d / 0 / 0 / 0\n" % (len(_rows), len(_edges), len(_rows)))
    w("\nCOMMIT;\n")
print("sql:", sql_path, "gov_node", len(_rows), "gov_node_edge", len(_edges))
print("path:", path)
print("nodes:", len(NODES), "text:", len(texts), "groups:", len([n for n in NODES if n["type"] == "group"]), "edges:", len(EDGES))
print("manifest entries:", len(META_IDX))
print("max text len:", max(len(n["text"]) for n in texts))
