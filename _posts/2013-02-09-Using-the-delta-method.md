---
layout: post
title: "Using the delta method"
description: ""
category: R
tags: [R, delta method, stats, statsblogs]
---
{% include JB/setup %}

_This was originally posted at [Point Mass Prior](http://dasonk.github.com) and features MathML.  If you're viewing from StatsBlogs the math probably won't show up properly and it would be beneficial to view the post [here]({{ page.url }})_

Somebody recently asked me about the delta method and specifically the `deltamethod` function in the msm package.  I thought I would write about that and so to motivate this we'll look at an example.  The example we'll consider is a simple case where we fit a quadratic regression to some data.  This means our model has the form

$$y_i = \beta_0 + \beta_1x_i + \beta_2x_i^2 + \epsilon_i$$

where $$\epsilon_i$$ are independent and identically distributed normal random variables with mean 0 and a variance of $$\sigma^2$$.

To start we'll generate some data such that we have roots at x=0 and x=10 and the quadratic is such that we have a maximum instead of a minimum.


{% highlight r %}
set.seed(500)
n <- 30
x <- runif(n, 0, 10)
y <- -x * (x - 10) + rnorm(n, 0, 8)  # y = 0 +10x - x^2 + error
{% endhighlight %}


We can plot the data to get a feel for it:

![center](/../figs/2013-02-09-Using-the-delta-method/plotdat.bmp) 


Now it might be that what we're really interested in is the input value that gives us the maximum value for the response (on average).  Let's call that value $$x_\text{max}$$.  Now if we knew the true parameters for this data we could figure out exactly where that maximum occurs.  We know that for a quadratic function $$y = \beta_0 + \beta_1x + \beta_2x^2$$ the maximum value occurs at $$x = \frac{-\beta_1}{2\beta_2}$$.  In our specific case we have $$y = 0 + 10x -x^2$$ so the maximum occurs at $$x = 5$$.  Just eyeballing our plot it doesn't look like the quadratic that will be fit will give us a maximum that occurs exactly at $$x=5$$.  Let's actually fit the quadratic regression and see what we get for the estimated value of $$x_\text{max}$$ which I will call $$\hat{x}_\text{max}$$.


{% highlight r %}
# Estimate quadratic regression
o <- lm(y ~ x + I(x^2))
# View the output
summary(o)
{% endhighlight %}



{% highlight text %}
## 
## Call:
## lm(formula = y ~ x + I(x^2))
## 
## Residuals:
##    Min     1Q Median     3Q    Max 
## -14.26  -6.13  -1.49   7.62  13.87 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)   -2.923      4.983   -0.59  0.56233    
## x             10.794      2.422    4.46  0.00013 ***
## I(x^2)        -1.040      0.239   -4.35  0.00017 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1 
## 
## Residual standard error: 8.71 on 27 degrees of freedom
## Multiple R-squared: 0.424,	Adjusted R-squared: 0.381 
## F-statistic: 9.93 on 2 and 27 DF,  p-value: 0.000585
{% endhighlight %}



{% highlight r %}
# Make scatterplot and add the estimated curve
plot(x, y, main = "Scatterplot with estimated regression curve", xlim = c(0, 
    10))
curve(coef(o)[1] + coef(o)[2] * x + coef(o)[3] * x^2, col = "red", add = T)
# Add a line at the theoretical maximum
abline(v = 5, col = "black")
# Estimate the xmax value
beta2 <- coef(o)["I(x^2)"]
beta1 <- coef(o)["x"]
estmax <- unname(-beta1/(2 * beta2))
# Add a line at estimated maximum
abline(v = estmax, col = "blue", lty = 2)
legend("topleft", legend = c("True max", "Estimated max", "Estimated curve"), 
    col = c("black", "blue", "red"), lty = c(1, 2, 1))
{% endhighlight %}

![center](/../figs/2013-02-09-Using-the-delta-method/estimatequadratic.bmp) 


So our estimate of the value where the maximum occurs is $$\hat{x}_\text{max} =$$ 5.1903.  This is pretty close but it would still be nice to have some sort of interval to go along with our estimate.  This is where [the delta method](http://en.wikipedia.org/wiki/Delta_method) can help us out.  The delta method can be thought of as a way to get an estimated standard error for a transformation of estimated parameter values.  In our case we're interested in applying the function

$$g(x, y) = \frac{-x}{2y}$$

to our estimated parameters. 

$$\hat{x}_\text{max} = g(\hat{\beta_1}, \hat{\beta_2}) = \frac{-\hat{\beta_1}}{2\hat{\beta_2}}$$

To perform the delta method we need to know a little bit of calculus.  The method requires taking derivatives of our function of interest.  Now this isn't too bad to do in practice but not everybody that wants to perform an analysis will know how to take derivatives (or at least it might have been a long time since they've taken a derivative).



Luckily for us we don't have to do the delta method by hand though as long as we know the transformation of interest.  The `deltamethod` function in the msm package provides a convenient way to get the estimated standard error of the transformation as long as we can provide

  1. The transformation of interest
  2. The estimated parameter values
  3. The covariance matrix of the estimated parameters
  
We already know (1) but we have to make sure it write it in the proper syntax for `deltamethod`. We can easily obtain (2) by using `coef` on our fitted model and we can also easily obtain (3) by using `vcov` on the estimated model. 

When writing the syntax for the transformation when using the `deltamethod` function you need to refer to the first parameter as `x1`, the second parameter as `x2`, and so on.  So if I wanted to find the standard error for the sum of two parameters I would write that as `~ x1 + x2`.  In our case our estimated parameters are from the output of `coef(o)` so let's sneak a peak at them to remind ourselves the output order.


{% highlight r %}
coef(o)
{% endhighlight %}



{% highlight text %}
## (Intercept)           x      I(x^2) 
##      -2.923      10.794      -1.040
{% endhighlight %}


So in this case when writing our transformation we would refer to $$\hat{\beta_0}$$ as `x1`, $$\hat{\beta_1}$$ as `x2`, and $$\hat{\beta_2}$$ as `x3`.  As a reminder the transformation we applied was $$\frac{-\hat{\beta_1}}{2\hat{\beta_2}}$$ so the formula we want is `~ -x2 / (2 * x3)`.




{% highlight r %}
library(msm)
standerr <- deltamethod(~-x2/(2 * x3), coef(o), vcov(o))
standerr
{% endhighlight %}



{% highlight text %}
## [1] 0.2652
{% endhighlight %}



{% highlight r %}
# Make a confidence interval
(ci <- estmax + c(-1, 1) * qnorm(0.975) * standerr)
{% endhighlight %}



{% highlight text %}
## [1] 4.671 5.710
{% endhighlight %}

So we see that our confidence interval does contain the true value.  We could also do a hypothesis test if we wanted to test against a certain value.  Here we'll test using a null hypothesis that the true $$x_\text{max} = 5$$.


{% highlight r %}
# If we want to do a hypothesis test of Ho: xmax = 5 Ha: xmax != 5
z <- (estmax - 5)/standerr
# Calculate p-value
pval <- 2 * pnorm(-abs(z))
pval
{% endhighlight %}



{% highlight text %}
## [1] 0.4729
{% endhighlight %}


Our p-value of 0.473 doesn't allow us to reject the null hypothesis in this situation.

So we can see that it's fairly easy to implement the delta method in R.  Now this isn't necessarily my favorite way to get intervals for transformations of parameters but if you're a frequentist then it can be quite useful.

