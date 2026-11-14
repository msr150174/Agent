CREATE TABLE admission_channels(
  channel TEXT, target TEXT, basis TEXT);

CREATE TABLE admission_rules(category TEXT, rule TEXT);

CREATE TABLE class_types(
  type_name TEXT, majors TEXT, note TEXT);

CREATE TABLE colleges(
  college_id INTEGER PRIMARY KEY, name TEXT, remark TEXT);

CREATE TABLE contacts(purpose TEXT, method TEXT);

CREATE TABLE data_gaps(
  kb TEXT, gap TEXT, status TEXT, suggestion TEXT, priority TEXT);

CREATE TABLE data_sources(
  src_code TEXT, name TEXT, url TEXT, status TEXT, used_for TEXT);

CREATE TABLE departments(name TEXT, affairs TEXT);

CREATE TABLE employment_data(
  year TEXT, employment_rate TEXT, avg_salary TEXT, note TEXT, source TEXT);

CREATE TABLE exam_scores(channel TEXT, score TEXT, year TEXT, note TEXT);

CREATE TABLE faq(question TEXT, answer TEXT);

CREATE TABLE financial_aid(
  item TEXT, target TEXT, standard TEXT, level TEXT);

CREATE TABLE hot_majors(major TEXT);

CREATE TABLE interview_tips(title TEXT, category TEXT, source_level TEXT, content TEXT);

CREATE TABLE kb_docs(
  doc_id TEXT PRIMARY KEY, doc_name TEXT, file_name TEXT,
  source_site TEXT, collected_at TEXT, scope TEXT, reliability TEXT);

CREATE TABLE key_programs(
  level TEXT, cnt TEXT, detail TEXT);

CREATE TABLE leadership(title TEXT, name TEXT, responsibility TEXT);

CREATE TABLE majors_positions(
  college TEXT, major TEXT, positions TEXT, has_national_std TEXT, note TEXT);

CREATE TABLE mh_articles(
  section TEXT, title TEXT, url TEXT, date TEXT, author TEXT, is_video INTEGER);

CREATE TABLE mh_boundary_types(
  type TEXT, meaning TEXT, scenario TEXT);

CREATE TABLE mh_bystander(item TEXT);

CREATE TABLE mh_crisis_levels(
  level TEXT, typical TEXT, principle TEXT);

CREATE TABLE mh_early_signals(direction TEXT, manifestation TEXT);

CREATE TABLE mh_help_paths(
  scenario TEXT, suggestion TEXT);

CREATE TABLE mh_id_dims(
  dimension TEXT, how TEXT, criterion TEXT);

CREATE TABLE mh_misconceptions(misconception TEXT, fact TEXT);

CREATE TABLE mh_psych_effects(
  effect TEXT, explanation TEXT, usage TEXT);

CREATE TABLE mh_red_flags(signal TEXT);

CREATE TABLE mh_seasonal(
  node TEXT, issue TEXT, preparation TEXT);

CREATE TABLE mh_self_help(type TEXT, description TEXT);

CREATE TABLE mh_topics(
  topic TEXT, content TEXT, source TEXT);

CREATE TABLE positions(
  title TEXT, category TEXT, source_level TEXT, source TEXT, source_url TEXT,
  published_at TEXT, effective_from TEXT, effective_to TEXT, region TEXT, paths TEXT,
  seg_what TEXT, seg_skills TEXT, seg_certificates TEXT, seg_salary TEXT, seg_majors TEXT);

CREATE TABLE resume_tips(title TEXT, category TEXT, source_level TEXT, content TEXT);

CREATE TABLE rights_traps(
  title TEXT, category TEXT, source_level TEXT, source TEXT,
  content TEXT, effective_date TEXT, fixed_ending TEXT);

CREATE TABLE salary_percentiles(
  rank INTEGER, job TEXT, p10 INTEGER, p25 INTEGER, p50 INTEGER, p75 INTEGER, p90 INTEGER,
  source TEXT, period TEXT, unit TEXT);

CREATE TABLE school_enterprise(item TEXT);

CREATE TABLE school_overview(
  key TEXT PRIMARY KEY, value TEXT, source TEXT, as_of TEXT);

CREATE TABLE training_directions(
  name TEXT, positioning TEXT, courses TEXT, certificates TEXT, employment TEXT);

CREATE TABLE tuition(
  category TEXT, fee_yearly INTEGER, note TEXT);
