## What is R?

# - R is a free, open-source software and programming language
# -  Developed as an environment for statistical computing and graphics
# -  Now one of the dominant software environments for data analysis 
# -  Used by a variety of scientific disciplines, including economics, econometrics, finance etc
# -  R: a language to explore, summarize, and model data
# -  functions = verbs
# -  objects = nouns
# -  R: encourages publications  of ``Reproducible Research" 


### Installing R and RStudio

#  -  Download and install the latest R: <http://www.r-project.org/>
#  -  Download and Install RStudio: <https://rstudio.com/>
#  -  R is the underlying engine that powers RStudio's computations
#  -  RStudio will provide sample data, command autocompletion, help files, and an effective interface for getting things done quickly
#  -  There are four main parts of RStudio
# 	 -  The Editor: the top left quadrant - where you write code for later use
# 	 -  The Console: the lower left quadrant 
# 	 -  History / Environment: the top right quadrant 
# 	 -  Misc: the bottom right panel 

### Launching RStudio and Installing Packages
# 
#  -  R provides several in-house and user contributed packages
#  -  The easiest way to install packages is to do it via R console. 
#  -  The command *install.packages("package name")* installs R packages directly from internet.
# 


# the help window in RStudio
# help(install.packages)

# Example
# Install package Quantreg 
# install.packages("quantreg")

# to activate the package
# library(quantreg)



### Updating R

# To update R to the newest version, using the following code

# # Open R and type the following
# 
# 	# install.packages("installr")
# 	# 
# 	# library(installr)
# 	# 
# 	# updateR()
# 


################## Basics of coding #######

# We always start by cleaning the environment 
rm(list=ls())


# Evaluation
1+3
(1+2)==1
(1+2)!=1

# Assignment
a <- 3
a_1 <- 3*5
a_2 <- (3+4)^2

# Evaluation
a


# Spacing does not matter 
a<-3 
a <- 3 


# Combining 
b <- a + 1
b


# Other operations
b <- a * 2
b
b <- sqrt(a)
bb <- a/2
b
b <- a - 1
b
b <- a^3
b
b <- (100*2) + (50/2)
b


a == b   # a is equal to b?
a != b   # a is not equal to b?


# Other comparison operators
5 > 6
6 < 5
6 <= 6
6>=5

# This command lists all objects in the global environment
ls()


# Remove an object
rm(a_1,pippo)

## Data Types in R

# -  To make the best of the R language, you will need a strong understanding of the basic data types and data structures and how to operate on them. 
# -  Everything in R is an object.
# -  R has many data types. These include
# 	-  character
# 	-  numeric 
# 	-  factors
# 	-  date and time


### Characters
# The character class is the typical string, a set of one or more letters.


# Example
Names <- c("Mario", "Federico", "Gloria", "Manuel", "Marco")
Names
## Note: c()    Combine values or characters into a vector

class(Names)



###  Numeric
# The numeric class is the typical real or decimal numbers.

# Example
Height <- c(58.5, 44.6, 67.2, 61.3, 59.7)
class(Height)



###  Factors

# The factor class is an important data type to represent categorical data.
# Factor objects can be created from character object or from numeric object.

# Example of factors are Blood type (A , B, AB, O)
b.type <- c("A", "AB", "B", "O") 	# character object

# use factor Function to convert to factor object
b.type2 <- factor(b.type)
b.type2
class(b.type2)


###  Date and Time

# R is capable of dealing with calendar dates and times.
# This is important when dealing with time series models. 
# The function *as.Date* can be used to create an object of class Date.


# Example 
date1 = "05-11-2019"
date2 = as.Date(date1, "%d-%m-%Y")
date1
date2
class(date1)
class(date2)



## Data Structures in R

# R has many data structures. These include
# 		-  vectors
# 		-  matrices
#	    -  dataframes
# 		-  lists

# Creating a vector a which contains three values 1,2,3
a <- c(1,2,3)


# Creating a vector b containing three elements "one", "two", "three"
b <- c("one", "two", "three")
b


# Combine
c <- c(a,b)
c


# Create a vector a with values from 1 to 5
a <- 1:5


#Create a vector using a sequence
aa <-  seq(from = 1, to = 10, by = 0.1)


# Vector comparison 
v <- c(1,2,3,4,5)
v <= 2
v != 3

logic_vec<-(v != 3)


# Create a matrix with values from 1 to 25, number of rows = 5 and number of columns = 5
A <- matrix(data=1:25, nrow=5, ncol=5, byrow = T)
A


# Another way to do the same
B <- rbind(1:5,6:10,11:15,16:20,21:25)
B


# Get dimension of a vector or a matrix
dim(B)
nrow(B)
ncol(B)

v<-1:150
length(v)

# Selecting row and/or columns
bb <- B[,1]
bb
AA <- A[1:3,1:2]
AA

AA <- A[1:3,c(1:2,5)]


## Functions

# R functions
# dim (x) 		  dimensions of x
# str (x) 		  Structure of an object
# list (..) 		create a list
# colnames (x) 	set or find column names
# rownames (x) 	set or find row names
# ncol(x) 		  number of columns
# nrow(z) 		  number of row
# rbind (..) 		combine by rows
# cbind (..) 		combine by columns
# is.na (x) 		also is.null(x), is...
# na.omit (x) 	ignore missing data
# rm () 			  remove variables from workspace
# mean (x)		
# sum (x)
# min (x)
# max (x)
# range (x)
# sd (x) 			  standard deviation
# cor (x) 		  correlation
# cov (x) 		  covariance
# solve (x) 		inverse of x


