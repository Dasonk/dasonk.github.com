---
layout: post
title: "Using nls in place of the delta method"
description: ""
category: R
tags: [R, nls, stats, statsblogs]
---
{% include JB/setup %}

_This was originally posted at [Point Mass Prior](http://dasonk.github.com) and features MathML.  If you're viewing from StatsBlogs the math probably won't show up properly and it would be beneficial to view the post [here]({{ page.url }})_.

It's been a while since my last post which was on [using the delta method](http://dasonk.github.io/r/2013/02/09/Using-the-delta-method/) in R with a specific application to finding the 'x' value that corresponds to the maximum/minimum value in a quadratic regression.  This post will be about how to do the same thing in a slightly different way.  Quadratic regression can be fit using a linear model of the form

$$y_i = \beta_0 + \beta_1x_i + \beta_2x_i^2 + \epsilon_i$$

where $$\epsilon_i$$ are independent and identically distributed normal random variables with mean 0 and a variance of $$\sigma^2$$.  However, if our concern is on the 'x' value that provides the minimum/maximum value and possibly the value of the response at the minimum/maximum we can reformulate the model as

$$y_i = \theta_1(x_i - \theta_2)^2 + \theta_3 + \epsilon_i$$

So that the x value that corresponds to the minimum/maximum is represented directly through the parameter $$\theta_2$$.  The actual minimum/maximum value is also represented as a parameter in the model as $$\theta_3$$.  In this case $$\theta_1$$ can be interpreted as half of the second derivative with respect to x but that isn't as much of an interest here.  Note that we can expand this model out to get the same form as the linear model so it really is representing the same model but notice that we don't actually have a _linear_ model anymore.

To fit this we would need to use something other than `lm`.  The natural choice in R is to use `nls`.  We'll look at an example of how to fit this model and get confidence intervals for the quantities of interest.  We'll use the same simulated data as my previous post so we can compare how the delta method and nls compare for this problem.

As a reminder the exact model we fit previously was where  $$y = - x*(x-10) + \epsilon$$ so to write it using the same form as our nonlinear model we have $$y = -1*(x - 5)^2 + 25 + \epsilon$$.  So the maximum occurs at $$x=5$$ and produces an output of 25 at that location.


{% highlight r %}
set.seed(500)
n <- 30
x <- runif(n, 0, 10)
y <- -x * (x - 10) + rnorm(n, 0, 8)  # y = 0 +10x - x^2 + error
{% endhighlight %}


Now we fit our model using `nls`.  We need to provide starting values for the parameters since it fits using an iterative procedure.  I provide some pretty bad starting values here but it still fits its just fine.

{% highlight r %}
o <- nls(y ~ t1 * (x - t2)^2 + t3, start = list(t1 = 1, t2 = 1, t3 = 1))
{% endhighlight %}


Now we can look at the output we get


{% highlight r %}
summary(o)
{% endhighlight %}



{% highlight text %}
## 
## Formula: y ~ t1 * (x - t2)^2 + t3
## 
## Parameters:
##    Estimate Std. Error t value Pr(>|t|)    
## t1   -1.040      0.239   -4.35  0.00017 ***
## t2    5.190      0.265   19.57  < 2e-16 ***
## t3   25.089      2.661    9.43  4.9e-10 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 8.71 on 27 degrees of freedom
## 
## Number of iterations to convergence: 8 
## Achieved convergence tolerance: 2.22e-07
{% endhighlight %}


We see that the estimated value at which the maximum occurs is 5.1903.  If we go back to the delta method post we see that we obtained the same estimate.  Another interesting point is the the standard error for this term is the same as we obtained using the delta method.  In both cases we get a standard error of 0.2652

We can easily obtain a confidence interval for this using `confint`


{% highlight r %}
confint(o)
{% endhighlight %}



{% highlight text %}
## Waiting for profiling to be done...
{% endhighlight %}



{% highlight text %}
##      2.5%   97.5%
## t1 -1.530 -0.5499
## t2  4.639  5.8815
## t3 19.650 30.5620
{% endhighlight %}


Now recall that we used the asymptotic normality of the transformation applied when we used the delta method to obtain a confidence interval so that previous interval which went from 4.671 to 5.710 was based on a normal distribution assumption.  When using confint with a nls object it uses t-based methods to get a confidence interval so it will be a little bit wider.  Recall that we have the same estimate and the same standard error as when we used the delta method so if we want we could get the same interval based on asymptotic normality as well.  Alternatively if you use `confint.default` it will use a normal distribution to create your confidence intervals


{% highlight r %}
confint.default(o)
{% endhighlight %}



{% highlight text %}
##     2.5 %  97.5 %
## t1 -1.508 -0.5719
## t2  4.671  5.7101
## t3 19.874 30.3054
{% endhighlight %}


And here we see that we get the same confidence interval as when we used the asymptotic normality argument to get the confidence intervals for the delta method approach.
