# Introduction

## Goal of this course

The goal of this course is to teach you how to simulate and analyze the various types of datasets you are likely to encounter as a psychologist. The focus is on behavioral data---e.g., measures of reaction time, perceptual judgments, choices, decision, ratings on a survey, hours of sleep, etc.---usually collected in the context of a study or experiment. 

In its approach to statistical analysis, this course attempts to maximize **flexibility**, **generalizability**, and **reproducibility**. You may have heard talk in the media about psychology being in the throes of various 'crises'. There have been some high-profile replication failures that have contributed to the impression that all is not well. There have also been a number of demonstrations that the standard approaches to data analysis in psychology are flawed, in that they allow researchers to present results as clean-cut and confirmatory while hiding various analyses that have been pursued and discarded while seeking to attain the desired result. But it is not just the field of psychology where such problems can be found---the problem is widespread, encompassing other fields of study as well. And the truth is that a certain level of self-criticism and self-reflection can also be seen positively---as a sign of a healthy discipline. Whatever your take, there is room for improvement, and the purpose of this course is to give you tools to ensure that your own analyses are not only statistically sound, but also as generalizable and reproducible as possible. 

### Flexibility

The approach taken in this course differs from other courses in that it emphasizes learning a flexible regression modeling framework rather than teaching 'recipes' for dealing with different types of data, and assumes that the fundamental type of data you will need to analyze will be <a class='glossary' target='_blank' title='(or multi-level) Relating to datasets where there are multiple observations taken on the same variable on the same sampling units (usually subjects or stimuli).' href='https://psyteachr.github.io/glossary/m#multilevel'>multilevel</a> and also that you will need to deal not only with continuous measurements but also ordinal measurements (ratings on a Likert scale), counts (number of times particular event types have taken place), and nominal data (what category something falls into).

The most flexible approach available is the General Linear Model approach, in which some <a class='glossary' target='_blank' title='A variable (in a regression) whose value is assumed to be influenced by one or more predictor variables.' href='https://psyteachr.github.io/glossary/r#response-variable'>response variable</a> is modeled in terms of a weighted linear sum of <a class='glossary' target='_blank' title='A variable whose value is used (in a model) to predict the value of a response variable.' href='https://psyteachr.github.io/glossary/p#predictor-variable'>predictor variables</a>. A simple mathematical example of one such formula is

$$Y_i = \beta_0 + \beta_1 X_i + e_i$$

where $Y_i$ is the measured response for observation $i$, modeled in terms of an <a class='glossary' target='_blank' title='Also referred to as y-intercept, this is a constant corresponding to the value of the \(y\) variable (in a regression context, the response variable) when all predictor variables are set to zero.' href='https://psyteachr.github.io/glossary/i#intercept'>intercept</a> term plus the effect of <a class='glossary' target='_blank' title='A variable whose value is used (in a model) to predict the value of a response variable.' href='https://psyteachr.github.io/glossary/p#predictor-variable'>predictor</a> $X_i$ weighted by coefficient $\beta_1$ and <a class='glossary' target='_blank' title='That part of an observation that cannot be captured by the statistical model, and thus is assumed to reflect unknown factors.' href='https://psyteachr.github.io/glossary/r#residual-error'>residual error</a> term $e_i$, which reflects unmodeled variance.

You might recognize the above equation as representing the equation for a line ($y = mx + b$), with $\beta_0$ playing the role of the <a class='glossary' target='_blank' title='Also referred to as y-intercept, this is a constant corresponding to the value of the \(y\) variable (in a regression context, the response variable) when all predictor variables are set to zero.' href='https://psyteachr.github.io/glossary/i#intercept'>y-intercept</a> and $\beta_1$ playing the role of the <a class='glossary' target='_blank' title='A quantity that captures how much change in one variable is associated with a unit increase in another variable.' href='https://psyteachr.github.io/glossary/s#slope'>slope</a>. The $e_i$ term reflects what is left of observation $i$ after accounting for the the intercept and the predictor $X_i$.

