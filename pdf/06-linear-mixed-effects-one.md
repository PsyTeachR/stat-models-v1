# Linear mixed-effects models with one random factor

## Learning objectives

* understand how linear mixed-effects models can replace conventional analyses, and when they are appropriate
* express various types of common designs in a regression framework
* use model comparison (`anova()`) for testing effects
* express various study designs using the R regression formula syntax

## When, and why, would you want to replace conventional analyses with linear mixed-effects modeling?

We have repeatedly emphasized how many common techniques in psychology can be seen as special cases of the general linear model. This implies that it would be possible to replace these techniques with regression. In fact, you could analyze almost any conceivable dataset in psychology using one of the four functions below:


\begin{tabular}{l|l|l|l}
\hline
sampling design & type of data & function & description\\
\hline
single level & continuous, normally distributed & `base::lm()` & simple linear model\\
\hline
single level & count or categorical & `base::glm()` & generalized linear model\\
\hline
multilevel & continuous, normally distributed & `lme4::lmer()` & linear mixed-effects model\\
\hline
multilevel & count or categorical & `lme4::glmer()` & generalized linear mixed-effects model\\
\hline
\end{tabular}

To decide which function to use, you need to know the type of data you're working with (continuous and normally distributed, or not) and how the data have been sampled (single-level or <a class='glossary' target='_blank' title='(or multi-level) Relating to datasets where there are multiple observations taken on the same variable on the same sampling units (usually subjects or stimuli).' href='https://psyteachr.github.io/glossary/m#multilevel'>multilevel</a>). Arguments to these functions are highly similar across all four versions.  We will learn about analyzing count and categorical data later in this course. For now, we will focus on continuous data, but many of the principles are identical.

