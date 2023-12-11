#!/usr/bin/env bash

# Clone directory and install using renv.
cd $HOME
git clone https://github.com/ohdsi-studies/LegendT2dm
cd LegendT2dm

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

# Activate
Rscript -e 'renv::activate()'

# Rebuild the environment.
Rscript -e 'renv::rebuild()'

# And restore.
Rscript -e 'renv::restore()'
