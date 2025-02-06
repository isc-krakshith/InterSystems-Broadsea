docker-compose --profile default down
docker volume prune -a -f
sleep 5
docker-compose pull
docker-compose --profile default up --build -d
sleep 45
## POST CONFIGURATION
docker-compose exec broadsea-atlasdb psql -U postgres -f "/docker-entrypoint-initdb.d/200_populate_source_source_daimon.sql"
# 
docker cp ./WebAPI/assets/intersystems-jdbc-3.10.1.jar broadsea-hades:/opt/hades/jdbc_drivers/
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