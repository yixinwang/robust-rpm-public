library(rstan)

# the data is generated from a mixture of 
# 3 skewed normal distributions with mixture 
# proportions 0.3, 0.3, 0.4
# following the set up in appendix D4.

source("skewnormal.data.R")

# set priors
alpha <- 1 # dirichlet prior on mixture proportions
beta_a <- 1 # beta prior on weights
beta_b <- 0.005

filename <- "skewnormal_wparams.data.R"

stan_rdump(c("N", "D", "K", "X", "alpha",
		"beta_a", "beta_b"), filename)

# Below we fit reweighted GMM and the classical GMM
# by Automatic Differentiation Variational Inference

###################################
# Reweighted Probabilistic Model
###################################

gmm_w_beta <- stan_model(file='gmm_w_beta.stan')
fit_wt <- vb(gmm_w_beta, iter = 80000, eta = 0.5, 
	tol_rel_obj = 1e-3, 
	# adapt_engaged = F, 
	data = read_rdump(filename))
pi_wt <- colMeans(extract(fit_wt)$pi)
mu_wt <- data.frame(colMeans(extract(fit_wt)$mu)[pi_wt > 0.1,])

# Extract posterior means of mixture proportions (K=30)
# Count number of proportions larger than 0.01 (3)
print("Reweighted Probabilistic Model")
print("mixture proportions")
print(pi_wt)
print("number of components")
print(sum(pi_wt > 0.1))

###################################
# Classical Probabilistic Model
###################################

gmm <- stan_model(file='gmm.stan') #unweighted
fit_unwt <- vb(gmm, iter = 80000, eta = 0.5, 
	tol_rel_obj = 1e-3, 
	adapt_engaged = F, 
	data = read_rdump(filename))
pi_unwt <- colMeans(extract(fit_unwt)$pi)
mu_unwt <- data.frame(colMeans(extract(fit_unwt)$mu)[pi_unwt > 0.1,])

# Extract posterior means of mixture proportions (K=30)
# Count number of proportions larger than 0.01 (8-4)
print("Classical Probabilistic Model")
print("mixture proportions")
print(pi_unwt)
print("number of components")
print(sum(pi_unwt > 0.1))

# there is some randomness in outcomes due to initialization
# may end up with 4-7 components in different runs
# but the number is always larger than the true 3.

# below we reproduce Fig.4
dat = data.frame(X)
colnames(dat) = c("x1", "x2")
colnames(mu_wt) = c("x1", "x2")
colnames(mu_unwt) = c("x1", "x2")

require(gridExtra)
plot_wt = ggplot(dat, aes(x1, x2)) + geom_point(color = "gray") + 
geom_point(data = mu_wt, aes(x1, x2), 
	shape = 4, size = 8) + ggtitle("Reweighted Model")


plot_unwt = ggplot(dat, aes(x1, x2)) + geom_point(color = "gray") + 
geom_point(data = mu_unwt, aes(x1, x2), 
	shape = 4, size = 8) + ggtitle("Classical Model")

grid.arrange(plot_wt, plot_unwt, ncol=2)