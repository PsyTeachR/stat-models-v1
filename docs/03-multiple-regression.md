# Multiple regression

:::{.warning}
This chapter is under construction as of August 31, 2021; contents may change!
:::

General model for single-level data with $m$ predictors:

$$
Y_i = \beta_0 + \beta_1 X_{1i} + \beta_2 X_{2i} + \ldots + \beta_m X_{mi} + e_i
$$

The individual $X_{hi}$ variables can be any combination of continuous and/or categorical predictors, including interactions among variables.

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

<div class="kable-table">

|     grade|       GPA| lecture| nclicks|
|---------:|---------:|-------:|-------:|
| 2.3951389| 1.1341088|       6|      88|
| 3.6651591| 0.9708817|       6|      96|
| 2.8527501| 3.3432350|       6|     123|
| 1.3597001| 2.7595763|       9|      99|
| 2.3133351| 1.0222222|       4|      66|
| 2.5828588| 0.8413324|       8|      99|
| 2.6946280| 4.0000000|       5|      86|
| 3.0549095| 2.2949328|       7|     118|
| 3.2104521| 3.3874844|       9|      98|
| 2.2441902| 3.2666345|      10|     115|
| 3.1338540| 2.2291875|       6|     114|
| 2.2259639| 1.7315937|       5|      84|
| 0.0000000| 0.4728941|       3|      95|
| 3.6278825| 1.5600287|      10|     123|
| 1.3405646| 2.7518845|       9|     115|
| 2.0876289| 2.0010052|       5|     101|
| 0.4346968| 2.1971687|       5|      84|
| 2.2624223| 2.7121565|       7|      90|
| 0.7232609| 2.8904362|       5|      83|
| 3.3532095| 1.8096567|       8|     102|
| 3.8653284| 3.5056229|       8|     121|
| 2.7834847| 1.9056691|       2|      85|
| 3.7018629| 2.4818014|      10|      87|
| 2.4481796| 2.4502653|       7|      81|
| 2.7484218| 3.7482459|       8|     110|
| 1.5854671| 2.9709662|       9|     100|
| 2.4482854| 2.9100299|      10|     129|
| 1.7412862| 0.9462394|       6|      90|
| 2.9308757| 2.3993738|       5|      96|
| 2.8210166| 2.4575954|       8|     129|
| 2.5831640| 3.0110584|       8|     118|
| 0.9659023| 1.7466986|       7|      94|
| 2.5080683| 3.1387667|       6|     113|
| 3.8499634| 3.3548881|       9|     122|
| 0.8822343| 1.5336613|      10|      84|
| 3.9024303| 1.7277751|       7|      82|
| 3.4712202| 1.7162995|       4|      83|
| 2.5115666| 2.6390593|       6|     112|
| 3.5146988| 3.3294875|       7|      89|
| 2.8290397| 2.6533664|       9|     100|
| 2.7471315| 2.8562607|       4|      84|
| 2.7449956| 2.9568736|      10|     102|
| 3.0977301| 0.3793328|       4|     111|
| 2.9783206| 2.4891591|       6|      96|
| 2.5125859| 2.5350625|       9|     103|
| 2.8944945| 4.0000000|       9|      77|
| 1.8156094| 2.2001745|       5|      96|
| 3.0011643| 2.8021604|       8|     112|
| 3.8528217| 2.8347729|      10|      76|
| 2.0496313| 1.1178989|       6|      81|
| 2.0300626| 1.0270266|       3|      99|
| 2.6281108| 1.8298851|       7|     106|
| 3.8726751| 2.7044881|       7|      97|
| 3.5678280| 1.6363600|       6|      85|
| 3.7235079| 1.6461525|       6|      88|
| 2.5045121| 1.9153413|       8|      92|
| 1.2359004| 3.4497622|       9|     122|
| 2.9946271| 2.9535615|       7|     110|
| 2.3944125| 3.7537037|       6|     106|
| 1.4451098| 0.9303599|       6|      83|
| 2.4376733| 3.1152237|       9|      95|
| 2.1284143| 2.3039751|       7|     119|
| 2.8615197| 1.7626461|       6|      99|
| 2.6672037| 1.5447171|       4|      54|
| 1.9934927| 1.3665324|       5|     116|
| 2.7596577| 2.2032136|       7|      61|
| 3.6984273| 1.1520123|       7|     103|
| 0.9500710| 2.1250378|       8|      96|
| 2.5592971| 3.7351342|       9|      80|
| 3.2861875| 3.4664206|      10|     115|
| 2.1222741| 3.3947098|       8|     106|
| 2.5400241| 1.8211989|       7|      84|
| 4.0000000| 2.4929632|      10|     127|
| 1.4398139| 2.6862850|       3|     109|
| 2.4110543| 1.4900472|       3|      92|
| 0.0000000| 0.4014776|       3|      67|
| 2.5738293| 2.9524421|       6|     105|
| 3.1142057| 1.8539501|       3|      79|
| 2.1363495| 2.6226571|      10|     106|
| 2.6817641| 2.2073880|       8|     110|
| 3.3349288| 1.7543494|       9|     105|
| 1.6988012| 2.1246531|       4|     101|
| 1.5526163| 1.5286636|      10|     109|
| 2.8019608| 2.8027352|       7|     102|
| 3.3707676| 1.6986526|       7|     105|
| 2.2348459| 1.4769582|       7|      80|
| 3.6601457| 4.0000000|       8|     109|
| 2.7328271| 3.0817157|      10|      94|
| 2.2687056| 3.1470495|       6|     106|
| 3.9933377| 2.2272781|       7|     105|
| 2.9514553| 2.8082666|       8|      88|
| 3.7680715| 3.8783317|       7|     120|
| 3.2473376| 2.0760349|       5|      67|
| 1.7682800| 3.3295325|       6|      84|
| 2.8944518| 4.0000000|       9|     102|
| 4.0000000| 4.0000000|       9|      84|
| 2.7733935| 3.5680159|       7|     107|
| 1.6120128| 2.3200362|       8|      94|
| 3.5397356| 2.8607765|       7|     108|
| 3.5275687| 2.8646434|      10|     109|