m   <- mean(bb)
med <- median(bb)


# User-defined functions
#write a function to calculate the mean
media <- function(x) {
  m     <-sum(x)/length(x)   
  m
}

media(bb)

m_row <- apply(A,1,mean)
m_col <- apply(A,2,mean)


# Getting help with R
help(vector)



### Dataframes

# Dataframe is the most convenient data structures in R for tabular data.

# Dataframes have multiple rows and multiple columns with different data types.


# Example
num1 = seq(1:5)
ch1 = c("A", "B", "C", "D", "E")
df1 = data.frame(ch1, num1)
df1
colnames(df1) <- c('Character','Number')
df1




###  Lists

# A list is like generic vector containing other objects. 
# They can have numerous elements any type and structure they can also be of different lengths

# Example
e1 = c(2, 3, 5) #element 1

e2 = c("aa", "bb", "cc", "dd", "ee")  #element 2

e3 = c(TRUE, FALSE, TRUE, FALSE, FALSE)#element 3

e4 = df1 #element 4 (previously constructed dataframe)
lst1 = list(e1,e2,e3, e4)   
str(lst1) # show the structure of lst1
lst1[[1]]




########## CONDITIONAL STATEMENTS / LOOPS ##########

## If-else statements

# if (condition) {
#   # code executed when condition is TRUE
# } else {
#   # code executed when condition is FALSE
# }

# "if" statement

x <- 7

# check if x is greater than 0
if (x > 0) {
  print("The number is positive")
}

# "if...else" statement

age <- 16

# check if age is greater than 18
if (age >= 18) {
  print("You are eligible to vote.")
} else {
  print("You cannot vote.")
}


# more than 1 "if...else"
x <- 0

# check if x is positive or negative or zero
if (x > 0) {
  print("x is a positive number")
} else if (x < 0) {
  print("x is a negative number")
} else {
  print("x is zero")
}


# dealing with for loops
# for (i in 1:N)
# {
# ## write your commands here
# }

#simple for loop
for (i in 1:5){
  # statement
  print(i)
}

#another simple for loop
for (i in 1:10){
  # statement
  i<-i+i
}

#let's create a function to find the factorial of a number

findfactorial <- function(n){
  
  factorial <- 1
  
  if ((n==0)|(n==1))
    factorial <- 1
  
  else{
    for( i in 1:n)
      factorial <- factorial * i
  }
  return (factorial)
}

findfactorial(3)


#another more precise function to compute factorials

findfact <- function(n){
  factorial <- 1
  
  if( n < 0 )
    print("Factorial of negative numbers does not exist!")
  else if( n == 0 )
    print("Factorial of 0 is 1")
  else {
    for(i in 1:n)
      factorial <- factorial * i
    
    print(paste("Factorial of ",n," is ",factorial))
  }
}

findfact(-5)


# while statement
# factorial function with while statement

findfactorial <- function(n){
  factorial <- 1
  if(n==0 | n==1){
    factorial <- 1
  } else{
    while(n >= 1){
      factorial <- factorial * n
      n <- n-1
    }
  }
  return (factorial)
}

findfactorial(7) # could you make this function in a "better" way?


findfactorial1 <- function(n){
  factorial <- 1
  if (n<0) {
    stop("Factorial does not exist")}
  
  else if(n==0 | n==1){
    factorial <- 1}
  else{
    while(n >= 1){
      factorial <- factorial * n
      n <- n-1
    }
    return(factorial)
  }
  
}

findfactorial1(-7)
findfactorial1(5)


#find factorial of a number via recursion

findfactorial2 <- function(n) {
  if (n == 0)     return (1)
  else 
    return (n * findfactorial1(n-1))
}

findfactorial2(6)


## Generate random draws
# runif - random draws from a uniform distribution
# rnorm - random draws from a normal distribution
# rexp - random draws from an exponential distribution
# rgeom - random draws from a geometric distribution
# rbeta - random draws from a beta distribution
# rt  - random draws from a t-distribution
# rbinom - random draws from a binomial distribution
# rchisq - random draws from a chi-square distribution

set.seed(123)
x <- rnorm(1000, mean = 10, sd=10)

mean(x)



VarX <- function(x){
  x <- na.omit(x)
  n <- length(x)
  xbar <- mean(x)
  sq.dev <- (x - xbar)^2
  vx <- (1/(n-1))*sum(sq.dev)
  return(vx)
}


var(x)
VarX(x)



## For loops

S = 1000 # set the number of simulations
N = 1000 # set the length of the sample
mu = 0 # population mean
sigma = 2 # population standard deviation
Ybar = vector('numeric', S) # create an empty vector of S elements
# to store the mean of each simulation
for (i in 1:S)
{
  Y = rnorm(N, mu, sigma) # Generate a sample of length N
  Ybar[i] = mean(Y) 
}


Fx <- function(x)
{
  if(x < -1){
    y <- 1
  } else if(x >= -1 && x<= 2){
    y <- x^2
  } else if (x > 2){
    y <- 4
  }
  return(y)
}

x <- as.matrix(runif(1000, -5, 5))
y <- as.matrix(apply(x, 1, Fx))
plot(x,y, col="red")
