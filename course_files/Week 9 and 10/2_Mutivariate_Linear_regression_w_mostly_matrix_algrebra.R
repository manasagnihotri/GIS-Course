
#Multivariate linear regression with mostly matrix algebra

x1<-c(4,4,7,7,10,10)
x2<-c(1,2,2,4,3,6)
y<-c(14,23,30,50,39,67)
summary(lm(y~x1+x2))
summary(lm(y~x1))

#how in the heck do we rule out relationships among x vars?
#We cancel out the influence of x2 on x1
#by running a regression with x1 as the dv and x2 as the iv
#residuals from this regression = x1 without x2
#we then use these residuals in a simple regression of x1
#and y to get the partial coefficient in the model for x1

lm(y~x1+x2)

#run regression of x2 on x1 to rule out relationship of x2 on x1 and
#keep residuals, which are x1 without the part of x1 that relates with x2
lm(x1~x2)$residuals

#create new variable that controls for x2
x1residuals<-lm(x1~x2)$residuals

#truncated model with new variable demonstrats that SSxy/SSxx in 
#a simple model with x1residuals is the same coefficient we 
#calculate in a full multivariate model

lm(y~x1residuals)

#view full model
summary(lm(y~x1+x2))

#beta0 is incorrect because we calculate b0=ybar-mean(x1residuals)*b1
#but we do not subtract mean(x2residuals)*b2

#bivariate regression without controlling for x2
summary(lm(y~x1))

#see the difference?
#can do the same thing for x2
summary(lm(y~x1+x2))
summary(lm(y~x2))
x2residuals<-lm(x2~x1)$residuals
summary(lm(y~x2residuals))

#calculate the model using matrix algebra 

#create matrix of x values with first column set to 1
xmatrix<-cbind(c(1,1,1,1,1,1),x1,x2)

#multiply transposition of matrix of x values by matrix of x values
tXX<- t(xmatrix) %*% xmatrix 

#take the inverse
XtXNeg1<-solve(tXX)

#multiply it by the transposition of matrix of x values
XtXNeg1t<-XtXNeg1%*%t(xmatrix)

#multiply it by the vector of y values (and n by 1 matrix)
Bvector<-XtXNeg1t%*%y
summary(lm(y~x1+x2))

#regression line (i.e.-fitted values)
yhat<-xmatrix %*% Bvector

#Residuals
residuals<-y-yhat


#check calculation using lm()
lm(y~x1+x2)$residuals


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

hatmatrix<-xmatrix%*%(XtXNeg1t)

#demonstrate that we get yhat by multiplying y by hatmatrix
hatmatrix%*%y

#extract yhat from model results to check above
y-lm(y~x1+x2)$residuals


#calculate variance covariance matrix, which is used to calculate
#standard errors for betas 

tXX<- t(xmatrix) %*% xmatrix 

#multiply mse by the inverse of above
var_cov_matrix<-mse*solve(tXX)


#double-check using lm()
vcov(lm(y~x1+x2))

#calculate standard error for each beta by taking square root of 
#diagonal elements
standard_error_b0<-sqrt(var_cov_matrix[1,1])
standard_error_b1<-sqrt(var_cov_matrix[2,2])
standard_error_b2<-sqrt(var_cov_matrix[3,3])

beta0<-as.vector(Bvector)[1]
beta1<-as.vector(Bvector)[2]
beta2<-as.vector(Bvector)[3]

#calculate t-values for hyp tests for difference from zero
beta0/standard_error_b0

beta1/standard_error_b1

beta2/standard_error_b2

summary(lm(y~x1+x2))

#calculate confidence interval for a point estimate of yhat
#let's set x1 to 3 to predict yhat and then calculate a confidence interval

x1_to_use_to_predict_yhat<-6
x2_set_to_average_value<-mean(x2)

#OR you could simply make up a vector of x values to use to calculate yhat

#calculate xh, which is a 3 by 1 matrix of x matrix values (including ones)
xh<-matrix( c(1,x1_to_use_to_predict_yhat, x2_set_to_average_value), nrow=3, ncol=1) 

#calculate transposition of xh, which is a one by three matrix
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


#calculate an f test for regression
#fvalue<-msr/mse
n<-length(y)
p<-length(lm(y~x1+x2)$coefficients)

SSR<-SSyy-SSE

#or sum((yhat-mean(y))^2)
msr<-SSR/(p-1)
mse<-SSE/(n-p)

fstatistic<-msr/mse
fstatistic

summary(lm(y~x1+x2))