Here is a comparison chart for single-level data (data where you don't have <a class='glossary' target='_blank' title='A dataset has repeated measures if there are multiple measurements taken on the same variable for individual sampling units.' href='https://psyteachr.github.io/glossary/r#repeated-measures'>repeated-measures</a>):


\begin{tabular}{l|l|l}
\hline
test & conventional approach & regression approach\\
\hline
one-sample t-test & `t.test(y, mu = c)` & `lm(y \textasciitilde{} 1, offset = c)`\\
\hline
independent samples t-test & `t.test(x, y)` & `lm(y \textasciitilde{} x)`\\
\hline
one factor ANOVA & `aov(y \textasciitilde{} x)` & `lm(y \textasciitilde{} x)`\\
\hline
factorial ANOVA & `aov(y \textasciitilde{} a * b)` & `lm(y \textasciitilde{} a * b)`\\
\hline
\end{tabular}

All of above designs are *between-subjects* designs without repeated measures. (Note that in the factorial case, we would probably replace `a` and `b` with our own deviation-coded numerical predictors, for reasons already discussed in [the chapter on interactions](interactions.html)).

Where mixed-effects models come into play is with multilevel data. Data is usually multilevel for one of the three reasons below (multiple reasons could simultaneously apply):

1. you have a within-subject factor, and/or
2. you have **pseudoreplications**, and/or
3. you have multiple stimulus items (which we will discuss in the [next chapter](linear-mixed-effects-models-with-crossed-random-factors.html)).

(At this point, it would be a good idea to refresh your memory on the meaning of between- versus within- subject factors). In the `sleepstudy` data, you had the within-subject factor of `Day` (which is more a numeric variable, actually, than a factor; but it has multiple values varying within each participant).

**Pseudoreplications** occur when you take multiple measurements within the same condition. For instance, imagine a study where you randomly assign participants to consume one of two beverages---alcohol or water---before administering a simple response time task where they press a button as fast as possible when a light flashes. You would probably take more than one measurement of response time for each participant; let's assume that you measured it over 100 trials. You'd have one between-subject factor (beverage) and 100 observations per subject, for say, 20 subjects in each group. One common mistake novices make when analyzing such data is to try to run a t-test. **You can't directly use the conventional a t-test when you have pseudoreplications (or multiple stimuli).** You must first calculate means for each subject, and then run your analysis **on the means, not on the raw data.** There are versions of ANOVA that can deal with pseudoreplications, but you are probably better off using a linear-mixed effects model, which can better handle the complex dependency structure.

Here is a comparison chart for multi-level data:


\begin{tabular}{l|l|l}
\hline
test & conventional approach & regression approach\\
\hline
one-sample t-test with pseudoreplications & calculate means and use `t.test(x\_mean)` & <code>lmer(y \textasciitilde{} (1 | subject), offset = c)</code>\\
\hline
paired samples t-test, no pseudoreplications & `t.test(x, y, paired = TRUE)` & <code>lmer(y \textasciitilde{} x + (1 | subject))</code>\\
\hline
paired samples t-test with pseudoreplications & calculate means and use `t.test(x\_mean, y\_mean)` & <code>lmer(y \textasciitilde{} x + (1 + x | subject))</code>\\
\hline
repeated-measures ANOVA no pseudoreplications & `aov(y \textasciitilde{} x + Error(subject))` & <code>lmer(y \textasciitilde{} x + (1 | subject))</code>\\
\hline
repeated-measures ANOVA with pseudoreplications & `aov(y \textasciitilde{} x + Error(subject/x))` & <code>lmer(y \textasciitilde{} x + (1 + x | subject))</code>\\
\hline
factorial ANOVA, a \& b within, no pseudoreplications & `aov(y \textasciitilde{} a * b + Error(subject))` & <code>lmer(y \textasciitilde{} a * b + (1 | subject))</code>\\
\hline
factorial ANOVA with pseudoreplications & `aov(y \textasciitilde{} a * b + Error(subject/(a * b))` & <code>lmer(y \textasciitilde{} a * b + (1 + a * b | subject)</code>\\
\hline
\end{tabular}

One of the main selling points of the general linear models / regression framework over t-test and ANOVA is its flexibility. We saw this in the last chapter with the `sleepstudy` data, which could only be properly handled within a linear mixed-effects modelling framework. Despite the many advantages of regression, if you are in a situation where you have balanced data and can reasonably apply t-test or ANOVA without violating any of the assumptions behind the test, it makes sense to do so; these approaches have a long history in psychology and are more widely understood.

## Example: Independent-samples $t$-test on multi-level data

Let's consider a situation where you are testing the effect of alcohol consumption on simple reaction time (e.g., press a button as fast as you can after a light appears). To keep it simple, let's assume that you have collected data from 14 participants randomly assigned to perform a set of 10 simple RT trials after one of two interventions: drinking a pint of alcohol (treatment condition) or a placebo drink (placebo condition).  You have 7 participants in each of the two groups. Note that you would need more than this for a real study.

This [web app](https://shiny.psy.gla.ac.uk/Dale/icc){target="_blank"} presents simulated data from such a study. Subjects P01-P07 are from the placebo condition, while subjects T01-T07 are from the treatment condition. Please stop and have a look!

If we were going to run a t-test on these data, we would first need to calculate subject means, because otherwise the observations are not independent. You could do this as follows. (If you want to run the code below, you can download sample data from the web app above and save it as `independent_samples.csv`).


```r
library("tidyverse")

dat <- read_csv("data/independent_samples.csv", col_types = "cci")

subj_means <- dat %>%
  group_by(subject, cond) %>%
  summarise(mean_rt = mean(RT)) %>%
  ungroup()

subj_means
```

```
## # A tibble: 14 x 3
##    subject cond  mean_rt
##    <chr>   <chr>   <dbl>
##  1 P01     P        354 
##  2 P02     P        384.
##  3 P03     P        391.
##  4 P04     P        404.
##  5 P05     P        421.
##  6 P06     P        392 
##  7 P07     P        400.
##  8 T08     T        430.
##  9 T09     T        432.
## 10 T10     T        410.
## 11 T11     T        455.
## 12 T12     T        450.
## 13 T13     T        418.
## 14 T14     T        489.
```

Then, the $t$-test can be run using the "formula" version of `t.test()`.


```r
t.test(mean_rt ~ cond, subj_means)
```

```
## 
## 	Welch Two Sample t-test
## 
## data:  mean_rt by cond
## t = -3.7985, df = 11.32, p-value = 0.002807
## alternative hypothesis: true difference in means is not equal to 0
## 95 percent confidence interval:
##  -76.32580 -20.44563
## sample estimates:
## mean in group P mean in group T 
##        392.3143        440.7000
```

While there is nothing wrong with this analysis, aggregating the data throws away information. we can see in the above web app that there are actually two different sources of variability: trial-by-trial variability in simple RT (represented by $\sigma$) and variability across subjects in terms of their how slow or fast they are relative to the population mean ($\gamma_{00}$).  The Data Generating Process for response time ($Y_{st}$) for subject $s$ on trial $t$ is shown below.

*Level 1:*

\begin{equation}
Y_{st} = \beta_{0s} + \beta_{1} X_{s} + e_{st}
\end{equation}

*Level 2:*

\begin{equation}
\beta_{0s} = \gamma_{00} + S_{0s}
\end{equation}

\begin{equation}
\beta_{1} = \gamma_{10}
\end{equation}

*Variance Components:*

\begin{equation}
S_{0s} \sim N\left(0, {\tau_{00}}^2\right) 
\end{equation}

\begin{equation}
e_{st} \sim N\left(0, \sigma^2\right)
\end{equation}

In the above equation, $X_s$ is a numerical predictor coding which condition the subject $s$ is in; e.g., 0 for placebo, 1 for treatment.

The multi-level equations are somewhat cumbersome for such a simple model; we could just reduce levels 1 and 2 to 

\begin{equation}
Y_{st} = \gamma_{00} + S_{0s} + \gamma_{10} X_s + e_{st},
\end{equation}

but it is worth becoming familiar with the multi-level format for when we encounter more complex designs.

Unlike the `sleepstudy` data seen in the last chapter, we only have one random effect for each subject, $S_{0s}$. There is no random slope. Each subject appears in only one of the two treatment conditions, so it would not be possible to estimate how the effect of placebo versus alcohol varies over subjects.  The mixed-effects model that we would fit to these data, with random intercepts but no random slopes, is known as a **random intercepts model**.

A random-intercepts model would adequately capture the two sources of variability mentioned above: the inter-subject variability in overall mean RT in the parameter ${\tau_{00}}^2$, and the trial-by-trial variability in the parameter $\sigma^2$. We can calculate the proportion of the total variability attributable to individual differences among subjects using the formula below.

$$ICC = \frac{{\tau_{00}}^2}{{\tau_{00}}^2 + \sigma^2}$$

This quantity, known as the **intra-class correlation coefficient**, and tells you how much clustering there is in your data. It ranges from 0 to 1, with 0 indicating that all the variability is due to residual variance, and 1 indicating that all the variability is due to individual differences among subjects.

The lmer syntax for fitting a random intercepts model to the data is `lmer(RT ~ cond + (1 | subject), dat, REML=FALSE)`. Let's create our own numerical predictor first, to make it explicit that we are using dummy coding.


```r
dat2 <- dat %>%
  mutate(cond_d = if_else(cond == "T", 1L, 0L))

distinct(dat2, cond, cond_d)  ## double check
```

```
## # A tibble: 2 x 2
##   cond  cond_d
##   <chr>  <int>
## 1 P          0
## 2 T          1
```

And now, estimate the model.


```r
library("lme4")

mod <- lmer(RT ~ cond_d + (1 | subject), dat2, REML = FALSE)

summary(mod)
```

```
## Linear mixed model fit by maximum likelihood  ['lmerMod']
## Formula: RT ~ cond_d + (1 | subject)
##    Data: dat2
## 
##      AIC      BIC   logLik deviance df.resid 
##   1451.8   1463.5   -721.9   1443.8      136 
## 
## Scaled residuals: 
##      Min       1Q   Median       3Q      Max 
## -2.67117 -0.66677  0.01656  0.75361  2.58447 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev.
##  subject  (Intercept)  329.3   18.15   
##  Residual             1574.7   39.68   
## Number of obs: 140, groups:  subject, 14
## 
## Fixed effects:
##             Estimate Std. Error t value
## (Intercept)  392.314      8.339  47.045
## cond_d        48.386     11.793   4.103
## 
## Correlation of Fixed Effects:
##        (Intr)
## cond_d -0.707
```

Play around with the sliders in the app above and check the lmer output panel until you understand how the output maps onto the model parameters.

### When is a random-intercepts model appropriate?

Of course, a mixed-effects model is only appropriate when you have multilevel data. The random-intercepts model is appropriate for any one-sample or between-subjects data with pseudoreplications (if you don't have pseudoreplications in this situation, you don't have multilevel data, and you can just use vanilla regression, e.g., `lm()`).

The "random-intercepts-only" model is also appropriate when you have within-subject factors in your design, but **only if you don't also have pseudoreplications**; that is, it is **only** appropriate when you have a single observation per subject per level of the within-subject factor. If you have more than one observation per subject per level/cell, you need to enrich your random effects structure with random slopes, as described in the next section. If the reason you have multiple observations per subject per level is because you have each subject reacting to the same set of stimuli, then you might want to consider a mixed-effects model with crossed random effects for subjects and stimuli, as described in the [next chapter](linear-mixed-effects-models-with-crossed-random-factors.html).

The same logic goes for factorial designs in which there is more than one within-subjects factor. In factorial designs, the random-intercepts model is appropriate if you have one observation per subject per **cell** formed by each combination of the within-subjects factors. For instance, if $A$ and $B$ are two two-level within-subject factors, you need to check that you have only one observation for each subject in $A_1B_1$, $A_1B_2$, $A_2B_1$, and $A_2B_2$. If you have more than one observation, you will need to consider including a random slope in your model.

## Expressing the study design and performing tests in regression

In order to reproduce all of the t-test/ANOVA-style analyses in linear mixed-effects models, you'll need to better understand two things: (1) how to express your study design in a regression formula, and (2) how to get p-values for any tests you perform. The latter part is not obvious within the linear mixed-effects approach, since in many circumstances, the output of `lme4::lmer()` does not give you p-values by default, reflecting the fact that there are multiple options for deriving them [@Luke_2017]. Or, you might get p-values for individual regression coefficients, but the test you want to perform is a composite one where you need to test multiple parameters simultaneously. 

First, let's take a closer look at the regression formula syntax in R and **`lme4`**. For the regression model $y = \beta_0 + \beta_1 x_1 + \beta_2 x_2 + \ldots + \beta_m x_m + e$ with by-subject random effects you'd have:

`y ~ 1 + x1 + x2 + ... + xm + (1 + x1 + ... | subject)`

The residual term is implied and so not mentioned; only the predictors. The left side (before the tilde `~`) specifies the response variable, the right side has the predictor variables. The term in brackets, `(... | ...)`, is specific to **`lme4`**. The right side of the vertical bar `|` specifies the name of a variable (in this case, `subject`) that codes the levels of the random factor. The left side specifies what regression coefficients you want to allow to vary over those levels. The `1` at the start of the formula specifies that you want an intercept, which is included by default anyway, and so can be omitted. The `1` within the bracket specifies a **random intercept**, which is also included by default; the predictor variables mentioned inside the brackets specify **random slopes**. So you could write the above formula equivalently as:

`y ~ x1 + x2 + ... + xm + (x1 + ... | subject)`.

There is another important type of shortcut in R formulas, which we already saw in the [chapter on interactions](interactions.html); namely the "star syntax" `a * b` for specifying interactions. If you have two factors, `a` and `b` in your design, and you want all main effects and interactions in the model, you can use:

`y ~ a * b`

which is equivalent to `y ~ a + b + a:b` where `a` and `b` are the predictors coding main effects of A and B respectively, and `a:b` codes the AB interaction. It saves a lot of typing (and mistakes) to use the star syntax for interactions rather than spelling them out. This can be seen more easily in the example below, which codes a 2x2x2 factorial design including factors A, B, and C:

`y ~ a * b * c`

which is equivalent to

`y ~ a + b + c + a:b + a:c + b:c + a:b:c`

where `a:b`, `a:c`, and `b:c` are two-way interactions and `a:b:c` is the three-way interaction. You can use the star syntax inside the brackets for the random effects term as well, e.g., 

`y ~ a * b * c + (a * b * c | subject)`

is equivalent to

`y ~ a + b + c + a:b + a:c + b:c + a:b:c + (a + b + c + a:b + a:c + b:c + a:b:c | subject)`

which, despite its complexity, is a design that is not that uncommon in psychology (e.g., if you have all factors within and multiple stimuli per condition)!

### Factors with more than two levels

As noted above, you could conduct a one-factor ANOVA in regression using the formula `lm(y ~ x)` for single-level or `lmer(y ~ x + (1 | subject))` for the multilevel version without pseudoreplications. In the formula, the `x` predictor would be of type `factor()`, which R would (by default) convert to $k-1$ dummy-coded numerical predictors (one for each level; see the [interaction chapter](interactions.html) for information).

It is often sensible to code your own numerical predictors, particularly if your goal is to do ANOVA-style tests of main effects and interactions, which can be difficult if any of your variables are of type `factor`. So for a design with one three-level factor called `meal` (`breakfast`, `lunch`, `dinner`) you could create two variables, `lunch_v_breakfast` and `dinner_v_breakfast` following the scheme below.


\begin{tabular}{l|r|r}
\hline
factor level & lunch\_v\_breakfast & dinner\_v\_breakfast\\
\hline
breakfast & -1/3 & -1/3\\
\hline
lunch & +2/3 & -1/3\\
\hline
dinner & -1/3 & +2/3\\
\hline
\end{tabular}

If your dependent variable is `calories`, your model would be:

`calories ~ lunch_v_breakfast + dinner_v_breakfast`.

But what if you wanted to interact `meal` with another two-level factor---say, `time_of_week` (`weekday` versus `weekend`, coded as -.5 and +.5 respectively), because you think the calories consumed per meal would differ across the levels of this variable? Then your model would be:

`calories ~ (lunch_v_breakfast + dinner_v_breakfast) * time_of_week`.

[(The inclusion of an interaction is the reason we chose the "deviation" coding scheme.)](interactions.html#coding-schemes-for-categorical-variables). We put brackets around the predictors associated with the two-level variable so that each one interacts with `time_of_week`. The above star syntax is shorthand for:

`calories ~ lunch_v_breakfast + dinner_v_breakfast + time_of_week + lunch_v_breakfast:time_of_week + dinner_v_breakfast:time_of_week`.

This is the "regression way" of estimating parameters for a 3x2 factorial design.

### Multiparameter tests

Whenever you are dealing with designs where all categorical factors have no more than two levels, the test of the regression coefficient associated with a given factor will be equivalent to the test for the effect in the ANOVA framework, provided you use [sum or deviation coding](multiple-regression.html#dealing-with-categorical-predictors). But in the above example, we have a 3x2 design, with two predictor variables coding the main effect of `meal` (`lunch_v_breakfast` and `dinner_v_breakfast`). Let's simulate some data and run a one-factor ANOVA with `aov()`, and then we'll replicate the analysis using the regression function `lm()` (note that the same procedure works for mixed-effects models on multilevel data, just using `lme4::lmer()` instead of `base::lm()`).


```r
## make up some data
set.seed(62)
meals <- tibble(meal = factor(rep(c("breakfast", "lunch", "dinner"),
                                  each = 6)),
                time_of_week = factor(rep(rep(c("weekday", "weekend"),
                                              each = 3), 3)),
                calories = rnorm(18, 450, 50))

## use sum coding instead of default 'dummy' (treatment) coding
options(contrasts = c(unordered = "contr.sum", ordered = "contr.poly"))

aov(calories ~ meal * time_of_week, data = meals) %>%
  summary()
```

```
##                   Df Sum Sq Mean Sq F value Pr(>F)
## meal               2   2164    1082   0.380  0.692
## time_of_week       1   5084    5084   1.783  0.207
## meal:time_of_week  2   4767    2384   0.836  0.457
## Residuals         12  34209    2851
```

We get three $F$-tests, one for each main effect (`meal` and `time_of_week`) one for the interaction. What happens if we fit a model using `lm()`?


```r
## add our own numeric predictors
meals2 <- meals %>%
  mutate(lunch_v_breakfast = if_else(meal == "lunch", 2/3, -1/3),
         dinner_v_breakfast = if_else(meal == "dinner", 2/3, -1/3),
         time_week = if_else(time_of_week == "weekend", 1/2, -1/2))

## double check our coding
distinct(meals2, meal, time_of_week,
         lunch_v_breakfast, dinner_v_breakfast, time_week)

## fit regression model
mod <- lm(calories ~ (lunch_v_breakfast + dinner_v_breakfast) *
            time_week, data = meals2)

summary(mod)
```

```
## # A tibble: 6 x 5
##   meal      time_of_week lunch_v_breakfast dinner_v_breakfast time_week
##   <fct>     <fct>                    <dbl>              <dbl>     <dbl>
## 1 breakfast weekday                 -0.333             -0.333      -0.5
## 2 breakfast weekend                 -0.333             -0.333       0.5
## 3 lunch     weekday                  0.667             -0.333      -0.5
## 4 lunch     weekend                  0.667             -0.333       0.5
## 5 dinner    weekday                 -0.333              0.667      -0.5
## 6 dinner    weekend                 -0.333              0.667       0.5
## 
## Call:
## lm(formula = calories ~ (lunch_v_breakfast + dinner_v_breakfast) * 
##     time_week, data = meals2)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -68.522 -35.895  -4.063  42.061  73.081 
## 
## Coefficients:
##                              Estimate Std. Error t value Pr(>|t|)    
## (Intercept)                    451.15      12.58  35.848 1.42e-13 ***
## lunch_v_breakfast              -25.23      30.83  -0.818    0.429    
## dinner_v_breakfast             -20.59      30.83  -0.668    0.517    
## time_week                       33.61      25.17   1.335    0.207    
## lunch_v_breakfast:time_week    -58.31      61.65  -0.946    0.363    
## dinner_v_breakfast:time_week    17.93      61.65   0.291    0.776    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 53.39 on 12 degrees of freedom
## Multiple R-squared:  0.2599,	Adjusted R-squared:  -0.04843 
## F-statistic: 0.843 on 5 and 12 DF,  p-value: 0.5447
```

OK, this output looks very different! How do you perform ANOVA-like tests in those situations? You have estimates for `lunch_v_breakfast` and `dinner_v_breakfast` but how would you convert this into a single test for the main effect of `meal`? Likewise, you have two interaction terms, `lunch_v_breakfast:tow` and `dinner_v_breakfast:tow`; how do you convert this into a single test for the interaction?

The solution is to perform **multiparameter tests** using model comparison, implemented by the `anova()` function in R. To test for the main effect of `meal`, you'd compare a model containing the two predictor variables coding that factor (`lunch_v_breakfast` and `dinner_v_breakfast`) to a model excluding these two predictors but that is otherwise identical. You can either re-fit the model by writing it out and excluding the terms, or by using the `update()` function and removing the terms (which is a shortcut). Let's write it out first.


```r
## fit the model
mod_main_eff <- lm(calories ~ time_week +
                     lunch_v_breakfast:time_week + dinner_v_breakfast:time_week,
                   meals2)

## compare models
anova(mod, mod_main_eff)
```

```
## Analysis of Variance Table
## 
## Model 1: calories ~ (lunch_v_breakfast + dinner_v_breakfast) * time_week
## Model 2: calories ~ time_week + lunch_v_breakfast:time_week + dinner_v_breakfast:time_week
##   Res.Df   RSS Df Sum of Sq      F Pr(>F)
## 1     12 34209                           
## 2     14 36373 -2   -2163.9 0.3795 0.6921
```

OK, now here is an equivalent version using the shortcut `update()` function, which takes the model you want to update as the first argument and then a special syntax for the formula including your changes. For the formula, we use `. ~ . -lunch_v_breakfast -dinner_v_breakfast~` Although this formula seems weird, the dot `.` says "keep everything on this side of the model formula (left of `~`) as it is in the original model." So the formula `. ~ .` would use the same formula as the original model; that is, `update(mod, . ~ .)` would fit the exact same model as above. In contrast, `. ~ . -x -y` means "everything the same on the left side (same DV), but remove variables `x` and `y` from the right side.


```r
mod_main_eff2 <- update(mod, . ~ . -lunch_v_breakfast -dinner_v_breakfast)

anova(mod, mod_main_eff2)
```

```
## Analysis of Variance Table
## 
## Model 1: calories ~ (lunch_v_breakfast + dinner_v_breakfast) * time_week
## Model 2: calories ~ time_week + lunch_v_breakfast:time_week + dinner_v_breakfast:time_week
##   Res.Df   RSS Df Sum of Sq      F Pr(>F)
## 1     12 34209                           
## 2     14 36373 -2   -2163.9 0.3795 0.6921
```

As you can see, this gives us the same result as above.

If we want to test the main effect of `time_of_week`, we remove that predictor.


```r
mod_tow <- update(mod, . ~ . -time_week)

anova(mod, mod_tow)
```

```
## Analysis of Variance Table
## 
## Model 1: calories ~ (lunch_v_breakfast + dinner_v_breakfast) * time_week
## Model 2: calories ~ lunch_v_breakfast + dinner_v_breakfast + lunch_v_breakfast:time_week + 
##     dinner_v_breakfast:time_week
##   Res.Df   RSS Df Sum of Sq      F Pr(>F)
## 1     12 34209                           
## 2     13 39294 -1   -5084.1 1.7834 0.2065
```

Try to figure out how to test the interaction on your own.


<div class='solution'><button>Click to see solution</button>



```r
mod_interact <- update(mod, . ~ . -lunch_v_breakfast:time_week
                       -dinner_v_breakfast:time_week)

anova(mod, mod_interact)
```

```
## Analysis of Variance Table
## 
## Model 1: calories ~ (lunch_v_breakfast + dinner_v_breakfast) * time_week
## Model 2: calories ~ lunch_v_breakfast + dinner_v_breakfast + time_week
##   Res.Df   RSS Df Sum of Sq      F Pr(>F)
## 1     12 34209                           
## 2     14 38977 -2   -4767.4 0.8362 0.4571
```


</div>


We got the exact same results doing model comparison with `lm()` as we did using `aov()`. Although this involved more steps, it is worth learning this approach as it will ultimately give you much more flexibility.

