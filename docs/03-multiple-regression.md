# Multiple regression

NULL

The general model for single-level data with $m$ predictors is

$$
Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \ldots + \beta_m X_{mi} + e_i
$$

with $e_i \sim \mathcal{N}\left(0, \sigma^2\right)$—in other words, with the assumption that the errors are from a normal distribution having a mean of zero and variance $\sigma^2$. 

Note that the key assumption here is **not** that the response variable (the $Y$s) is normally distributed, **nor** that the individual predictor variables (the $X$s) are normally distributed; it is **only** that the model residuals are normally distributed (for discussion, see [this blog post](https://datahowler.wordpress.com/2018/08/04/checking-model-assumptions-look-at-the-residuals-not-the-raw-data/)). The individual $X$ predictor variables can be any combination of continuous and/or categorical predictors, including interactions among variables. Further assumptions behind this particular model are that the relationship is "planar" (can be described by a flat surface, analogous to the linearity assumption in simple regression) and that the error variance is independent of the predictor values.

The $\beta$ values are referred to as **regression coefficients**. Each $\beta_h$ is interpreted as the **partial effect of $\beta_h$ holding constant all other predictor variables.** If you have $m$ predictor variables, you have $m+1$ regression coefficients: one for the intercept, and one for each predictor.

Although discussions of multiple regression are common in statistical textbooks, you will rarely be able to apply the exact model above. This is because the above model assumes single-level data, whereas most psychological data is multi-level. However, the fundamentals are the same for both types of datasets, so it is worthwhile learning them for the simpler case first.

## An example: How to get a good grade in statistics

Let's look at some (made up, but realistic) data to see how we can use multiple regression to answer various study questions. In this hypothetical study, you have a dataset for 100 statistics students, which includes their final course grade (`grade`), the number of lectures each student attended (`lecture`, an integer ranging from 0-10), how many times each student clicked to download online materials (`nclicks`) and each student's grade point average prior to taking the course, `GPA`, which ranges from 0 (fail) to 4 (highest possible grade).

### Data import and visualization

Let's load in the data [grades.csv](data/grades.csv){target="_download"} and have a look.


```r
library("corrr") # correlation matrices
library("tidyverse")

grades <- read_csv("data/grades.csv", col_types = "ddii")

grades
```

```
## # A tibble: 100 × 4
##    grade   GPA lecture nclicks
##    <dbl> <dbl>   <int>   <int>
##  1  2.40 1.13        6      88
##  2  3.67 0.971       6      96
##  3  2.85 3.34        6     123
##  4  1.36 2.76        9      99
##  5  2.31 1.02        4      66
##  6  2.58 0.841       8      99
##  7  2.69 4           5      86
##  8  3.05 2.29        7     118
##  9  3.21 3.39        9      98
## 10  2.24 3.27       10     115
## # … with 90 more rows
```

First let's look at all the pairwise correlations.


```r
grades %>%
  correlate() %>%
  shave() %>%
  fashion()
```

```
## 
## Correlation method: 'pearson'
## Missing treated using: 'pairwise.complete.obs'
```

```
##      term grade  GPA lecture nclicks
## 1   grade                           
## 2     GPA   .25                     
## 3 lecture   .24  .44                
## 4 nclicks   .16  .30     .36
```


```r
pairs(grades)
```

<div class="figure" style="text-align: center">
<img src="03-multiple-regression_files/figure-html/pairs-1.png" alt="All pairwise relationships in the `grades` dataset." width="100%" />
<p class="caption">(\#fig:pairs)All pairwise relationships in the `grades` dataset.</p>
</div>

### Estimation and interpretation

To estimate the regression coefficients (the $\beta$s), we will use the `lm()` function. For a GLM with $m$ predictors:

$$
Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \ldots + \beta_m X_{mi} + e_i
$$

The call to base R's `lm()` is

`lm(Y ~ X1 + X2 + ... + Xm, data)`

The `Y` variable is your response variable, and the `X` variables are the predictor variables. Note that you don't need to explicitly specify the intercept or residual terms; those are included by default.

For the current data, let's predict `grade` from `lecture` and `nclicks`.


```r
my_model <- lm(grade ~ lecture + nclicks, grades)

summary(my_model)
```

```
## 
## Call:
## lm(formula = grade ~ lecture + nclicks, data = grades)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -2.21653 -0.40603  0.02267  0.60720  1.38558 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)  
## (Intercept) 1.462037   0.571124   2.560   0.0120 *
## lecture     0.091501   0.045766   1.999   0.0484 *
## nclicks     0.005052   0.006051   0.835   0.4058  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.8692 on 97 degrees of freedom
## Multiple R-squared:  0.06543,	Adjusted R-squared:  0.04616 
## F-statistic: 3.395 on 2 and 97 DF,  p-value: 0.03756
```



We'll often write the parameter symbol with a little hat on top to make clear that we are dealing with estimates from the sample rather than the (unknown) true population values. From above:

* $\hat{\beta}_0$ = 1.46
* $\hat{\beta}_1$ = 0.09
* $\hat{\beta}_2$ = 0.01

This tells us that a person's predicted grade is related to their lecture attendance and download rate by the following formula:

`grade` = 1.46 + 0.09 $\times$ `lecture` + 0.01 $\times$ `nclicks`

Because $\hat{\beta}_1$ and $\hat{\beta}_2$ are both positive, we know that higher values of `lecture` and `nclicks` are associated with higher grades.

So if you were asked, what grade would you predict for a student who attends 3 lectures and downloaded 70 times, you could easily figure that out by substituting the appropriate values.

`grade` = 1.46 + 0.09 $\times$ 3 + 0.01 $\times$ 70

which equals

`grade` = 1.46 + 0.27 + 0.7

and reduces to

`grade` = 2.43

### Predictions from the linear model using `predict()`

If we want to predict response values for new predictor values, we can use the `predict()` function in base R. 

`predict()` takes two main arguments. The first argument is a fitted model object (i.e., `my_model` from above) and the second is a data frame (or tibble) containing new values for the predictors.

<div class="warning">
<p>You need to include <strong>all</strong> of the predictor variables in the new table. You'll get an error message if your tibble is missing any predictors. You also need to make sure that the variable names in the new table <strong>exactly</strong> match the variable names in the model.</p>
</div>

Let's create a tibble with new values and try it out.


```r
## a 'tribble' is a way to make a tibble by rows,
## rather than by columns. This is sometimes useful
new_data <- tribble(~lecture, ~nclicks,
                    3, 70,
                    10, 130,
                    0, 20,
                    5, 100)
```

:::{.info}

The `tribble()` function provides a way to build a tibble row by row, whereas with `tibble()` the table is built column by column.

The first row of the `tribble()` contains the column names, each preceded by a tilde (`~`).

This is sometimes easier to read than doing it row by row, although the result is the same. Consider that we could have made the above table using


```r
new_data <- tibble(lecture = c(3, 10, 0, 5),
                   nclicks = c(70, 130, 20, 100))
```

:::

Now that we've created our table `new_data`, we just pass it to `predict()` and it will return a vector with the predictions for $Y$ (`grade`).


```r
predict(my_model, new_data)
```

```
##        1        2        3        4 
## 2.090214 3.033869 1.563087 2.424790
```

That's great, but maybe we want to line it up with the predictor values. We can do this by just adding it as a new column to `new_data`.


```r
new_data %>%
  mutate(predicted_grade = predict(my_model, new_data))
```

```
## # A tibble: 4 × 3
##   lecture nclicks predicted_grade
##     <dbl>   <dbl>           <dbl>
## 1       3      70            2.09
## 2      10     130            3.03
## 3       0      20            1.56
## 4       5     100            2.42
```

Want to see more options for `predict()`? Check the help at `?predict.lm`.

### Visualizing partial effects

As noted above the parameter estimates for each regression coefficient tell us about the **partial** effect of that variable; it's effect holding all of the others constant. Is there a way to visualize this partial effect? Yes, you can do this using the `predict()` function, by making a table with varying values for the focal predictor, while filling in all of the other predictors with their mean values.

For example, let's visualize the partial effect of `lecture` on `grade` holding `nclicks` constant at its mean value.


```r
nclicks_mean <- grades %>% pull(nclicks) %>% mean()

## new data for prediction
new_lecture <- tibble(lecture = 0:10,
                      nclicks = nclicks_mean)

## add the predicted value to new_lecture
new_lecture2 <- new_lecture %>%
  mutate(grade = predict(my_model, new_lecture))

new_lecture2
```

```
## # A tibble: 11 × 3
##    lecture nclicks grade
##      <int>   <dbl> <dbl>
##  1       0    98.3  1.96
##  2       1    98.3  2.05
##  3       2    98.3  2.14
##  4       3    98.3  2.23
##  5       4    98.3  2.32
##  6       5    98.3  2.42
##  7       6    98.3  2.51
##  8       7    98.3  2.60
##  9       8    98.3  2.69
## 10       9    98.3  2.78
## 11      10    98.3  2.87
```

Now let's plot.


```r
ggplot(grades, aes(lecture, grade)) + 
  geom_point() +
  geom_line(data = new_lecture2)
```

<div class="figure" style="text-align: center">
<img src="03-multiple-regression_files/figure-html/partial-lecture-plot-1.png" alt="Partial effect of 'lecture' on grade, with nclicks at its mean value." width="100%" />
<p class="caption">(\#fig:partial-lecture-plot)Partial effect of 'lecture' on grade, with nclicks at its mean value.</p>
</div>

:::{.warning}

Partial effect plots only make sense when there are no interactions in the model between the focal predictor and any other predictor.

The reason is that when there are interactions, the partial effect of focal predictor $X_i$ will differ across the values of the other variables it interacts with.

:::

Now can you visualize the partial effect of `nclicks` on `grade`?

See the solution at the bottom of the page.

### Standardizing coefficients

One kind of question that we often use multiple regression to address is, **Which predictors matter most in predicting Y?**

Now, you can't just read off the $\hat{\beta}$ values and choose the one with the largest absolute value, because the predictors are all on different scales.  To answer this question, you need to **center** and **scale** the predictors.

Remember $z$ scores?

$$
z = \frac{X - \mu_x}{\sigma_x}
$$

A $z$ score represents the distance of a score $X$ from the sample mean ($\mu_x$) in standard deviation units ($\sigma_x$). So a $z$ score of 1 means that the score is one standard deviation about the mean; a $z$-score of -2.5 means 2.5 standard deviations below the mean.  $Z$-scores give us a way of comparing things that come from different populations by calibrating them to the standard normal distribution (a distribution with a mean of 0 and a standard deviation of 1).

So we re-scale our predictors by converting them to $z$-scores. This is easy enough to do.


```r
grades2 <- grades %>%
  mutate(lecture_c = (lecture - mean(lecture)) / sd(lecture),
         nclicks_c = (nclicks - mean(nclicks)) / sd(nclicks))

grades2
```

```
## # A tibble: 100 × 6
##    grade   GPA lecture nclicks lecture_c nclicks_c
##    <dbl> <dbl>   <int>   <int>     <dbl>     <dbl>
##  1  2.40 1.13        6      88  -0.484     -0.666 
##  2  3.67 0.971       6      96  -0.484     -0.150 
##  3  2.85 3.34        6     123  -0.484      1.59  
##  4  1.36 2.76        9      99   0.982      0.0439
##  5  2.31 1.02        4      66  -1.46      -2.09  
##  6  2.58 0.841       8      99   0.493      0.0439
##  7  2.69 4           5      86  -0.972     -0.796 
##  8  3.05 2.29        7     118   0.00488    1.27  
##  9  3.21 3.39        9      98   0.982     -0.0207
## 10  2.24 3.27       10     115   1.47       1.08  
## # … with 90 more rows
```

Now let's re-fit the model using the centered and scaled predictors.


```r
my_model_scaled <- lm(grade ~ lecture_c + nclicks_c, grades2)

summary(my_model_scaled)
```

```
## 
## Call:
## lm(formula = grade ~ lecture_c + nclicks_c, data = grades2)
## 
## Residuals:
##      Min       1Q   Median       3Q      Max 
## -2.21653 -0.40603  0.02267  0.60720  1.38558 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  2.59839    0.08692  29.895   <2e-16 ***
## lecture_c    0.18734    0.09370   1.999   0.0484 *  
## nclicks_c    0.07823    0.09370   0.835   0.4058    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.8692 on 97 degrees of freedom
## Multiple R-squared:  0.06543,	Adjusted R-squared:  0.04616 
## F-statistic: 3.395 on 2 and 97 DF,  p-value: 0.03756
```



This tells us that lecture_c has a relatively larger influence; for each standard deviation increase in this variable, `grade` increases by about 0.19.

Another common approach to standardization involves standardizing the response variable as well as the predictors, i.e., $z$-scoring the $Y$ values as well as the $X$ values. The relative rank order of the predictors will be the same under this approach. The main difference would be that the predictors will not be expressed in standard deviation ($SD$) units of the response variable, rather than in raw units.

:::{.info}

**Multicollinearity and its discontents**

In discussions about multiple regression you may hear concerns expressed about "multicollinearity", which is a fancy way of referring to the existence of intercorrelations between the predictor variables. This is only a potential problem insofar as it potentially affects the interpretation of the effects of individual predictor variables. When predictor variables are correlated, $\beta$ values can change depending upon which predictors are included or excluded from the model, sometimes even changing signs. The key things to keep in mind about this are:

- correlated predictors are probably unavoidable in observational studies; 
- it is not an assumption underlying regression that your predictors have to be independent (in other words, findingcorrelations amongst your predictors does not invalidate your model);
- when strong correlations are present, use caution in interpreting individual regression coefficients;
- there is no known "remedy" for it, nor is it clear that any such remedy is desireable, and many so-called remedies do more harm than good.

For more information and guidance, see [@Vanhove_2021].

:::

### Model comparison

Another common kind of question multiple regression is also used to address is of the form: Does some predictor or set of predictors of interest significantly impact my response variable **over and above the effects of some control variables**?

For example, we saw above that the model including `lecture` and `nclicks` was statistically significant, 
$F(2,
97) = 
3.395$, 
$p = 0.038$.

The null hypothesis for a regression model with $m$ predictors is

$$H_0: \beta_1 = \beta_2 = \ldots = \beta_m = 0;$$

in other words, that all of the coefficients (except the intercept) are zero. If the null hypothesis is true, then the null model

$$Y_i = \beta_0$$

gives just as good of a prediction as the model including all of the predictors and their coefficients. In other words, your best prediction for $Y$ is just its mean ($\mu_y$); the $X$ variables are irrelevant. We rejected this null hypothesis, which implies that we can do better by including our two predictors, `lecture` and `nclicks`.

But you might ask: maybe its the case that better students get better grades, and the relationship between `lecture`, `nclicks`, and `grade` is just mediated by student quality. After all, better students are more likely to go to lecture and download the materials. So we can ask, are attendance and downloads associated with better grades **above and beyond** student ability, as measured by GPA?

The way we can test this hypothesis is by using **model comparison**. The logic is as follows. First, estimate a model containing any control predictors but excluding the focal predictors of interest. Second, estimate a model containing the control predictors as well as the focal predictors. Finally, compare the two models, to see if there is any statistically significant gain by including the predictors. 

Here is how you do this:


```r
m1 <- lm(grade ~ GPA, grades) # control model
m2 <- lm(grade ~ GPA + lecture + nclicks, grades) # bigger model

anova(m1, m2)
```

```
## Analysis of Variance Table
## 
## Model 1: grade ~ GPA
## Model 2: grade ~ GPA + lecture + nclicks
##   Res.Df    RSS Df Sum of Sq      F Pr(>F)
## 1     98 73.528                           
## 2     96 71.578  2    1.9499 1.3076 0.2752
```



The null hypothesis is that we are just as good predicting `grade` from `GPA` as we are predicting it from `GPA` plus `lecture` and `nclicks`. We will reject the null if adding these two variables leads to a substantial enough reduction in the **residual sums of squares** (RSS); i.e., if they explain away enough residual variance.

We see that this is not the case: 
$F(2, 96 ) = 
1.308$, 
$p = 0.275$. So we don't have evidence that lecture attendance and downloading the online materials is associated with better grades above and beyond student ability, as measured by GPA.

## Dealing with categorical predictors

You can include categorical predictors in a regression model, but first you have to code them as numerical variables. There are a couple of important considerations here. 

:::{.danger}

A **nominal** variable is a categorical variable for which there is no inherent ordering among the levels of the variable. Pet ownership (cat, dog, ferret) is a nominal variable; cat is not greater than dog and dog is not greater than ferret.

It is common to code nominal variables using numbers. However, you have to be **very careful** about using numerically-coded nominal variables in your models. If you have a number that is really just a nominal variable, make sure you define it as type `factor()` before entering it into the model. Otherwise, it will try to treat it as an actual number, and the results of your modeling will be garbage! 

It is far too easy to make this mistake, and difficult to catch if authors do not share their data and code. In 2016, [a paper on religious affiliation and altruism in children that was published in Current Biology had to be retracted for just this kind of mistake](https://www.sciencedirect.com/science/article/pii/S0960982216306704).

:::

### Dummy coding

For a factor with two levels, choose one level as zero and the other as one. The choice is arbitrary, and will affect the sign of the coefficient, but not its standard error or p-value.  Here is some code that will do this. Note that if you have a predictor of type character or factor, R will automatically do that for you. We don't want R to do this for reasons that will become apparent in the next lecture, so let's learn how to make our own numeric predictor.

First, we gin up some fake data to use in our analysis.


```r
fake_data <- tibble(Y = rnorm(10),
                    group = rep(c("A", "B"), each = 5))

fake_data
```

```
## # A tibble: 10 × 2
##         Y group
##     <dbl> <chr>
##  1  1.17  A    
##  2  0.687 A    
##  3 -0.756 A    
##  4  0.195 A    
##  5  1.59  A    
##  6 -0.315 B    
##  7 -0.694 B    
##  8 -0.721 B    
##  9 -1.20  B    
## 10 -1.01  B
```

Now let's add a new variable, `group_d`, which is the dummy coded group variable. We will use the `dplyr::if_else()` function to define the new column.


```r
fake_data2 <- fake_data %>%
  mutate(group_d = if_else(group == "B", 1, 0))

fake_data2
```

```
## # A tibble: 10 × 3
##         Y group group_d
##     <dbl> <chr>   <dbl>
##  1  1.17  A           0
##  2  0.687 A           0
##  3 -0.756 A           0
##  4  0.195 A           0
##  5  1.59  A           0
##  6 -0.315 B           1
##  7 -0.694 B           1
##  8 -0.721 B           1
##  9 -1.20  B           1
## 10 -1.01  B           1
```

Now we just run it as a regular regression model.


```r
summary(lm(Y ~ group_d, fake_data2))
```

```
## 
## Call:
## lm(formula = Y ~ group_d, data = fake_data2)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -1.3326 -0.3415  0.0805  0.3822  1.0101 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)  
## (Intercept)   0.5767     0.3067   1.880   0.0969 .
## group_d      -1.3645     0.4338  -3.146   0.0137 *
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.6858 on 8 degrees of freedom
## Multiple R-squared:  0.553,	Adjusted R-squared:  0.4971 
## F-statistic: 9.896 on 1 and 8 DF,  p-value: 0.01368
```

Note that if we reverse the coding we get the same result, just the sign is different.


```r
fake_data3 <- fake_data %>%
  mutate(group_d = if_else(group == "A", 1, 0))

summary(lm(Y ~ group_d, fake_data3))
```

```
## 
## Call:
## lm(formula = Y ~ group_d, data = fake_data3)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -1.3326 -0.3415  0.0805  0.3822  1.0101 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)  
## (Intercept)  -0.7878     0.3067  -2.569   0.0332 *
## group_d       1.3645     0.4338   3.146   0.0137 *
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 0.6858 on 8 degrees of freedom
## Multiple R-squared:  0.553,	Adjusted R-squared:  0.4971 
## F-statistic: 9.896 on 1 and 8 DF,  p-value: 0.01368
```

The interpretation of the intercept is the estimated mean for the group coded as zero. You can see by plugging in zero for X in the prediction formula below. Thus, $\beta_1$ can be interpreted as the difference between the mean for the baseline group and the group coded as 1.

$$\hat{Y_i} = \hat{\beta}_0 + \hat{\beta}_1 X_i $$

### Dummy coding when $k > 2$

When the predictor variable is a factor with $k$ levels where $k>2$, we need $k-1$ predictors to code that variable. So if the factor has 4 levels, we'll need to define three predictors. Here is code to do that. Try it out and see if you can figure out how it works.


```r
mydata <- tibble(season = rep(c("winter", "spring", "summer", "fall"),
                              each = 5),
                 bodyweight_kg = c(rnorm(5, 105, 3),
                                   rnorm(5, 103, 3),
                                   rnorm(5, 101, 3),
                                   rnorm(5, 102.5, 3)))

mydata
```

```
## # A tibble: 20 × 2
##    season bodyweight_kg
##    <chr>          <dbl>
##  1 winter         102. 
##  2 winter         106. 
##  3 winter         108. 
##  4 winter          99.7
##  5 winter         105. 
##  6 spring         105. 
##  7 spring         102. 
##  8 spring         100. 
##  9 spring         102. 
## 10 spring         105. 
## 11 summer         101. 
## 12 summer         100. 
## 13 summer         101. 
## 14 summer          99.0
## 15 summer          99.9
## 16 fall           102. 
## 17 fall            99.4
## 18 fall           105. 
## 19 fall           103. 
## 20 fall           104.
```

Now let's add three predictors to code the variable `season`.


```r
## baseline value is 'winter'
mydata2 <- mydata %>%
  mutate(V1 = if_else(season == "spring", 1, 0),
         V2 = if_else(season == "summer", 1, 0),
         V3 = if_else(season == "fall", 1, 0))

mydata2
```

```
## # A tibble: 20 × 5
##    season bodyweight_kg    V1    V2    V3
##    <chr>          <dbl> <dbl> <dbl> <dbl>
##  1 winter         102.      0     0     0
##  2 winter         106.      0     0     0
##  3 winter         108.      0     0     0
##  4 winter          99.7     0     0     0
##  5 winter         105.      0     0     0
##  6 spring         105.      1     0     0
##  7 spring         102.      1     0     0
##  8 spring         100.      1     0     0
##  9 spring         102.      1     0     0
## 10 spring         105.      1     0     0
## 11 summer         101.      0     1     0
## 12 summer         100.      0     1     0
## 13 summer         101.      0     1     0
## 14 summer          99.0     0     1     0
## 15 summer          99.9     0     1     0
## 16 fall           102.      0     0     1
## 17 fall            99.4     0     0     1
## 18 fall           105.      0     0     1
## 19 fall           103.      0     0     1
## 20 fall           104.      0     0     1
```

:::{.warning}

**Why not just use 'factor' variables as predictors?**

If you've ever used point-and-click statistical software like SPSS, you probably never had to learn about coding categorical predictors. Normally, the software recognizes when a predictor is categorical and, behind the scenes, it takes care of recoding it into a numerical predictor. R is no different: if you supply a predictor of type `character` or `factor` to a linear modeling function, it will create numerical dummy-coded predictors for you, as shown in the code below.


```r
my_data <- tibble(group = rep(c("A", "B", "C"),
                              each = 6),
                  Y = rnorm(18))

lm(Y ~ group, my_data) %>%
  summary()
```

```
## 
## Call:
## lm(formula = Y ~ group, data = my_data)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -1.1855 -0.7148  0.0357  0.5429  1.4828 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)  -0.1628     0.3491  -0.466    0.648
## groupB        0.1844     0.4938   0.373    0.714
## groupC        0.0839     0.4938   0.170    0.867
## 
## Residual standard error: 0.8552 on 15 degrees of freedom
## Multiple R-squared:  0.009234,	Adjusted R-squared:  -0.1229 
## F-statistic: 0.0699 on 2 and 15 DF,  p-value: 0.9328
```

Here, R implicitly creates two dummy variables that it calls `groupB` and `groupC`. The variable `groupB` takes on the value of `1` when `group == "B"` and is `0` otherwise; `groupC` takes on the value of `1` when `group == "C"` and is `0` otherwise. R automatically identifies that the `group` variable has three levels, `A`, `B`, and `C`, and arbitrarily chooses as baseline the level that comes earliest when the levels are sequenced alphabetically.

This seems like a handy thing to have R do for us, but dangers lurk in relying on the default. We'll learn more about these dangers in the next chapter, but consider what would happen if, instead of labeling the levels of `group` using letters "A", "B", and "C", we had used integer values 1, 2, and 3.


```r
my_data2 <- tibble(group = rep(c(1, 2, 3),
                               each = 6),
                   Y = rnorm(18))

lm(Y ~ group, my_data2) %>%
  summary()
```

```
## 
## Call:
## lm(formula = Y ~ group, data = my_data2)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -2.8742 -0.2223  0.1019  0.7840  1.4999 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)  0.15770    0.69536   0.227    0.823
## group        0.07857    0.32189   0.244    0.810
## 
## Residual standard error: 1.115 on 16 degrees of freedom
## Multiple R-squared:  0.00371,	Adjusted R-squared:  -0.05856 
## F-statistic: 0.05958 on 1 and 16 DF,  p-value: 0.8103
```

R didn't understand that `group` was meant to be a continuous variable, and so it is treating it as continuous. The estimate for `group` is a nonsense estimate.

Moral: rather than letting R guess whether something is meant as a continuous or categorical variable, take control of your destiny and make your choice explicit. This also avoids further snags we'll encounter in the next chapter.

:::


## Equivalence between multiple regression and one-way ANOVA

If we wanted to see whether our bodyweight varies over season, we could do a one way ANOVA on `mydata2` like so.


```r
## make season into a factor with baseline level 'winter'
mydata3 <- mydata2 %>%
  mutate(season = factor(season, levels = c("winter", "spring",
                                            "summer", "fall")))

my_anova <- aov(bodyweight_kg ~ season, mydata3)
summary(my_anova)
```

```
##             Df Sum Sq Mean Sq F value Pr(>F)  
## season       3  42.78  14.261   2.606 0.0876 .
## Residuals   16  87.56   5.473                 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
```

OK, now can we replicate that result using the regression model below?

$$Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \beta_3 X_{3i} + e_i$$


```r
summary(lm(bodyweight_kg ~ V1 + V2 + V3, mydata3))
```

```
## 
## Call:
## lm(formula = bodyweight_kg ~ V1 + V2 + V3, data = mydata3)
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -4.5843 -1.0563  0.1967  1.6833  3.9939 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)  104.305      1.046  99.699   <2e-16 ***
## V1            -1.534      1.480  -1.037   0.3152    
## V2            -4.087      1.480  -2.762   0.0139 *  
## V3            -1.661      1.480  -1.123   0.2781    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 2.339 on 16 degrees of freedom
## Multiple R-squared:  0.3282,	Adjusted R-squared:  0.2023 
## F-statistic: 2.606 on 3 and 16 DF,  p-value: 0.08761
```

Note that the $F$ values and $p$ values are identical for the two methods!

## Solutions to exercises


<div class='webex-solution'><button>Solution to partial effect plot</button>


First create a tibble with new predictors. We might also want to know the range of values that `nclicks` varies over.


```r
lecture_mean <- grades %>% pull(lecture) %>% mean()
min_nclicks <- grades %>% pull(nclicks) %>% min()
max_nclicks <- grades %>% pull(nclicks) %>% max()

## new data for prediction
new_nclicks <- tibble(lecture = lecture_mean,
                      nclicks = min_nclicks:max_nclicks)

## add the predicted value to new_lecture
new_nclicks2 <- new_nclicks %>%
  mutate(grade = predict(my_model, new_nclicks))

new_nclicks2
```

```
## # A tibble: 76 × 3
##    lecture nclicks grade
##      <dbl>   <int> <dbl>
##  1    6.99      54  2.37
##  2    6.99      55  2.38
##  3    6.99      56  2.38
##  4    6.99      57  2.39
##  5    6.99      58  2.39
##  6    6.99      59  2.40
##  7    6.99      60  2.40
##  8    6.99      61  2.41
##  9    6.99      62  2.41
## 10    6.99      63  2.42
## # … with 66 more rows
```

Now plot.


```r
ggplot(grades, aes(nclicks, grade)) +
  geom_point() +
  geom_line(data = new_nclicks2)
```

<div class="figure" style="text-align: center">
<img src="03-multiple-regression_files/figure-html/partial-nclicks-1.png" alt="Partial effect plot of nclicks on grade." width="100%" />
<p class="caption">(\#fig:partial-nclicks)Partial effect plot of nclicks on grade.</p>
</div>


</div>

