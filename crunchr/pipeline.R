system("sudo yum install java-11-openjdk-devel")
install.packages("renv", repos="https://cloud.r-project.org")
install.packages("devtools", repos="https://cloud.r-project.org")

system("git clone https://github.com/ohdsi-studies/LegendT2dm $HOME/workspace/HOME/code/LegendT2dm/")

library(devtools)
library(renv)

renv::activate()

# For now, let's just make this work, which involves some manual editing.
# It appears that the environment for renv stored upon save assumed renv v1.0.3.
# However, the lock file disagrees.
# Open editor (vi, nano, etc.) and make the renv entry look like:
#
# "renv": {
#   "Package": "renv",
#   "Version": "0.13.2",
#   "Source": "Repository",
#   "Repository": "CRAN"
# }
#
# Then edit the cpp11 entry in the lockfile
# to be Version 0.1.0 and remove the hash and correct the json.
#
# "cpp11": {
#   "Package": "cpp11",
#   "Version": "0.1.0",
#   "Source": "Repository",
#   "Repository": "CRAN"
# }
#
# We can work this to be automatic with sed with some work or just pull in a new
# working lockfile as a pull request.

# We then need to activate, restore the correct renv version, then
# rebuild the lock file, then restore the packages.
#
# This is all necessary because cpp11 version 0.2.7 in the lockfile will not compile.
# Not even in the provided Dockerfile.

renv::rebuild()
renv::restore()

system("mkdir -p $HOME/HOME/code/legend-t2dm/DatabaseDrivers")
system('export DATABASECONNECTOR_JAR_FOLDER="$HOME/LegendT2dm/DatabaseDrivers"')

system("mkdir -p $HOME/LegendT2dm/AndromedaTemp")
system('export ANDROMEDA_TEMP_FOLDER="$HOME/LegendT2dm/AndromedaTemp"')

system("mkdir -p $HOME/LegendT2dm/StudyResult")
system('export STUDY_RESULTS_FOLDER="$HOME/LegendT2dm/StudyResults"')

# Run Study

# Run-once: set-up your database driver
DatabaseConnector::downloadJdbcDrivers(dbms = "postgresql")

# Optional: specify where the temporary files (used by the Andromeda package) will be created:
options(andromedaTempFolder = Sys.getenv("ANDROMEDA_TEMP_FOLDER"))

# Maximum number of cores to be used:
maxCores <- min(8, parallel::detectCores()) # Or more depending on your hardware

# Minimum cell count when exporting data:
minCellCount <- 5

# Patch for Oracle (if necessary)
oracleTempSchema <- NULL

# The folder where the study intermediate and result files will be written:
outputFolder <- Sys.getenv("STUDY_RESULTS_FOLDER")

# Details for connecting to the server:
# Ensure these credentials are correct
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "postgresql",
                                                                server = "0.0.0.0/postgres",
                                                                user = "ohdsi",
                                                                password = "ohdsi")

# The name of the database schema where the CDM data can be found:
cdmDatabaseSchema <- "cdm"

# The name of the database schema and table where the study-specific cohorts will be instantiated:
cohortDatabaseSchema <- "scratch"
tablePrefix <- "legendt2dm_study"

# Some meta-information that will be used by the export function:
databaseId <- "Synpuf"
databaseName <- "Medicare Claims Synthetic Public Use Files (SynPUFs)"
databaseDescription <- "Medicare Claims Synthetic Public Use Files (SynPUFs) were created to allow interested parties to gain familiarity using Medicare claims data while protecting beneficiary privacy. These files are intended to promote development of software and applications that utilize files in this format, train researchers on the use and complexities of Centers for Medicare and Medicaid Services (CMS) claims, and support safe data mining innovations. The SynPUFs were created by combining randomized information from multiple unique beneficiaries and changing variable values. This randomization and combining of beneficiary information ensures privacy of health information."

# For some database platforms (e.g. Oracle): define a schema that can be used to emulate temp tables:
options(sqlRenderTempEmulationSchema = NULL)

indicationId <- "class"
filterOutcomeCohorts <- NULL
filterExposureCohorts <- NULL

# Get the cohorts
createOutcomeCohorts(connectionDetails,
                       cdmDatabaseSchema,
                       cdmDatabaseSchema,
                       cohortDatabaseSchema,
                       tablePrefix,
                       oracleTempSchema,
                       outputFolder,
                       databaseId,
                       filterOutcomeCohorts = NULL)

createExposureCohorts(connectionDetails = connectionDetails,
                      cdmDatabaseSchema = cdmDatabaseSchema,
                      vocabularyDatabaseSchema = cdmDatabaseSchema,
                      cohortDatabaseSchema = cohortDatabaseSchema,
                      tablePrefix = tablePrefix,
                      indicationId = indicationId,
                      oracleTempSchema = oracleTempSchema,
                      outputFolder = outputFolder,
                      databaseId = databaseId,
                      filterExposureCohorts = filterExposureCohorts)