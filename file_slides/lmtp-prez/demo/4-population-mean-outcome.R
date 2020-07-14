
# Nick Williams
# Research Biostatistician
# Department of Population Health Sciences
# Weill Cornell Medicine

# packages ----------------------------------------------------------------

library(lmtp)
library(sl3)
library(future)
library(progressr)

# global ------------------------------------------------------------------

# paths
data_in <- here("data", "simulated-na.rds")

# data import -------------------------------------------------------------

sim <- readRDS(data_in)

# analysis ----------------------------------------------------------------

# say we have censoring and want to obtain an estimate of the 
# true population mean outcome under the observed exposures
# we can't use the empirical mean because it is biased due to missingness
# we can use lmtp though by setting shift = NULL!
# this is because estimating this outcome is equivalent to estimating 
# the effect of an intervention where the intervention is preventing censoring
mean(sim$Y, na.rm = T)

trt <- paste0("A_", 1:4)
cen <- paste0("C_", 1:4) # introducing censoring indicators
tim <- lapply(1:4, function(x) paste0("L_", x)) # introducing time varying covariates
out <- "Y"

# sl3 learners
# going to use an ensemble of intercept only, GLM, and extreme gradient boosting
lrnrs <- make_learner_stack(Lrnr_mean, 
                            Lrnr_glm, 
                            Lrnr_xgboost)

plan(multiprocess)

with_progress({
  psi.tmle <- lmtp_tmle(sim, trt, out, time_vary = tim, cens = cen, shift = NULL, 
                        learners_outcome = lrnrs, learners_trt = lrnrs, 
                        folds = 2) # would normally set folds to 10
})

with_progress({
  psi.sdr <- lmtp_sdr(sim, trt, out, time_vary = tim, cens = cen, shift = NULL, 
                      learners_outcome = lrnrs, learners_trt = lrnrs, 
                      folds = 2) # would normally set folds to 10
})