</div>

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

<div class="kable-table">

|term    |grade |GPA |lecture |nclicks |
|:-------|:-----|:---|:-------|:-------|
|grade   |      |    |        |        |
|GPA     |.25   |    |        |        |
|lecture |.24   |.44 |        |        |
|nclicks |.16   |.30 |.36     |        |

</div>


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

<div class="info">

The `tribble()` function provides a way to build a tibble row by row, whereas with `tibble()` the table is built column by column.

The first row of the `tribble()` contains the column names, each preceded by a tilde (`~`).

This is sometimes easier to read than doing it row by row, although the result is the same. Consider that we could have made the above table using


```r
new_data <- tibble(lecture = c(3, 10, 0, 5),
                   nclicks = c(70, 130, 20, 100))
```

</div>

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

<div class="kable-table">

| lecture| nclicks| predicted_grade|
|-------:|-------:|---------------:|
|       3|      70|        2.090214|
|      10|     130|        3.033869|
|       0|      20|        1.563087|
|       5|     100|        2.424790|

</div>

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

<div class="kable-table">

| lecture| nclicks|    grade|
|-------:|-------:|--------:|
|       0|   98.32| 1.958798|
|       1|   98.32| 2.050299|
|       2|   98.32| 2.141799|
|       3|   98.32| 2.233300|
|       4|   98.32| 2.324801|
|       5|   98.32| 2.416302|
|       6|   98.32| 2.507803|
|       7|   98.32| 2.599303|
|       8|   98.32| 2.690804|
|       9|   98.32| 2.782305|
|      10|   98.32| 2.873806|

</div>

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

<div class="warning">

Partial effect plots only make sense when there are no interactions in the model between the focal predictor and any other predictor.

The reason is that when there are interactions, the partial effect of focal predictor $X_i$ will differ across the values of the other variables it interacts with.

</div>

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

<div class="kable-table">

