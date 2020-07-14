
# Nick Williams
# Research Biostatistician
# Department of Population Health Sciences
# Weill Cornell Medicine

# packages ----------------------------------------------------------------

library(lmtp)
library(sl3)
library(future)
library(progressr)

# specifying covariates ---------------------------------------------------

# In the lmtp framework, there are 5 types of variables: treatment, outcome, 
# baseline, time-varying, and censoring. Treatment and outcome variables 
# are self-explanatory, baseline variables are those that are observed pre-treatment 
# allocation, don’t change (i.e., age at treatment assignment), and always are used 
# for estimation at all time points, time-varying variables are variables that (you guessed it…) 
# change over time, censoring nodes indicate if an observation is 
# observed (or censored) at the next time-point.

# How these nodes are specified depends on the specific data generating 
# mechanism and should be pre-specified based on a conceptual model (i.e, a DAG). 
# How these nodes are used by lmtp estimators is specified by what we call a node list. 
# The analyst doesn’t explicitly create the node list themselves, but instead supplies 
# the variables and the instructions on how to combine; this is done through the k parameter.
# when in doubt, use k = Inf

# let's consider a longitudinal study with 1 baseline confounder, W
# 3 time-varying treatment nodes, A1, A2, A3
# 3 time-varying confounders, L1, L2, L3, 
# and an outcome at time 4, Y.
a <- c("A1", "A2", "A3") # treatments are established using a vector ordered by time (same with censoring nodes)
baseline <- c("W") # baseline confounders are established using a vector
nodes <- list(c("L1"), # time-varying covariates are established using a LIST ordered by time
              c("L2"), # this allows for multiple time-varying covariates at each time point
              c("L3"))

# we can make sure our specification is correct by checking create_node_list()
create_node_list(a, 3, nodes, baseline = baseline, k = Inf)
# by changing k we can adjust the 
create_node_list(a, 3, nodes, baseline = baseline, k = 0) 

# writing shift functions -------------------------------------------------

# How do we communicate an intervention of interest to lmtp? 
# We will use a concept called a shift function. Shift functions
# are user defined R functions with 2 parameters. The first for the 
# name of the data set and the second for the name of the current treatment 
# variable

# the general form is: 
shift.function <- function(data, trt) {
  # some code that modifies the treatment
}

# the shift function should return a vector the same length and type 
# as the observed treatment but modified according the intervention 
# of interest

# For example, a shift function for an intervention that decreases 
# the natural value of the exposure by 5 units would just be: 
down.5 <- function(data, trt) {
  data[[trt]] - 5
}

# this is a general purpose framework that will allow us to work 
# with multiple variable types and implement complex interventions
# We will go over more complex functions throughout

# using sl3 ---------------------------------------------------------------

# the sl3 package is used to implement the Super Learner algorithm
# the analyst must first create sl3 learner stacks which contain the 
# individual models that are to be combined
# this can be done in a couple of ways, but the easiest is to use the 
# make_learner_stack() function

# For example, an ensemble of an intercept only model, a GLM, and a random 
# forest could be created using: 
lrnrs <- make_learner_stack(Lrnr_mean, Lrnr_glm, Lrnr_ranger)

# we can adjust hyperparameters by using a list within make_learner_stack()
# for example, lets adjust the number of trees in that random forest: 
lrnrs <- make_learner_stack(Lrnr_mean, 
                            Lrnr_glm, 
                            list(Lrnr_ranger, num.trees = 1000))

# parallel processing -----------------------------------------------------

# computation time can take a while with lots of time points and observations
# lmtp is setup to use parallel processing based on the future package
# the simplest invocation of this is to use plan(multiprocess) before calling an 
# lmtp estimator
plan(multiprocess)

# progress bars -----------------------------------------------------------

# whats more annoying than long computation time? long computation time 
# with zero user feedback. Don't fret, lmtp is also setup to use progress bars
# through the progressr package
# all you have to do is wrap estimators in with_progress()
with_progress({
  fit <- ...
})
