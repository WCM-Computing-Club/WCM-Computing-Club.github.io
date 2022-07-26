
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
data_in <- here("data", "bmi-rct-data.rds")

# data import -------------------------------------------------------------

bmi <- readRDS(data_in)

# analysis ----------------------------------------------------------------

trt <- c("A1", "A2")
out <- "month12BMI"
bas <- c("gender", "race")
tim <- list(c("baselineBMI"), c("month4BMI"))

# sl3 learners
# going to use an ensemble of intercept only, GLM, and extreme gradient boosting
lrnrs <- make_learner_stack(Lrnr_mean, 
                            Lrnr_glm, 
                            Lrnr_xgboost)

# shift function for a dynamic treatment regime
# lets estimate the population mean outcome under a dynamic treatment regime where
# everyone is treated at time 1. At time 2, everyone of gender 1 is treated and 
# only those of gender 0 are treated if their BMI is greater than 30 at month 4. 
policy.dyn <- function(data, trt) {
  purrr::map_dbl(1:nrow(data), function(x) {
    if (trt == "A1") 1
    else {
      if (data[["gender"]][x] == 1) 1
      else {
        if (data[["month4BMI"]][x] > 35) 1
        else 0
      }
    }
  })
}

head(bmi$A1)
head(policy.dyn(bmi, "A1"))
head(bmi$A2)
head(policy.dyn(bmi, "A2"))

plan(multiprocess)

# dynamic treatment regime
with_progress({
  psi.tmle.dyn <- lmtp_tmle(bmi, trt, out, bas, tim, shift = policy.dyn, 
                            outcome_type = "continuous", learners_trt = lrnrs, 
                            learners_outcome = lrnrs, folds = 5)
})

with_progress({
  psi.sdr.dyn <- lmtp_sdr(bmi, trt, out, bas, tim, shift = policy.dyn, 
                          outcome_type = "continuous", learners_trt = lrnrs, 
                          learners_outcome = lrnrs, folds = 5)
})

# we can compare it to a static treatment regime where everyone gets the treatment
with_progress({
  psi.tmle.stc <- lmtp_tmle(bmi, trt, out, bas, tim, shift = static_binary_on, 
                            outcome_type = "continuous", learners_trt = lrnrs, 
                            learners_outcome = lrnrs, folds = 5)
})

with_progress({
  psi.sdr.stc <- lmtp_sdr(bmi, trt, out, bas, tim, shift = static_binary_on, 
                          outcome_type = "continuous", learners_trt = lrnrs, 
                          learners_outcome = lrnrs, folds = 5)
})

# and where no one gets the treatmetn
with_progress({
  psi.tmle.off <- lmtp_tmle(bmi, trt, out, bas, tim, shift = static_binary_off, 
                            outcome_type = "continuous", learners_trt = lrnrs, 
                            learners_outcome = lrnrs, folds = 5)
})

with_progress({
  psi.sdr.off <- lmtp_sdr(bmi, trt, out, bas, tim, shift = static_binary_off, 
                          outcome_type = "continuous", learners_trt = lrnrs, 
                          learners_outcome = lrnrs, folds = 5)
})

# lets now obtain casual contrasts
# notice how we can compare multiple policies at once
lmtp_contrast(psi.tmle.dyn, psi.tmle.off, ref = psi.tmle.stc)




