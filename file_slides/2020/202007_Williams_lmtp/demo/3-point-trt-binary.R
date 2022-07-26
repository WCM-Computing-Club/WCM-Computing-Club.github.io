
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
data_in <- here("data", "rhc-data.rds")

# data import -------------------------------------------------------------

rhc <- as.data.frame(readRDS(data_in))

# analysis ----------------------------------------------------------------

trt <- "treatment" 
out <- "died"
cnf <- names(rhc)[!(names(rhc) %in% c(trt, out))]

# sl3 learners
# going to use an ensemble of intercept only, GLM, and extreme gradient boosting
lrnrs <- make_learner_stack(Lrnr_mean, 
                            Lrnr_glm, 
                            Lrnr_xgboost)

# parallel processing
plan(multiprocess)

# treatment specific mean (TSM) when everyone got the RHC
with_progress({
  psi.all.tmle <- lmtp_tmle(data = rhc, 
                            trt = trt, 
                            outcome = out, 
                            baseline = cnf, 
                            shift = static_binary_on, 
                            learners_outcome = lrnrs, 
                            learners_trt = lrnrs, 
                            folds = 2) # would normally set this to 10
})

with_progress({
  psi.all.sdr <- lmtp_sdr(rhc, trt, out, cnf, shift = static_binary_on, 
                          learners_outcome = lrnrs, learners_trt = lrnrs, 
                          folds = 2) # would normally set this to 10
})

# TSM when no one got the RHC
with_progress({
  psi.none.tmle <- lmtp_tmle(rhc, trt, out, cnf, shift = static_binary_off, 
                             learners_outcome = lrnrs, learners_trt = lrnrs, 
                             folds = 2) # would normally set this to 10
})

with_progress({
  psi.none.sdr <- lmtp_sdr(rhc, trt, out, cnf, shift = static_binary_off, 
                           learners_outcome = lrnrs, learners_trt = lrnrs, 
                           folds = 2) # would normally set this to 10
})

# what if we want the causal relative risk? 
# can use lmtp_contrast
lmtp_contrast(psi.all.tmle, ref = psi.none.tmle, type = "rr")
lmtp_contrast(psi.all.sdr, ref = psi.none.sdr, type = "rr")

# BONUS: need the results tidied?
# lmtp already has a broom::tidy method
tidy(psi.all.tmle)
