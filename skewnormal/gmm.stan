data {
  int N;            // number of data points
  int D;            // dimension
  int K;            // number of mixture components
  vector[D] X[N];   // dataset

  real<lower=0> alpha;   
}

transformed data{
  vector[K] alpha_vec;  // dirichlet prior
  for (k in 1:K)
    alpha_vec[k] <- alpha;
}

parameters {
  simplex[K] pi;                // mixing proportions
  vector[D] mu[K];              // locations of mixture components
  vector<lower=0>[D] sigma[K];  // standard deviations of mixture components
}

model {
  // priors
  pi ~ dirichlet(alpha_vec);
  for (k in 1:K) {
      mu[k] ~ normal(0.0, 10.0);
      sigma[k] ~ lognormal(0.0, 10.0);
  }

  // likelihood
  for (n in 1:N) {
    real ps[K];
    for (k in 1:K) 
      ps[k] <- log(pi[k]) + normal_log(X[n], mu[k], sigma[k]);
    target += log_sum_exp(ps);
  }
}
