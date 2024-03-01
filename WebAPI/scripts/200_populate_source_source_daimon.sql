-- OHDSI CDM source
INSERT INTO webapi.source( source_id, source_name, source_key, source_connection, source_dialect)
VALUES (2, 'OHDSI IRIS Database', 'IRIS','jdbc:IRIS://host.docker.internal:1972/USER?user=_system&password=SYS', 'iris');
-- CDM daimon
INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (4, 2, 0, 'demo_cdm', 0);

-- VOCABULARY daimon
INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (5, 2, 1, 'demo_cdm', 10);

-- RESULTS daimon
INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (6, 2, 2, 'demo_cdm_results', 0);

-- EVIDENCE daimon - no evidence data to load in demo dataset
-- INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (4, 1, 3, 'demo_cdm_results', 0);
