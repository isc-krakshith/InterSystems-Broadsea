/usr/bin/keytool -importcert -file /home/ohdsi/certificateSQLaaS.pem -keystore /home/ohdsi/keystore.jks -alias IRIScert -storepass changeit -noprompt
rm /home/ohdsi/certificateSQLaaS.pem
##rm /usr/local/lib/R/site-library/FeatureExtraction/java/SqlRender-1.7.0.jar