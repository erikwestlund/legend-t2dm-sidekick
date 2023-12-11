#!/usr/bin/env bash

# We only need renv; renv restore will do the rest for our package management.
Rscript -e 'install.packages("renv", repos="https://cloud.r-project.org")'
