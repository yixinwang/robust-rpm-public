data {
  int N;
  int<lower=0> y[N];
  real<lower=0> a;
  real<lower=0> b;
  real<lower=0> beta_a;  
  real<lower=0> beta_b;  
}
parameters {
  real<lower=0> theta;
  vector<lower=0,upper=1>[N] v;
}
model {
  v ~ beta(beta_a, beta_b);
  theta ~ gamma(a, b);
  for (n in 1:N) {
    increment_log_prob(v[n] * poisson_log(y[n], theta));
  }
}
