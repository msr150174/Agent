-- 路书知识库 v1.1 → v1.2 补丁（可重复执行；在 lu_shu_kb_v1.1.db 上跑完即为 v1.2）
-- 生成：由 v1.1 / v1.2 两库逐表对比自动导出，只含差异行
PRAGMA foreign_keys = OFF;
BEGIN;

-- 新表 gov_contract
CREATE TABLE gov_contract (
  contract_ver TEXT NOT NULL,
  field_path   TEXT NOT NULL,
  field_type   TEXT NOT NULL,
  required     INTEGER NOT NULL,
  meaning      TEXT,
  note         TEXT,
  sort_no      INTEGER,
  PRIMARY KEY (contract_ver, field_path)
);
-- 新表 gov_error_code
CREATE TABLE gov_error_code (
  code         TEXT PRIMARY KEY,
  trigger_cond TEXT NOT NULL,
  fixed_text   TEXT NOT NULL,
  u4_reason    TEXT,
  short_circuit INTEGER DEFAULT 0,
  sort_no      INTEGER
);
-- 新表 gov_group
CREATE TABLE gov_group (
  group_code   TEXT PRIMARY KEY,
  group_name   TEXT NOT NULL,
  kb_variable  TEXT NOT NULL,
  tables       TEXT NOT NULL,
  files        TEXT,
  used_by      TEXT,
  node_ref     TEXT,
  note         TEXT
);
-- 新表 gov_node
CREATE TABLE gov_node (
  node_id      TEXT PRIMARY KEY,
  node_type    TEXT NOT NULL,
  node_name    TEXT NOT NULL,
  zone         TEXT,
  mount        TEXT,
  io_in        TEXT,
  io_out       TEXT,
  fail_text    TEXT,
  verify_text  TEXT,
  impl_node    TEXT,
  sort_no      INTEGER
);
-- 新表 gov_node_edge
CREATE TABLE gov_node_edge (
  from_node    TEXT NOT NULL,
  to_node      TEXT NOT NULL,
  from_side    TEXT,
  to_side      TEXT,
  edge_kind    TEXT,
  sort_no      INTEGER,
  PRIMARY KEY (from_node, to_node)
);
-- 新表 gov_route_keyword
CREATE TABLE gov_route_keyword (
  keyword      TEXT NOT NULL,
  college_id   TEXT REFERENCES fact_college(college_id),
  college_name TEXT,
  major_name   TEXT,
  basis        TEXT,
  node         TEXT,
  note         TEXT,
  PRIMARY KEY (keyword, college_name)
);
-- 新表 idx_entry
CREATE TABLE idx_entry (
  entry_id     TEXT PRIMARY KEY,
  system       TEXT NOT NULL,
  doc_id       TEXT REFERENCES gov_doc(doc_id),
  file_name    TEXT,
  section      TEXT,
  title        TEXT NOT NULL,
  category     TEXT,
  topic        TEXT,
  scope        TEXT,
  source_level TEXT,
  source       TEXT,
  effective_from TEXT,
  verified_at  TEXT,
  tags         TEXT,
  related      TEXT,
  kb_variable  TEXT,
  group_code   TEXT REFERENCES gov_group(group_code),
  table_hint   TEXT,
  canvas_node  TEXT,
  entry_version TEXT
);
-- 新表 idx_region
CREATE TABLE idx_region (
  entry_id     TEXT PRIMARY KEY,
  file_name    TEXT NOT NULL,
  title        TEXT NOT NULL,
  category     TEXT,
  topic        TEXT,
  effective_from TEXT,
  source       TEXT,
  data_points  TEXT,
  evidence_level TEXT,
  content_status TEXT,
  canvas_node  TEXT,
  note         TEXT
);
-- 新表 maj_event
CREATE TABLE maj_event (
  event_id     TEXT PRIMARY KEY,
  name         TEXT NOT NULL,
  event_type   TEXT NOT NULL,
  level        TEXT,
  major_group  TEXT,
  signup_start TEXT,
  signup_end   TEXT,
  exam_date    TEXT,
  channel      TEXT,
  source_level TEXT,
  src_id       TEXT REFERENCES gov_source(src_id),
  verified_at  TEXT,
  note         TEXT,
  doc_id       TEXT REFERENCES gov_doc(doc_id)
);

ALTER TABLE act_position ADD COLUMN is_cross_ref INTEGER;
ALTER TABLE fact_college ADD COLUMN college_type TEXT;
ALTER TABLE fact_college ADD COLUMN source_ref TEXT;
ALTER TABLE fact_major ADD COLUMN college_basis TEXT;
ALTER TABLE fact_major ADD COLUMN college_confirmed INTEGER;
ALTER TABLE gov_gap ADD COLUMN gap_code TEXT;
ALTER TABLE gov_gap ADD COLUMN gap_level TEXT;
ALTER TABLE gov_gap ADD COLUMN canvas_ref TEXT;
ALTER TABLE gov_gap ADD COLUMN ref_table TEXT;
ALTER TABLE gov_gap ADD COLUMN ref_id TEXT;
ALTER TABLE maj_path_coverage ADD COLUMN path_code TEXT;

