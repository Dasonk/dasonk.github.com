---
layout: post
title: "Using Jekyll and Mathjax"
description: "My hackish way to get mathjax support on my blog"
category: blog
tags: [jekyll, mathjax, blog, statsblogs]
---
{% include JB/setup %}

To get Mathjax support the easiest thing to do is to add the following to _include/themes/yourtheme/default.html where "yourtheme" is whichever theme you're currently using.

{% highlight html %}
<script type="text/javascript"
    src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
{% endhighlight %}

I'm sure there is a better way to do this so that you don't need to add this whenever you change themes but this is working for me for the time being.
    
However using Maruku (the default markdown rendering engine with Jekyll) actually using math can be a pain since it likes to replace `_` with `<em>` no matter where it is in the post.  So `$$x_i$$` gets converted to `$$x<em>i$$` which is not what we want.

To have a nice setup for using math in my posts I switched my markdown rendering engine from the default with Jekyll (Maruku) to kramdown.  I just installed the kramdown gem

{% highlight bash %}
gem install kramdown
# Although you probably need to do...
sudo gem install kramdown
{% endhighlight %}

and then I needed to add

    markdown: kramdown
    
to the _config.yml file at the top directory of my repository.

After that  using Mathjax is as simple as surrounding any math in double dollar signs `$$ insert_math_here $$` so that `$$x^2$$` gets rendered as $$x^2$$.  If your dollar signs are standalone not inline with other text like this: 

{% highlight latex %}
$$a^2 + b^2 = c^2$$
{% endhighlight %}

then it will get centered and displayed like "display math" like:

$$a^2 + b^2 = c^2$$

Combining this with the fact that I write my posts using R Markdown so I can easily insert code and output into my posts makes the whole process a lot nicer.

I have heard good things about rdiscount as a markdown rendering engine but I don't think I'll use it.  It doesn't appear to support the syntax I described in this post and I rather like this syntax.  kramdown appears to work well enough for my needs so I think I'll stick with that for now.
