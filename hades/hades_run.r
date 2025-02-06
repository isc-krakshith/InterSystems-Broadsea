conn <- connect(connectionDetails)
ddl_script <- readChar("omop.ddl", file.info("omop.ddl")$size)
executeSql(conn, ddl_script)
achilles(connectionDetails = connectionDetails, cdmDatabaseSchema = "OMOPCDM54", cdmVersion = "5.4",resultsDatabaseSchema = "OMOPCDM54_RESULTS", outputFolder = "output", optimizeAtlasCache = TRUE) 