### 2nd week - Exercises in R – Solutions 
rm(list=ls())


### 1. Area of a circle with radius 15
r <- 15
A <- pi * r^2
A


### 2. Areas of 100 circles with radii 1,...,100
radii <- 1:100
areas <- pi * radii^2
areas


### 3. Celsius to Fahrenheit conversion
C <- 0:100
F <- 32 + 1.8 * C
F


### 4. Numbers from 1 to 100
onehundred <- 1:100

# (a) Sum of 1,...,100
sum(onehundred)

# (b) Sum of squares: 1^2 + 2^2 + ... + 100^2
sum((1:100)^2)

# (c) Sum of square roots
sum(sqrt(1:100))


### 5. Vector of colors
colors <- c("red","green","blue")
color_vector <- c(
  rep(colors[3], 98),
  rep(colors[2], 99),
  rep(colors[1],100)
)
length(color_vector)
head(color_vector)
tail(color_vector)


### 6. Function with a for loop: sum of squares
sumsquares <- function(n) {
  total <- 0
  for (i in 1:n) {
    total <- total + i^2
  }
  return(total)
}

# Example:
sumsquares(5)   # 1^2 + 2^2 + 3^2 + 4^2 + 5^2 = 55


### 7. Function with if/else: classify number
classifynumber <- function(x) {
  if (x > 0) {
    return("positive")
  } else if (x < 0) {
    return("negative")
  } else {
    return("zero")
  }
}

# Examples:
classifynumber(10)   
classifynumber(-3)   
classifynumber(0)    


### 8. Function combining for + if/else: count even numbers
countevens <- function(vec) {
  count <- 0
  for (value in vec) {
    if (value %% 2 == 0) {   #modulus operator (it checks if a number is divisible by another)
      count <- count + 1
    }
  }
  return(count)
}

# Example:
countevens(c(1,2,3,4,5,6))   


###9.Simulating Data from a Distribution
# -----------------------------------------------------------
# (a) Normal simulation + plot
# (b) Monte Carlo simulations
# (c) 95% confidence interval for the mean using Monte Carlo

set.seed(123)
mu    <- 10
sigma <- 3
n     <- 500

# Simulate Normal sample
x <- rnorm(n, mean = mu, sd = sigma)

# (a) Histogram and true/estimated normal densities
  hist(x, prob = TRUE, main = "Histogram of simulated data", xlab = "x")
  m_hat <- mean(x); s_hat <- sd(x)
  curve(dnorm(x, mean = m_hat, sd = s_hat),
        add = TRUE, lty = 1, lwd = 2)
  curve(dnorm(x, mean = mu, sd = sigma), add = TRUE, lty = 2, lwd = 2)
  legend("topright",
         legend = c('Simulated density', 'True density'),
         lty = c(1,2), lwd = 2)


# (b) Monte Carlo simulations
n_sim <- 1000
mean_vec <- rep(0, n_sim)


for (i in 1:n_sim) {
set.seed(123+i)
  x_sim <- rnorm(n, mean = mu, sd = sigma)
  mean_vec[i] <- mean(x_sim)
}

mean(mean_vec)
mu               #expected value of the sample mean
var(mean_vec) 
sigma^2/n        #variance of the sample mean


# (c) empirical 95% confidence interval for the mean
quantile(mean_vec, c(0.025, 0.975))
mu-1.96*sigma/sqrt(n)
mu+1.96*sigma/sqrt(n)