A terminological convention in this course is that Greek letters ($\beta$, $\rho$, $\tau$) represent unobserved <a class='glossary' target='_blank' title='A quantity representing a property of a population of interest.' href='https://psyteachr.github.io/glossary/p#population-parameter'>population parameters</a> while Latin letters ($X$, $Y$) represent observed values.

This linear formulation is highly general, and we will see how it can be used to model different kinds of relationships between different kinds of variables. One limitation of the current course is that it focuses mainly on <a class='glossary' target='_blank' title='Relating to a single variable.' href='https://psyteachr.github.io/glossary/u#univariate'>univariate</a> data, where a single <a class='glossary' target='_blank' title='A variable (in a regression) whose value is assumed to be influenced by one or more predictor variables.' href='https://psyteachr.github.io/glossary/r#response-variable'>response variable</a> is the focus of analysis. It is often the case that you will be dealing with multiple response variables on the same subjects, but modeling them all simultaneously is technically very difficult and beyond the scope of this course. A simpler approach (and the one adopted here) is to analyze each response variable in a separate univariate analysis.

## Generalizability

The term <a class='glossary' target='_blank' title='A term referring to the degree to which findings can be readily applied to situations beyond the particular context in which the data were collected.' href='https://psyteachr.github.io/glossary/g#generalizability'>generalizability</a> refers to the degree to which findings from a study can be readily applied to situations beyond the particular context (subjects, stimuli, task, etc.) in which the data were collected. At best, our findings would apply to all members of the human species across a wide variety of contexts; at worst, they would apply only to those specific people observed in the specific context of our study. Most studies fall somewhere between these two opposing poles.

The generalizability of a finding depends on several factors: how the study was designed, what materials were used, how subjects were recruited, the nature of the task given to the subjects, **and the way the data were analyzed**. It is this last point that we will focus on in this course. When analyzing a dataset, if you want to make generalizable claims, you must make decisions about what would count as a replication of your study---about which aspects would remain fixed across replications, and which aspects you would allow to vary. Unfortunately, you will sometimes find that data have been analyzed in a way that does not support generalization in the broadest sense, often because analyses underestimate the influence of ideosyncratic features of stimulus materials or experimental task on the observed result [@yarkoni_2019].

## Reproduciblity and Transparency

The term <a class='glossary' target='_blank' title='The extent to which the findings of a study can be repeated in some other context' href='https://psyteachr.github.io/glossary/r#reproducibility'>reproducibility</a> refers to the degree to which it is possible to reproduce the pattern of findings in a study under various circumstances.

We say a finding is *analytically* or *computationally* reproducible if, given the raw data, we can obtain the same pattern of results. Note that this is different from saying a finding is **replicable**, which refers to being able to reproduce the finding in **new samples.** There is not widespread agreement about these terms, but it is convenient to view analytic reproducibility and replicability as two different but related types of reproducibility, with the former capturing reproducibility across analysts (or among the same analysts over time) and the latter reflecting reproducibility across participants. 

Ensuring that analyses are reproducible is a hard problem. If you fail to properly document your own analyses, or the software that you used gets modified or goes out of date and becomes unavailable, you may have trouble reproducing your own findings!

Another important property of analyses is <a class='glossary' target='_blank' title='The degree to which all the steps and decisions in a study have been documented and made available for verification.' href='https://psyteachr.github.io/glossary/t#transparency'>transparency</a>: the extent to which all the steps in some research study have been made available. A study may be transparent but not reproducible, and vice versa. It is important to use a workflow that promotes transparency. This makes the 'edit-and-execute' workflow of script programming ideal for data analysis, far superior to the 'point-and-click' workflow of most commercial statistical programs. By writing code, you make the logic and decision process explicit to others and easy to reconstruct.

## A simulation-based approach

A final characteristic that distinguishes this course is that it uses a **simulation-based approach** to learning about statistical models. By data simulation we mean specifying a model to characterize a population of interest and then using the computer's random number generator to simulate the process of sampling data from that population. We will look at a simple example of this below.

The typical problem that you will face when you analyze data is that you won't know the 'ground truth' about the population you are studying. You take a sample from that population, make some assumptions about how the observed data have been generated, and then use the observed data to estimate unknown population parameters and the uncertainty around these parameters. 

