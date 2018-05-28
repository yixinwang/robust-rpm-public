data {
  int<lower=0> N;
  vector[N] x;
  int<lower=0,upper=1> y[N];
}
parameters {
  real beta1;
} 
model {
  beta1 ~ normal(0, 3);
  for (n in 1:N)
    increment_log_prob(bernoulli_logit_log(y[n], beta1 * x[n]));
}
