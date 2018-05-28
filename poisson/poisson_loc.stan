data {
  int N;
  int<lower=0> y[N];
  real a;
  real b;
}
parameters {
  real<lower=0> theta;
  vector<lower=0>[N] theta_loc;
  real<lower=0> sigma;
}
model {
  theta ~ gamma(a,b);
  sigma ~ lognormal(0, 10);
  theta_loc ~ normal(theta, sigma);
  for (n in 1:N)
    y[n] ~ poisson(theta_loc[n]);
}