|     grade|       GPA| lecture| nclicks|  lecture_c|  nclicks_c|
|---------:|---------:|-------:|-------:|----------:|----------:|
| 2.3951389| 1.1341088|       6|      88| -0.4835417| -0.6664932|
| 3.6651591| 0.9708817|       6|      96| -0.4835417| -0.1498318|
| 2.8527501| 3.3432350|       6|     123| -0.4835417|  1.5939004|
| 1.3597001| 2.7595763|       9|      99|  0.9817363|  0.0439162|
| 2.3133351| 1.0222222|       4|      66| -1.4603938| -2.0873120|
| 2.5828588| 0.8413324|       8|      99|  0.4933103|  0.0439162|
| 2.6946280| 4.0000000|       5|      86| -0.9719678| -0.7956586|
| 3.0549095| 2.2949328|       7|     118|  0.0048843|  1.2709870|
| 3.2104521| 3.3874844|       9|      98|  0.9817363| -0.0206665|
| 2.2441902| 3.2666345|      10|     115|  1.4701623|  1.0772390|
| 3.1338540| 2.2291875|       6|     114| -0.4835417|  1.0126563|
| 2.2259639| 1.7315937|       5|      84| -0.9719678| -0.9248239|
| 0.0000000| 0.4728941|       3|      95| -1.9488198| -0.2144145|
| 3.6278825| 1.5600287|      10|     123|  1.4701623|  1.5939004|
| 1.3405646| 2.7518845|       9|     115|  0.9817363|  1.0772390|
| 2.0876289| 2.0010052|       5|     101| -0.9719678|  0.1730816|
| 0.4346968| 2.1971687|       5|      84| -0.9719678| -0.9248239|
| 2.2624223| 2.7121565|       7|      90|  0.0048843| -0.5373279|
| 0.7232609| 2.8904362|       5|      83| -0.9719678| -0.9894066|
| 3.3532095| 1.8096567|       8|     102|  0.4933103|  0.2376642|
| 3.8653284| 3.5056229|       8|     121|  0.4933103|  1.4647351|
| 2.7834847| 1.9056691|       2|      85| -2.4372458| -0.8602412|
| 3.7018629| 2.4818014|      10|      87|  1.4701623| -0.7310759|
| 2.4481796| 2.4502653|       7|      81|  0.0048843| -1.1185719|
| 2.7484218| 3.7482459|       8|     110|  0.4933103|  0.7543256|
| 1.5854671| 2.9709662|       9|     100|  0.9817363|  0.1084989|
| 2.4482854| 2.9100299|      10|     129|  1.4701623|  1.9813965|
| 1.7412862| 0.9462394|       6|      90| -0.4835417| -0.5373279|
| 2.9308757| 2.3993738|       5|      96| -0.9719678| -0.1498318|
| 2.8210166| 2.4575954|       8|     129|  0.4933103|  1.9813965|
| 2.5831640| 3.0110584|       8|     118|  0.4933103|  1.2709870|
| 0.9659023| 1.7466986|       7|      94|  0.0048843| -0.2789972|
| 2.5080683| 3.1387667|       6|     113| -0.4835417|  0.9480737|
| 3.8499634| 3.3548881|       9|     122|  0.9817363|  1.5293177|
| 0.8822343| 1.5336613|      10|      84|  1.4701623| -0.9248239|
| 3.9024303| 1.7277751|       7|      82|  0.0048843| -1.0539892|
| 3.4712202| 1.7162995|       4|      83| -1.4603938| -0.9894066|
| 2.5115666| 2.6390593|       6|     112| -0.4835417|  0.8834910|
| 3.5146988| 3.3294875|       7|      89|  0.0048843| -0.6019105|
| 2.8290397| 2.6533664|       9|     100|  0.9817363|  0.1084989|
| 2.7471315| 2.8562607|       4|      84| -1.4603938| -0.9248239|
| 2.7449956| 2.9568736|      10|     102|  1.4701623|  0.2376642|
| 3.0977301| 0.3793328|       4|     111| -1.4603938|  0.8189083|
| 2.9783206| 2.4891591|       6|      96| -0.4835417| -0.1498318|
| 2.5125859| 2.5350625|       9|     103|  0.9817363|  0.3022469|
| 2.8944945| 4.0000000|       9|      77|  0.9817363| -1.3769026|
| 1.8156094| 2.2001745|       5|      96| -0.9719678| -0.1498318|
| 3.0011643| 2.8021604|       8|     112|  0.4933103|  0.8834910|
| 3.8528217| 2.8347729|      10|      76|  1.4701623| -1.4414853|
| 2.0496313| 1.1178989|       6|      81| -0.4835417| -1.1185719|
| 2.0300626| 1.0270266|       3|      99| -1.9488198|  0.0439162|
| 2.6281108| 1.8298851|       7|     106|  0.0048843|  0.4959949|
| 3.8726751| 2.7044881|       7|      97|  0.0048843| -0.0852491|
| 3.5678280| 1.6363600|       6|      85| -0.4835417| -0.8602412|
| 3.7235079| 1.6461525|       6|      88| -0.4835417| -0.6664932|
| 2.5045121| 1.9153413|       8|      92|  0.4933103| -0.4081625|
| 1.2359004| 3.4497622|       9|     122|  0.9817363|  1.5293177|
| 2.9946271| 2.9535615|       7|     110|  0.0048843|  0.7543256|
| 2.3944125| 3.7537037|       6|     106| -0.4835417|  0.4959949|
| 1.4451098| 0.9303599|       6|      83| -0.4835417| -0.9894066|
| 2.4376733| 3.1152237|       9|      95|  0.9817363| -0.2144145|
| 2.1284143| 2.3039751|       7|     119|  0.0048843|  1.3355697|
| 2.8615197| 1.7626461|       6|      99| -0.4835417|  0.0439162|
| 2.6672037| 1.5447171|       4|      54| -1.4603938| -2.8623041|
| 1.9934927| 1.3665324|       5|     116| -0.9719678|  1.1418217|
| 2.7596577| 2.2032136|       7|      61|  0.0048843| -2.4102254|
| 3.6984273| 1.1520123|       7|     103|  0.0048843|  0.3022469|
| 0.9500710| 2.1250378|       8|      96|  0.4933103| -0.1498318|
| 2.5592971| 3.7351342|       9|      80|  0.9817363| -1.1831546|
| 3.2861875| 3.4664206|      10|     115|  1.4701623|  1.0772390|
| 2.1222741| 3.3947098|       8|     106|  0.4933103|  0.4959949|
| 2.5400241| 1.8211989|       7|      84|  0.0048843| -0.9248239|
| 4.0000000| 2.4929632|      10|     127|  1.4701623|  1.8522311|
| 1.4398139| 2.6862850|       3|     109| -1.9488198|  0.6897430|
| 2.4110543| 1.4900472|       3|      92| -1.9488198| -0.4081625|
| 0.0000000| 0.4014776|       3|      67| -1.9488198| -2.0227294|
| 2.5738293| 2.9524421|       6|     105| -0.4835417|  0.4314123|
| 3.1142057| 1.8539501|       3|      79| -1.9488198| -1.2477373|
| 2.1363495| 2.6226571|      10|     106|  1.4701623|  0.4959949|
| 2.6817641| 2.2073880|       8|     110|  0.4933103|  0.7543256|
| 3.3349288| 1.7543494|       9|     105|  0.9817363|  0.4314123|
| 1.6988012| 2.1246531|       4|     101| -1.4603938|  0.1730816|
| 1.5526163| 1.5286636|      10|     109|  1.4701623|  0.6897430|
| 2.8019608| 2.8027352|       7|     102|  0.0048843|  0.2376642|
| 3.3707676| 1.6986526|       7|     105|  0.0048843|  0.4314123|
| 2.2348459| 1.4769582|       7|      80|  0.0048843| -1.1831546|
| 3.6601457| 4.0000000|       8|     109|  0.4933103|  0.6897430|
| 2.7328271| 3.0817157|      10|      94|  1.4701623| -0.2789972|
| 2.2687056| 3.1470495|       6|     106| -0.4835417|  0.4959949|
| 3.9933377| 2.2272781|       7|     105|  0.0048843|  0.4314123|
| 2.9514553| 2.8082666|       8|      88|  0.4933103| -0.6664932|
| 3.7680715| 3.8783317|       7|     120|  0.0048843|  1.4001524|
| 3.2473376| 2.0760349|       5|      67| -0.9719678| -2.0227294|
| 1.7682800| 3.3295325|       6|      84| -0.4835417| -0.9248239|
| 2.8944518| 4.0000000|       9|     102|  0.9817363|  0.2376642|
| 4.0000000| 4.0000000|       9|      84|  0.9817363| -0.9248239|
| 2.7733935| 3.5680159|       7|     107|  0.0048843|  0.5605776|
| 1.6120128| 2.3200362|       8|      94|  0.4933103| -0.2789972|
| 3.5397356| 2.8607765|       7|     108|  0.0048843|  0.6251603|
| 3.5275687| 2.8646434|      10|     109|  1.4701623|  0.6897430|

