-- 由 _画布生成脚本.py 自动导出，不要手改。
-- 目的：把 gov_node / gov_node_edge 从 v1.2 旧口径（40 行 / 32 条）
--       升级到与画布严格一一对应的 v1.3 口径（44 行 / 42 条）。
-- 依据：路书_2026-11-13 v1.3.canvas（text 44 / group 7 / edge 42）
-- 幂等：先清空再插入，可重复执行。

BEGIN;

DELETE FROM gov_node_edge;
DELETE FROM gov_node;

INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('SPEC-01-TYPES','SPEC','〔META〕SPEC-01-TYPES ｜ SPEC ｜ 节点类型与命名规范','① 协议层 · 先读这里（给智能体的阅读协议，不是业务规则）',NULL,NULL,NULL,NULL,NULL,NULL,1);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('SPEC-02-RULES','SPEC','〔META〕SPEC-02-RULES ｜ SPEC ｜ 全局铁律（所有节点共用前缀）','① 协议层 · 先读这里（给智能体的阅读协议，不是业务规则）',NULL,NULL,NULL,NULL,NULL,NULL,2);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('INDEX-03-MANIFEST','INDEX','〔META〕INDEX-03-MANIFEST ｜ DOC ｜ 机器可读节点清单（JSON，唯一入口）','① 协议层 · 先读这里（给智能体的阅读协议，不是业务规则）',NULL,NULL,NULL,NULL,NULL,NULL,3);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('DATA-04-DB','DATA','〔META〕DATA-04-DB ｜ DATA ｜ 数据库六层挂载表','② 数据层 · 挂什么（回答能力的唯一来源）',NULL,NULL,NULL,NULL,NULL,NULL,4);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('DATA-05-KB','DATA','〔META〕DATA-05-KB ｜ DATA ｜ 知识库文件与生效口径','② 数据层 · 挂什么（回答能力的唯一来源）',NULL,NULL,NULL,NULL,NULL,NULL,5);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('MATRIX-06-COVER','MATRIX','〔META〕MATRIX-06-COVER ｜ MATRIX ｜ 专业 × 路径覆盖矩阵（写死的回答边界）','② 数据层 · 挂什么（回答能力的唯一来源）',NULL,NULL,NULL,NULL,NULL,NULL,6);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('MATRIX-07-GAP','MATRIX','〔META〕MATRIX-07-GAP ｜ MATRIX ｜ 缺口清单 G1–G15（命中即答未覆盖）','② 数据层 · 挂什么（回答能力的唯一来源）',NULL,NULL,NULL,NULL,NULL,NULL,7);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('INDEX-08-KW','INDEX','〔META〕INDEX-08-KW ｜ DOC ｜ 学院—专业—路由关键词表（6 二级学院 + 1 产业学院）','② 数据层 · 挂什么（回答能力的唯一来源）',NULL,NULL,NULL,NULL,NULL,NULL,8);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('CONTRACT-09-RET','CONTRACT','〔META〕CONTRACT-09-RET ｜ CONTRACT ｜ 统一返回契约 v1.2（与 gov_contrac','③ 契约层 · 节点之间怎么交接（含 U 串联闸门）',NULL,NULL,NULL,NULL,NULL,NULL,9);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('CONTRACT-10-ERR','CONTRACT','〔META〕CONTRACT-10-ERR ｜ CONTRACT ｜ 错误码与兜底话术映射（gov_error_code','③ 契约层 · 节点之间怎么交接（含 U 串联闸门）',NULL,NULL,NULL,NULL,NULL,NULL,10);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('CONTRACT-11-ROUTE','CONTRACT','〔META〕CONTRACT-11-ROUTE ｜ CONTRACT ｜ 调用关系与路由决策树','③ 契约层 · 节点之间怎么交接（含 U 串联闸门）',NULL,NULL,NULL,NULL,NULL,NULL,11);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('DATA-32-VAR','DATA','〔META〕DATA-32-VAR ｜ DATA ｜ 变量注册表（gov_variable，提示词只许引这里有的名字）','② 数据层 · 挂什么（回答能力的唯一来源）',NULL,NULL,NULL,NULL,NULL,NULL,32);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('DATA-33-DOC','DATA','〔META〕DATA-33-DOC ｜ DATA ｜ 文档注册表与生效日期口径（gov_doc，7 册）','② 数据层 · 挂什么（回答能力的唯一来源）',NULL,NULL,NULL,NULL,NULL,NULL,33);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('SUB-34-U1','SUB','〔META〕SUB-34-U1 ｜ SUB ｜ U1 实体抽取','④ 公共子流 U1–U7 · 被所有流程调用',NULL,NULL,NULL,NULL,NULL,NULL,34);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('SUB-35-U2','SUB','〔META〕SUB-35-U2 ｜ SUB ｜ U2 分组检索（group → 表 / 文件，与 gov_group 9','④ 公共子流 U1–U7 · 被所有流程调用',NULL,NULL,NULL,NULL,NULL,NULL,35);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('SUB-36-U3','SUB','〔META〕SUB-36-U3 ｜ SUB ｜ U3 来源挂载','④ 公共子流 U1–U7 · 被所有流程调用',NULL,NULL,NULL,NULL,NULL,NULL,36);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('SUB-37-U4','SUB','〔META〕SUB-37-U4 ｜ SUB ｜ U4 未覆盖兜底','④ 公共子流 U1–U7 · 被所有流程调用',NULL,NULL,NULL,NULL,NULL,NULL,37);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('SUB-38-U5','SUB','〔META〕SUB-38-U5 ｜ SUB ｜ U5 四段格式化','④ 公共子流 U1–U7 · 被所有流程调用',NULL,NULL,NULL,NULL,NULL,NULL,38);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('SUB-39-U6','SUB','〔META〕SUB-39-U6 ｜ SUB ｜ U6 时间窗过滤（只能学期级，必读）','④ 公共子流 U1–U7 · 被所有流程调用',NULL,NULL,NULL,NULL,NULL,NULL,39);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('SUB-40-U7','SUB','〔META〕SUB-40-U7 ｜ SUB ｜ U7 分学期清单结构（路线图专用格式化）','④ 公共子流 U1–U7 · 被所有流程调用',NULL,NULL,NULL,NULL,NULL,NULL,40);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('FLOW-41-M','FLOW','〔META〕FLOW-41-M ｜ FLOW ｜ 主智能体工作流 W-M1…M5','⑤ 工作流 · 主流程与分支（左→右＝调用顺序）',NULL,NULL,NULL,NULL,NULL,NULL,41);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('FLOW-42-SG','FLOW','〔META〕FLOW-42-SG ｜ FLOW ｜ 学校侧 W-S1/S2 · W-G1/G2','⑤ 工作流 · 主流程与分支（左→右＝调用顺序）',NULL,NULL,NULL,NULL,NULL,NULL,42);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('FLOW-43-L','FLOW','〔META〕FLOW-43-L ｜ FLOW ｜ 生活与安全 W-L0/L1','⑤ 工作流 · 主流程与分支（左→右＝调用顺序）',NULL,NULL,NULL,NULL,NULL,NULL,43);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('CONTRACT-44-GATE','CONTRACT','〔META〕CONTRACT-44-GATE ｜ CONTRACT ｜ U 子流串联与熔断闸门（节点之间怎么串）','④ 公共子流 U1–U7 · 被所有流程调用',NULL,NULL,NULL,NULL,NULL,NULL,44);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('FLOW-47-C','FLOW','〔META〕FLOW-47-C ｜ FLOW ｜ 职业规划 W-C1…C5（全树最复杂）','⑤ 工作流 · 主流程与分支（左→右＝调用顺序）',NULL,NULL,NULL,NULL,NULL,NULL,47);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('FLOW-52-C7','FLOW','〔META〕FLOW-52-C7 ｜ FLOW ｜ W-C7 区域行情（索引级，数字有禁区）','⑤ 工作流 · 主流程与分支（左→右＝调用顺序）',NULL,NULL,NULL,NULL,NULL,NULL,52);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('FLOW-53-F','FLOW','〔META〕FLOW-53-F ｜ FLOW ｜ 学院工作流 W-F1…F3（6 节点同构：5 二级学院 + 1 产业学','⑤ 工作流 · 主流程与分支（左→右＝调用顺序）',NULL,NULL,NULL,NULL,NULL,NULL,53);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('FLOW-54-C6','FLOW','〔META〕FLOW-54-C6 ｜ FLOW ｜ W-C6 求职实务','⑤ 工作流 · 主流程与分支（左→右＝调用顺序）',NULL,NULL,NULL,NULL,NULL,NULL,54);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('FLOW-55-R','FLOW','〔META〕FLOW-55-R ｜ FLOW ｜ 终审 W-R1…R3（唯一出口）','⑤ 工作流 · 主流程与分支（左→右＝调用顺序）',NULL,NULL,NULL,NULL,NULL,NULL,55);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-57-MAIN','AGENT','〔META〕AGENT-57-MAIN ｜ AGENT ｜ 提示词 · 主智能体','⑥ 智能体提示词 · 可直接复制上线（红=提示词）',NULL,NULL,NULL,NULL,NULL,NULL,57);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-58-COUNSEL','AGENT','〔META〕AGENT-58-COUNSEL ｜ AGENT ｜ 提示词 · 职业规划','⑥ 智能体提示词 · 可直接复制上线（红=提示词）',NULL,NULL,NULL,NULL,NULL,NULL,58);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-59-JUDGE','AGENT','〔META〕AGENT-59-JUDGE ｜ AGENT ｜ 提示词 · 终审（W-R）','⑥ 智能体提示词 · 可直接复制上线（红=提示词）',NULL,NULL,NULL,NULL,NULL,NULL,59);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-60-OFFICIAL','AGENT','〔META〕AGENT-60-OFFICIAL ｜ AGENT ｜ 提示词 · 学校官网','⑥ 智能体提示词 · 可直接复制上线（红=提示词）',NULL,NULL,NULL,NULL,NULL,NULL,60);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-61-AFFAIR','AGENT','〔META〕AGENT-61-AFFAIR ｜ AGENT ｜ 提示词 · 学校政务','⑥ 智能体提示词 · 可直接复制上线（红=提示词）',NULL,NULL,NULL,NULL,NULL,NULL,61);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-62-LIFE','AGENT','〔META〕AGENT-62-LIFE ｜ AGENT ｜ 提示词 · 学生需求','⑥ 智能体提示词 · 可直接复制上线（红=提示词）',NULL,NULL,NULL,NULL,NULL,NULL,62);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-63-COL-XX','AGENT','〔META〕AGENT-63-COL-XX ｜ AGENT ｜ 提示词 · 信息学院','⑥ 智能体提示词 · 可直接复制上线（红=提示词）',NULL,NULL,NULL,NULL,NULL,NULL,63);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-64-COL-JG','AGENT','〔META〕AGENT-64-COL-JG ｜ AGENT ｜ 提示词 · 经济管理学院','⑥ 智能体提示词 · 可直接复制上线（红=提示词）',NULL,NULL,NULL,NULL,NULL,NULL,64);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-65-COL-RW','AGENT','〔META〕AGENT-65-COL-RW ｜ AGENT ｜ 提示词 · 人文与教育学院','⑥ 智能体提示词 · 可直接复制上线（红=提示词）',NULL,NULL,NULL,NULL,NULL,NULL,65);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-66-COL-WJ','AGENT','〔META〕AGENT-66-COL-WJ ｜ AGENT ｜ 提示词 · 卫生健康学院','⑥ 智能体提示词 · 可直接复制上线（红=提示词）',NULL,NULL,NULL,NULL,NULL,NULL,66);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-67-COL-SJ','AGENT','〔META〕AGENT-67-COL-SJ ｜ AGENT ｜ 提示词 · 设计与传媒学院','⑥ 智能体提示词 · 可直接复制上线（红=提示词）',NULL,NULL,NULL,NULL,NULL,NULL,67);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('AGENT-68-COL-ICT','AGENT','〔META〕AGENT-68-COL-ICT ｜ AGENT ｜ 提示词 · 华为ICT学院','⑥ 智能体提示词 · 可直接复制上线（红=提示词）',NULL,NULL,NULL,NULL,NULL,NULL,68);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('QA-70-CASES','QA','〔META〕QA-70-CASES ｜ QA ｜ 验收用例 T01–T12 + 终审 + 一致性校验','⑦ 验收与变更 · 上线前自测',NULL,NULL,NULL,NULL,NULL,NULL,70);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('DOC-71-CHANGELOG','DOC','〔META〕DOC-71-CHANGELOG ｜ DOC ｜ v1.3 变更清单与待决策项','⑦ 验收与变更 · 上线前自测',NULL,NULL,NULL,NULL,NULL,NULL,71);
INSERT INTO gov_node(node_id,node_type,node_name,zone,mount,io_in,io_out,fail_text,verify_text,impl_node,sort_no) VALUES('DOC-72-README','DOC','〔META〕DOC-72-README ｜ DOC ｜ 画布使用说明','① 协议层 · 先读这里（给智能体的阅读协议，不是业务规则）',NULL,NULL,NULL,NULL,NULL,NULL,72);

INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('DOC-72-README','SPEC-01-TYPES','right','left',NULL,1);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('SPEC-01-TYPES','SPEC-02-RULES','right','left',NULL,2);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('SPEC-02-RULES','INDEX-03-MANIFEST','right','left',NULL,3);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('DATA-04-DB','DATA-05-KB','right','left',NULL,4);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('DATA-05-KB','MATRIX-06-COVER','right','left',NULL,5);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('MATRIX-06-COVER','MATRIX-07-GAP','right','left',NULL,6);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('MATRIX-07-GAP','INDEX-08-KW','right','left',NULL,7);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('DATA-04-DB','DATA-32-VAR','bottom','top','变量注册',8);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('DATA-32-VAR','DATA-33-DOC','right','left','文档注册',9);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('DATA-33-DOC','CONTRACT-09-RET','bottom','top','契约落地',10);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('CONTRACT-09-RET','CONTRACT-10-ERR','right','left',NULL,11);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('CONTRACT-10-ERR','CONTRACT-11-ROUTE','right','left',NULL,12);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('INDEX-03-MANIFEST','SUB-35-U2','bottom','top',NULL,13);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('CONTRACT-11-ROUTE','FLOW-41-M','bottom','top','路由',14);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('SUB-34-U1','SUB-35-U2','right','left',NULL,15);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('SUB-35-U2','SUB-36-U3','right','left',NULL,16);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('SUB-36-U3','SUB-37-U4','right','left',NULL,17);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('SUB-37-U4','SUB-38-U5','right','left',NULL,18);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('SUB-38-U5','SUB-39-U6','right','left',NULL,19);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('SUB-39-U6','SUB-40-U7','bottom','top','路线图格式化',20);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-41-M','FLOW-42-SG','right','left','转交',21);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-42-SG','FLOW-43-L','right','left','转交',22);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-43-L','FLOW-47-C','right','left','转交',23);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-47-C','FLOW-53-F','right','left','转交',24);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-47-C','FLOW-54-C6','bottom','top','A–F 分支',25);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-54-C6','FLOW-52-C7','right','left',NULL,26);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-52-C7','FLOW-55-R','right','left','送审',27);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-53-F','FLOW-55-R','bottom','top','送审',28);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-41-M','AGENT-57-MAIN','bottom','top','提示词',29);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-47-C','AGENT-58-COUNSEL','bottom','top','提示词',30);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-55-R','AGENT-59-JUDGE','bottom','top','提示词',31);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('FLOW-42-SG','AGENT-60-OFFICIAL','right','left','提示词',32);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('AGENT-60-OFFICIAL','AGENT-61-AFFAIR','right','left','提示词',33);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('AGENT-61-AFFAIR','AGENT-62-LIFE','right','left','提示词',34);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('AGENT-62-LIFE','AGENT-63-COL-XX','right','left','提示词',35);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('AGENT-63-COL-XX','AGENT-64-COL-JG','right','left','同构',36);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('AGENT-64-COL-JG','AGENT-65-COL-RW','right','left','同构',37);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('AGENT-65-COL-RW','AGENT-66-COL-WJ','right','left','同构',38);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('AGENT-66-COL-WJ','AGENT-67-COL-SJ','right','left','同构',39);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('AGENT-67-COL-SJ','AGENT-68-COL-ICT','right','left','同构',40);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('CONTRACT-44-GATE','FLOW-41-M','right','left','闸门',41);
INSERT INTO gov_node_edge(from_node,to_node,from_side,to_side,edge_kind,sort_no) VALUES('QA-70-CASES','DOC-71-CHANGELOG','right','left',NULL,42);

