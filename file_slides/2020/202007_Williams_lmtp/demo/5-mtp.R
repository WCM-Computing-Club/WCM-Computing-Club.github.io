
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
data_in <- here("data", "simulated-na.rds")

# data import -------------------------------------------------------------

sim <- readRDS(data_in)

# analysis ----------------------------------------------------------------

trt <- paste0("A_", 1:4)
cen <- paste0("C_", 1:4) # introducing censoring indicators
tim <- lapply(1:4, function(x) paste0("L_", x)) # introducing time varying covariates
out <- "Y"

# sl3 learners
# going to use an ensemble of intercept only, GLM, and extreme gradient boosting
lrnrs <- make_learner_stack(Lrnr_mean, 
                            Lrnr_glm, 
                            Lrnr_xgboost)

# shift function
# we are now interested in the effect of a longitudinal modified treatment policy
# specifically, an MTP where treatment is decreased at each time point only if
# doing such won't make the treatment value go below 1
# lets first look at a version treating the exposure as a continuous variable
policy.num <- function(data, trt) {
  (data[[trt]] - 1) * (data[[trt]] - 1 >= 1) + data[[trt]] * (data[[trt]] - 1 < 1)
}

head(sim$A_1)
head(policy.num(sim, "A_1"))

plan(multiprocess)

with_progress({
  psi.tmle.num <- lmtp_tmle(sim, trt, out, time_vary = tim, cens = cen, shift = policy.num, 
                        learners_outcome = lrnrs, learners_trt = lrnrs, folds = 2) # would normally set folds to 10
})

with_progress({
  psi.sdr.num <- lmtp_sdr(sim, trt, out, time_vary = tim, cens = cen, shift = policy.num, 
                      learners_outcome = lrnrs, learners_trt = lrnrs, folds = 2) # would normally set folds to 10
})

# lets now look at the same shift function but when the exposure is treated 
# as an ordered factor
# this just converts the observed exposures to an ordered factor
for (i in trt) {
  sim[[i]] <- factor(sim[[i]], levels = 0:5, ordered = T)
}

# a shift function that respects that exposure is an ordered factor
policy.ord <- function(data, trt) {
  out <- list()
  for (i in 1:length(data[[trt]])) {
    if (as.character(data[[trt]][i]) %in% c("0", "1")) {
      out[[i]] <- as.character(data[[trt]][i])
    } else {
      out[[i]] <- as.numeric(as.character(data[[trt]][i])) - 1
    }
  }
  factor(unlist(out), levels = 0:5, ordered = T)
}

head(sim$A_1)
head(policy.ord(sim, "A_1"))

with_progress({
  psi.tmle.ord <- lmtp_tmle(sim, trt, out, time_vary = tim, cens = cen, shift = policy.ord, 
                        learners_outcome = lrnrs, learners_trt = lrnrs, folds = 2) # would normally set folds to 10
})

with_progress({
  psi.sdr.ord <- lmtp_sdr(sim, trt, out, time_vary = tim, cens = cen, shift = policy.ord, 
                      learners_outcome = lrnrs, learners_trt = lrnrs, folds = 2) # would normally set folds to 10
})

