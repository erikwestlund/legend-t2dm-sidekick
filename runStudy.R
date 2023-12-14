# This is based upon Extra/CodeToRun.R in the LegendT2dm package.
#
# This scaffolds up the study and configures. The only changes required to run this study are
# swapping out the correct database credentials.

library(devtools)
renv::activate()
renv::restore()
devtools::load_all()

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