library(arm)
library(rstan)
library(ggplot2)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())


# set prior parameters
N <- 100
a <- 2 # gamma prior on theta, the rate parameter of poisson
b <- 0.5
beta_a <- 0.1 # beta prior on weights
beta_b <- 0.01
alpha <- rep(1, N) # dirichlet prior on weights

# simulate data set of size N = 100 with 25% corruption
# first 75 observations are drawn from Poisson(5)
# last 25 observations are drawn from Poisson(50)

i = 5
corrupt <- 0.05 * i
filename <- sprintf("poisson.data_%.2f.R", corrupt)
y <- c(rpois(N - 5 * i, 5), rpois(5 * i, 50))
stan_rdump(c("N", "y", "a", "b", "beta_a", "beta_b", 
    "alpha"), filename)


# Below we fit reweighted Poisson model, the classical 
# Poisson model, and localization by MCMC
# This reproduces Fig. 2a

###################################
# Reweighted Probabilistic Model
###################################

# fit RPM with dirichlet priors on weights

# # mcmc
# fit_dirichlet <- stan(file='poisson_wt_dirichlet.stan', data = read_rdump(filename))

# advi (much faster)
m_dirichlet <- stan_model(file='poisson_wt_dirichlet.stan')
fit_dirichlet <- vb(m_dirichlet, data = read_rdump(filename), iter = 50000)

fit_dirichlet_sp <- extract(fit_dirichlet)$theta
print("Reweighted Probabilistic Model with Dirichlet weighting")
print(summary(fit_dirichlet_sp))

# fit RPM with beta priors on weights

# # mcmc
# fit_beta <- stan(file='poisson_wt_beta.stan', data = read_rdump(filename))

# advi (much faster)
m_beta <- stan_model(file='poisson_wt_beta.stan')
fit_beta <- vb(m_beta, data = read_rdump(filename), iter = 50000)

fit_beta_sp <- extract(fit_beta)$theta
print("Reweighted Probabilistic Model with Beta weighting")
print(summary(fit_beta_sp))

###################################
# Classical Probabilistic Model
###################################

# # mcmc
# fit_unwt <- stan(file='poisson_unwt.stan', data = read_rdump(filename))

# advi (much faster)
m_unwt <- stan_model(file='poisson_unwt.stan')
fit_unwt <- vb(m_unwt, data = read_rdump(filename), iter = 50000)

fit_unwt_sp <- extract(fit_unwt)$theta
print("Classical Probabilistic Model")
print(summary(fit_unwt_sp))

###################################
# Localized Probabilistic Model
###################################

# # mcmc
# fit_loc <- stan(file='poisson_loc.stan', data = read_rdump(filename)) 

# advi (much faster)
m_loc <- stan_model(file='poisson_loc.stan')
fit_loc <- vb(m_loc, data = read_rdump(filename), iter = 50000)

fit_loc_sp <- extract(fit_loc)$theta
print("Localized Probabilistic Model")
print(summary(fit_loc_sp))


# this is the gamma(a, b) prior we specified
prior_sp <- rgamma(1000, a, b)

#save samples
dat <- data.frame(theta = c(fit_unwt_sp, fit_beta_sp, 
	fit_dirichlet_sp, fit_loc_sp, prior_sp),
 models = rep(c("unweighted", "weighted - beta",
 	"weighted - dirichlet", "localization", "prior"), 
 c(length(fit_unwt_sp), length(fit_beta_sp),
 	length(fit_dirichlet_sp), length(fit_loc_sp), length(prior_sp))))

write.csv(dat, "poisson25corrupt.csv", quote = F, row.names = F)


# Plot posterior density comparison (Fig. 2a)
print(ggplot(dat, aes(x = theta, fill = models)) + 
geom_density(adjust = 8, alpha = 0.4) + xlim(0, 30) + 
geom_vline(xintercept = 5, linetype = "longdash"))


