-- =============================================================
-- 路书知识库 v1.1  schema
-- 依据：路书_变量名规范 v1.1（保留 KB_ 三层，新增 MAJOR 专业层）
-- 数据来源：学科(3 专业册) / 学校官网 / 心理安全 / 职业规划
-- 分层前缀：gov_ 治理 · fact_ 事实(KB_FACT) · act_ 行动(KB_ACTION)
--           psy_ 支持(KB_SUPPORT) · maj_ 专业(KB_MAJOR) · task_ 任务
-- =============================================================
PRAGMA foreign_keys = ON;

-- -------------------------------------------------------------
-- 0. 治理层 gov_*
-- -------------------------------------------------------------
CREATE TABLE gov_layer (
  layer_code    TEXT PRIMARY KEY,
  layer_name    TEXT NOT NULL,
  kb_variable   TEXT,
  route_priority INTEGER NOT NULL,      -- 数字越小越优先；危机=1
  description   TEXT
);

CREATE TABLE gov_doc (
  doc_id        TEXT PRIMARY KEY,       -- FACT / ACTION / SUPPORT / MAJOR_SE ...
  doc_name      TEXT NOT NULL,
  layer_code    TEXT NOT NULL REFERENCES gov_layer(layer_code),
  file_name     TEXT NOT NULL,
  kb_variable   TEXT NOT NULL,
  doc_version   TEXT,
  compiled_date TEXT,
  effective_note TEXT,                  -- 生效日期口径（原文怎么写就怎么记）
  char_len      INTEGER,
  section_cnt   INTEGER,
  note          TEXT
);

CREATE TABLE gov_source (
  src_id      TEXT PRIMARY KEY,
  doc_id      TEXT REFERENCES gov_doc(doc_id),
  src_type    TEXT NOT NULL,            -- 官方 / 市场 / 自建 / 混合
  src_name    TEXT NOT NULL,
  src_url     TEXT,
  published_at TEXT,
  stat_period TEXT,
  note        TEXT
);

CREATE TABLE gov_gap (
  gap_id    TEXT PRIMARY KEY,
  doc_id    TEXT REFERENCES gov_doc(doc_id),
  scope     TEXT,                        -- 全库 / 某专业 / 某章
  gap_title TEXT NOT NULL,
  status    TEXT,                        -- 官网未公开 / 本库未覆盖 / 待核实
  answer_rule TEXT,                      -- 命中时怎么答
  advise    TEXT
);

CREATE TABLE gov_variable (
  var_name    TEXT PRIMARY KEY,
  layer_code  TEXT REFERENCES gov_layer(layer_code),
  var_level   TEXT NOT NULL,             -- 主变量 / 章节子变量 / 专业子变量
  doc_id      TEXT REFERENCES gov_doc(doc_id),
  target      TEXT NOT NULL,             -- 指向文件 / 章节 / 表
  usage_note  TEXT
);

CREATE TABLE gov_naming_rule (
  rule_no INTEGER PRIMARY KEY,
  rule_text TEXT NOT NULL
);

CREATE TABLE gov_forbidden (
  term   TEXT PRIMARY KEY,
  reason TEXT NOT NULL
);

-- 表 → 层 → 变量 映射（由构建脚本自动生成，与文档同源）
CREATE TABLE gov_table_map (
  table_name  TEXT PRIMARY KEY,
  table_cn    TEXT,
  layer_code  TEXT REFERENCES gov_layer(layer_code),
  kb_variable TEXT,
  section_var TEXT,
  note        TEXT
);

-- 字段字典（构建脚本从 PRAGMA 自动导出 + 字段语义）
CREATE TABLE gov_field_dict (
  table_name TEXT NOT NULL,
  field_name TEXT NOT NULL,
  field_type TEXT,
  meaning    TEXT,
  domain     TEXT,                       -- 取值域 / 单位 / 枚举
  PRIMARY KEY (table_name, field_name)
);

CREATE TABLE gov_build_log (
  log_id  INTEGER PRIMARY KEY AUTOINCREMENT,
  step    TEXT NOT NULL,
  detail  TEXT,
  ts      TEXT DEFAULT (datetime('now','localtime'))
);

