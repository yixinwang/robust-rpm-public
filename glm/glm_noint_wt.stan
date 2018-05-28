data {
  int<lower=0> N;
  vector[N] x;
  int<lower=0,upper=1> y[N];
  vector<lower=0>[N] alpha;   
}
parameters {
  real beta;
  simplex[N] v;
} 
transformed parameters{
  vector[N] w;
  w <- N * v;
}
model {
  v ~ dirichlet(alpha);
  beta ~ normal(0,100);
  for (n in 1:N)
    increment_log_prob(w[n] * bernoulli_logit_log(y[n], beta * x[n]));
}