</div>

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

<div class="kable-table">

| Res.Df|      RSS| Df| Sum of Sq|        F|    Pr(>F)|
|------:|--------:|--:|---------:|--------:|---------:|
|     98| 73.52823| NA|        NA|       NA|        NA|
|     96| 71.57829|  2|  1.949939| 1.307618| 0.2752366|

</div>



The null hypothesis is that we are just as good predicting `grade` from `GPA` as we are predicting it from `GPA` plus `lecture` and `nclicks`. We will reject the null if adding these two variables leads to a substantial enough reduction in the **residual sums of squares** (RSS); i.e., if they explain away enough residual variance.

We see that this is not the case: 
$F(2, 96 ) = 
1.308$, 
$p = 0.275$. So we don't have evidence that lecture attendance and downloading the online materials is associated with better grades above and beyond student ability, as measured by GPA.

## Dealing with categorical predictors

You can include categorical predictors in a regression model, but first you have to code them as numerical variables. There are a couple of important considerations here. 

<div type="danger">

A **nominal** variable is a categorical variable for which there is no inherent ordering among the levels of the variable. Pet ownership (cat, dog, ferret) is a nominal variable; cat is not greater than dog and dog is not greater than ferret.

It is common to code nominal variables using numbers. However, you have to be **very careful** about using numerically-coded nominal variables in your models. If you have a number that is really just a nominal variable, make sure you define it as type `factor()` before entering it into the model. Otherwise, it will try to treat it as an actual number, and the results of your modeling will be garbage! 

