docker commit 2e1e899d2626 sween/atlas
docker commit 50fc1b9ff142 sween/broadsea-hades
docker commit 04ba47947c19 sween/broadsea-atlasdb
docker commit dd9088a4adc8 sween/intersystems-broadsea-ohdsi-webapi-local
docker commit 146635a50693 sween/nginx

docker tag sween/atlas sween/atlas:latest
docker tag sween/broadsea-hades sween/broadsea-hades:4.2.1
docker tag sween/broadsea-atlasdb sween/broadsea-atlasdb:2.0.0
docker tag sween/nginx sween/nginx:latest
docker tag sween/intersystems-broadsea-ohdsi-webapi-local sween/intersystems-broadsea-ohdsi-webapi-local:latest


docker push sween/atlas:latest
docker push sween/broadsea-hades:4.2.1
docker push sween/broadsea-atlasdb:2.0.0
docker push sween/nginx:latest
docker push sween/intersystems-broadsea-ohdsi-webapi-local:latest