Data simulation inverts this process. You to define the parameters of a model representing the ground truth about a (hypothetical) population and then generate data from it. You can then analyze the resulting data in the way that you normally would, and see how well your parameter estimates correspond to the true values.

Let's look at an example. Let's assume you are interested in the question of whether being a parent of a toddler 'sharpens' your reflexes. If you've ever taken care of a toddler, you know that physical danger always seems imminent---they could fall of the chair they just climbed on, slam their finger in a door, bang their head on the corner of a table, etc.---so you need to be attentive and ready to act fast. You hypothesize that this vigilance will translate into faster response times in other situations where a toddler is not around, such as in a psychological laboratory. So you recruit a set of parents of toddlers to come into the lab. You give each parent the task of pressing a button as quickly as possible in response to a flashing light, and measure their response time (in milliseconds). For each parent, you calculate their mean response time over all trials. We can simulate the mean response time for each of say, 50 parents using the `rnorm()` function in R. But before we do that, we will load in the packages that we need (tidyverse) and set the <a class='glossary' target='_blank' title='A value used to set the initial state of a random number generator.' href='https://psyteachr.github.io/glossary/r#random-seed'>random seed</a> to make sure that you (the reader) get the same random values as me (the author).


```r
library("tidyverse")

set.seed(2020)  # can be any arbitrary integer
```


```r
parents <- rnorm(n = 50, mean = 480, sd = 40)

parents
```

```
##  [1] 495.0789 492.0619 436.0791 434.7838 368.1386 508.8229 517.5648 470.8249
##  [9] 550.3653 484.6947 445.8751 516.3704 527.8549 465.1366 475.0696 552.0017
## [17] 548.1598 358.4494 388.4410 482.3321 566.9746 523.9273 492.7288 477.0741
## [25] 513.3707 487.9500 531.9137 517.4687 474.1027 484.4173 447.4998 450.2519
## [33] 523.8138 577.4149 495.5247 491.6251 468.5761 483.0406 457.5881 497.8875
## [41] 516.3400 459.7976 467.9598 450.9586 432.7969 490.1230 465.1715 480.8872
## [49] 506.4018 499.5517
```

We chose to generate the data using `rnorm()`---a function that generates random numbers from a normal distribution---reflecting our assumption that mean response time is normally distributed in the population. A normal distribution is defined by two parameters, a mean (usually notated with the Greek letter $\mu$, pronounced "myoo"), and a standard deviation (usually notated with the Greek letter $\sigma$, pronounced "sigma"). Since we have generated the data ourselves, both $\mu$ and $\sigma$ are known, and in the call to `rnorm()`, we set them to the values 480 and 40 respectively.

But of course, to test our hypothesis, we need a comparison group, so we define a control group of non-parents. We generate data from this control group in the same way as above, but changing the mean.


```r
control <- rnorm(n = 50, mean = 500, sd = 40)
```

Let's put them into a <a class='glossary' target='_blank' title='A container for tabular data with some different properties to a data frame' href='https://psyteachr.github.io/glossary/t#tibble'>tibble</a> to make it easier to plot and analyze the data. Each row from this table represents the mean response time from a particular subject.


```r
dat <- tibble(group = rep(c("parent", "control"), c(length(parents), length(control))),
              rt = c(parents, control))

dat
```

```
## # A tibble: 100 x 2
##    group     rt
##    <chr>  <dbl>
##  1 parent  495.
##  2 parent  492.
##  3 parent  436.
##  4 parent  435.
##  5 parent  368.
##  6 parent  509.
##  7 parent  518.
##  8 parent  471.
##  9 parent  550.
## 10 parent  485.
## # … with 90 more rows
```

Here are some things to try with this simulated data.

1. Plot the data in some sensible way.
2. Calculate means and standard deviations. How do they compare with the population parameters?
3. Run a t-test on these data. Is the effect of group significant? 

Once you have done these things, do them again, but changing the sample size, population parameters or both.

## What you will learn

By the end of this course, you should be able to:

- simulate bivariate data
- understand the relationship between correlation and regression
- specify regression models to reflect various study designs
- specify and interpret various types of interactions
- simulate data from these models, including multilevel data
- handle continuous, count, or nominal dependent variables.
