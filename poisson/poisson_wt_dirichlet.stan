data {
  int N;
  int<lower=0> y[N];
  real a;
  real b;
  vector<lower=0>[N] alpha;  
}
parameters {
  real<lower=0> theta;
  simplex[N] v;
}
transformed parameters{
  vector[N] w;
  w <- N * v;
}
model {
  v ~ dirichlet(alpha);
  theta ~ gamma(a, b);
  for (n in 1:N) {
    increment_log_prob(w[n] * poisson_log(y[n], theta));
  }
}