-- ============ 校验视图（口径固化，随库发布） ============
-- sort_no 允许跳号（跳号处为预留位，如 44 之后留 45/46 给后续扩展），
-- 但必须严格递增且唯一；「序号即阅读顺序」由本视图守护。
DROP VIEW IF EXISTS v_node_seq_check;
CREATE VIEW v_node_seq_check AS
SELECT
  (SELECT COUNT(*) FROM gov_node)                               AS node_cnt,
  (SELECT COUNT(*) FROM gov_node_edge)                          AS edge_cnt,
  (SELECT COUNT(DISTINCT sort_no) FROM gov_node)                AS distinct_seq,
  (SELECT COUNT(*) FROM gov_node
     WHERE node_id NOT GLOB '[A-Z]*-[0-9][0-9]-*')              AS bad_id_format,
  (SELECT COUNT(*) FROM gov_node_edge
     WHERE from_node NOT IN (SELECT node_id FROM gov_node)
        OR to_node   NOT IN (SELECT node_id FROM gov_node))     AS dangling_edge,
  (SELECT COUNT(*) FROM gov_node WHERE zone IS NULL OR zone='') AS empty_zone;

-- 一次查询即可判定画布与库是否同源：六列应分别为
--   44 / 42 / 44 / 0 / 0 / 0

COMMIT;