-- -------------------------------------------------------------
-- 1. 检索底座：全库章节切分 + 全文索引
-- -------------------------------------------------------------
CREATE TABLE kb_section (
  sec_id      TEXT PRIMARY KEY,          -- DOC#0001
  doc_id      TEXT NOT NULL REFERENCES gov_doc(doc_id),
  chapter_no  TEXT,                      -- 一 / 2 / A1 ...
  chapter_title TEXT,
  sec_no      TEXT,                      -- 1.4 / 5.2
  title       TEXT NOT NULL,
  level       INTEGER NOT NULL,          -- 标题层级 1/2/3/4
  line_start  INTEGER,
  line_end    INTEGER,
  body        TEXT NOT NULL,
  char_len    INTEGER,
  sec_var     TEXT                       -- 对应章节子变量（可空）
);
CREATE INDEX idx_sec_doc ON kb_section(doc_id);
CREATE INDEX idx_sec_level ON kb_section(doc_id, level);

-- 中文检索：正文逐字加空格存 seg，查询同样处理后按短语匹配
CREATE VIRTUAL TABLE kb_search USING fts5(
  sec_id UNINDEXED,
  doc_id UNINDEXED,
  title,
  seg,
  tokenize='unicode61'
);

-- -------------------------------------------------------------
-- 2. 事实层 fact_*  →  KB_FACT
-- -------------------------------------------------------------
CREATE TABLE fact_school (
  school_id   TEXT PRIMARY KEY,
  doc_id      TEXT REFERENCES gov_doc(doc_id),
  name        TEXT, code TEXT, identity_code TEXT,
  level       TEXT, nature TEXT, run_type TEXT, supervisor TEXT,
  address     TEXT, postcode TEXT, campus TEXT,
  area_mu     TEXT, founded_from TEXT, founded_year TEXT,
  college_cnt INTEGER, major_cnt INTEGER,
  staff       TEXT, full_time_teacher TEXT,
  equipment_value TEXT, books TEXT, ebooks TEXT,
  plan_2026   TEXT, stat_asof TEXT, src_note TEXT
);

