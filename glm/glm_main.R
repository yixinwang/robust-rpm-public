library(rstan)
library(ggplot2)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

p = 0.75
datfilename <- sprintf("glm_noint_latentgp_%2f.data.R", p)
source(datfilename)

# the data set is size 100
# top 75 observations (major group) are generated from 
# bernoulli(1/(1+exp(-0.5x)))
# last 25 observations (minor group)are generated from
# bernoulli(1/(1+exp(-0.01x)))

# set priors
alpha <- rep(1, N) # dirichlet prior on weights

filename <- sprintf("glm_noint_latentgp_%2f_wparams.data.R", p)

stan_rdump(c("N", "x", "y", "truebeta1", 
		"alpha"), filename)

# Below we fit reweighted GLM and the classical GLM
# by MCMC

###################################
# Reweighted Probabilistic Model
###################################

fit_wt <- stan(file='glm_noint_wt.stan', data = read_rdump(filename))

# posterior distribution of beta, the slope
# the posterior can accurately capture features
# of the major group
print("Reweighted Probabilistic Model")
print(summary(extract(fit_wt)$beta))

# posterior means of weights
# this produces a similar figure to Fig. 3b
# showing that the RPM is able to correctly identify
# the missed minor group
w_wt_sp <- extract(fit_wt)$w
weight <- colMeans(w_wt_sp)
group = c(rep("major", p * N), rep("minor", (N - p * N)))
dat <- data.frame(group = group, weight = weight)
boxplot(weight~group, data = dat, ylab = "weights")


###################################
# Classical Probabilistic Model
###################################

fit_unwt <- stan(file='glm_noint_unwt.stan', data = read_rdump(filename))

# posterior distribution of beta, the slope
# the posterior is biased toward the minor group
print("Classical Probabilistic Model")
print(summary(extract(fit_unwt)$beta))


