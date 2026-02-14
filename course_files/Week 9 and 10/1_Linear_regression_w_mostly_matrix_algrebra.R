x<-c(1,2,3,4,5)
y<-c(1,1,2,2,4)
lm(y~x)
summary(lm(y~x))

#Let's calculate our coefficients b = (X'X)^-1 * X'y

xmatrix<-cbind(c(1,1,1,1,1),x)
tXX<- t(xmatrix) %*% xmatrix 

#leaves you with a matrix that includes n, the sum of x,
#and the sum of x-squared

inverse_of_tXX<-solve(tXX)
inverse_of_tXX_times_tX<-inverse_of_tXX%*%t(xmatrix)

#above leaves you with a matrix with columns equal to n
#which allows you to mulitply by y to get betas

Bvector<-inverse_of_tXX_times_tX%*%y
summary(lm(y~x))

#regression line (i.e.-fitted values)
yhat<-xmatrix %*% Bvector

#Residuals
options(scipen=999) #turn off scientific notation


residuals<-y-yhat


#check calculation using lm()
lm(y~x)$residuals #very slightly diff't due to rounding diffs


#calculate MSE
#now we can think in vector and scalar terms (hooray!)

squaredresiduals<-residuals*residuals

#calculate SSE
sumof_squaredresiduals<-sum(squaredresiduals)
SSE<-sumof_squaredresiduals

n<-length(y)
p<-length(Bvector)
mse<-sumof_squaredresiduals/(n-p)

SSyy<-sum(as.vector(y-(mean(y)))*(y-(mean(y))))

rsquared<-(SSyy-SSE)/SSyy


#calculate hat matrix, which is used in several formulas
#called the hat matrix  because it puts the hat on y 
#i.e.-multiplying the hat matrix by variables by y
#gives us yhat

hatmatrix<-xmatrix%*%(inverse_of_tXX_times_tX)

#demonstrate that we get yhat by multiplying y by hatmatrix
hatmatrix%*%y

#extract yhat from model results to check above
y-lm(y~x)$residuals


#calculate variance covariance matrix, which is used to calculate
#standard errors for betas 
tXX<- t(xmatrix) %*% xmatrix 

#multiply mse by the inverse of above
var_cov_matrix<-mse*solve(tXX)


#double-check using lm()
vcov(lm(y~x))

#calculate standard error for each beta by taking square root of 
#diagonal elements
standard_error_b0<-sqrt(var_cov_matrix[1,1])
standard_error_b1<-sqrt(var_cov_matrix[2,2])


beta0<-as.vector(Bvector)[1]
beta1<-as.vector(Bvector)[2]

#calculate t-values for hyp tests for difference from zero
beta0/standard_error_b0

beta1/standard_error_b1


#calculate confidence interval for a point estimate of yhat
#let's set x1 to 3 to predict yhat and then calculate a confidence interval

#x_to_use_to_predict_yhat<-3
#OR you could simply make up a vector of x values to use to calculate yhat

#calculate xh, which is a 2 by 1 matrix of x matrix values (including ones)
xh<-matrix( c(1, 3), nrow=2, ncol=1) 

#calculate transposition of xh, which is a one by two matrix
txh<-t(xh)

#calculate yhat by multiplying transposition of xh by Betas
yhat_value<-txh%*%Bvector

#part one of calculating std error of yhat_value
txh_times_inverse_of_TXX<-txh%*%solve(tXX)

#part two
txh_times_inverse_of_TXX_times_xh<-txh_times_inverse_of_TXX%*% xh

#now take the square root of the mse times the above to get the std error
std_error_for_yhatvalue<-sqrt(mse%*%txh_times_inverse_of_TXX_times_xh)

critical_value_of_t<-qt(0.975, nrow(xmatrix)-length(Bvector))

#print predicted value of y when x is set to 3 and upper and lower confidence
#interval
yhat_value
yhat_value+(critical_value_of_t*std_error_for_yhatvalue)
yhat_value-(critical_value_of_t*std_error_for_yhatvalue)

#double-check conf.interval using lm() and predict() r functions:
newdata = data.frame(x=3)

predict(lm(y~x), newdata, interval="confidence")