CREATE TABLE fact_motto (
  id      INTEGER PRIMARY KEY AUTOINCREMENT,
  kind    TEXT NOT NULL,                 -- 校训/校风/教风/学风/办学理念/办学定位/办学愿景/指导思想/办学特色
  content TEXT NOT NULL,
  doc_id  TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_feature (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  dimension TEXT NOT NULL,               -- 三优 / 三强 / 四好
  items     TEXT NOT NULL,
  doc_id    TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_college (
  college_id TEXT PRIMARY KEY,
  name       TEXT NOT NULL,
  note       TEXT,
  doc_id     TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_major (
  major_name TEXT PRIMARY KEY,
  college_id TEXT REFERENCES fact_college(college_id),
  major_code TEXT,
  is_key     INTEGER DEFAULT 0,
  is_hot     INTEGER DEFAULT 0,
  tags       TEXT,                       -- 省级品牌/高水平群成员/学分互认/创新班/三二分段
  tuition_note TEXT,
  note       TEXT,
  doc_id     TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_key_program (
  id      INTEGER PRIMARY KEY AUTOINCREMENT,
  level   TEXT NOT NULL,                 -- 省级高水平专业群/省级品牌专业/省级特色专业/校级重点建设
  name    TEXT,
  members TEXT,
  status  TEXT,                          -- 已列名 / 官网未列名
  doc_id  TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_training_direction (
  dir_id     TEXT PRIMARY KEY,
  seq        TEXT,
  name       TEXT NOT NULL,
  positioning TEXT,
  doc_id     TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_direction_course (
  id      INTEGER PRIMARY KEY AUTOINCREMENT,
  dir_id  TEXT NOT NULL REFERENCES fact_training_direction(dir_id),
  course  TEXT NOT NULL
);

CREATE TABLE fact_direction_cert (
  id      INTEGER PRIMARY KEY AUTOINCREMENT,
  dir_id  TEXT NOT NULL REFERENCES fact_training_direction(dir_id),
  cert    TEXT NOT NULL
);

CREATE TABLE fact_direction_job (
  id      INTEGER PRIMARY KEY AUTOINCREMENT,
  dir_id  TEXT NOT NULL REFERENCES fact_training_direction(dir_id),
  job     TEXT NOT NULL
);

CREATE TABLE fact_class_type (
  type_id  TEXT PRIMARY KEY,
  type_name TEXT NOT NULL,
  majors   TEXT,
  note     TEXT,
  doc_id   TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_admission_channel (
  channel_id TEXT PRIMARY KEY,
  channel    TEXT NOT NULL,
  target     TEXT,
  basis      TEXT,
  policy_doc TEXT,
  doc_id     TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_admission_rule (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  category  TEXT NOT NULL,               -- 夏季高考/春季高考/体检/注册复查/批次分数
  seq       TEXT,
  rule_text TEXT NOT NULL,
  doc_id    TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_exam_score (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  year      TEXT NOT NULL,
  exam_type TEXT NOT NULL,
  score     TEXT NOT NULL,
  note      TEXT,
  doc_id    TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_tuition (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  year         TEXT,
  major_category TEXT NOT NULL,
  fee_per_year INTEGER,
  unit         TEXT DEFAULT '元/生·学年',
  note         TEXT,
  doc_id       TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_financial_aid (
  aid_id   TEXT PRIMARY KEY,
  level    TEXT,                          -- 国家 / 学校
  name     TEXT NOT NULL,
  target   TEXT,
  standard TEXT,
  note     TEXT,
  doc_id   TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_living (
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  category TEXT NOT NULL,                 -- 住宿/餐饮文体/社团
  item     TEXT,
  detail   TEXT,
  doc_id   TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_transport (
  id     INTEGER PRIMARY KEY AUTOINCREMENT,
  mode   TEXT NOT NULL,
  route  TEXT NOT NULL,
  doc_id TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_articulation (
  art_id   TEXT PRIMARY KEY,
  art_type TEXT NOT NULL,                 -- 三二分段/学分互认/国际项目/组织保障
  majors   TEXT,
  partner  TEXT,
  detail   TEXT,
  status   TEXT,                          -- 已明确 / 官网仅图片未文字化
  doc_id   TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_employment_stat (
  id     INTEGER PRIMARY KEY AUTOINCREMENT,
  year   TEXT NOT NULL,
  metric TEXT NOT NULL,                   -- 毕业去向落实率 / 就业平均薪酬
  value  TEXT NOT NULL,
  note   TEXT,
  doc_id TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_coop (
  id     INTEGER PRIMARY KEY AUTOINCREMENT,
  form   TEXT NOT NULL,
  detail TEXT NOT NULL,
  doc_id TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_department (
  dept_id TEXT PRIMARY KEY,
  name    TEXT NOT NULL,
  duty    TEXT,
  doc_id  TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_contact (
  id      INTEGER PRIMARY KEY AUTOINCREMENT,
  purpose TEXT NOT NULL,
  method  TEXT NOT NULL,
  doc_id  TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_leader (
  id     INTEGER PRIMARY KEY AUTOINCREMENT,
  title  TEXT NOT NULL,
  name   TEXT NOT NULL,
  scope  TEXT,
  doc_id TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE fact_faq (
  q_no     TEXT PRIMARY KEY,
  question TEXT NOT NULL,
  answer   TEXT NOT NULL,
  doc_id   TEXT REFERENCES gov_doc(doc_id)
);

-- -------------------------------------------------------------
-- 3. 行动层 act_*  →  KB_ACTION
-- -------------------------------------------------------------
CREATE TABLE act_major_position (
  mp_id      TEXT PRIMARY KEY,
  college_name TEXT,
  major_name TEXT NOT NULL,
  positions_text TEXT,
  has_national_standard TEXT,
  note       TEXT,
  doc_id     TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE act_position (
  pos_id       TEXT PRIMARY KEY,
  name         TEXT NOT NULL,
  group_name   TEXT,                      -- 信息技术类/商贸类/医护类/制造类
  category     TEXT,                      -- 岗位
  source_level TEXT,                      -- 官方/市场/自建
  source       TEXT,
  source_url   TEXT,
  published_at TEXT,
  effective_from TEXT,
  effective_to TEXT,
  applicable_region TEXT,
  applicable_paths TEXT,
  verified_at  TEXT,
  data_layer   TEXT,                      -- L1 / L1+L2 / L1+L2+L3
  duty         TEXT,                      -- ① 这个岗位做什么
  salary_note  TEXT,                      -- ④ 薪资水平（原文口径）
  doc_id       TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE act_position_skill (
  id     INTEGER PRIMARY KEY AUTOINCREMENT,
  pos_id TEXT NOT NULL REFERENCES act_position(pos_id),
  seq    TEXT,
  skill  TEXT NOT NULL,
  note   TEXT                             -- 来源说明（本校课程 / L2 JD）
);

CREATE TABLE act_position_cert (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  pos_id    TEXT NOT NULL REFERENCES act_position(pos_id),
  cert      TEXT NOT NULL,
  mandatory INTEGER DEFAULT 0,            -- 0 加分项/非强制  1 强制
  note      TEXT
);

CREATE TABLE act_position_major (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  pos_id     TEXT NOT NULL REFERENCES act_position(pos_id),
  major_name TEXT NOT NULL,
  weight     TEXT                         -- 待教师打标，禁止填数字
);

CREATE TABLE act_salary_stat (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  seq       TEXT,
  job_name  TEXT NOT NULL,
  p10 INTEGER, p25 INTEGER, p50 INTEGER, p75 INTEGER, p90 INTEGER,
  unit      TEXT DEFAULT '元/月',
  region    TEXT,
  period    TEXT,
  metric_caliber TEXT,                    -- 市场招聘分位数，非实发工资
  source_level TEXT,
  src_id    TEXT REFERENCES gov_source(src_id),
  sample_size TEXT,                       -- 源页未公开
  doc_id    TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE act_guide (
  guide_id  TEXT PRIMARY KEY,
  section_no TEXT,                        -- 4.1 / 5.2 / 6.2
  chapter   TEXT,                         -- 简历 / 面试 / 权益
  title     TEXT NOT NULL,
  source_level TEXT,
  red_line  TEXT,
  doc_id    TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE act_guide_item (
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  guide_id TEXT NOT NULL REFERENCES act_guide(guide_id),
  seq      TEXT,
  item     TEXT NOT NULL
);

CREATE TABLE act_rights_rule (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  topic     TEXT NOT NULL,                -- 三方协议/试用期/培训贷/虚假招聘/投诉
  seq       TEXT,
  rule_text TEXT NOT NULL,
  legal_basis TEXT,
  doc_id    TEXT REFERENCES gov_doc(doc_id)
);

-- -------------------------------------------------------------
-- 4. 支持层 psy_*  →  KB_SUPPORT
-- -------------------------------------------------------------
CREATE TABLE psy_crisis_level (
  level     TEXT PRIMARY KEY,             -- 轻度/中度/重度
  typical   TEXT,
  principle TEXT,
  note      TEXT,
  sec_id    TEXT REFERENCES kb_section(sec_id)
);

CREATE TABLE psy_red_flag (
  id     INTEGER PRIMARY KEY AUTOINCREMENT,
  seq    TEXT,
  flag   TEXT NOT NULL,
  sec_id TEXT REFERENCES kb_section(sec_id)
);

CREATE TABLE psy_self_check_dim (
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  dimension TEXT NOT NULL,
  how      TEXT,
  standard TEXT,
  sec_id   TEXT REFERENCES kb_section(sec_id)
);

CREATE TABLE psy_early_signal (
  id     INTEGER PRIMARY KEY AUTOINCREMENT,
  signal TEXT NOT NULL,
  sec_id TEXT REFERENCES kb_section(sec_id)
);

CREATE TABLE psy_topic (
  topic_id  TEXT PRIMARY KEY,
  chapter_no TEXT,
  chapter_title TEXT,
  sec_no    TEXT,
  title     TEXT NOT NULL,
  category  TEXT,                         -- 附录A 栏目名
  body      TEXT,
  sec_id    TEXT REFERENCES kb_section(sec_id)
);

CREATE TABLE psy_article (
  article_id TEXT PRIMARY KEY,
  category   TEXT NOT NULL,               -- A1 心理知识 / A2 危机处理 ...
  seq        INTEGER,
  title      TEXT NOT NULL,
  url        TEXT,
  pub_date   TEXT,
  org        TEXT,
  note       TEXT,                        -- （视频）等
  doc_id     TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE psy_help_path (
  id     INTEGER PRIMARY KEY AUTOINCREMENT,
  seq    TEXT,
  path   TEXT NOT NULL,
  note   TEXT,
  sec_id TEXT REFERENCES kb_section(sec_id)
);

CREATE TABLE psy_misconception (
  id     INTEGER PRIMARY KEY AUTOINCREMENT,
  wrong  TEXT NOT NULL,
  right  TEXT,
  sec_id TEXT REFERENCES kb_section(sec_id)
);

CREATE TABLE psy_effect (
  id      INTEGER PRIMARY KEY AUTOINCREMENT,
  name    TEXT NOT NULL,
  gist    TEXT,
  sec_id  TEXT REFERENCES kb_section(sec_id)
);

CREATE TABLE psy_seasonal (
  id      INTEGER PRIMARY KEY AUTOINCREMENT,
  node    TEXT NOT NULL,
  detail  TEXT,
  sec_id  TEXT REFERENCES kb_section(sec_id)
);

CREATE TABLE psy_bystander_tip (
  id     INTEGER PRIMARY KEY AUTOINCREMENT,
  seq    TEXT,
  tip    TEXT NOT NULL,
  sec_id TEXT REFERENCES kb_section(sec_id)
);

-- -------------------------------------------------------------
-- 5. 专业层 maj_*  →  KB_MAJOR / KB_MAJOR_<专业代码>
-- -------------------------------------------------------------
CREATE TABLE maj_major (
  major_id     TEXT PRIMARY KEY,          -- SE / CS / VR
  name         TEXT NOT NULL,
  major_code   TEXT NOT NULL,             -- 510203 / 510201 / 510208
  kb_variable  TEXT NOT NULL,             -- KB_MAJOR_510203
  category_code TEXT,                     -- 51
  category_name TEXT,                     -- 电子与信息大类
  sub_category TEXT,                      -- 计算机类 5102
  group_name   TEXT,                      -- 软件技术专业群
  duration     TEXT,
  entry_req    TEXT,
  college_name TEXT,
  grad_credit  REAL, grad_hours INTEGER,
  cert_req     TEXT,
  practice_ratio TEXT,
  effective_note TEXT,
  compiled_by  TEXT, compiled_date TEXT,
  doc_id       TEXT REFERENCES gov_doc(doc_id)
);

CREATE TABLE maj_overview (
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  major_id TEXT NOT NULL REFERENCES maj_major(major_id),
  item     TEXT NOT NULL,
  value    TEXT,
  src_ref  TEXT
);

CREATE TABLE maj_career_orientation (
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  major_id TEXT NOT NULL REFERENCES maj_major(major_id),
  position_group TEXT NOT NULL,
  job_category   TEXT,                    -- 主要职业类别（代码）
  cert_hint      TEXT
);

CREATE TABLE maj_position_ladder (
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  major_id TEXT NOT NULL REFERENCES maj_major(major_id),
  seq      TEXT,
  direction TEXT,
  entry_position TEXT,
  develop_position TEXT
);

CREATE TABLE maj_core_ability (
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  major_id TEXT NOT NULL REFERENCES maj_major(major_id),
  direction TEXT,
  ability   TEXT
);

CREATE TABLE maj_certificate (
  cert_id   TEXT PRIMARY KEY,
  major_id  TEXT NOT NULL REFERENCES maj_major(major_id),
  seq       TEXT,
  cert_name TEXT NOT NULL,
  issuer    TEXT,
  cert_level TEXT,
  note      TEXT                          -- 是否排进课表 / 与毕业关联
);

CREATE TABLE maj_course_platform (
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  major_id TEXT NOT NULL REFERENCES maj_major(major_id),
  platform TEXT NOT NULL,                 -- 通识/专业/实践/就业与育人
  module   TEXT NOT NULL,                 -- 公共必修/专业群共享/专业核心...
  courses  TEXT
);

CREATE TABLE maj_course (
  course_id TEXT PRIMARY KEY,             -- SE-C01 / CS-26SI010101
  major_id  TEXT NOT NULL REFERENCES maj_major(major_id),
  course_code TEXT,
  course_name TEXT NOT NULL,
  module    TEXT,
  credit    REAL,
  hours_total INTEGER, hours_theory INTEGER, hours_practice INTEGER,
  assessment TEXT,                        -- 考试/考查/其他/—
  is_exam   INTEGER DEFAULT 0,
  is_competition INTEGER DEFAULT 0,
  note      TEXT
);

CREATE TABLE maj_semester (
  major_id TEXT NOT NULL REFERENCES maj_major(major_id),
  semester INTEGER NOT NULL,
  weeks_regular   REAL,
  weeks_cognition REAL,
  weeks_intern    REAL,
  weeks_practice  REAL,
  weeks_exam      REAL,
  weeks_flex      REAL,
  weeks_total     REAL,
  credit_sum      TEXT,                   -- 原文标注的学期学分（可能虚高，原文为准）
  hour_sum        TEXT,
  weekly_hours    TEXT,
  note            TEXT,
  PRIMARY KEY (major_id, semester)
);

CREATE TABLE maj_semester_course (
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  major_id TEXT NOT NULL REFERENCES maj_major(major_id),
  semester INTEGER NOT NULL,
  course_id TEXT REFERENCES maj_course(course_id),
  course_name TEXT,
  module   TEXT,
  schedule TEXT,                          -- x/yW 安排
  credit   REAL,
  hours    INTEGER,
  assessment TEXT
);
CREATE INDEX idx_msc_major_sem ON maj_semester_course(major_id, semester);

CREATE TABLE maj_path_coverage (
  major_id TEXT NOT NULL REFERENCES maj_major(major_id),
  path     TEXT NOT NULL,                 -- 就业 / 专插本·专升本 / 考编
  coverage TEXT NOT NULL,                 -- 充分覆盖 / 部分覆盖 / 未覆盖
  note     TEXT,
  PRIMARY KEY (major_id, path)
);

CREATE TABLE maj_key_node (
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  major_id TEXT NOT NULL REFERENCES maj_major(major_id),
  node_type TEXT NOT NULL,                -- 考试课/技能竞赛/考证课/岗位实习/实习节点
  semester INTEGER,
  detail   TEXT NOT NULL,
  src_ref  TEXT
);

CREATE TABLE maj_data_issue (
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  major_id TEXT,
  issue_no TEXT,
  issue    TEXT NOT NULL,
  handling TEXT
);

-- -------------------------------------------------------------
-- 6. 任务层 task_*（路线图只给定义与骨架，节点取自专业层真实数据）
-- -------------------------------------------------------------
CREATE TABLE task_path (
  path_id   TEXT PRIMARY KEY,
  name      TEXT NOT NULL,
  definition TEXT,
  note      TEXT
);

-- -------------------------------------------------------------
-- 7. 检索视图
-- -------------------------------------------------------------
CREATE VIEW v_school_card AS
SELECT s.name, s.code, s.identity_code, s.level, s.nature, s.run_type, s.supervisor,
       s.address, s.postcode, s.campus, s.area_mu, s.founded_year,
       s.college_cnt, s.major_cnt, s.staff, s.full_time_teacher,
       s.equipment_value, s.books, s.ebooks, s.plan_2026, s.stat_asof
FROM fact_school s;

CREATE VIEW v_major_timeline AS
SELECT m.major_code, m.name AS major_name, c.semester, c.module, c.course_name,
       c.credit, c.hours, c.schedule, c.assessment, k.course_code
FROM maj_semester_course c
JOIN maj_major m ON m.major_id = c.major_id
LEFT JOIN maj_course k ON k.course_id = c.course_id
ORDER BY m.major_code, c.semester, c.id;

CREATE VIEW v_major_exam_course AS
SELECT m.major_code, m.name AS major_name, c.semester, c.course_name, c.assessment
FROM maj_semester_course c JOIN maj_major m ON m.major_id = c.major_id
WHERE c.assessment = '考试';

CREATE VIEW v_position_card AS
SELECT p.pos_id, p.name, p.group_name, p.source_level, p.duty, p.salary_note,
       (SELECT group_concat(skill, '；') FROM act_position_skill s WHERE s.pos_id = p.pos_id) AS skills,
       (SELECT group_concat(cert,  '；') FROM act_position_cert  c WHERE c.pos_id = p.pos_id) AS certs,
       (SELECT group_concat(major_name, '、') FROM act_position_major x WHERE x.pos_id = p.pos_id) AS majors
FROM act_position p;

CREATE VIEW v_major_position AS
SELECT p.name AS position_name, p.group_name,
       (SELECT mp.major_name FROM act_position_major x
          JOIN act_major_position mp ON mp.major_name = x.major_name
         WHERE x.pos_id = p.pos_id LIMIT 1) AS school_major
FROM act_position p;

CREATE VIEW v_salary_lookup AS
SELECT job_name, p50 AS median, p25, p75, p10, p90, unit, period, metric_caliber, source_level
FROM act_salary_stat;

CREATE VIEW v_gap_all AS
SELECT doc_id, scope, gap_title, status, answer_rule, advise FROM gov_gap;

CREATE VIEW v_roadmap_step AS
SELECT m.major_code, m.name AS major_name, c.semester,
       group_concat(CASE WHEN c.assessment='考试' THEN c.course_name END, '、') AS exam_courses,
       group_concat(CASE WHEN c.module='企业实践' THEN c.course_name END, '、') AS practice,
       group_concat(CASE WHEN c.module IN ('专业延展') THEN c.course_name END, '、') AS cert_course
FROM maj_semester_course c JOIN maj_major m ON m.major_id = c.major_id
GROUP BY m.major_code, m.name, c.semester
ORDER BY m.major_code, c.semester;

CREATE VIEW v_variable_route AS
SELECT v.var_name, l.layer_name, v.var_level, v.target, v.usage_note,
       l.route_priority
FROM gov_variable v LEFT JOIN gov_layer l ON l.layer_code = v.layer_code
ORDER BY l.route_priority, v.var_name;
