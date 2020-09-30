# This script launches the ANTS container with the correct binding points
# The home directory will serve as the output directory

docker run --rm -ti --entrypoint=/bin/bash \
  -v /Users/butellyn/Documents/ExtraLong/data/freesurferCrossSectional/fmriprepdir:/data \
  -v /Users/butellyn/Documents/ExtraLong/data/singleSubjectTemplates:/home \
  antsx/ants