It is far too easy to make this mistake, and difficult to catch if authors do not share their data and code. In 2016, [a paper on religious affiliation and altruism in children that was published in Current Biology had to be retracted for just this kind of mistake](https://www.sciencedirect.com/science/article/pii/S0960982216306704).

</div>

### Dummy coding

For a factor with two levels, choose one level as zero and the other as one. The choice is arbitrary, and will affect the sign of the coefficient, but not its standard error or p-value.  Here is some code that will do this. Note that if you have a predictor of type character or factor, R will automatically do that for you. We don't want R to do this for reasons that will become apparent in the next lecture, so let's learn how to make our own numeric predictor.

First, we gin up some fake data to use in our analysis.


```r
fake_data <- tibble(Y = rnorm(10),
                    group = rep(c("A", "B"), each = 5))

fake_data
```

<div class="kable-table">

|          Y|group |
|----------:|:-----|
| -0.0548731|A     |
|  0.7537445|A     |
|  0.5065243|A     |
|  1.5966796|A     |
| -0.2969751|A     |
|  0.2049147|B     |
|  1.1649721|B     |
| -1.5696485|B     |
| -0.3248692|B     |
| -0.0727994|B     |

</div>

Now let's add a new variable, `group_d`, which is the dummy coded group variable. We will use the `dplyr::if_else()` function to define the new column.


```r
fake_data2 <- fake_data %>%
  mutate(group_d = if_else(group == "B", 1, 0))

fake_data2
```

<div class="kable-table">

|          Y|group | group_d|
|----------:|:-----|-------:|
| -0.0548731|A     |       0|
|  0.7537445|A     |       0|
|  0.5065243|A     |       0|
|  1.5966796|A     |       0|
| -0.2969751|A     |       0|
|  0.2049147|B     |       1|
|  1.1649721|B     |       1|
| -1.5696485|B     |       1|
| -0.3248692|B     |       1|
| -0.0727994|B     |       1|

</div>

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
## -1.4502 -0.4683  0.0261  0.3065  1.2845 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)   0.5010     0.3909   1.282    0.236
## group_d      -0.6205     0.5528  -1.122    0.294
## 
## Residual standard error: 0.8741 on 8 degrees of freedom
## Multiple R-squared:  0.136,	Adjusted R-squared:  0.02806 
## F-statistic:  1.26 on 1 and 8 DF,  p-value: 0.2942
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
## -1.4502 -0.4683  0.0261  0.3065  1.2845 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)  -0.1195     0.3909  -0.306    0.768
## group_d       0.6205     0.5528   1.122    0.294
## 
## Residual standard error: 0.8741 on 8 degrees of freedom
## Multiple R-squared:  0.136,	Adjusted R-squared:  0.02806 
## F-statistic:  1.26 on 1 and 8 DF,  p-value: 0.2942
```

The interpretation of the intercept is the estimated mean for the group coded as zero. You can see by plugging in zero for X in the prediction formula below. Thus, $\beta_1$ can be interpreted as the difference between the mean for the baseline group and the group coded as 1.

$$\hat{Y_i} = \hat{\beta}_0 + \hat{\beta}_1 X_i $$

<!--
<div type="info">

Why not just use **factors** as your predictors?

</div>
-->

### Dummy coding when $k > 2$

When the predictor variable is a factor with $k$ levels where $k>2$, we need $k-1$ predictors to code that variable. So if the factor has 4 levels, we'll need to define three predictors. Here is code to do that. Try it out and see if you can figure out how it works.


```r
mydata <- tibble(season = rep(c("winter", "spring", "summer", "fall"), each = 5),
                 bodyweight_kg = c(rnorm(5, 105, 3),
                                   rnorm(5, 103, 3),
                                   rnorm(5, 101, 3),
                                   rnorm(5, 102.5, 3)))

mydata
```

<div class="kable-table">

|season | bodyweight_kg|
|:------|-------------:|
|winter |     107.55789|
|winter |     100.26797|
|winter |     107.78621|
|winter |     104.55462|
|winter |     103.05212|
|spring |     102.09345|
|spring |     106.07493|
|spring |     100.26337|
|spring |     111.19945|
|spring |     106.91919|
|summer |     102.51706|
|summer |      98.03092|
|summer |      99.92075|
|summer |     100.06264|
|summer |      92.47949|
|fall   |      96.52094|
|fall   |     104.66900|
|fall   |     105.57964|
|fall   |     101.82025|
|fall   |     105.26998|

</div>

Now let's add three predictors to code the variable `season`.


```r
## baseline value is 'winter'
mydata2 <- mydata %>%
  mutate(V1 = if_else(season == "spring", 1, 0),
         V2 = if_else(season == "summer", 1, 0),
         V3 = if_else(season == "fall", 1, 0))

mydata2
```

<div class="kable-table">

|season | bodyweight_kg| V1| V2| V3|
|:------|-------------:|--:|--:|--:|
|winter |     107.55789|  0|  0|  0|
|winter |     100.26797|  0|  0|  0|
|winter |     107.78621|  0|  0|  0|
|winter |     104.55462|  0|  0|  0|
|winter |     103.05212|  0|  0|  0|
|spring |     102.09345|  1|  0|  0|
|spring |     106.07493|  1|  0|  0|
|spring |     100.26337|  1|  0|  0|
|spring |     111.19945|  1|  0|  0|
|spring |     106.91919|  1|  0|  0|
|summer |     102.51706|  0|  1|  0|
|summer |      98.03092|  0|  1|  0|
|summer |      99.92075|  0|  1|  0|
|summer |     100.06264|  0|  1|  0|
|summer |      92.47949|  0|  1|  0|
|fall   |      96.52094|  0|  0|  1|
|fall   |     104.66900|  0|  0|  1|
|fall   |     105.57964|  0|  0|  1|
|fall   |     101.82025|  0|  0|  1|
|fall   |     105.26998|  0|  0|  1|

</div>

## Equivalence between multiple regression and one-way ANOVA

If we wanted to see whether our bodyweight varies over season, we could do a one way ANOVA on `mydata2` like so.


```r
## make season into a factor with baseline level 'winter'
mydata3 <- mydata2 %>%
  mutate(season = factor(season, levels = c("winter", "spring", "summer", "fall")))

my_anova <- aov(bodyweight_kg ~ season, mydata3)
summary(my_anova)
```

```
##             Df Sum Sq Mean Sq F value Pr(>F)  
## season       3  136.6   45.53   3.189 0.0522 .
## Residuals   16  228.4   14.28                 
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
##    Min     1Q Median     3Q    Max 
## -6.251 -1.998  1.042  2.575  5.889 
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept) 104.6438     1.6898  61.925   <2e-16 ***
## V1            0.6663     2.3898   0.279   0.7840    
## V2           -6.0416     2.3898  -2.528   0.0224 *  
## V3           -1.8718     2.3898  -0.783   0.4449    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 3.779 on 16 degrees of freedom
## Multiple R-squared:  0.3742,	Adjusted R-squared:  0.2568 
## F-statistic: 3.189 on 3 and 16 DF,  p-value: 0.0522
```

Note that the $F$ values and $p$ values are identical for the two methods!

## Solution to partial effect plot

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

<div class="kable-table">

| lecture| nclicks|    grade|
|-------:|-------:|--------:|
|    6.99|      54| 2.374462|
|    6.99|      55| 2.379514|
|    6.99|      56| 2.384567|
|    6.99|      57| 2.389619|
|    6.99|      58| 2.394672|
|    6.99|      59| 2.399724|
|    6.99|      60| 2.404777|
|    6.99|      61| 2.409829|
|    6.99|      62| 2.414882|
|    6.99|      63| 2.419934|
|    6.99|      64| 2.424987|
|    6.99|      65| 2.430039|
|    6.99|      66| 2.435092|
|    6.99|      67| 2.440144|
|    6.99|      68| 2.445197|
|    6.99|      69| 2.450249|
|    6.99|      70| 2.455302|
|    6.99|      71| 2.460354|
|    6.99|      72| 2.465407|
|    6.99|      73| 2.470459|
|    6.99|      74| 2.475512|
|    6.99|      75| 2.480564|
|    6.99|      76| 2.485617|
|    6.99|      77| 2.490669|
|    6.99|      78| 2.495722|
|    6.99|      79| 2.500774|
|    6.99|      80| 2.505827|
|    6.99|      81| 2.510879|
|    6.99|      82| 2.515932|
|    6.99|      83| 2.520984|
|    6.99|      84| 2.526037|
|    6.99|      85| 2.531089|
|    6.99|      86| 2.536142|
|    6.99|      87| 2.541194|
|    6.99|      88| 2.546247|
|    6.99|      89| 2.551299|
|    6.99|      90| 2.556352|
|    6.99|      91| 2.561404|
|    6.99|      92| 2.566457|
|    6.99|      93| 2.571509|
|    6.99|      94| 2.576562|
|    6.99|      95| 2.581614|
|    6.99|      96| 2.586667|
|    6.99|      97| 2.591719|
|    6.99|      98| 2.596772|
|    6.99|      99| 2.601824|
|    6.99|     100| 2.606876|
|    6.99|     101| 2.611929|
|    6.99|     102| 2.616982|
|    6.99|     103| 2.622034|
|    6.99|     104| 2.627086|
|    6.99|     105| 2.632139|
|    6.99|     106| 2.637192|
|    6.99|     107| 2.642244|
|    6.99|     108| 2.647296|
|    6.99|     109| 2.652349|
|    6.99|     110| 2.657402|
|    6.99|     111| 2.662454|
|    6.99|     112| 2.667506|
|    6.99|     113| 2.672559|
|    6.99|     114| 2.677611|
|    6.99|     115| 2.682664|
|    6.99|     116| 2.687716|
|    6.99|     117| 2.692769|
|    6.99|     118| 2.697821|
|    6.99|     119| 2.702874|
|    6.99|     120| 2.707926|
|    6.99|     121| 2.712979|
|    6.99|     122| 2.718031|
|    6.99|     123| 2.723084|
|    6.99|     124| 2.728136|
|    6.99|     125| 2.733189|
|    6.99|     126| 2.738241|
|    6.99|     127| 2.743294|
|    6.99|     128| 2.748346|
|    6.99|     129| 2.753399|

</div>

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
