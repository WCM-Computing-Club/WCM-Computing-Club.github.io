
# Nick Williams
# Research Biostatistician
# Department of Population Health Sciences
# Weill Cornell Medicine

# packages ----------------------------------------------------------------

library(here)
library(lmtp)
library(sl3)
library(future)
library(progressr)

# global ------------------------------------------------------------------

# paths
data_in <- here("data", "ltmle-surv-data.rds")

# data import -------------------------------------------------------------

surv <- readRDS(data_in)
# 1. there are 2 variables for the outcome
# 2. when an observation experiences the event, they're future events are imputed using LOCF
#    this allows us to estimate the cumulative incidence of the event

# analysis ----------------------------------------------------------------

bas <- "L0.c"
tim <- list(c("L0.a", "L0.b"), # we can supply multiple time-varying covariates at each time point
            c("L1.a", "L1.b"))
trt <- c("A0", "A1")
cen <- c("C0", "C1")
out <- c("Y1", "Y2") # notice that we are now supplying a vector of outcomes

# sl3 learners
# going to use an ensemble of intercept only, GLM, and extreme gradient boosting
lrnrs <- make_learner_stack(Lrnr_mean, 
                            Lrnr_glm, 
                            Lrnr_xgboost)

plan(multiprocess)

# treating all
with_progress({
  psi.tmle.on <- lmtp_tmle(surv, trt, out, bas, tim, cen, 
                           shift = static_binary_on, learners_outcome = lrnrs, 
                           learners_trt = lrnrs, folds = 5) # again folds should really be 10
})

with_progress({
  psi.sdr.on <- lmtp_sdr(surv, trt, out, bas, tim, cen, 
                         shift = static_binary_on, learners_outcome = lrnrs, 
                         learners_trt = lrnrs, folds = 5) # again folds should really be 10
})

# treating none
with_progress({
  psi.tmle.off <- lmtp_tmle(surv, trt, out, bas, tim, cen, 
                            shift = static_binary_off, learners_outcome = lrnrs, 
                            learners_trt = lrnrs, folds = 5) # again folds should really be 10
})

with_progress({
  psi.sdr.off <- lmtp_sdr(surv, trt, out, bas, tim, cen, 
                          shift = static_binary_off, learners_outcome = lrnrs, 
                          learners_trt = lrnrs, folds = 5) # again folds should really be 10
})

# causal risk ratios
lmtp_contrast(psi.tmle.on, ref = psi.tmle.off, type = "rr")
lmtp_contrast(psi.sdr.on, ref = psi.sdr.off, type = "rr")

