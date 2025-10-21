
#=============================================================================================================================#
#=============================================================================================================================#
#========================================== LINEAR REGRESSION MODEL =====================================================#
#=============================================================================================================================#
#=============================================================================================================================#


# Clear the environment 
rm(list=ls())

library(AmesHousing)  
library(car)          
library(lmtest)


# A REGRESSION MODEL WITH BOTH QUANTITATIVE AND QUALITATIVE PREDICTORS
#install.packages("AmesHousing")
library(AmesHousing)

data <- make_ames()
?make_ames
# oppure:
help("make_ames", package = "AmesHousing")

# Two simple models to show how we manage qualitative variables
data_reg <- data[, c("Sale_Price", "Gr_Liv_Area", "House_Style")]
summary(data_reg)
data_reg$Sale_Price <- data_reg$Sale_Price/1000 # prices in thousands of euros, 
                                                # to facilitate interpretation and avoid excessively large coefficient estimates
levels(data_reg$House_Style)

model <- lm(Sale_Price ~ Gr_Liv_Area + House_Style, data = data_reg)
summary(model)

model_int <- lm(Sale_Price ~ Gr_Liv_Area * House_Style, data = data_reg)
summary(model_int)


##########################################################
# Other linear regression models on AmesHousing data


# --- 1) Load data and select subset -----------------------------------------

# Select subset of variables (including a categorical one)
vars <- c("Sale_Price","Gr_Liv_Area","Total_Bsmt_SF","Garage_Area",
          "Overall_Qual","Lot_Area","House_Style", "Garage_Cars", "Fireplaces",
          "Full_Bath", "Latitude", "Longitude", "Pool_Area",  "Kitchen_AbvGr")

dat <- data[ , vars]
dat$Sale_Price1 <- dat$Sale_Price/1000 


# --- 2) Train / test split ---------------------------------------------------
n <- nrow(dat)
set.seed(268)
id_train <- sample.int(n, size = floor(0.7 * n))
train <- dat[id_train, ]
test  <- dat[-id_train, ]

# --- 3) Fit linear model -----------------------------------------------------
mod <- lm(Sale_Price1 ~ ., data = train[,-1])

# --- 4) Basic inference ------------------------------------------------------
summary(mod)

anova(mod)

# --- 5) Multicollinearity diagnostics ---------------------------------------
vif_vals <- vif(mod)
print(vif_vals)


# --- 6) Stepwise selection ------------------------------------------
step_mod <- step(mod, direction = "both")

summary(step_mod)


# --- 7) Residual diagnostics -------------------------------------------------
res <- residuals(step_mod)
fit <- fitted(step_mod)

# 7a) Residuals vs Fitted
plot(fit, res, xlab = "Fitted values", ylab = "Residuals",
     main = "Residuals vs Fitted")
abline(h = 0, lty = 2)


# --- 7b) Residuals vs predictors (numeric only) ------------------------------
par(mfrow = c(2,3))
pred_names <- c("Gr_Liv_Area","Total_Bsmt_SF","Garage_Area","Lot_Area", "Latitude", "Longitude")
for (v in pred_names) {
  plot(train[[v]], res, xlab = v, ylab = "Residuals",
       main = paste("Residuals vs", v))
  abline(h = 0, lty = 2)
}
par(mfrow = c(1,1))

# 7c) Normality of residuals
qqnorm(res) 
qqline(res, lty = 2)


# 7d) Other standard diagnostic plots
plot(step_mod, which = 3)   # Scale-Location
plot(step_mod, which = 4)   # Cook's distance
plot(step_mod, which = 5)   # Residuals vs Leverage

# 7e) Heteroskedasticity (Breusch–Pagan test)
bptest(step_mod)


# --- 8) Simple predictive evaluation ----------------------------------------
pred_test <- predict(step_mod, newdata = test)

#R squared
ss_tot <- sum((test$Sale_Price1 - mean(test$Sale_Price1))^2)
r2_out <- 1 - sum((test$Sale_Price1 - pred_test)^2) / ss_tot

#Error measures
rmse_price <- sqrt(mean((test$Sale_Price1 - pred_test)^2)) #root mean squared error
mae_price  <- mean(abs(test$Sale_Price1 - pred_test)) #mean absolute error
mape_price <- mean(abs((test$Sale_Price1 - pred_test) / test$Sale_Price1)) * 100 #mean absolute percentage error (be cautious in case of zeros!)