-- gov_contract: 11 行初始数据
INSERT OR REPLACE INTO gov_contract(contract_ver,field_path,field_type,required,meaning,note,sort_no) VALUES('v1.2','agent','string',1,'产生该结果的节点 id（如 FLOW-21-C）','供终审定位上游',1);
INSERT OR REPLACE INTO gov_contract(contract_ver,field_path,field_type,required,meaning,note,sort_no) VALUES('v1.2','coverage','enum',1,'covered / partial / not_covered','三态写死，not_covered 只能走 U4',2);
INSERT OR REPLACE INTO gov_contract(contract_ver,field_path,field_type,required,meaning,note,sort_no) VALUES('v1.2','data','object',1,'结构化结果（可为空对象）','字段由各节点自定，但不得塞原始长文',3);
INSERT OR REPLACE INTO gov_contract(contract_ver,field_path,field_type,required,meaning,note,sort_no) VALUES('v1.2','claims','array<claim>',1,'结论级出处列表（v1.2 起必填）','终审按 claim 回查，粒度必须到句',4);
INSERT OR REPLACE INTO gov_contract(contract_ver,field_path,field_type,required,meaning,note,sort_no) VALUES('v1.2','sources','array<source>',1,'本次引用的文件与生效日期','去重后的文件级清单',5);
INSERT OR REPLACE INTO gov_contract(contract_ver,field_path,field_type,required,meaning,note,sort_no) VALUES('v1.2','error','enum|null',1,'错误码（见 gov_error_code），无错为 null','不许放自由文本',6);
INSERT OR REPLACE INTO gov_contract(contract_ver,field_path,field_type,required,meaning,note,sort_no) VALUES('v1.2','claims[].text','string',1,'一条结论原文','必须能被检索片段命中',7);
INSERT OR REPLACE INTO gov_contract(contract_ver,field_path,field_type,required,meaning,note,sort_no) VALUES('v1.2','claims[].src','string',1,'该结论来源文件名','与 gov_doc.file_name 对齐',8);
INSERT OR REPLACE INTO gov_contract(contract_ver,field_path,field_type,required,meaning,note,sort_no) VALUES('v1.2','claims[].effective_from','string',1,'该来源的生效日期/统计期','照原文口径，不换算',9);
INSERT OR REPLACE INTO gov_contract(contract_ver,field_path,field_type,required,meaning,note,sort_no) VALUES('v1.2','sources[].file','string',1,'文件名','',10);
INSERT OR REPLACE INTO gov_contract(contract_ver,field_path,field_type,required,meaning,note,sort_no) VALUES('v1.2','sources[].effective_from','string',1,'生效日期','',11);
-- gov_error_code: 8 行初始数据
INSERT OR REPLACE INTO gov_error_code(code,trigger_cond,fixed_text,u4_reason,short_circuit,sort_no) VALUES('E_EMPTY','完全无实体（不是错误）','走 W-M2 开场三问，不算错误',NULL,0,1);
INSERT OR REPLACE INTO gov_error_code(code,trigger_cond,fixed_text,u4_reason,short_circuit,sort_no) VALUES('E_NO_GROUP','分组不存在或无权限','这不归我负责，请转〔对应同事〕','out_of_scope',0,2);
INSERT OR REPLACE INTO gov_error_code(code,trigger_cond,fixed_text,u4_reason,short_circuit,sort_no) VALUES('E_NO_DATA','库内无命中','现有资料未覆盖，建议向〔具体部门〕确认','no_data',0,3);
INSERT OR REPLACE INTO gov_error_code(code,trigger_cond,fixed_text,u4_reason,short_circuit,sort_no) VALUES('E_OUT_OF_SCOPE','超出本节点职责','这不归我负责，请转〔对应同事〕','out_of_scope',0,4);
INSERT OR REPLACE INTO gov_error_code(code,trigger_cond,fixed_text,u4_reason,short_circuit,sort_no) VALUES('E_UNSOURCED','结论无出处','删除该句；整条都无据 → 现有资料未覆盖','no_data',0,5);
INSERT OR REPLACE INTO gov_error_code(code,trigger_cond,fixed_text,u4_reason,short_circuit,sort_no) VALUES('E_CONTRADICTED','把「未覆盖」写成确定结论','整条替换为 U4 话术','no_data',0,6);
INSERT OR REPLACE INTO gov_error_code(code,trigger_cond,fixed_text,u4_reason,short_circuit,sort_no) VALUES('E_TIMEOUT','子节点超时','这一部分暂时查询不到，建议咨询学校教务处或对应学院','timeout',0,7);
INSERT OR REPLACE INTO gov_error_code(code,trigger_cond,fixed_text,u4_reason,short_circuit,sort_no) VALUES('E_BLOCKED','命中安全熔断','立即输出熔断话术，短路其余流程','error',1,8);
-- gov_group: 9 行初始数据
INSERT OR REPLACE INTO gov_group(group_code,group_name,kb_variable,tables,files,used_by,node_ref,note) VALUES('A-概况','学校概况（校情/学院/专业/理念/重点专业）','KB_FACT','fact_school,fact_college,fact_major,fact_motto,fact_feature,fact_key_program,fact_training_direction','学校官网_广州华南商贸职业学院_知识库.md','W-S1 / W-S2','DATA-04-DB / INDEX-08-KW','主数据 2026 年版');
INSERT OR REPLACE INTO gov_group(group_code,group_name,kb_variable,tables,files,used_by,node_ref,note) VALUES('A-政务','办事事项（部门/联系方式/问答/录取规则）','KB_FACT','fact_department,fact_contact,fact_faq,fact_admission_rule,fact_leader','学校官网_广州华南商贸职业学院_知识库.md','W-G1 / W-G2','FLOW-19-SG','覆盖有限：faq 8 行 / contact 6 行 / department 7 行');
INSERT OR REPLACE INTO gov_group(group_code,group_name,kb_variable,tables,files,used_by,node_ref,note) VALUES('A-生活','校园生活与交通','KB_FACT','fact_living,fact_transport','学校官网_广州华南商贸职业学院_知识库.md','W-L1','FLOW-20-L','不给地点电话，只给动作');
INSERT OR REPLACE INTO gov_group(group_code,group_name,kb_variable,tables,files,used_by,node_ref,note) VALUES('B-学院','学院专业级内容（培养方案 + 岗位 + 技能 + 薪资）','KB_MAJOR_510201 / KB_MAJOR_510203 / KB_MAJOR_510208','fact_major,maj_major,maj_course,maj_semester,maj_semester_course,maj_certificate,maj_key_node,maj_path_coverage,act_major_position,act_position,act_position_skill,act_position_cert,act_position_major,act_salary_stat','CS/SE/VR 三册 + 职业规划_知识库_v1.1.md','W-F1 / W-F2 / W-F3','FLOW-24-F','v1.2 补入 act_position 等 5 张岗位表（v1.1 分组表漏列，但 W-F2 实际要用）');
INSERT OR REPLACE INTO gov_group(group_code,group_name,kb_variable,tables,files,used_by,node_ref,note) VALUES('C-政策','收费 / 招生通道 / 资助 / 升学 / 路径定义','KB_FACT','fact_tuition,fact_admission_channel,fact_financial_aid,fact_articulation,fact_class_type,task_path','学校官网_广州华南商贸职业学院_知识库.md','W-C2','FLOW-21-C','考编三专业未覆盖，SE 专插本未覆盖');
INSERT OR REPLACE INTO gov_group(group_code,group_name,kb_variable,tables,files,used_by,node_ref,note) VALUES('D-区域','大湾区区域行情（索引级 8 条）','IDX_REGION','idx_region,idx_entry','A_*.md / C_*.md / E_*.md 共 8 篇（原文未入库）','W-C7','FLOW-23-C7','只到索引级：标题与关键数字可引，细分数字不可编');
INSERT OR REPLACE INTO gov_group(group_code,group_name,kb_variable,tables,files,used_by,node_ref,note) VALUES('E-赛事证书','赛事与证书池','KB_MAJOR_510201 / KB_MAJOR_510203 / KB_MAJOR_510208','maj_certificate,maj_key_node,maj_event','CS/SE/VR 三册 + 职业规划_知识库_v1.1.md','W-C4 / W-C5 / W-F3','SUB-17-U6','技能竞赛仅 1 条（SE）；act_event 结构就绪、数据待采（G11）');
INSERT OR REPLACE INTO gov_group(group_code,group_name,kb_variable,tables,files,used_by,node_ref,note) VALUES('F-求职','简历 / 面试 / 权益','KB_ACTION','act_guide,act_guide_item,act_rights_rule','职业规划_知识库_v1.1.md','W-C6','FLOW-22-C6','谈薪不给数字；权益类必须带法条名');
INSERT OR REPLACE INTO gov_group(group_code,group_name,kb_variable,tables,files,used_by,node_ref,note) VALUES('G-心理','心理安全与熔断','KB_SUPPORT','psy_crisis_level,psy_red_flag,psy_help_path,psy_article,psy_topic,psy_misconception,psy_self_check_dim','心理安全_大学生心理健康安全_知识库.md','W-L0','FLOW-20-L','无心理中心直拨号码；仅 110/120 有原文出处');
-- gov_node: 40 行初始数据
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('DOC-00-README','DOC','画布使用说明','① 协议层','无（只描述本画布）','无','阅读顺序与约定','—','新读者能在 3 分钟内找到「我手上有什么、怎么交接、谁负责哪段」',NULL,1);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('SPEC-01-TYPES','SPEC','节点类型与命名规范','① 协议层','无','无','type 枚举与 id 规则','—','全部节点 id 与 type 均符合本规范',NULL,2);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('SPEC-02-RULES','SPEC','全局铁律（所有节点共用前缀）','① 协议层','无','无','system prompt 前缀','—','任何节点输出都能被这 7 条逐条检验',NULL,3);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('INDEX-03-MANIFEST','DOC','机器可读节点清单（JSON，唯一入口）','① 协议层','无','无','全部节点的结构化清单','—','清单节点数 = 画布 text 节点数；每条 id 与画布节点 id 一致',NULL,4);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('DATA-04-DB','DATA','数据库六层挂载表','② 数据层','lu_shu_kb_v1.2.db','只读查询','结构化事实','库不可查 → E_NO_DATA → U4','每个 FLOW 的 mount 都能在本表找到对应行',NULL,5);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('DATA-05-KB','DATA','知识库文件与生效口径','② 数据层','KB_FACT / KB_ACTION / KB_SUPPORT / KB_MAJOR_* / IDX_REGION / IDX_ALL','只读检索','原文片段 + 文件名 + 生效日期','无命中 → 空数组（不是报错）','任意引用都能回指到文件名与生效日期',NULL,6);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('MATRIX-06-COVER','MATRIX','专业 × 路径覆盖矩阵（写死的回答边界）','② 数据层','maj_major / maj_path_coverage / maj_semester / fact_major（含 college_basis）/ fact_college（含 college_type）/ act_major_position','major','能不能答、能答到哪一层','矩阵外专业 → 岗位级以外一律 E_NO_DATA','三个专业册外的问题不会答出课程名/学分',NULL,7);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('MATRIX-07-GAP','MATRIX','缺口清单 G1–G15（命中即答未覆盖）','② 数据层','gov_gap 28（其中 15 条带 gap_code）/ v_gap_code / maj_data_issue 24','问题','是否属缺口','—','命中任一条不得输出具体数字或名称',NULL,8);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('INDEX-08-KW','DOC','学院—专业—路由关键词表（6 二级学院 + 1 产业学院）','② 数据层','fact_college 6（college_type）/ fact_major 11（college_basis）/ gov_route_keyword 49','原话关键词','学院节点名','未命中 → 语义判断 → 职业规划','6 个二级学院全部可被命中；专业归属以 fact_major 实查为准',NULL,9);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('CONTRACT-09-RET','CONTRACT','统一返回契约 v1.2','③ 契约层','无','各节点输出','父节点可解析的结构','不符合契约 → E_CONTRACT','所有 FLOW/SUB 的输出都能被终审直接消费',NULL,10);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('CONTRACT-10-ERR','CONTRACT','错误码与兜底话术映射','③ 契约层','无','error','U4 四条话术之一','—','8 个错误码各有唯一话术，话术内不含任何具体事实',NULL,11);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('CONTRACT-11-ROUTE','CONTRACT','调用关系与路由决策树','③ 契约层','无','学生原话','目标节点','判不了 → 职业规划','T01–T08 全对（QA-38）',NULL,12);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('SUB-12-U1','SUB','U1 实体抽取','④ 公共子流 U1–U6','无（纯规则 + 词典）','{raw_text}','{major, grade, path, time, missing[]}','E_EMPTY → 父流走 W-M2','「我是电商的大二学生」→ major=电子商务, grade=2, missing 不含 major/grade',NULL,13);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('SUB-13-U2','SUB','U2 分组检索（group → 表 / 文件）','④ 公共子流 U1–U6','见下表','{query, group}','[{chunk, file, seq, effective_from, score}]','E_NO_GROUP → U4','用 B-信息 查「护理」→ 返回 []，且不返回任何护理内容',NULL,14);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('SUB-14-U3','SUB','U3 来源挂载','④ 公共子流 U1–U6','kb_section / gov_doc','{claims[], chunks[]}','{text, claims[], sources[], unsourced[]}','全部 unsourced → E_UNSOURCED → U4','混合输入（一条有据、一条无据）→ 后者必须出现在 unsourced',NULL,15);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('SUB-15-U4','SUB','U4 未覆盖兜底','④ 公共子流 U1–U6','无','{reason}','固定话术','—','四个原因分别触发，话术与 CONTRACT-10 完全一致',NULL,16);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('SUB-16-U5','SUB','U5 四段格式化','④ 公共子流 U1–U6','无','{conclusion, points[], next_action, sources[]}','四段文本','—','points 超过 3 条时截断为 3 条，不扩写',NULL,17);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('SUB-17-U6','SUB','U6 时间窗过滤（有硬缺陷，必读）','④ 公共子流 U1–U6','maj_key_node / maj_certificate','{items[], today, windowMonths=6}','过滤后列表 + 剔除项','时间不可解析 → 保留并标「时间未核实」','喂已截止赛事 → 不在结果里；喂时间模糊的 → 保留并标注',NULL,18);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('FLOW-18-M','FLOW','主智能体工作流 W-M1…M5','⑤ 工作流','无（只路由，不查库）','任意学生输入','转交指令 / 汇总结果','零实体→W-M2；判不了→职业规划；子节点异常→W-M5','T01–T08 路由全对；W-M4 不得新增事实',NULL,19);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('FLOW-19-SG','FLOW','学校侧 W-S1/S2 · W-G1/G2','⑤ 工作流','KB_FACT（fact_school / fact_college / fact_major / fact_department / fact_contact / fact_faq / fact_admission_rule）','原话 + 实体','CONTRACT-09','无命中 → U4(no_data)','学院数量必须答 6 个；问电话无数据 → 未覆盖，不给号码',NULL,20);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('FLOW-20-L','FLOW','生活与安全 W-L0/L1','⑤ 工作流','KB_SUPPORT（psy_crisis_level / psy_red_flag / psy_help_path）+ KB_FACT（fact_living / fact_transport）','原话','熔断话术 或 生活两步指引','命中熔断 → E_BLOCKED，短路其余全部流程','「我不想活了」→ 第一句必须是转介；除 110/120 外不出现任何号码',NULL,21);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('FLOW-21-C','FLOW','职业规划 W-C1…C5（全树最复杂）','⑤ 工作流','KB_ACTION + KB_MAJOR_* + task_path + maj_path_coverage','原话 + {major, grade, path}','CONTRACT-09','见各子流；考编/SE专插本 → E_NO_DATA','C1 两次计分一致；C2 三条齐全且标注未覆盖；C3 首字节 ≤2s；C4 只出 3 个',NULL,22);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('FLOW-24-F','FLOW','学院工作流 W-F1…F3（六院同构）','⑤ 工作流','KB_MAJOR_*(仅 3 专业) + act_major_position / act_position / act_position_skill / act_position_cert','{major, grade} 或 {majorGroup}','CONTRACT-09','非本院 → 一句「这属于〔XX〕学院」；缺维度 → 未覆盖','不出现其他学院课程；W-F3 只返数据不出对话',NULL,23);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('FLOW-22-C6','FLOW','W-C6 求职实务（v1.2 新增）','⑤ 工作流','act_guide 12 / act_guide_item 44 / act_rights_rule 18（KB_ACTION）','{major, grade, 具体诉求}','CONTRACT-09','无命中 → U4','谈薪不给数字；简历只诊断不代写；权益类必须带法条名',NULL,24);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('FLOW-23-C7','FLOW','W-C7 区域行情（v1.2 新增）','⑤ 工作流','IDX_REGION（kb_index system=region，8 篇）','区域类问题','CONTRACT-09','无命中 → U4','每答必带「据大湾区企业调研样本 N≈116」；不把企业侧数据说成个人概率',NULL,25);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('FLOW-25-R','FLOW','终审 W-R1…R3（唯一出口）','⑤ 工作流','**全库只读**（唯一挂载全部知识库与数据表的节点）','{answer, agent, coverage, claims[], sources[]}','{verdict, finalText, removedClaims[], trace}','库不可查 → 标 unreviewed 原样放行','编造日期 → unsourced；全编造 → block + U4 话术',NULL,26);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-26-MAIN','AGENT','提示词 · 主智能体','⑥ 智能体提示词','**无**（不查库，只路由）','任意输入','一行转交指令 + 原话','判不了 → 职业规划；子节点异常 → 兜底话术','8 条路由用例全对；除转交指令外不输出解释',NULL,27);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-27-COUNSEL','AGENT','提示词 · 职业规划','⑥ 智能体提示词','KB_ACTION + KB_MAJOR_* + task_path + maj_path_coverage','原话 + 实体','四段式，≤250 字','考编/SE专插本 → 未覆盖','七类任务各有子流程；未覆盖项显式标注',NULL,28);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-28-JUDGE','AGENT','提示词 · 终审（W-R）','⑥ 智能体提示词','**全库只读**（唯一全量挂载）','{answer, agent, coverage, claims[], sources[]}','{finalText, trace}','库不可查 → unreviewed 放行','编造内容能拦下；字数上限生效；不动结论',NULL,29);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-29-OFFICIAL','AGENT','提示词 · 学校官网','⑥ 智能体提示词','KB_FACT（fact_school / fact_college / fact_major / fact_motto / fact_contact / fact_admission_*）','原话','四段式，≤150 字','无数据 → 未覆盖','学院数量答 6（含马克思主义学院）；只有招生电话可给',NULL,30);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-30-AFFAIR','AGENT','提示词 · 学校政务','⑥ 智能体提示词','KB_FACT（fact_department / fact_contact / fact_faq / fact_admission_rule）','原话','结论/材料/地点/时限/来源','缺要素 → 该项未覆盖','三要素齐全或标未覆盖；无编造电话',NULL,31);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-31-LIFE','AGENT','提示词 · 学生需求','⑥ 智能体提示词','KB_SUPPORT（psy_crisis_level / psy_red_flag / psy_help_path）+ KB_FACT（fact_living / fact_transport）','原话','熔断话术 或 生活两步指引，≤120 字','命中熔断 → 短路其余流程','熔断话术在最前；除 110/120 外不给任何号码',NULL,32);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-32-COL-XX','AGENT','提示词 · 信息学院','⑥ 智能体提示词','见正文数据挂载','学生原话','四段式，≤200 字','非本院 → 转交；查不到 → 未覆盖','输出不含其他学院课程；缺项显式写未覆盖','FLOW-24-F',33);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-33-COL-JG','AGENT','提示词 · 经济管理学院','⑥ 智能体提示词','见正文数据挂载','学生原话','四段式，≤200 字','非本院 → 转交；查不到 → 未覆盖','输出不含其他学院课程；缺项显式写未覆盖','FLOW-24-F',34);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-34-COL-RW','AGENT','提示词 · 人文与教育学院','⑥ 智能体提示词','见正文数据挂载','学生原话','四段式，≤200 字','非本院 → 转交；查不到 → 未覆盖','输出不含其他学院课程；缺项显式写未覆盖','FLOW-24-F',35);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-35-COL-WJ','AGENT','提示词 · 卫生健康学院','⑥ 智能体提示词','见正文数据挂载','学生原话','四段式，≤200 字','非本院 → 转交；查不到 → 未覆盖','输出不含其他学院课程；缺项显式写未覆盖','FLOW-24-F',36);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-36-COL-SJ','AGENT','提示词 · 设计与传媒学院','⑥ 智能体提示词','见正文数据挂载','学生原话','四段式，≤200 字','非本院 → 转交；查不到 → 未覆盖','输出不含其他学院课程；缺项显式写未覆盖','FLOW-24-F',37);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-37-COL-ICT','AGENT','提示词 · 华为ICT产业学院','⑥ 智能体提示词','见正文数据挂载','学生原话','四段式，≤200 字','非本院 → 转交；查不到 → 未覆盖','输出不含其他学院课程；缺项显式写未覆盖','FLOW-24-F',38);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('QA-38-CASES','QA','验收用例 T01–T08 与终审用例','⑦ 验收与变更','全部','用例','通过/不通过','任一不通过 → 不许上线','12 条用例全部通过',NULL,39);
INSERT OR REPLACE INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('DOC-39-CHANGELOG','DOC','v1.2 变更清单与待决策项','⑦ 验收与变更','无','无','变更记录 / 待决策','—','每条变更都可回指到具体节点',NULL,40);
-- gov_node_edge: 32 行初始数据
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('DOC-00-README','SPEC-01-TYPES','right','left','call',1);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('SPEC-01-TYPES','SPEC-02-RULES','right','left','call',2);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('SPEC-02-RULES','INDEX-03-MANIFEST','right','left','call',3);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('DATA-04-DB','DATA-05-KB','right','left','call',4);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('DATA-05-KB','MATRIX-06-COVER','right','left','call',5);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('MATRIX-06-COVER','MATRIX-07-GAP','right','left','call',6);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('MATRIX-07-GAP','INDEX-08-KW','right','left','call',7);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('DATA-05-KB','CONTRACT-09-RET','bottom','top','sequence',8);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('CONTRACT-09-RET','CONTRACT-10-ERR','right','left','call',9);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('CONTRACT-10-ERR','CONTRACT-11-ROUTE','right','left','call',10);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('INDEX-03-MANIFEST','SUB-13-U2','bottom','top','sequence',11);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('CONTRACT-11-ROUTE','FLOW-18-M','bottom','top','sequence',12);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('SUB-12-U1','SUB-13-U2','right','left','call',13);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('SUB-13-U2','SUB-14-U3','right','left','call',14);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('SUB-14-U3','SUB-15-U4','right','left','call',15);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('SUB-15-U4','SUB-16-U5','right','left','call',16);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('SUB-16-U5','SUB-17-U6','right','left','call',17);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-18-M','FLOW-19-SG','right','left','call',18);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-19-SG','FLOW-20-L','right','left','call',19);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-20-L','FLOW-21-C','right','left','call',20);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-21-C','FLOW-24-F','right','left','call',21);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-21-C','FLOW-22-C6','bottom','top','sequence',22);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-22-C6','FLOW-23-C7','right','left','call',23);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-23-C7','FLOW-25-R','right','left','call',24);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-24-F','FLOW-25-R','bottom','top','sequence',25);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-19-SG','FLOW-25-R','bottom','top','sequence',26);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-20-L','FLOW-25-R','bottom','top','sequence',27);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-18-M','AGENT-26-MAIN','bottom','top','sequence',28);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-21-C','AGENT-27-COUNSEL','bottom','top','sequence',29);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-25-R','AGENT-28-JUDGE','bottom','top','sequence',30);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-24-F','AGENT-32-COL-XX','bottom','top','sequence',31);
INSERT OR REPLACE INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('QA-38-CASES','DOC-39-CHANGELOG','right','left','call',32);
-- gov_route_keyword: 49 行初始数据
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('信息','C01','信息学院',NULL,'学院名/别名','AGENT-32-COL-XX','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('计算机应用','C01','信息学院',NULL,'学院名/别名','AGENT-32-COL-XX','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('计应','C01','信息学院',NULL,'学院名/别名','AGENT-32-COL-XX','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('软件','C01','信息学院',NULL,'学院名/别名','AGENT-32-COL-XX','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('网络','C01','信息学院',NULL,'学院名/别名','AGENT-32-COL-XX','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('数媒','C01','信息学院',NULL,'学院名/别名','AGENT-32-COL-XX','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('人工智能','C01','信息学院',NULL,'学院名/别名','AGENT-32-COL-XX','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('AI','C01','信息学院',NULL,'学院名/别名','AGENT-32-COL-XX','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('人工智能技术应用','C01','信息学院','人工智能技术应用',NULL,'AGENT-32-COL-XX','专业名即路由词；归属依据见 basis');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('数字媒体技术','C01','信息学院','数字媒体技术',NULL,'AGENT-32-COL-XX','专业名即路由词；归属依据见 basis');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('计算机应用技术','C01','信息学院','计算机应用技术',NULL,'AGENT-32-COL-XX','专业名即路由词；归属依据见 basis');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('计算机网络技术','C01','信息学院','计算机网络技术',NULL,'AGENT-32-COL-XX','专业名即路由词；归属依据见 basis');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('软件技术','C01','信息学院','软件技术',NULL,'AGENT-32-COL-XX','专业名即路由词；归属依据见 basis');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('经管','C02','经济管理学院',NULL,'学院名/别名','AGENT-33-COL-JG','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('电商','C02','经济管理学院',NULL,'学院名/别名','AGENT-33-COL-JG','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('跨境电商','C02','经济管理学院',NULL,'学院名/别名','AGENT-33-COL-JG','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('直播电商','C02','经济管理学院',NULL,'学院名/别名','AGENT-33-COL-JG','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('会计','C02','经济管理学院',NULL,'学院名/别名','AGENT-33-COL-JG','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('商英','C02','经济管理学院',NULL,'学院名/别名','AGENT-33-COL-JG','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('物流','C02','经济管理学院',NULL,'学院名/别名','AGENT-33-COL-JG','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('国贸','C02','经济管理学院',NULL,'学院名/别名','AGENT-33-COL-JG','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('商务英语','C02','经济管理学院','商务英语',NULL,'AGENT-33-COL-JG','专业名即路由词；归属依据见 basis');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('大数据与会计','C02','经济管理学院','大数据与会计',NULL,'AGENT-33-COL-JG','专业名即路由词；归属依据见 basis');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('电子商务','C02','经济管理学院','电子商务',NULL,'AGENT-33-COL-JG','专业名即路由词；归属依据见 basis');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('人文','C03','人文与教育学院',NULL,'学院名/别名','AGENT-34-COL-RW','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('教育','C03','人文与教育学院',NULL,'学院名/别名','AGENT-34-COL-RW','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('学前','C03','人文与教育学院',NULL,'学院名/别名','AGENT-34-COL-RW','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('文秘','C03','人文与教育学院',NULL,'学院名/别名','AGENT-34-COL-RW','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('应用英语','C03','人文与教育学院',NULL,'学院名/别名','AGENT-34-COL-RW','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('设计','C04','设计与传媒学院',NULL,'学院名/别名','AGENT-36-COL-SJ','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('传媒','C04','设计与传媒学院',NULL,'学院名/别名','AGENT-36-COL-SJ','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('广告','C04','设计与传媒学院',NULL,'学院名/别名','AGENT-36-COL-SJ','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('视觉传达','C04','设计与传媒学院',NULL,'学院名/别名','AGENT-36-COL-SJ','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('播音','C04','设计与传媒学院',NULL,'学院名/别名','AGENT-36-COL-SJ','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('数媒设计','C04','设计与传媒学院',NULL,'学院名/别名','AGENT-36-COL-SJ','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('卫健','C05','卫生健康学院',NULL,'学院名/别名','AGENT-35-COL-WJ','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('中药','C05','卫生健康学院',NULL,'学院名/别名','AGENT-35-COL-WJ','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('药学','C05','卫生健康学院',NULL,'学院名/别名','AGENT-35-COL-WJ','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('健康','C05','卫生健康学院',NULL,'学院名/别名','AGENT-35-COL-WJ','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('康复','C05','卫生健康学院',NULL,'学院名/别名','AGENT-35-COL-WJ','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('中药学','C05','卫生健康学院','中药学',NULL,'AGENT-35-COL-WJ','专业名即路由词；归属依据见 basis');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('护理','C05','卫生健康学院','护理',NULL,'AGENT-35-COL-WJ','专业名即路由词；归属依据见 basis');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('马克思','C06','马克思主义学院',NULL,'学院名/别名','AGENT-26-MAIN','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('思政','C06','马克思主义学院',NULL,'学院名/别名','AGENT-26-MAIN','仅用于路由，不是专业清单');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('华为',NULL,'华为ICT产业学院（云智技术产业学院）',NULL,'官网 7.2/8.2 产业学院（非二级学院）','AGENT-37-COL-ICT','产业学院不属于 3.1 的六个二级学院；专业清单未收录');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('华为ICT',NULL,'华为ICT产业学院（云智技术产业学院）',NULL,'官网 7.2/8.2 产业学院（非二级学院）','AGENT-37-COL-ICT','产业学院不属于 3.1 的六个二级学院；专业清单未收录');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('ICT',NULL,'华为ICT产业学院（云智技术产业学院）',NULL,'官网 7.2/8.2 产业学院（非二级学院）','AGENT-37-COL-ICT','产业学院不属于 3.1 的六个二级学院；专业清单未收录');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('云智技术',NULL,'华为ICT产业学院（云智技术产业学院）',NULL,'官网 7.2/8.2 产业学院（非二级学院）','AGENT-37-COL-ICT','产业学院不属于 3.1 的六个二级学院；专业清单未收录');
INSERT OR REPLACE INTO gov_route_keyword(keyword,college_id,college_name,major_name,basis,node,note) VALUES('通信',NULL,'华为ICT产业学院（云智技术产业学院）',NULL,'官网 7.2/8.2 产业学院（非二级学院）','AGENT-37-COL-ICT','产业学院不属于 3.1 的六个二级学院；专业清单未收录');
-- idx_entry: 25 行初始数据
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('profession-root','profession','ACTION','职业规划_知识库_v1.1.md','（整册）','职业规划知识库总纲（兴趣→专业→岗位→技能/证书→薪资→简历→面试→权益）','综合','综合','学校/珠三角','官方/市场/自建混合','教育部/广东省人社厅/本校招生网/团队整理','2026-06-18','2026-11-03','["职业规划", "岗位", "简历", "面试", "权益", "薪资", "总纲"]','["A_湾区企业人才需求结构.md", "A_受访企业画像.md", "A_国际化人才需求.md", "A_招聘渠道与求职建议.md", "A_人才流动与留存.md", "A_AI浪潮下的人才影响.md", "C_人才政策评价与三大痛点.md", "E_人才发展建议.md"]','KB_ACTION',NULL,NULL,'SPEC-02-RULES','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('profession-schema','profession','ACTION','职业规划_知识库_v1.1.md','§〇','字段与来源等级口径（category / source_level 铁律与红线）','综合','综合','学校/珠三角','自建','路书团队整理','2026-11-03','2026-11-03','["schema", "source_level", "薪资铁律", "红线"]','[]','KB_ACTION',NULL,NULL,'SPEC-02-RULES / CONTRACT-09-RET','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('profession-major-map','profession','ACTION','职业规划_知识库_v1.1.md','§2.1','专业→岗位对照表（本校 11 个代表性专业可投岗位）','专业','专业','学校/珠三角','市场','本校招生网《创新人才培养》','2026-06-18','2026-11-03','["专业对照", "岗位入口", "软件技术", "电商", "护理", "人工智能"]','["A_湾区企业人才需求结构.md", "A_受访企业画像.md"]','KB_ACTION','B-学院','act_major_position,act_position_major','FLOW-24-F / SUB-13-U2','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('profession-job-notes','profession','ACTION','职业规划_知识库_v1.1.md','§2.3','岗位笔记（五段式：做什么/会什么/证书/薪资/对口专业）','岗位','岗位','学校/珠三角','市场/官方混合','本校招生网 + 中国公共招聘网 JD + 广东省人社厅 L3','2026-06-18','2026-11-03','["岗位", "能力", "证书", "薪资", "五段式"]','["A_湾区企业人才需求结构.md", "A_受访企业画像.md", "A_AI浪潮下的人才影响.md", "A_国际化人才需求.md"]','KB_ACTION','B-学院','act_position,act_position_skill,act_position_cert','FLOW-24-F','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('profession-salary','profession','ACTION','职业规划_知识库_v1.1.md','§三','薪资分位数数据表（L3·珠三角制造业 18 岗真实官方统计）','岗位','岗位','珠三角','市场','广东省人社厅《珠三角制造业典型岗位薪酬分位数（2025Q4）》','2025-10-01','2026-11-03','["薪资", "分位数", "L3", "制造业", "质检员", "电工", "焊工", "模具工"]','["A_人才流动与留存.md"]','KB_ACTION','B-学院','act_salary_stat','FLOW-24-F','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('profession-resume-struct','profession','ACTION','职业规划_知识库_v1.1.md','§4.1','简历标准结构（板块顺序）','简历面试','简历面试','全国','自建','路书团队整理（参考高校就业指导中心通用模板）','2026-11-03','2026-11-03','["简历", "结构"]','[]','KB_ACTION','F-求职','act_guide,act_guide_item','FLOW-22-C6','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('profession-resume-action','profession','ACTION','职业规划_知识库_v1.1.md','§4.2','经历描写：动词 + 内容 + 量化结果（强/弱写法）','简历面试','简历面试','全国','自建','路书团队整理','2026-11-03','2026-11-03','["简历", "动词", "量化"]','[]','KB_ACTION','F-求职','act_guide,act_guide_item','FLOW-22-C6','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('profession-resume-err','profession','ACTION','职业规划_知识库_v1.1.md','§4.3','简历常见错误清单（诊断用，不代写）','简历面试','简历面试','全国','自建','路书团队整理','2026-11-03','2026-11-03','["简历", "错误清单"]','[]','KB_ACTION','F-求职','act_guide,act_guide_item','FLOW-22-C6','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('profession-interview-flow','profession','ACTION','职业规划_知识库_v1.1.md','§5.1','面试通用流程（准备→开场→问答→反问→收尾）','简历面试','简历面试','全国','自建','路书团队整理','2026-11-03','2026-11-03','["面试", "流程"]','[]','KB_ACTION','F-求职','act_guide,act_guide_item','FLOW-22-C6','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('profession-interview-qa','profession','ACTION','职业规划_知识库_v1.1.md','§5.2','面试高频问题类型与回答框架（不编原题）','简历面试','简历面试','全国','自建','路书团队整理','2026-11-03','2026-11-03','["面试", "高频问题", "自我介绍", "缺点"]','[]','KB_ACTION','F-求职','act_guide,act_guide_item','FLOW-22-C6','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('profession-interview-group','profession','ACTION','职业规划_知识库_v1.1.md','§5.3','群面 / 无领导小组讨论要点','简历面试','简历面试','全国','自建','路书团队整理','2026-11-03','2026-11-03','["面试", "群面"]','[]','KB_ACTION','F-求职','act_guide,act_guide_item','FLOW-22-C6','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('profession-offer-salary','profession','ACTION','职业规划_知识库_v1.1.md','§5.4','录用通知与薪酬谈判（红线：不给数字）','简历面试','简历面试','全国','自建','路书团队整理','2026-11-03','2026-11-03','["面试", "Offer", "谈薪", "红线"]','["profession-salary", "A_人才流动与留存.md"]','KB_ACTION','F-求职','act_guide,act_salary_stat','FLOW-22-C6','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('profession-triparty','profession','ACTION','职业规划_知识库_v1.1.md','§6.1','三方协议是什么、注意什么','简历面试','简历面试','全国','官方','教育部《普通高等学校毕业生就业工作暂行规定》','2026-11-03','2026-11-03','["权益", "三方协议", "官方"]','[]','KB_ACTION','F-求职','act_rights_rule','FLOW-22-C6','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('profession-probation','profession','ACTION','职业规划_知识库_v1.1.md','§6.2','试用期法律规定（期限 + 工资≥80%）','简历面试','简历面试','全国','官方','《劳动合同法》第十九条、第二十条','2012-12-28','2026-11-03','["权益", "试用期", "劳动合同法", "官方"]','[]','KB_ACTION','F-求职','act_rights_rule','FLOW-22-C6','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('profession-trainloan','profession','ACTION','职业规划_知识库_v1.1.md','§6.3','培训贷陷阱识别','简历面试','简历面试','全国','官方','教育部、银保监会等培训贷风险提示','2026-11-03','2026-11-03','["权益", "培训贷", "陷阱", "官方"]','["A_招聘渠道与求职建议.md"]','KB_ACTION','F-求职','act_rights_rule','FLOW-22-C6','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('profession-fraud','profession','ACTION','职业规划_知识库_v1.1.md','§6.4','虚假招聘与黑中介识别','简历面试','简历面试','全国','官方','人力资源社会保障部招聘陷阱提示','2026-11-03','2026-11-03','["权益", "虚假招聘", "黑中介", "官方"]','["A_招聘渠道与求职建议.md"]','KB_ACTION','F-求职','act_rights_rule','FLOW-22-C6','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('profession-complaint','profession','ACTION','职业规划_知识库_v1.1.md','§6.5','就业权益投诉渠道（12333 / 12345）','简历面试','简历面试','全国','官方','全国人社政务服务热线 12333；政务服务便民热线 12345','2026-11-03','2026-11-03','["权益", "投诉", "12333", "12345", "官方"]','[]','KB_ACTION','F-求职','act_rights_rule','FLOW-22-C6','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('region-profile','region','REGION','A_受访企业画像.md','（整篇）','受访企业画像（行业/所有制结构，N=116）','A','区域市场趋势','粤港澳大湾区','市场','《粤港澳大湾区企业人才现状与发展趋势：2025》','2026-05-28','2026-11-12','["企业画像", "制造44.8%", "IT18.1%", "民营69.8%", "港澳资16.4%"]','["职业规划_知识库_v1.1.md#§2.1", "A_湾区企业人才需求结构.md", "A_国际化人才需求.md"]','IDX_REGION','D-区域','idx_region','FLOW-23-C7','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('region-demand','region','REGION','A_湾区企业人才需求结构.md','（整篇）','湾区企业未来人才需求结构（研发51.3%/销售55.7%，第一优先研发45.2%）','A','岗位','粤港澳大湾区','市场','《粤港澳大湾区企业人才现状与发展趋势：2025》第一/二章','2026-05-28','2026-11-12','["需求结构", "研发", "销售", "技术支撑", "复合人才"]','["职业规划_知识库_v1.1.md#§2.3", "A_受访企业画像.md", "A_AI浪潮下的人才影响.md"]','IDX_REGION','D-区域','idx_region','FLOW-23-C7','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('region-international','region','REGION','A_国际化人才需求.md','（整篇）','湾区企业国际化/跨境人才需求（科技57.3%/国际业务52.7%）','A','岗位（跨境）','粤港澳大湾区','市场','《粤港澳大湾区企业人才现状与发展趋势：2025》1.3','2026-05-28','2026-11-12','["跨境", "国际化", "港澳资", "资格互认"]','["职业规划_知识库_v1.1.md#§2.3", "A_受访企业画像.md", "C_人才政策评价与三大痛点.md"]','IDX_REGION','D-区域','idx_region','FLOW-23-C7','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('region-channel','region','REGION','A_招聘渠道与求职建议.md','（整篇）','企业招聘渠道分布与求职渠道建议（综合网站85%）','A','求职策略','粤港澳大湾区','市场','《粤港澳大湾区企业人才现状与发展趋势：2025》第二章表2-4','2026-05-28','2026-11-12','["招聘渠道", "综合网站85%", "内推", "校招", "渠道组合"]','["职业规划_知识库_v1.1.md#§2.1", "职业规划_知识库_v1.1.md#§三", "职业规划_知识库_v1.1.md#§六", "A_人才流动与留存.md"]','IDX_REGION','D-区域','idx_region','FLOW-23-C7','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('region-mobility','region','REGION','A_人才流动与留存.md','（整篇）','湾区人才流动与留存（年均流失11.7%，深/江门>15%）','A','区域市场趋势','粤港澳大湾区','市场','《粤港澳大湾区企业人才现状与发展趋势：2025》第四章','2026-05-28','2026-11-12','["流失率", "留存", "薪酬竞争力", "深江高流失"]','["职业规划_知识库_v1.1.md#§五.4", "职业规划_知识库_v1.1.md#§六", "A_招聘渠道与求职建议.md"]','IDX_REGION','D-区域','idx_region','FLOW-23-C7','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('region-ai','region','REGION','A_AI浪潮下的人才影响.md','（整篇）','AI 浪潮下的人才影响（仅15%企业有完善培养体系）','A','岗位（技能）','粤港澳大湾区','市场','《粤港澳大湾区企业人才现状与发展趋势：2025》摘要及人才培养章节','2026-05-28','2026-11-12','["AI", "数字复合", "培养体系15%", "职位重组"]','["职业规划_知识库_v1.1.md#§2.3", "E_人才发展建议.md", "C_人才政策评价与三大痛点.md"]','IDX_REGION','D-区域','idx_region','FLOW-23-C7','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('region-policy','region','REGION','C_人才政策评价与三大痛点.md','（整篇）','人才政策评价与企业端三大痛点（覆盖有限55.6%）','C','政策','粤港澳大湾区','市场','《粤港澳大湾区企业人才现状与发展趋势：2025》第五章表5-3','2026-05-28','2026-11-12','["政策", "满意度", "覆盖有限", "宣传不到位", "兑现周期长"]','["职业规划_知识库_v1.1.md#§六", "E_人才发展建议.md", "A_国际化人才需求.md"]','IDX_REGION','D-区域','idx_region','FLOW-23-C7','v1.2');
INSERT OR REPLACE INTO idx_entry(entry_id,system,doc_id,file_name,section,title,category,topic,scope,source_level,source,effective_from,verified_at,tags,related,kb_variable,group_code,table_hint,canvas_node,entry_version) VALUES('region-advice','region','REGION','E_人才发展建议.md','（整篇）','人才发展对策建议（普惠化/精准触达/分层分类/托底培训）','E','政策与对策','粤港澳大湾区','市场','《粤港澳大湾区企业人才现状与发展趋势：2025》第六章 6.1','2026-05-28','2026-11-12','["对策", "普惠政策", "培训券", "技能提升补贴", "环境评分"]','["职业规划_知识库_v1.1.md#§四", "职业规划_知识库_v1.1.md#§五", "职业规划_知识库_v1.1.md#§三", "C_人才政策评价与三大痛点.md", "A_AI浪潮下的人才影响.md"]','IDX_REGION','D-区域','idx_region','FLOW-23-C7','v1.2');
-- idx_region: 8 行初始数据
INSERT OR REPLACE INTO idx_region(entry_id,file_name,title,category,topic,effective_from,source,data_points,evidence_level,content_status,canvas_node,note) VALUES('region-profile','A_受访企业画像.md','受访企业画像（行业 / 所有制结构，N=116）','A','区域市场趋势','2026-05-28','《粤港澳大湾区企业人才现状与发展趋势：2025》','制造 44.8%；IT 18.1%；民营 69.8%；港澳资 16.4%','标题与标签级','原文未入库（仅索引级）','FLOW-23-C7',NULL);
INSERT OR REPLACE INTO idx_region(entry_id,file_name,title,category,topic,effective_from,source,data_points,evidence_level,content_status,canvas_node,note) VALUES('region-demand','A_湾区企业人才需求结构.md','湾区企业未来人才需求结构（研发 51.3% / 销售 55.7%，第一优先研发 45.2%）','A','岗位','2026-05-28','《粤港澳大湾区企业人才现状与发展趋势：2025》','研发 51.3%；销售 55.7%；第一优先研发 45.2%','标题级','原文未入库（仅索引级）','FLOW-23-C7',NULL);
INSERT OR REPLACE INTO idx_region(entry_id,file_name,title,category,topic,effective_from,source,data_points,evidence_level,content_status,canvas_node,note) VALUES('region-international','A_国际化人才需求.md','湾区企业国际化 / 跨境人才需求（科技 57.3% / 国际业务 52.7%）','A','岗位（跨境）','2026-05-28','《粤港澳大湾区企业人才现状与发展趋势：2025》','科技 57.3%；国际业务 52.7%','标题级','原文未入库（仅索引级）','FLOW-23-C7',NULL);
INSERT OR REPLACE INTO idx_region(entry_id,file_name,title,category,topic,effective_from,source,data_points,evidence_level,content_status,canvas_node,note) VALUES('region-channel','A_招聘渠道与求职建议.md','企业招聘渠道分布与求职渠道建议（综合网站 85%）','A','求职策略','2026-05-28','《粤港澳大湾区企业人才现状与发展趋势：2025》','综合网站 85%（内推、校招仅见于标签，无数字）','标题与标签级','原文未入库（仅索引级）','FLOW-23-C7','内推 63.7% / 校招 52.2% 仅见于画布，原文未入库，禁止引用');
INSERT OR REPLACE INTO idx_region(entry_id,file_name,title,category,topic,effective_from,source,data_points,evidence_level,content_status,canvas_node,note) VALUES('region-mobility','A_人才流动与留存.md','湾区人才流动与留存（年均流失 11.7%，深 / 江门 >15%）','A','区域市场趋势','2026-05-28','《粤港澳大湾区企业人才现状与发展趋势：2025》','年均流失 11.7%；深圳 / 江门 >15%','标题级','原文未入库（仅索引级）','FLOW-23-C7','企业侧调研值，不可说成个人离职概率');
INSERT OR REPLACE INTO idx_region(entry_id,file_name,title,category,topic,effective_from,source,data_points,evidence_level,content_status,canvas_node,note) VALUES('region-ai','A_AI浪潮下的人才影响.md','AI 浪潮下的人才影响（仅 15% 企业有完善培养体系）','A','岗位（技能）','2026-05-28','《粤港澳大湾区企业人才现状与发展趋势：2025》','仅 15% 企业有完善培养体系','标题级','原文未入库（仅索引级）','FLOW-23-C7',NULL);
INSERT OR REPLACE INTO idx_region(entry_id,file_name,title,category,topic,effective_from,source,data_points,evidence_level,content_status,canvas_node,note) VALUES('region-policy','C_人才政策评价与三大痛点.md','人才政策评价与企业端三大痛点（覆盖有限 55.6%）','C','政策','2026-05-28','《粤港澳大湾区企业人才现状与发展趋势：2025》','覆盖有限 55.6%（宣传不到位 51.0% 仅见于画布，原文未入库）','标题级','原文未入库（仅索引级）','FLOW-23-C7','51.0% 禁止引用');
INSERT OR REPLACE INTO idx_region(entry_id,file_name,title,category,topic,effective_from,source,data_points,evidence_level,content_status,canvas_node,note) VALUES('region-advice','E_人才发展建议.md','人才发展对策建议（普惠化 / 精准触达 / 分层分类 / 托底培训）','E','政策与对策','2026-05-28','《粤港澳大湾区企业人才现状与发展趋势：2025》','无数字；四类对策','标题级','原文未入库（仅索引级）','FLOW-23-C7',NULL);
-- maj_event: 0 行初始数据

-- act_position: 13 行新增/变更
INSERT OR REPLACE INTO act_position(pos_id,name,group_name,category,source_level,source,source_url,published_at,effective_from,effective_to,applicable_region,applicable_paths,verified_at,data_layer,duty,salary_note,doc_id,is_cross_ref) VALUES('P01','软件开发工程师','信息技术类（软件技术专业群）','岗位','市场','本校招生网《创新人才培养》栏目（课程与就业方向）+ 中国公共招聘网在招 JD','https://nzsw.scbt.edu.cn/html/zsw/zhaoshengzhinan1112/chuangxinrencaipeiyang/index.html','2026-06-18','2026-06-18','2027-06-30','珠三角','[就业]','2026-11-03','L1+L2','这个岗位做什么：参与软件产品的需求分析、模块设计、编码实现与单元测试；维护已有系统、修复缺陷；与产品/测试协作交付版本。','薪资水平：本校无对应 L3 制造业标准岗；广东统计口径下软件业城镇单位平均工资高于制造业，但分位数据待补（见 §七缺口 G-2）。不估算、不承诺。','ACTION',0);
INSERT OR REPLACE INTO act_position(pos_id,name,group_name,category,source_level,source,source_url,published_at,effective_from,effective_to,applicable_region,applicable_paths,verified_at,data_layer,duty,salary_note,doc_id,is_cross_ref) VALUES('P02','软件测试工程师','信息技术类（软件技术专业群）','岗位','市场','本校招生网《创新人才培养》+ 广东省人社厅《珠三角制造业典型岗位薪酬》（质检类口径参照）','https://hrss.gd.gov.cn/gkmlpt/content/4/4855/post_4855116.html','2026-02-11','2025-10-01','2025-12-31','珠三角','[就业]','2026-11-03','L1+L2+L3','这个岗位做什么：设计测试用例、执行功能/接口/回归测试、提交并跟踪缺陷、输出测试报告，保障软件质量（即软件的「质检员」）。','薪资水平：参照同属「质量检验」性质的 L3 数据——2025 年第四季度珠三角制造业质检员 50 分位 7000 元/月、75 分位 8000 元/月；检测员 50 分位 7500 元/月。注：此为制造业质检口径，软件测试属泛 IT 岗位，实际分位待补（见 §七 G-2），此处仅作性质参照，不得直接等同。','ACTION',0);
INSERT OR REPLACE INTO act_position(pos_id,name,group_name,category,source_level,source,source_url,published_at,effective_from,effective_to,applicable_region,applicable_paths,verified_at,data_layer,duty,salary_note,doc_id,is_cross_ref) VALUES('P03','网络运维 / 实施工程师','信息技术类（软件技术专业群）','岗位','市场','本校招生网《创新人才培养》（信息技术类）+ 中国公共招聘网 JD','https://nzsw.scbt.edu.cn/html/zsw/zhaoshengzhinan1112/chuangxinrencaipeiyang/index.html','2026-06-18','2026-06-18','2027-06-30','珠三角','[就业]','2026-11-03','L1+L2','这个岗位做什么：负责企业网络/系统的部署、配置、监控与故障排查；或作为实施工程师到客户现场安装调试软件系统并培训使用。','薪资水平：本校无对应 L3 标准岗，待补（§七 G-2）。不估算。','ACTION',0);
INSERT OR REPLACE INTO act_position(pos_id,name,group_name,category,source_level,source,source_url,published_at,effective_from,effective_to,applicable_region,applicable_paths,verified_at,data_layer,duty,salary_note,doc_id,is_cross_ref) VALUES('P04','电商运营专员','商贸类（电子商务 / 大数据与会计）','岗位','市场','本校招生网《创新人才培养》（智能电商方向）+ 中国公共招聘网 JD','https://nzsw.scbt.edu.cn/html/zsw/zhaoshengzhinan1112/chuangxinrencaipeiyang/index.html','2026-06-18','2026-06-18','2027-06-30','珠三角','[就业]','2026-11-03','L1+L2','这个岗位做什么：负责网店/店铺的日常运营——商品上架、活动策划、流量获取、数据复盘、客户维护，对销售额负责。','薪资水平：本校无对应 L3 标准岗（电商运营不在制造业 18 岗内），待补（§七 G-2）。不估算。','ACTION',0);
INSERT OR REPLACE INTO act_position(pos_id,name,group_name,category,source_level,source,source_url,published_at,effective_from,effective_to,applicable_region,applicable_paths,verified_at,data_layer,duty,salary_note,doc_id,is_cross_ref) VALUES('P05','跨境电商运营','商贸类（电子商务 / 大数据与会计）','岗位','市场','本校招生网《创新人才培养》（外语+数字化+产业方向）+ 中国公共招聘网 JD','https://nzsw.scbt.edu.cn/html/zsw/zhaoshengzhinan1112/chuangxinrencaipeiyang/index.html','2026-06-18','2026-06-18','2027-06-30','粤港澳大湾区','[就业]','2026-11-03','L1+L2','这个岗位做什么：在 Amazon、Shopee、TikTok Shop 等平台运营跨境店铺，负责选品、Listing 优化、海外社媒推广、跨境物流与售后。','薪资水平：待补（§七 G-2）。不估算。','ACTION',0);
INSERT OR REPLACE INTO act_position(pos_id,name,group_name,category,source_level,source,source_url,published_at,effective_from,effective_to,applicable_region,applicable_paths,verified_at,data_layer,duty,salary_note,doc_id,is_cross_ref) VALUES('P06','会计 / 出纳','商贸类（电子商务 / 大数据与会计）','岗位','市场','本校招生网《创新人才培养》（财经商贸类）+ 中国公共招聘网 JD','https://nzsw.scbt.edu.cn/html/zsw/zhaoshengzhinan1112/chuangxinrencaipeiyang/index.html','2026-06-18','2026-06-18','2027-06-30','珠三角','[就业]','2026-11-03','L1+L2','这个岗位做什么：出纳负责现金/银行收支与日记账；会计负责凭证编制、账簿登记、报表出具与税务申报（初级岗位多从助理/出纳做起）。','薪资水平：待补（§七 G-2）。不估算。','ACTION',0);
INSERT OR REPLACE INTO act_position(pos_id,name,group_name,category,source_level,source,source_url,published_at,effective_from,effective_to,applicable_region,applicable_paths,verified_at,data_layer,duty,salary_note,doc_id,is_cross_ref) VALUES('P07','护士','健康类（护理 / 中药学）','岗位','官方','本校招生网《创新人才培养》（护理+中医+康复方向）+ 《护士条例》','https://nzsw.scbt.edu.cn/html/zsw/zhaoshengzhinan1112/chuangxinrencaipeiyang/index.html','2026-06-18','2026-06-18','2027-06-30','全国','[就业]','2026-11-03','L1','这个岗位做什么：在医疗机构从事临床护理、病情观察、用药照护、健康宣教；可在临床护理、慢病调理、老年康养等方向细分。','薪资水平：待补（§七 G-2）。不估算。','ACTION',0);
INSERT OR REPLACE INTO act_position(pos_id,name,group_name,category,source_level,source,source_url,published_at,effective_from,effective_to,applicable_region,applicable_paths,verified_at,data_layer,duty,salary_note,doc_id,is_cross_ref) VALUES('P08','中药调剂员 / 中药学技术岗','健康类（护理 / 中药学）','岗位','市场','本校招生网《创新人才培养》（护理+中医+康复方向）','https://nzsw.scbt.edu.cn/html/zsw/zhaoshengzhinan1112/chuangxinrencaipeiyang/index.html','2026-06-18','2026-06-18','2027-06-30','珠三角','[就业]','2026-11-03','L1+L2','这个岗位做什么：在药店/医院中药房从事饮片调配、煎药、用药指导；或在中药企业做质检、仓储。','薪资水平：待补（§七 G-2）。不估算。','ACTION',0);
INSERT OR REPLACE INTO act_position(pos_id,name,group_name,category,source_level,source,source_url,published_at,effective_from,effective_to,applicable_region,applicable_paths,verified_at,data_layer,duty,salary_note,doc_id,is_cross_ref) VALUES('P09','健康管理师','健康类（护理 / 中药学）','岗位','市场','本校招生网《创新人才培养》（护理+中医+康复方向）','https://nzsw.scbt.edu.cn/html/zsw/zhaoshengzhinan1112/chuangxinrencaipeiyang/index.html','2026-06-18','2026-06-18','2027-06-30','珠三角','[就业]','2026-11-03','L1+L2','这个岗位做什么：在体检中心、康养机构、社区做健康评估、慢病干预、健康宣教与档案建立。','薪资水平：待补（§七 G-2）。不估算。','ACTION',0);
INSERT OR REPLACE INTO act_position(pos_id,name,group_name,category,source_level,source,source_url,published_at,effective_from,effective_to,applicable_region,applicable_paths,verified_at,data_layer,duty,salary_note,doc_id,is_cross_ref) VALUES('P10','质检员（制造业）','制造业技能岗（真实 L3 分位数，供跨专业就业参考）','岗位','市场','广东省人力资源和社会保障厅《珠三角地区制造业热门技能人才典型岗位平均招聘薪酬分位数（2025年第四季度）》','https://hrss.gd.gov.cn/gkmlpt/content/4/4855/post_4855116.html','2026-02-11','2025-10-01','2025-12-31','珠三角','[就业]','2026-11-03','L3','这个岗位做什么：按图纸/标准对原材料、半成品、成品进行检验、判定与记录，放行合格品、隔离不合格品。','薪资水平（真实 L3，2025 Q4 珠三角制造业，单位元/月）：10 分位 5500｜25 分位 6000｜50 分位 7000｜75 分位 8000｜90 分位 9500。即一半质检员月薪在 7000 元及以下。','ACTION',1);
INSERT OR REPLACE INTO act_position(pos_id,name,group_name,category,source_level,source,source_url,published_at,effective_from,effective_to,applicable_region,applicable_paths,verified_at,data_layer,duty,salary_note,doc_id,is_cross_ref) VALUES('P11','电工（制造业）','制造业技能岗（真实 L3 分位数，供跨专业就业参考）','岗位','市场','广东省人力资源和社会保障厅《珠三角地区制造业热门技能人才典型岗位平均招聘薪酬分位数（2025年第四季度）》','https://hrss.gd.gov.cn/gkmlpt/content/4/4855/post_4855116.html','2026-02-11','2025-10-01','2025-12-31','珠三角','[就业]','2026-11-03','L3','这个岗位做什么：负责生产设备、线路的安装、检修、维护与应急抢修，保障用电安全。','薪资水平（真实 L3，2025 Q4 珠三角制造业，元/月）：10 分位 5500｜25 分位 6500｜50 分位 8500｜75 分位 10000｜90 分位 11000。','ACTION',1);
INSERT OR REPLACE INTO act_position(pos_id,name,group_name,category,source_level,source,source_url,published_at,effective_from,effective_to,applicable_region,applicable_paths,verified_at,data_layer,duty,salary_note,doc_id,is_cross_ref) VALUES('P12','焊工（制造业）','制造业技能岗（真实 L3 分位数，供跨专业就业参考）','岗位','市场','广东省人力资源和社会保障厅《珠三角地区制造业热门技能人才典型岗位平均招聘薪酬分位数（2025年第四季度）》','https://hrss.gd.gov.cn/gkmlpt/content/4/4855/post_4855116.html','2026-02-11','2025-10-01','2025-12-31','珠三角','[就业]','2026-11-03','L3','这个岗位做什么：按工艺要求进行金属构件的焊接、切割与修补，确保焊缝质量达标。','薪资水平（真实 L3，2025 Q4 珠三角制造业，元/月）：10 分位 6000｜25 分位 7500｜50 分位 9500｜75 分位 11000｜90 分位 12500。','ACTION',1);
INSERT OR REPLACE INTO act_position(pos_id,name,group_name,category,source_level,source,source_url,published_at,effective_from,effective_to,applicable_region,applicable_paths,verified_at,data_layer,duty,salary_note,doc_id,is_cross_ref) VALUES('P13','模具工（制造业）','制造业技能岗（真实 L3 分位数，供跨专业就业参考）','岗位','市场','广东省人力资源和社会保障厅《珠三角地区制造业热门技能人才典型岗位平均招聘薪酬分位数（2025年第四季度）》','https://hrss.gd.gov.cn/gkmlpt/content/4/4855/post_4855116.html','2026-02-11','2025-10-01','2025-12-31','珠三角','[就业]','2026-11-03','L3','这个岗位做什么：负责模具的设计辅助、加工、装配、调试与维护，支撑产品批量生产。','薪资水平（真实 L3，2025 Q4 珠三角制造业，元/月）：10 分位 6500｜25 分位 7500｜50 分位 9750｜75 分位 13000｜90 分位 15500。','ACTION',1);
-- fact_college: 6 行新增/变更
INSERT OR REPLACE INTO fact_college(college_id,name,note,doc_id,college_type,source_ref) VALUES('C01','信息学院','省级高水平专业群（软件技术专业群）所在学院','FACT','二级学院','官网 3.1 六个二级学院');
INSERT OR REPLACE INTO fact_college(college_id,name,note,doc_id,college_type,source_ref) VALUES('C02','经济管理学院','财经商贸类主体学院','FACT','二级学院','官网 3.1 六个二级学院');
INSERT OR REPLACE INTO fact_college(college_id,name,note,doc_id,college_type,source_ref) VALUES('C03','人文与教育学院','—','FACT','二级学院','官网 3.1 六个二级学院');
INSERT OR REPLACE INTO fact_college(college_id,name,note,doc_id,college_type,source_ref) VALUES('C04','设计与传媒学院','美术与设计类专业所在学院','FACT','二级学院','官网 3.1 六个二级学院');
INSERT OR REPLACE INTO fact_college(college_id,name,note,doc_id,college_type,source_ref) VALUES('C05','卫生健康学院','医药卫生类专业所在学院','FACT','二级学院','官网 3.1 六个二级学院');
INSERT OR REPLACE INTO fact_college(college_id,name,note,doc_id,college_type,source_ref) VALUES('C06','马克思主义学院','思政教学单位','FACT','二级学院','官网 3.1 六个二级学院');
-- fact_major: 11 行新增/变更
INSERT OR REPLACE INTO fact_major(major_name,college_id,major_code,is_key,is_hot,tags,tuition_note,note,doc_id,college_basis,college_confirmed) VALUES('软件技术','C01','510203',1,1,'省级品牌专业、三二分段、省级高水平专业群、报读热门',NULL,'对接广东科技学院软件工程（三二分段）','ACTION','官网 3.1+3.3（软件技术专业群所在学院＝信息学院）',1);
INSERT OR REPLACE INTO fact_major(major_name,college_id,major_code,is_key,is_hot,tags,tuition_note,note,doc_id,college_basis,college_confirmed) VALUES('计算机网络技术','C01',NULL,0,1,'报读热门',NULL,'高水平专业群成员','ACTION','官网 3.1+3.3（高水平专业群成员）',1);
INSERT OR REPLACE INTO fact_major(major_name,college_id,major_code,is_key,is_hot,tags,tuition_note,note,doc_id,college_basis,college_confirmed) VALUES('计算机应用技术','C01','510201',0,1,'校企联合培养、报读热门',NULL,'校企联合培养 24800 元/年','ACTION','官网 3.1+3.3（高水平专业群成员）',1);
INSERT OR REPLACE INTO fact_major(major_name,college_id,major_code,is_key,is_hot,tags,tuition_note,note,doc_id,college_basis,college_confirmed) VALUES('数字媒体技术','C01',NULL,0,1,'学分互认、报读热门',NULL,'学分互认专业','ACTION','官网 3.1+3.3（高水平专业群成员）',1);
INSERT OR REPLACE INTO fact_major(major_name,college_id,major_code,is_key,is_hot,tags,tuition_note,note,doc_id,college_basis,college_confirmed) VALUES('电子商务','C02',NULL,1,1,'省级品牌专业、三二分段、报读热门',NULL,'对接广东科技学院电子商务（三二分段）','ACTION','职业规划册 §2.1（act_major_position）',0);
INSERT OR REPLACE INTO fact_major(major_name,college_id,major_code,is_key,is_hot,tags,tuition_note,note,doc_id,college_basis,college_confirmed) VALUES('大数据与会计','C02',NULL,0,1,'报读热门',NULL,'报读热门','ACTION','职业规划册 §2.1（act_major_position）',0);
INSERT OR REPLACE INTO fact_major(major_name,college_id,major_code,is_key,is_hot,tags,tuition_note,note,doc_id,college_basis,college_confirmed) VALUES('商务英语','C02',NULL,0,0,NULL,NULL,'—','ACTION','职业规划册 §2.1（act_major_position）',0);
INSERT OR REPLACE INTO fact_major(major_name,college_id,major_code,is_key,is_hot,tags,tuition_note,note,doc_id,college_basis,college_confirmed) VALUES('护理','C05',NULL,0,1,'创新班、报读热门',NULL,'创新班 23800 元/年','ACTION','职业规划册 §2.1（act_major_position）',0);
INSERT OR REPLACE INTO fact_major(major_name,college_id,major_code,is_key,is_hot,tags,tuition_note,note,doc_id,college_basis,college_confirmed) VALUES('中药学','C05',NULL,0,1,'报读热门',NULL,'—','ACTION','职业规划册 §2.1（act_major_position）',0);
INSERT OR REPLACE INTO fact_major(major_name,college_id,major_code,is_key,is_hot,tags,tuition_note,note,doc_id,college_basis,college_confirmed) VALUES('人工智能技术应用','C01',NULL,0,0,'校企联合培养',NULL,'校企联合培养 24800 元/年','ACTION','职业规划册 §2.1（act_major_position）',0);
INSERT OR REPLACE INTO fact_major(major_name,college_id,major_code,is_key,is_hot,tags,tuition_note,note,doc_id,college_basis,college_confirmed) VALUES('虚拟现实技术应用',NULL,'510208',0,0,NULL,NULL,'仅见于专业知识库','MAJOR_VR','未标注（VR 册与官网均未标归属）',0);
-- gov_build_log: 6 行新增/变更
INSERT OR REPLACE INTO gov_build_log(log_id,step,detail,ts) VALUES(8,'migrate-v1.2','新增 gov_group 9 / gov_error_code 8 / gov_contract 11 / gov_node 40 / gov_node_edge 32 / gov_route_keyword 50','2026-11-12 14:24:06');
INSERT OR REPLACE INTO gov_build_log(log_id,step,detail,ts) VALUES(9,'fix-v1.2','college_type/basis/path_code/is_cross_ref 已填；gap 15 个编号；idx_entry 25；idx_region 8；变量 +2；规则 +3；禁用 +4','2026-11-12 14:24:43');
INSERT OR REPLACE INTO gov_build_log(log_id,step,detail,ts) VALUES(10,'sync-canvas','gov_node/gov_node_edge 与画布 r2 重新同步','2026-11-12 14:31:15');
INSERT OR REPLACE INTO gov_build_log(log_id,step,detail,ts) VALUES(11,'sync-canvas','gov_node/gov_node_edge 与画布 r2 重新同步','2026-11-12 14:31:25');
INSERT OR REPLACE INTO gov_build_log(log_id,step,detail,ts) VALUES(12,'sync-canvas','gov_node/gov_node_edge 与画布 r2 重新同步','2026-11-12 14:31:53');
INSERT OR REPLACE INTO gov_build_log(log_id,step,detail,ts) VALUES(13,'sync-canvas','gov_node/gov_node_edge 与画布 r2 重新同步','2026-11-12 14:32:17');
-- gov_doc: 1 行新增/变更
INSERT OR REPLACE INTO gov_doc(doc_id,doc_name,layer_code,file_name,kb_variable,doc_version,compiled_date,effective_note,char_len,section_cnt,note) VALUES('REGION','粤港澳大湾区企业人才现状与发展趋势：2025（区域层）','REGION','A_*.md / C_*.md / E_*.md 共 8 篇','IDX_REGION','2025 报告版','2026-11-12','effective_from 2026-05-28＝报告发布日；8 篇原文未入库，仅索引级可用',0,0,'索引级：标题与关键数字可引；原文级不可引，见 G15');
-- gov_field_dict: 103 行新增/变更
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_group','group_code','TEXT','分组代号（检索分组唯一键）','A-概况 / A-政务 / A-生活 / B-学院 / C-政策 / D-区域 / E-赛事证书 / F-求职 / G-心理');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_group','group_name','TEXT','分组中文名','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_group','kb_variable','TEXT','该组对应的知识库主变量','KB_FACT / KB_ACTION / KB_SUPPORT / KB_MAJOR_* / IDX_REGION');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_group','tables','TEXT','该组落到哪些表（逗号分隔）','表名列表');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_group','files','TEXT','该组落到哪些文件','文件名列表');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_group','used_by','TEXT','哪些工作流使用该组','W-S1/W-G1/W-F2/W-C6/W-C7/W-L0 等');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_group','node_ref','TEXT','画布上对应节点','节点 id');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_group','note','TEXT','口径备注','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_error_code','code','TEXT','错误码','E_EMPTY/E_NO_GROUP/E_NO_DATA/E_OUT_OF_SCOPE/E_UNSOURCED/E_CONTRADICTED/E_TIMEOUT/E_BLOCKED');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_error_code','trigger_cond','TEXT','触发条件','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_error_code','fixed_text','TEXT','固定话术（不许改写）','文本，不含任何具体事实');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_error_code','u4_reason','TEXT','对应 U4 的 reason','no_data/out_of_scope/error/timeout/NULL');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_error_code','short_circuit','INTEGER','是否短路其余流程','0 否 / 1 是（仅 E_BLOCKED）');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_error_code','sort_no','INTEGER','展示顺序','整数');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_contract','contract_ver','TEXT','契约版本','v1.2');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_contract','field_path','TEXT','字段路径（支持数组子字段）','agent/coverage/data/claims[]/sources[]/error');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_contract','field_type','TEXT','字段类型','string/enum/object/array<claim>/array<source>');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_contract','required','INTEGER','是否必填','0 否 / 1 是');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_contract','meaning','TEXT','字段含义','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_contract','note','TEXT','口径备注','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_contract','sort_no','INTEGER','字段顺序（程序解析用）','整数');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_node','node_id','TEXT','画布节点 id','{type}-{两位序号}-{短名}');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_node','node_type','TEXT','节点类型','DOC/SPEC/DATA/MATRIX/CONTRACT/SUB/FLOW/AGENT/QA');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_node','node_name','TEXT','节点名称','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_node','zone','TEXT','所属分区','①协议层…⑦验收');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_node','mount','TEXT','挂载的数据源（唯一事实来源）','表名/变量名/「无」');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_node','io_in','TEXT','输入','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_node','io_out','TEXT','输出','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_node','fail_text','TEXT','失败处理','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_node','verify_text','TEXT','验收口径','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_node','impl_node','TEXT','实现的流程节点','节点 id');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_node','sort_no','INTEGER','阅读顺序','整数');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_node_edge','from_node','TEXT','起点节点','节点 id');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_node_edge','to_node','TEXT','终点节点','节点 id');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_node_edge','from_side','TEXT','起点出线方向','right/bottom');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_node_edge','to_side','TEXT','终点入线方向','left/top');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_node_edge','edge_kind','TEXT','连线语义','call 调用 / sequence 同阶段先后');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_node_edge','sort_no','INTEGER','顺序','整数');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_route_keyword','keyword','TEXT','路由关键词（仅用于分流）','专业名/学院别名/产业学院别名');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_route_keyword','college_id','TEXT','所属学院','C01–C06 / NULL（产业学院）');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_route_keyword','college_name','TEXT','学院名称','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_route_keyword','major_name','TEXT','对应专业（别名行为空）','fact_major.major_name / NULL');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_route_keyword','basis','TEXT','关键词依据','学院名/别名、专业名、归属依据');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_route_keyword','node','TEXT','路由到的节点','AGENT-xx');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_route_keyword','note','TEXT','备注（不是专业清单）','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','entry_id','TEXT','索引条目 id','profession-* / region-*');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','system','TEXT','所属系统','profession 学校行动层 / region 湾区区域层');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','doc_id','TEXT','对应文档','ACTION / REGION');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','file_name','TEXT','文件名','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','section','TEXT','章节定位','§2.1 /（整篇）等');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','title','TEXT','条目标题','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','category','TEXT','采集分组（A/C/E）','A/C/E');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','topic','TEXT','统一主题','综合/专业/岗位/证书/简历面试/政策/区域市场趋势/求职策略');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','scope','TEXT','口径范围','学校/珠三角 或 粤港澳大湾区');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','source_level','TEXT','来源等级','官方/市场/自建/混合');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','source','TEXT','来源','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','effective_from','TEXT','生效日期/统计期起始','YYYY-MM-DD');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','verified_at','TEXT','核验日期','YYYY-MM-DD');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','tags','TEXT','标签（JSON 数组）','JSON');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','related','TEXT','跨库跳转（JSON 数组）','JSON');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','kb_variable','TEXT','对应变量','KB_ACTION / IDX_REGION');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','group_code','TEXT','检索分组','gov_group.group_code / NULL');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','table_hint','TEXT','优先查哪些表','表名列表');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','canvas_node','TEXT','画布节点','节点 id');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_entry','entry_version','TEXT','条目版本','v1.2');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_region','entry_id','TEXT','区域条目 id','region-*');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_region','file_name','TEXT','原报告文件名','A_/C_/E_*.md');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_region','title','TEXT','条目标题','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_region','category','TEXT','采集分组','A/C/E');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_region','topic','TEXT','统一主题','区域市场趋势/岗位/政策/求职策略');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_region','effective_from','TEXT','生效日期＝报告发布日','2026-05-28');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_region','source','TEXT','来源报告','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_region','data_points','TEXT','索引级可见的关键数字','文本（只含标题/标签能对上的数字）');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_region','evidence_level','TEXT','证据级别','标题级 / 标题与标签级');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_region','content_status','TEXT','原文状态','原文未入库（仅索引级）');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_region','canvas_node','TEXT','画布节点','FLOW-23-C7');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('idx_region','note','TEXT','禁止引用项等备注','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('maj_event','event_id','TEXT','赛事/证书时间表主键','EV-*');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('maj_event','name','TEXT','名称','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('maj_event','event_type','TEXT','类型','赛事 / 证书');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('maj_event','level','TEXT','级别','国家级/省级/校级');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('maj_event','major_group','TEXT','适用专业群','专业群或专业代码');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('maj_event','signup_start','TEXT','报名开始','YYYY-MM-DD');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('maj_event','signup_end','TEXT','报名截止','YYYY-MM-DD');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('maj_event','exam_date','TEXT','考试/决赛日期','YYYY-MM-DD');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('maj_event','channel','TEXT','报名归口','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('maj_event','source_level','TEXT','来源等级','官方/市场/自建');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('maj_event','src_id','TEXT','来源登记','gov_source.src_id');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('maj_event','verified_at','TEXT','核验日期','YYYY-MM-DD');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('maj_event','note','TEXT','备注','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('maj_event','doc_id','TEXT','来源文档','gov_doc.doc_id');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_gap','gap_code','TEXT','画布缺口编号（与 MATRIX-07 一一对应）','G1–G15 / NULL');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_gap','gap_level','TEXT','缺口层级','事实/专业/支持/行动/区域/结构');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_gap','canvas_ref','TEXT','画布引用位置','节点 id');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_gap','ref_table','TEXT','核对用的表','表名');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_gap','ref_id','TEXT','表内定位值','文本');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('fact_college','college_type','TEXT','学院类型','二级学院 / 产业学院');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('fact_college','source_ref','TEXT','出处','原文节号');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('fact_major','college_basis','TEXT','学院归属依据','官网原文/职业规划册 §2.1/未标注');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('fact_major','college_confirmed','INTEGER','是否原文明确归属','0 推断或未标注 / 1 原文明确');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('maj_path_coverage','path_code','TEXT','路径码（与 task_path 对齐）','PATH-EMP/PATH-UPG/PATH-GOV');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('act_position','is_cross_ref','INTEGER','是否跨专业参考岗位','0 本专业岗 / 1 制造业跨专业参考');
INSERT OR REPLACE INTO gov_field_dict(table_name,field_name,field_type,meaning,domain) VALUES('gov_variable','usage_note','TEXT','调用口径说明','文本');
-- gov_forbidden: 4 行新增/变更
INSERT OR REPLACE INTO gov_forbidden(term,reason) VALUES('KB_REGION / REGION_KB / KB_AREA 与 IDX_REGION 并存','区域层只许一个变量名 IDX_REGION，多名字必然漏检');
INSERT OR REPLACE INTO gov_forbidden(term,reason) VALUES('把「华为 ICT 产业学院」当成第七个二级学院','官网 3.1 明确六个二级学院（含马克思主义学院）；华为 ICT 产业学院是产业学院（7.2 / 8.2）');
INSERT OR REPLACE INTO gov_forbidden(term,reason) VALUES('用「一般大二学专业课」推断课程安排','课程级事实只能来自 maj_* 三册；三册外一律未覆盖');
INSERT OR REPLACE INTO gov_forbidden(term,reason) VALUES('用「设计师 / UI 设计师 / 视觉传达」等库外岗位名填充','act_position 13 行内没有的岗位名一律不许出现');
-- gov_gap: 28 行新增/变更
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-F01','FACT','全库','48 个专业完整名单','待核实','答“现有资料未覆盖”，并指向建议获取方式','查招生网「招生计划」页，或索取当年《招生专业目录》','G1','事实',NULL,NULL,NULL);
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-F02','FACT','全库','省级特色专业名称','官网未公开','答“现有资料未覆盖”，并指向建议获取方式','咨询招生办或查省级认定文件',NULL,'事实',NULL,NULL,NULL);
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-F03','FACT','全库','6 个校级重点专业群名称','官网未公开','答“现有资料未覆盖”，并指向建议获取方式','同上',NULL,'事实',NULL,NULL,NULL);
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-F04','FACT','全库','各专业招生计划数','待核实','答“现有资料未覆盖”，并指向建议获取方式','查分省分专业计划表（图片）',NULL,'事实',NULL,NULL,NULL);
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-F05','FACT','全库','各二级学院的专业与介绍（含人文与教育 / 设计与传媒 / 马克思主义学院无专业数据）','待核实','答“现有资料未覆盖”，并指向建议获取方式','查各学院子站（xxxy/jmxy/yyxy/jkxy/cmxy.scbt.edu.cn）','G14','事实','MATRIX-07 / INDEX-08-KW','fact_major','college_id');
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-F06','FACT','全库','国际项目细节（泰国、新加坡、华为 ICT）','待核实','答“现有资料未覆盖”，并指向建议获取方式','查招生网栏目或咨询招生办',NULL,'事实',NULL,NULL,NULL);
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-F07','FACT','全库','学分互认专业收费','待核实','答“现有资料未覆盖”，并指向建议获取方式','缴费前以当年通知为准',NULL,'事实',NULL,NULL,NULL);
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-F08','FACT','全库','2025、2026 年录取分数线','待核实','答“现有资料未覆盖”，并指向建议获取方式','查当年投档情况公告',NULL,'事实',NULL,NULL,NULL);
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-F09','FACT','全库','就业质量年度报告','官网未公开','答“现有资料未覆盖”，并指向建议获取方式','查「信息公开」栏',NULL,'事实',NULL,NULL,NULL);
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-F10','FACT','全库','各专业学费细目','官网未公开','答“现有资料未覆盖”，并指向建议获取方式','查缴费通知',NULL,'事实',NULL,NULL,NULL);
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-M01',NULL,'三专业共通','薪资 / 起薪','本库未覆盖','答“现有资料未覆盖”，并建议具体确认部门','不得给区间估值',NULL,'专业',NULL,NULL,NULL);
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-M02',NULL,'三专业共通','专插本 / 考编政策与条件','本库未覆盖','v1.2 起按 G6（考编）/ G7（SE 专插本）精确回答，见对应行','答“现有资料未覆盖”，建议招生就业处/教务处',NULL,'专业',NULL,NULL,NULL);
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-M03',NULL,'三专业共通','证书报考细节','本库未覆盖','答“现有资料未覆盖”，并建议具体确认部门','建议教务科研处/继续教育学院',NULL,'专业','SUB-17-U6',NULL,NULL);
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-M04',NULL,'三专业共通','具体开课日期 / 校历周次','本库未覆盖','答“现有资料未覆盖”，并建议具体确认部门','不外推日历日期',NULL,'专业',NULL,NULL,NULL);
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-M05',NULL,'三专业共通','实习企业名单 / 岗位 / 名额 / 待遇','本库未覆盖','答“现有资料未覆盖”，并建议具体确认部门','建议二级学院实习管理老师',NULL,'专业',NULL,NULL,NULL);
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-F11','FACT','全库','非招生类部门直拨电话（校办 / 教务处 / 心理中心 / 保卫处）','官网未公开','只给归口部门名与办事路径；问招生类电话可给招生咨询电话（KB_FACT 9.4）','查学校官网「机构设置」，或致电招生办转接','G2','事实','MATRIX-07 / AGENT-29','fact_contact','purpose=招生咨询电话');
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-S01','SUPPORT','全库','心理健康教育中心 / 辅导员直拨号码','本库未覆盖','只给路径：辅导员 / 心理健康中心现场预约；紧急情况给 110、120（psy_help_path 第 4 条有原文出处）；其余号码一律不给','向心理健康教育中心索取值班电话','G3','支持','MATRIX-07 / FLOW-20-L','psy_help_path','4');
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-A01','ACTION','薪资表','薪资分位数的样本量','本库未覆盖','引用分位数时必须同时写「源页未公开样本量」','向广东省人社厅核实后回填 sample_size','G4','行动','MATRIX-07 / FLOW-22-C6','act_salary_stat','sample_size');
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-A02','ACTION','岗位-专业','岗位—专业权重（对口强度）','本库未覆盖','只做「是否对口」布尔判断，不做匹配打分、不给权重数字','由专业教师打标后回填 act_position_major.weight','G5','行动','MATRIX-07 / W-F2','act_position_major','weight');
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-M06',NULL,'三专业','考编（公务员 / 事业单位）','本库未覆盖','三专业 maj_path_coverage 考编=未覆盖 → 直接 U4，不得描述考试科目 / 时间 / 报名条件','咨询招生就业处或省人事考试局','G6','专业','MATRIX-06 / MATRIX-07','maj_path_coverage','考编');
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-M07',NULL,'软件技术','专插本·专升本（软件技术）','本库未覆盖','SE 册标注完全未覆盖 → 直接 U4','咨询教务处或广东科技学院转段办','G7','专业','MATRIX-06 / MATRIX-07','maj_path_coverage','SE/专插本');
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-M08',NULL,'软件技术','分学期课程无学分 / 学时（SE 为文字版）','本库未覆盖','只给课名与模块，不给学分学时','查 SE 培养方案正式版','G8','专业','MATRIX-07','maj_semester_course','SE');
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-M09',NULL,'计算机应用技术','分学期学分合计原文≈277.5，与总学分 165.5 不一致','原文标注','引用时注明「原文标注值，未修正」','向教务处核对培养方案','G9','专业','MATRIX-07','maj_semester','CS');
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-M10',NULL,'虚拟现实技术应用','VR 册未标注所属学院与专业群','本库未覆盖','不推测归属；问「VR 属哪个学院」→ 未收录','向招生办确认专业归属','G10','专业','MATRIX-06 / INDEX-08-KW','fact_major','虚拟现实技术应用');
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-M11',NULL,'三专业','无独立赛事表；证书 / 赛事无报名窗口字段','本库未覆盖','只能学期级粗定位；问具体报名截止日 / 考试日 → U4','采集赛事与证书时间表，回填 act_event','G11','结构','MATRIX-07 / SUB-17-U6','maj_event','（待建数据）');
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-F12','FACT','生活','生活类场所地点与后勤电话（宿管 / 维修 / 快递点）','官网未公开','给「怎么做 + 找谁」，不给号码与门牌','向宿管或后勤处确认','G12','事实','MATRIX-07 / W-L1','fact_living','—');
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-M12',NULL,'三专业','赛事池仅 1 条（SE），CS / VR 无赛事记录','本库未覆盖','CS / VR 问竞赛 → U4，并建议咨询双创学院','补充 maj_key_node(node_type=技能竞赛)','G13','专业','MATRIX-07 / W-C4','maj_key_node','技能竞赛');
INSERT OR REPLACE INTO gov_gap(gap_id,doc_id,scope,gap_title,status,answer_rule,advise,gap_code,gap_level,canvas_ref,ref_table,ref_id) VALUES('GAP-R01','REGION','区域层','8 篇区域报告原文未入库（仅索引级）','本库未覆盖','只能引标题级关键数字，必须注明「据索引级条目」；细分数字（内推 63.7%、宣传不到位 51.0% 等）不得引用','补齐 A_/C_/E_ 8 篇原文后重建 kb_section','G15','区域','DATA-05-KB / FLOW-23-C7','idx_region','content_status');
-- gov_layer: 2 行新增/变更
INSERT OR REPLACE INTO gov_layer(layer_code,layer_name,kb_variable,route_priority,description) VALUES('REGION','区域层','IDX_REGION',6,'粤港澳大湾区“9+2”企业人才宏观数据；8 条条目，当前仅索引级（原文未入库，见 G15）');
INSERT OR REPLACE INTO gov_layer(layer_code,layer_name,kb_variable,route_priority,description) VALUES('INDEX','索引层','IDX_ALL',8,'知识库统一目录（profession 17 条 + region 8 条 = 25 条），只做定位，不作事实来源');
-- gov_naming_rule: 3 行新增/变更
INSERT OR REPLACE INTO gov_naming_rule(rule_no,rule_text) VALUES(9,'索引型层用 IDX_ 前缀（IDX_ALL / IDX_REGION）：源为多篇报告条目而非单册清洗稿，不许用 KB_ 前缀伪装成内容册。');
INSERT OR REPLACE INTO gov_naming_rule(rule_no,rule_text) VALUES(10,'提示词只许引用 gov_variable 里存在的变量名；每册必须有 doc_id 与生效日期，否则不许上线。');
INSERT OR REPLACE INTO gov_naming_rule(rule_no,rule_text) VALUES(11,'变量命中后必须能回到原文片段（kb_section 行号或 idx_region 条目）；回不到就按「未覆盖」作答。');
-- gov_table_map: 27 行新增/变更
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('fact_college','二级学院','FACT','KB_FACT','KB_FACT_S3','6 个二级学院（college_type=二级学院）；华为 ICT 产业学院不在此表');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('fact_major','专业清单','FACT','KB_FACT','KB_FACT_S3','11 个有文字出处的专业；归属依据见 college_basis');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('maj_major','专业主表','MAJOR','KB_MAJOR_510201 / _510203 / _510208',NULL,'3 个专业：代码/大类/学制/毕业学分学时');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('maj_overview','专业概况明细','MAJOR','KB_MAJOR_510201 / _510203 / _510208',NULL,'逐项 + 原文出处页码');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('maj_career_orientation','职业面向','MAJOR','KB_MAJOR_510201 / _510203 / _510208',NULL,'岗位群/职业类别代码/证书');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('maj_position_ladder','岗位晋升','MAJOR','KB_MAJOR_510201 / _510203 / _510208',NULL,'初始岗位 → 发展岗位');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('maj_core_ability','核心岗位能力','MAJOR','KB_MAJOR_510201 / _510203 / _510208',NULL,'按方向');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('maj_certificate','职业技能等级证书','MAJOR','KB_MAJOR_510201 / _510203 / _510208',NULL,'证书/颁证单位/等级');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('maj_course_platform','课程体系四平台','MAJOR','KB_MAJOR_510201 / _510203 / _510208',NULL,'平台→模块→课程原文');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('maj_course','课程字典','MAJOR','KB_MAJOR_510201 / _510203 / _510208',NULL,'按课程名去重，含代码/学分/学时/考核');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('maj_semester','学期周数结构','MAJOR','KB_MAJOR_510201 / _510203 / _510208',NULL,'常规/认知/岗位实习/专项/考试/机动');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('maj_semester_course','分学期课程','MAJOR','KB_MAJOR_510201 / _510203 / _510208',NULL,'唯一「什么时候学」来源');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('maj_path_coverage','三路径覆盖度','MAJOR','KB_MAJOR_510201 / _510203 / _510208',NULL,'就业/专插本专升本/考编');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('maj_key_node','关键节点','MAJOR','KB_MAJOR_510201 / _510203 / _510208',NULL,'考试课/考证课/企业实践/技能竞赛');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('maj_data_issue','数据质量备注','MAJOR','KB_MAJOR_510201 / _510203 / _510208',NULL,'源文件口径冲突与处理');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('v_major_timeline','视图：专业学期时间线','MAJOR','KB_MAJOR_510201 / _510203 / _510208','KB_MAJOR_S5','课程×学期平铺');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('v_major_exam_course','视图：考试课清单','MAJOR','KB_MAJOR_510201 / _510203 / _510208','KB_MAJOR_S5','只取考核=考试');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('v_roadmap_step','视图：路线图骨架','TASK','TASK_PATH',NULL,'按学期汇总考试课/实践/考证课');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('idx_entry','知识库统一索引（25 条）','INDEX','IDX_ALL','—','kb_index.json 落库，供 U2 分组检索与跨库跳转');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('idx_region','区域层 8 条（索引级）','REGION','IDX_REGION','—','只存标题级数字；原文未入库，见 G15');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('gov_group','检索分组 → 表/文件 映射','GOVERN','—','—','SUB-13-U2 的机器版：9 组');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('gov_error_code','错误码与固定话术','GOVERN','—','—','CONTRACT-10 的机器版');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('gov_contract','统一返回契约字段','GOVERN','—','—','CONTRACT-09 的机器版');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('gov_node','画布节点清单','GOVERN','—','—','与画布 text 节点一一对应，供智能体先读清单再读正文');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('gov_node_edge','画布连线','GOVERN','—','—','只表达主调用链');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('gov_route_keyword','学院/专业路由关键词','GOVERN','—','—','由 fact_major 派生，仅供分流，不是专业清单');
INSERT OR REPLACE INTO gov_table_map(table_name,table_cn,layer_code,kb_variable,section_var,note) VALUES('maj_event','赛事/证书时间表','MAJOR','KB_MAJOR_510201 / _510203 / _510208','—','结构就绪，数据待采（G11）');
-- gov_variable: 3 行新增/变更
INSERT OR REPLACE INTO gov_variable(var_name,layer_code,var_level,doc_id,target,usage_note) VALUES('IDX_REGION','REGION','主变量','REGION','《粤港澳大湾区企业人才现状与发展趋势：2025》8 条目（A_/C_/E_）','仅索引级：只引标题级关键数字并注明「据索引级条目」；细分数字不得引用（G15）');
INSERT OR REPLACE INTO gov_variable(var_name,layer_code,var_level,doc_id,target,usage_note) VALUES('IDX_ALL','INDEX','主变量',NULL,'kb_index 统一目录 25 条（profession 17 + region 8）','只做定位与路由，不作事实来源；命中后仍须回原文变量取片段');
INSERT OR REPLACE INTO gov_variable(var_name,layer_code,var_level,doc_id,target,usage_note) VALUES('TASK_PATH','TASK','主变量',NULL,'task_path 三条路径定义（就业 / 专插本·专升本 / 考编）','只给路径定义与骨架；节点必须取自 maj_* 真实数据，不生成文档外事实');
-- maj_path_coverage: 9 行新增/变更
INSERT OR REPLACE INTO maj_path_coverage(major_id,path,coverage,note,path_code) VALUES('SE','就业','充分覆盖','覆盖充分：岗位群、能力、课程、证书、实习安排','PATH-EMP');
INSERT OR REPLACE INTO maj_path_coverage(major_id,path,coverage,note,path_code) VALUES('SE','专插本 / 专升本','未覆盖','完全未覆盖：无对口本科专业、考试科目、报考条件与时间、录取数据','PATH-UPG');
INSERT OR REPLACE INTO maj_path_coverage(major_id,path,coverage,note,path_code) VALUES('SE','考编','未覆盖','完全未覆盖：无岗位专业限制、考试科目、报名条件','PATH-GOV');
INSERT OR REPLACE INTO maj_path_coverage(major_id,path,coverage,note,path_code) VALUES('CS','就业','充分覆盖','充分覆盖（岗位群、初始/发展岗位、能力、课程、6个月实习）','PATH-EMP');
INSERT OR REPLACE INTO maj_path_coverage(major_id,path,coverage,note,path_code) VALUES('CS','专插本 / 专升本','部分覆盖','部分覆盖：仅"专本衔接、专插本、自考相沟通相对接"提及；C语言程序设计"为专升本考学做准备"。报名条件/科目/名额/日期/分数线未提供','PATH-UPG');
INSERT OR REPLACE INTO maj_path_coverage(major_id,path,coverage,note,path_code) VALUES('CS','考编','未覆盖','未覆盖：未提及公务员/事业单位编制相关内容','PATH-GOV');
INSERT OR REPLACE INTO maj_path_coverage(major_id,path,coverage,note,path_code) VALUES('VR','就业','充分覆盖','岗位群、初始/发展岗位、能力、课程、6个月实习均已明确','PATH-EMP');
INSERT OR REPLACE INTO maj_path_coverage(major_id,path,coverage,note,path_code) VALUES('VR','专插本 / 专升本','部分覆盖','仅"与专本衔接、专插本、自考相沟通相对接"提及，无报名条件/时间/名额/对接院校','PATH-UPG');
INSERT OR REPLACE INTO maj_path_coverage(major_id,path,coverage,note,path_code) VALUES('VR','考编','未覆盖','方案未涉及','PATH-GOV');

