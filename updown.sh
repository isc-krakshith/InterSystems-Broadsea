export IRIS_USER="SQLAdmin"
export IRIS_PASS="REDACTED"
export IRIS_JDBC="jdbc:IRIS://k8s-0a6bc2ca-adb040ad-c7bf2ee7c6-e6b05ee242f76bf2.elb.us-east-1.amazonaws.com:443/USER/:::true"
#export IRIS_JDBC="jdbc:IRIS://192.168.1.162:1972/USER"

docker-compose --profile default down
# Danger Will Robinson, uncomment
docker volume prune -a -f
sleep 5
docker-compose pull
docker-compose --profile default up --build -d
sleep 30
## POST CONFIGURATION
cat << 'EOF' > ./WebAPI/iriscert/certificateSQLaaS.pem
-----BEGIN CERTIFICATE-----
MIIEqTCCA5GgAwIBAgIUXx8klJojVc86xAPTFDkJoE07YwMwDQYJKoZIhvcNAQEL
BQAwgZkxCzAJBgNVBAYTAlVTMRYwFAYDVQQIDA1NYXNzYWNodXNldHRzMQswCQYD
VQQHDAJVUzEhMB8GA1UECgwYSW50ZXJzeXN0ZW1zIENvcnBvcmF0aW9uMQ8wDQYD
VQQLDAZTUUxhYVMxMTAvBgNVBAMMKGE4ZmU2ZmNkOGZlMTk5NTEwZDg4ODgzNmFi
YTA5OTgzOS1kYXRhLTAwHhcNMjUwMTMxMZZxMzAwWhcNMjYwMTMxMTQxMzAwWjCB
mTELMAkGA1UEBhMCVVMxFjAUBgNVBAgMDU1hc3NhY2h1c2V0dHMxCzAJBgNVBAcM
AlVTMSEwHwYDVQQKDBhJbnRlcnN5c3RlbXMgQ29ycG9yYXRpb24xDzANBgNVBAsM
BlNRTGFhUzExMC8GA1UEAwwoYThmZTZmY2Q4ZmUxOTk1MTBkODg4ODM2YWJhMDk5
ODM5LWRhdGEtMDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJ2ie5b+
VSe3ydO5+GlNB5LeJbPA0ghd2g80zEJ7KzZnAQR8PVg6DJlPQhUH6F8UlKfG4xvj
+qPYh/MBrYckogj6ztGeW253ZsJcoXt+tQliOG4PRGHkw8PnHHHTMix+fgfsphlN
7s99/++YGfuo/iGEA1bSRTzdGQi+fHA2d9FKukgPL+aNbKbADENJjlfIgefuy28t
XRtzdT02lFQ2xAxL8sNgaueb9shEIsZSSqQ5TdeWLvoOsYfeAT/vJopOh3C6imTX
7LjZ3cstcXlQjjZuOdAHRaq6Xaik/z+GFYJulySVwgT3lWDk9pfGUmO7RGpgxZgv
nm6uR0dShaly8VsCAwEAAaOB5jCB4zAdBgNVHQ4EFgQUs2FrB/wuskOO8mHFuSQ0
LGE+614wHwYDVR0jBBgwFoAUs2FrB/wuskOO8mHFuSQ0LGE+614wDwYDVR0TAQH/
BAUwAwEB/zCBjwYDVR0RBIGHMIGEgihhOGZlNmZjZDhmZTE5OTUxMGQ4ODg4MzZh
YmEwOTk4MzktZGF0YS0wgglsb2NhbGhvc3SCTWs4cy0wYTZiYzJjYS1hZGIwNDBh
ZC1jN2JmMmVlN2M2LWU2YjA1ZWUyNDJmNzZiZjIuZWxiLnVzLWVhc3QtMS5hbWF6
b25hd3MuY29tMA0GCSqGSIb3DQEBCwUAA4IBAQA5LZg26VyRQGj7GxXt9hzK/GiD
B5f1tLu6JSoTCtPd+M1YEmhiAl3XJcsdD3Rew6j3EYyrT8qxpKLLMexvDvvGLV2w
Ru/yphunJdOz6v20WL99N2EALqSKO11VEgdtPnKPFbbKoSbyzrlFC1UXt6B0a4pY
DT/Zwpnn89S9PeIdXpg4k4FJkvBTbCPvzBMR7pulKD7+/AdpmRAx8UKRGGJxD9j6
x/Nv4xNzUHkVTK5XPUjEFoQN5m0vAXmCmRAS/KsOfeNmHS+nGNhxuxDgnfbZdgXg
otDYdlvsJJgPPNK6uYVWx9PlPTzpsH9vc7FVDpgYCdQHPbiVitvLrCcBXxjL
-----END CERTIFICATE-----
EOF

cat << EOF > ./WebAPI/scripts/200_populate_source_source_daimon.sql
INSERT INTO webapi.source( source_id, source_name, source_key, source_connection, source_dialect, username, password)
VALUES (2, 'OHDSI STAGE IRIS OMOP Database', 'IRIS', '$IRIS_JDBC', 'iris', '$IRIS_USER', '$IRIS_PASS');
INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (4, 2, 0, 'OMOPCDM54', 0);
INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (5, 2, 1, 'OMOPCDM54', 10);
INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (6, 2, 2, 'OMOPCDM54_RESULTS', 0);
EOF


docker-compose exec broadsea-atlasdb psql -U postgres -f "/docker-entrypoint-initdb.d/200_populate_source_source_daimon.sql"
# 
docker cp ./WebAPI/assets/intersystems-jdbc-3.10.3.jar broadsea-hades:/opt/hades/jdbc_drivers/
##docker cp ./WebAPI/assets/SqlRender-1.16.1-SNAPSHOT.jar broadsea-hades:/usr/local/lib/R/site-library/SqlRender/java/SqlRender.jar
##docker cp ./WebAPI/assets/SqlRender-1.16.1-SNAPSHOT.jar broadsea-hades:/usr/local/lib/R/site-library/FeatureExtraction/java/
##
sleep 5
docker cp ./WebAPI/iriscert/certificateSQLaaS.pem broadsea-hades:/home/ohdsi/
docker cp ./WebAPI/iriscert/SSLConfigHades.properties broadsea-hades:/home/ohdsi/SSLConfig.properties
docker cp ./hades/hades_setup.r broadsea-hades:/home/ohdsi/hades_setup.r
docker cp ./hades/hades_run.r broadsea-hades:/home/ohdsi/hades_run.r
docker cp ./hades/hades_postsetup.sh broadsea-hades:/home/ohdsi/hades_postsetup.sh
docker exec -it broadsea-hades /usr/bin/bash -c "chmod +x /home/ohdsi/hades_postsetup.sh && exit" 
sleep 2
docker exec --user root broadsea-hades /usr/bin/bash -c "/home/ohdsi/hades_postsetup.sh"
##
sleep 15
wget http://127.0.0.1/WebAPI/source/refresh/
wget -O omop.ddl "http://127.0.0.1/WebAPI/ddl/results?dialect=iris&schema=OMOPCDM54_RESULTS&vocabSchema=OMOPCDM54&tempSchema=OMOP_TEMP&initConceptHierarchy=true"
docker cp omop.ddl broadsea-hades:/home/ohdsi/omop.ddl