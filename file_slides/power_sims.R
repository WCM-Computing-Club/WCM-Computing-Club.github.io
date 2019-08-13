################################
# Power simulations in R
# Katherine Hoffman
# WCM Computing Club
# August 13, 2019
################################

library(tidyverse)

# Generate and analyze one data set ---------------------------------------

# Data generation parameters
n <- 100 # sample size of the experiment
mu <- 50 # population mean of controls
sd <- 10 # standard deviation of the population
delta <- 5 # treatment effect size 
A <- rep(c(0,1), each=n/2) # treatment assignments, assuming equal group sizes

# Generate outcomes
Y <- rnorm(n, mean = mu, sd = sd) + A*delta

# Full data set (it's giant!)
dat <- tibble(A, Y)
dat

# Sanity check
dat %>%
  mutate(A = factor(A, levels=0:1, labels=c("cont","trt"))) %>%
  ggplot(aes(Y, fill=A)) +
  geom_density(alpha=.5) +
  ggtitle("Distribution of Y under Treatment and Control")

# Fit a model
fit <- lm(Y ~ A, data = dat) # a linear model for the effect of treatment A on the outcome Y
summary(fit) 
summary(fit)$coefficients[2,4] # extract the p-value from the model summary



# Turn it into a simulation -----------------------------------------------

rm(list=ls())

alpha <- .05 # type I error rate
sims <- 500 # number of simulations
sign <- c() # an empty vector to hold the results of the significance test

for (i in 1:sims){
  n <- 100 # sample size of the experiment
  mu <- 50 # population mean of controls
  sd <- 10 # standard deviation of the population
  delta <- 5 # treatment effect size 
  A <- rep(c(0,1), each=n/2) # treatment assignments, assuming equal group sizes
  Y <- rnorm(n, mean = mu, sd = sd) + A*delta
  dat <- tibble(A, Y)
  fit <- lm(Y~A, data=dat)
  p_val <- summary(fit)$coefficients[2,4] # save the p-value
  sign[i] <- p_val <= alpha # to save whether the p-value is less than .05
}

power <- mean(sign)
power # this is our power!


# Vary the sample size ----------------------------------------------------

rm(list=ls()) 
alpha <- .05 # type I error rate
sims <- 500 # number of simulations
sign <- c() # an empty vector to hold the results of the significance test
n_sizes <- seq(10, 200, by=10)
power <- tibble()
power <- c()

for (j in 1:length(n_sizes)){
  n <- n_sizes[j]
  for(i in 1:sims){
    mu <- 50 # population mean of controls
    sd <- 10 # standard deviation of the population
    delta <- 5 # treatment effect size 
    A <- rep(c(0,1), each=n/2) # treatment assignments, assuming equal group sizes
    Y <- rnorm(n, mean = mu, sd = sd) + A*delta
    dat <- tibble(A, Y)
    fit <- lm(Y~A, data=dat)
    p_val <- summary(fit)$coefficients[2,4] # save the p-value
    sign[i] <- p_val <= alpha # to save whether the p-value is less than .05
  }
  power[j] <- mean(sign)
}

p_curve <- tibble(n_sizes, power)
p_curve

ggplot(p_curve, aes(n_sizes, power)) +
  geom_line() + 
  labs(x="Sample Size (n)", y="Power",
       title="Power Curve for Linear Regression of a Binary Treatment") +
  ylim(0,1) +
  geom_hline(yintercept = .8, linetype="dashed")



# Vary the sample and effect sizes ------------------------------------------

rm(list=ls()) 
alpha <- .05 # type I error rate
sims <- 200 # number of simulations
sign <- c() # an empty vector to hold the results of the significance test
n_sizes <- seq(10, 200, by=10)
deltas <- c(3,5,8)
power_table <- tibble(delta = rep(deltas, each=length(n_sizes)),
                      n = rep(n_sizes, times = length(deltas)),
                      power = rep(NA)) # table to keep track of our power
count <- 0 # to keep track of each n and delta combo

for (k in 1:length(deltas)){
  delta <- deltas[k]
for (j in 1:length(n_sizes)){
  n <- n_sizes[j]
  count <- count+1
for (i in 1:sims){
    mu <- 50 # population mean of controls
    sd <- 10 # standard deviation of the population
    A <- rep(c(0,1), each=n/2) # treatment assignments, assuming equal group sizes
    Y <- rnorm(n, mean = mu, sd = sd) + A*delta
    dat <- tibble(A, Y)
    fit <- lm(Y~A, data=dat)
    p_val <- summary(fit)$coefficients[2,4] # save the p-value
    sign[i] <- p_val <= alpha # to save whether the p-value is less than .05
}
  power_table[count,"power"] <- mean(sign) # record power for each delta and n combo
  print(count) # helpful to check on sim status
}
}

power_table

# Plot the three different power curves (one for each delta)
ggplot(power_table, aes(n, power, col=factor(delta), group=factor(delta))) +
  geom_line() + 
  labs(x="Sample Size (n)", y="Power",
       title="Power Curve for Linear Regression of a Binary Treatment",
       col = "Effect Size") +
  ylim(0,1) +
  geom_hline(yintercept = .8, linetype="dashed")