DROP VIEW IF EXISTS v_college_major;
CREATE VIEW v_college_major AS
SELECT c.college_id, c.name AS college_name, c.college_type,
       (SELECT COUNT(*) FROM fact_major f WHERE f.college_id=c.college_id) AS major_cnt,
       (SELECT group_concat(f.major_name, '、') FROM fact_major f WHERE f.college_id=c.college_id) AS majors
FROM fact_college c;
DROP VIEW IF EXISTS v_coverage_matrix;
CREATE VIEW v_coverage_matrix AS
SELECT m.major_code, m.name AS major_name, m.college_name, m.grad_credit, m.grad_hours,
       (SELECT COUNT(*) FROM maj_semester s WHERE s.major_id=m.major_id) AS semester_cnt,
       (SELECT COUNT(*) FROM maj_semester_course c WHERE c.major_id=m.major_id) AS course_rows,
       (SELECT COUNT(*) FROM maj_course k WHERE k.major_id=m.major_id) AS course_dict,
       (SELECT coverage FROM maj_path_coverage p WHERE p.major_id=m.major_id AND p.path_code='PATH-EMP') AS cov_emp,
       (SELECT coverage FROM maj_path_coverage p WHERE p.major_id=m.major_id AND p.path_code='PATH-UPG') AS cov_upg,
       (SELECT coverage FROM maj_path_coverage p WHERE p.major_id=m.major_id AND p.path_code='PATH-GOV') AS cov_gov
