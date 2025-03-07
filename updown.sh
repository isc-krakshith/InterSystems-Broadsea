export IRIS_USER="SQLAdmin"
export IRIS_PASS="REDACTED"
export IRIS_JDBC="jdbc:IRIS://k8s-0a6bc2ca-adb040ad-c7bf2ee7c6-e6b05ee242f76bf2.elb.us-east-1.amazonaws.com:443/USER/:::true"
export IRIS_DESCRIPTION="InterSystems OMOP Stage"
#export IRIS_JDBC="jdbc:IRIS://192.168.1.200:1972/USER"

docker-compose --profile default down
# Danger Will Robinson, uncomment
docker volume prune -a -f
sleep 5
docker-compose pull
docker-compose --profile default up --build -d
sleep 60
## POST CONFIGURATION
cat << 'EOF' > ./WebAPI/iriscert/certificateSQLaaS.pem
-----BEGIN CERTIFICATE-----

-----END CERTIFICATE-----
EOF

cat << EOF > ./WebAPI/scripts/200_populate_source_source_daimon.sql
INSERT INTO webapi.source( source_id, source_name, source_key, source_connection, source_dialect, username, password)
VALUES (2, '$IRIS_DESCRIPTION', 'IRIS', '$IRIS_JDBC', 'iris', '$IRIS_USER', '$IRIS_PASS');
INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (4, 2, 0, 'OMOPCDM54', 0);
INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (5, 2, 1, 'OMOPCDM54', 10);
INSERT INTO webapi.source_daimon( source_daimon_id, source_id, daimon_type, table_qualifier, priority) VALUES (6, 2, 2, 'OMOPCDM54_RESULTS', 0);
EOF

sleep 10
docker-compose exec broadsea-atlasdb psql -U postgres -f "/docker-entrypoint-initdb.d/200_populate_source_source_daimon.sql"
# 
docker cp ./WebAPI/assets/intersystems-jdbc-3.10.3.jar broadsea-hades:/opt/hades/jdbc_drivers/
##docker cp ./WebAPI/assets/SqlRender-1.16.1-SNAPSHOT.jar broadsea-hades:/usr/local/lib/R/site-library/SqlRender/java/SqlRender.jar
##docker cp ./WebAPI/assets/SqlRender-1.16.1-SNAPSHOT.jar broadsea-hades:/usr/local/lib/R/site-library/FeatureExtraction/java/
##
sleep 30
docker cp ./WebAPI/iriscert/certificateSQLaaS.pem broadsea-hades:/home/ohdsi/
docker cp ./WebAPI/iriscert/SSLConfigHades.properties broadsea-hades:/home/ohdsi/SSLConfig.properties
docker cp ./hades/hades_setup.r broadsea-hades:/home/ohdsi/hades_setup.r
docker cp ./hades/hades_run.r broadsea-hades:/home/ohdsi/hades_run.r
docker cp ./hades/hades_postsetup.sh broadsea-hades:/home/ohdsi/hades_postsetup.sh
docker exec -it broadsea-hades /usr/bin/bash -c "chmod +x /home/ohdsi/hades_postsetup.sh && exit" 
sleep 12
docker exec --user root broadsea-hades /usr/bin/bash -c "/home/ohdsi/hades_postsetup.sh"
##
sleep 15
wget http://127.0.0.1/WebAPI/source/refresh/
wget -O omop.ddl "http://127.0.0.1/WebAPI/ddl/results?dialect=iris&schema=OMOPCDM54_RESULTS&vocabSchema=OMOPCDM54&tempSchema=OMOP_TEMP&initConceptHierarchy=true"
docker cp omop.ddl broadsea-hades:/home/ohdsi/omop.ddl