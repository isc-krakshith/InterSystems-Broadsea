install.packages('Andromeda')
remotes::install_github("OHDSI/Achilles", force = TRUE)
remotes::install_github("OHDSI/DatabaseConnector", force = TRUE)
remotes::install_github("OHDSI/SqlRender", force = TRUE)
library(Andromeda)
library(DatabaseConnector)
library(Achilles)
library(SqlRender)