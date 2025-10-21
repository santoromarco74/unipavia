rm(list=ls())

#Simulated linear regression model
set.seed(123)

n <- 200
X1 <- rnorm(n, 5, 2)            # predictor 1
X2 <- 0.8 * X1 + rnorm(n, 0, 1) # predictor 2 (correlated with X1)
X3 <- rnorm(n, 0, 1)            # predictor 3 (independent)
# True model: Y = 3 + 1.5*X1 - 2.0*X2 + 0.8*X3 + 1.0*(X1*X3) + error
epsilon <- rnorm(n, 0, 1.5)      # base noise
Y <- 3 + 1.5*X1 - 2.0*X2 + 0.8*X3 + 1.0*(X1*X3) + epsilon

df <- data.frame(Y, X1, X2, X3)
head(df)


# Fit
model <- lm(Y ~ X1 + X2 + X3, data = df)

# Summary (coefficients, R^2, F-stat)
summary(model)

# ANOVA table
anova(model)

# Confidence intervals for coefficients
confint(model)

# Predicted vs actual (quick check)
pred <- predict(model)
plot(df$Y, pred, xlab = "Observed Y", ylab = "Predicted Y", main = "Observed vs Predicted")
abline(0, 1, col = "red", lwd = 2)

par(mfrow = c(2,2))
plot(model)  # base plots: Residuals vs Fitted, Normal Q-Q, Scale-Location, Residuals vs Leverage
par(mfrow = c(1,1))

# Shapiro-Wilk test for normality of residuals (optional, for small samples)
shapiro.test(residuals(model))

# Residuals vs fitted to visually check homoskedasticity 
plot(fitted(model), residuals(model),
     xlab = "Fitted values", ylab = "Residuals",
     main = "Residuals vs Fitted")
abline(h = 0, col = "red", lwd = 2)

# If not installed, install car
# install.packages("car")
library(car)
vif_vals <- vif(model)
vif_vals

cor(df)

#let's add an interaction term
model_interact <- lm(Y ~ X1 + X2 + X3 + X1 * X3, data = df)
summary(model_interact)

# polynomials
df$X1_sq <- df$X1^2
model_quad <- lm(Y ~ X1 + X1_sq + X2 + X3, data = df)
summary(model_quad)


### SWISS DATASET ANALYSIS

# Swiss dataset  
#install.packages("datasets")
library(datasets)
data("swiss")


# Structure check and inspection
str(swiss)
head(swiss)
help(swiss)

# Renaming of relevant variables (not mandatory)
sw <- swiss
colnames(sw) <- c("Fertility","Agriculture","Examination","Education", "Catholic","InfantMortality")

# Multiple regression model with selected variables
model1 <- lm(Fertility ~  Examination + InfantMortality, data = sw)

# Main results
summary(model1)

# ANOVA 
anova(model1)

# Residual plot
par(mfrow = c(2,2))
plot(model1)
par(mfrow = c(1,1))

# Check for residuals normality (Shapiro-Wilk test)
shapiro_test <- shapiro.test(residuals(model1))
shapiro_test

# To visually check homoschedasticity 
plot(fitted(model1), residuals(model1),
     xlab = "Fitted values", ylab = "Residuals",
     main = "Residuals vs Fitted")
abline(h = 0, col = "red")

# Multicollinearity: VIF
vif_vals <- vif(model1)
vif_vals


## CI 95% Beta coefficients
confint(model1)

## Complete model with all the variables in
model_full <- lm(Fertility ~ ., data = sw)

summary(model_full)
par(mfrow = c(2,2))
plot(model_full)
par(mfrow = c(1,1))

vif(model_full)
cor(sw$Examination, sw$Education)

model_full_def <- lm(Fertility ~ .-Examination, data = sw)

summary(model_full_def)

par(mfrow = c(2,2))
plot(model_full_def)
par(mfrow = c(1,1))

# ANOVA to compare the two models
anova(model_full_def, model_full)






