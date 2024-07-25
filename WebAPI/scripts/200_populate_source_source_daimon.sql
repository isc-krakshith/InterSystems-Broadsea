-- OHDSI CDM source
INSERT INTO webapi.source( source_id, source_name, source_key, source_connection, source_dialect, username, password)

VALUES (2, 'OHDSI IRIS Database', 'IRIS','jdbc:IRIS://host.docker.internal:1972/USER', 'iris', '_SYSTEM', 'SYS');
--VALUES (2, 'OHDSI IRIS Database', 'IRIS','jdbc:IRIS://<hostname>.elb.us-west-2.amazonaws.com:443/USER/:::true>', 'iris', '<username>', '<password>');
-- CDM daimon
INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (4, 2, 0, 'OMOPCDM54', 0);

-- VOCABULARY daimon
INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (5, 2, 1, 'OMOPCDM54', 10);

-- RESULTS daimon
INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (6, 2, 2, 'OMOPCDM54_RESULTS', 0);

-- EVIDENCE daimon - no evidence data to load in demo dataset
-- INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (4, 1, 3, 'demo_cdm_results', 0);