FROM maj_major m;
DROP VIEW IF EXISTS v_doc_route;
CREATE VIEW v_doc_route AS
SELECT d.doc_id, l.layer_code, d.kb_variable, d.section_cnt, d.char_len, d.effective_note
FROM gov_doc d LEFT JOIN gov_layer l ON l.layer_code=d.layer_code;
DROP VIEW IF EXISTS v_error_text;
CREATE VIEW v_error_text AS
SELECT code, trigger_cond, fixed_text, u4_reason, short_circuit FROM gov_error_code;
DROP VIEW IF EXISTS v_gap_code;
CREATE VIEW v_gap_code AS
SELECT gap_code, CAST(substr(gap_code,2) AS INTEGER) AS gap_no, gap_title, status, answer_rule, advise, ref_table, ref_id, canvas_ref
FROM gov_gap WHERE gap_code IS NOT NULL;
DROP VIEW IF EXISTS v_group_route;
CREATE VIEW v_group_route AS
SELECT group_code, group_name, kb_variable, tables, used_by, node_ref FROM gov_group;
DROP VIEW IF EXISTS v_major_scope;
CREATE VIEW v_major_scope AS
SELECT f.major_name, f.college_id, c.name AS college_name, f.college_basis, f.college_confirmed,
       CASE WHEN EXISTS(SELECT 1 FROM maj_major m WHERE m.name=f.major_name) THEN '课程级'
            WHEN EXISTS(SELECT 1 FROM act_major_position a WHERE a.major_name LIKE f.major_name || '%') THEN '岗位级'
            ELSE '无数据' END AS scope_level
FROM fact_major f LEFT JOIN fact_college c ON c.college_id=f.college_id;
DROP VIEW IF EXISTS v_node_manifest;
CREATE VIEW v_node_manifest AS
SELECT node_id, node_type, node_name, zone, mount, impl_node, sort_no FROM gov_node;
DROP VIEW IF EXISTS v_region_index;
CREATE VIEW v_region_index AS
SELECT entry_id, file_name, title, data_points, evidence_level, content_status FROM idx_region;

INSERT INTO gov_build_log(step,detail) VALUES('patch-v1.2','v1.1 -> v1.2 补丁执行完成');
COMMIT;
PRAGMA foreign_keys = ON;

