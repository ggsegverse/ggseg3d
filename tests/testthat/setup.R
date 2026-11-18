# rgl opens a real OpenGL window the moment a device is needed, which during
# a test run means one popping up over whatever you are doing -- and on a
# headless machine, a failure instead of a skip. Both the option and the
# environment variable are set: rgl reads RGL_USE_NULL when its namespace
# loads, and the option covers the case where it was already loaded.
#
# Here rather than in a test file: this used to sit on line 1 of
# test-rayshader.R, but testthat runs test-add-points.R first and that opens
# a device through ggsegray(), so the window appeared before the option was
# ever set.
Sys.setenv(RGL_USE_NULL = "TRUE")
options(rgl.useNULL = TRUE)

library(tidyr, quietly = TRUE, warn.conflicts = FALSE)
library(ggseg.formats, quietly = TRUE, warn.conflicts = FALSE)
library(ggseg3d, quietly = TRUE, warn.conflicts = FALSE)
