
# Nick Williams
# Research Biostatistician
# Department of Population Health Sciences
# Weill Cornell Medicine

# We need to install the necessary packages to start
# This also just includes packages used for the presentation
# Packages on CRAN
need <- c("devtools", "here", "progressr", "future", "purrr")
install.packages(need)

# github packages
remotes::install_github("nt-williams/lmtp")
remotes::install_github("tlverse/sl3@devel")
