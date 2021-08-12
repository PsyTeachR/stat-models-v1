# Linear mixed-effects models with crossed random factors

## Learning objectives

* analyze data from a design with crossed random factors of subjects and stimuli
* appropriately specify random effects to enable proper generalization
* simulate data for a design with crossed random factors

## Web app

- [Demo of crossed random effects](https://shiny.psy.gla.ac.uk/Dale/crossed)

## Generalizing over encounters between subjects and stimuli

A common goal of experiments in psychology is to test claims about behavior that arises in response to certain types of stimuli (or sometimes, the neural underpinning of that behavior). The stimuli might be, for instance, words, images, sounds, videos, or stories. Some examples of claims you might want to test are:

* when listening to words in a second language, do bilinguals experience interference from words in their native language?
* do people rate the attractiveness of faces differently when they are in a good mood than when they are in a bad mood?
* does viewing soothing images help reduce stress relative to more neutral images?
* when reading a scenario ambiguously describing a target individual, are people more likely to make assumptions about what social group the target belongs to after being subliminally primed?

One thing to note about all these claims is that the are of the type, "what happens to our measurements when an individual of type X encounters a stimulus of type Y", where X is drawn from a target population of subjects and Y is drawn from a target population of stimuli. In other words, we are attempt to make generalizable claims about a particular class of **events** involving **encounters** between sampling units of subjects and stimuli [@Barr_2017]. But just like we can't sample all possible subjects from the target population of subjects, we also cannot sample all possible stimuli from the target population of stimuli. Thus, when drawing inferences, we need to account for the uncertainty introduced in our estimates by *both* sampling processes [@Coleman_1964; @Clark_1973; @Judd_Westfall_Kenny_2012; @yarkoni_2019]. Linear mixed-effects models make it particularly easy to do this by allowing more than one random factor in our model formula [@Baayen_Davidson_Bates_2008]. 

Here is a simple example of a study where you are interested in testing whether people rate pictures of cats, dogs, or sunsets as more soothing images to look at. You want to say something general about the category of cats, dogs, and sunsets and not something about the specific pictures that you happened to sample. Let's say you randomly select four images from each of the three categories from Google Images (you would absolutely need to have more to be able to say something generalizable, but we chose a small number to keep the example simple). So your table of stimuli might look like the following:


| stimulus_id|category |file        |
|-----------:|:--------|:-----------|
|           1|cat      |cat1.jpg    |
|           2|cat      |cat2.jpg    |
|           3|cat      |cat3.jpg    |
|           4|cat      |cat4.jpg    |
|           5|dog      |dog1.jpg    |
|           6|dog      |dog2.jpg    |
|           7|dog      |dog3.jpg    |
|           8|dog      |dog4.jpg    |
|           9|sunset   |sunset1.jpg |
|          10|sunset   |sunset2.jpg |
|          11|sunset   |sunset3.jpg |
|          12|sunset   |sunset4.jpg |

Then you sample a set of four participants to perform the soothing ratings. Again, four would be too few for a real study, but we're keeping it small just for expository purposes.


| subject_id| age|date       |
|----------:|---:|:----------|
|          1|  45|2020-05-05 |
|          2|  42|2020-05-06 |
|          3|  42|2020-05-12 |
|          4|  54|2020-05-22 |

Now, because each subject has given a "soothingness" rating for each picture, you'd have a full dataset consisting of all of the levels of `subject_id` crossed with all of the levels of `stimulus_id`. This is what we mean when we talk about "crossed random factors." You can create the table containing all these combinations with the `crossing()` function from `tidyr` (which is loaded when you load in `tidyverse`).


```r
crossing(subjects %>% select(subject_id),
         stimuli %>% select(-category)) 
```


| subject_id| stimulus_id|file        |
|----------:|-----------:|:-----------|
|          1|           1|cat1.jpg    |
|          1|           2|cat2.jpg    |
|          1|           3|cat3.jpg    |
|          1|           4|cat4.jpg    |
|          1|           5|dog1.jpg    |
|          1|           6|dog2.jpg    |
|          1|           7|dog3.jpg    |
|          1|           8|dog4.jpg    |
|          1|           9|sunset1.jpg |
|          1|          10|sunset2.jpg |
|          1|          11|sunset3.jpg |
|          1|          12|sunset4.jpg |
|          2|           1|cat1.jpg    |
|          2|           2|cat2.jpg    |
|          2|           3|cat3.jpg    |
|          2|           4|cat4.jpg    |
|          2|           5|dog1.jpg    |
|          2|           6|dog2.jpg    |
|          2|           7|dog3.jpg    |
|          2|           8|dog4.jpg    |
|          2|           9|sunset1.jpg |
|          2|          10|sunset2.jpg |
|          2|          11|sunset3.jpg |
|          2|          12|sunset4.jpg |
|          3|           1|cat1.jpg    |
|          3|           2|cat2.jpg    |
|          3|           3|cat3.jpg    |
|          3|           4|cat4.jpg    |
|          3|           5|dog1.jpg    |
|          3|           6|dog2.jpg    |
|          3|           7|dog3.jpg    |
|          3|           8|dog4.jpg    |
|          3|           9|sunset1.jpg |
|          3|          10|sunset2.jpg |
|          3|          11|sunset3.jpg |
|          3|          12|sunset4.jpg |
|          4|           1|cat1.jpg    |
|          4|           2|cat2.jpg    |
|          4|           3|cat3.jpg    |
|          4|           4|cat4.jpg    |
|          4|           5|dog1.jpg    |
|          4|           6|dog2.jpg    |
|          4|           7|dog3.jpg    |
|          4|           8|dog4.jpg    |
|          4|           9|sunset1.jpg |
|          4|          10|sunset2.jpg |
|          4|          11|sunset3.jpg |
|          4|          12|sunset4.jpg |

Because you have 4 subjects responding to 12 stimuli, the resulting table will have 48 rows.

## lme4 syntax for crossed random factors

How should we analyze such data? Recall from the last chapter that the lme4 formula syntax for a model with by-subject random intercepts and slopes for predictor `x` would be given by `y ~ x + (1 + x | subject_id)` where the term in brackets with the vertical bar `|` provides the random effects specification. The variable to the right of the bar, `subject_id`, specifies the variable that identifies the levels of the random factor. The formula to the left of the bar within the brackets, `1 + x`, specifies the random effects associated with this factor, which in this case is a random intercept and random slope for `x`. The best way to think about this bracketed part of the formula `(1 + x | subject_id)` is **as an instruction to `lme4::lmer()` about how to build a covariance matrix capturing the variance introduced by the random factor of subjects.** By now you should realize that this instruction would result in the estimation of a two-dimensional covariance matrix, with one dimension for intercept variance and one for slope variance.

But we are not limited to the estimation of random effects for subjects; we can also specify the estimation of random effects for stimuli by simply adding another term to the formula. For example,

`y ~ x + (1 + x | subject_id) + (1 + x | stimulus_id)`

regresses `y` on `x` with by-subject random intercepts and slopes and by-stimulus random intercepts. In this way, the fitted model will capture two sources of uncertainty about our estimates---the uncertainty introduced by sampling subjects as well as the uncertainty introduced by sampling items. Now we are estimating **two independent covariance matrices**, one for subjects and one for items. In the above example, both of these matrices will have the same 2x2 structure, but this need not be the case. We can flexibly change the random effects structure by changing the formula specification on the left side of each bar `|` symbol. For instance, if we have another predictor `w`, we might have:

`y ~ x + (x | subject_id) + (x + w | stimulus_id)`

which would estimate the same 2x2 matrix for subjects, but the covariance matrix for stimuli would now be a 3x3 matrix (intercepts, slope of x, and slope of w). Although this enables great flexibility, as the random effects structure becomes more complex, the estimation process becomes more difficult and less likely to converge upon a result.

## Specifying random effects

The choice of random effects structure is not a new problem that appeared with linear mixed-effects models. In traditional approaches using t-test and ANOVA, you choose the random effects structure implicitly when you choose what procedure to use. As discussed in the last chapter, if you choose a paired samples t-test over an independent samples t-test, that is analogous to choosing to fit `lme4::lmer(y ~ x + (1 | subject))` over `lm(y ~ x)`. Likewise, you can run a mixed model ANOVA as either `aov(y ~ x + Error(subject_id))`, which is equivalent to a random intercepts model, or `aov(y ~ x + Error(x / subject_id))`, which is equivalent to a random slopes model. The tradition in psychology when performing confirmatory analyses is to use the *maximal random effects structure justified by the design of your study*. So, if you have one-factor data with pseudoreplications, you would use `aov(y ~ x + Error(x / subject_id))` rather than `aov(y ~ x + Error(subject_id))`. Analogously, if you were to analyze the same data with pseudoreplications using a linear mixed effects model, you should use `lme4::lmer(y ~ x + (1 + x | subject_id))` rather than `lme4::lmer(y ~ x + (1 | subject_id))`. In other words, you should account for all sources of non-independence introduced by repeated sampling from the same subjects or stimuli. This approach is known as the **maximal random effects** approach or the **design-driven approach** to specifying random effects structure [@Barr_et_al_2013]. Failing to account for dependencies introduced by the design is likely to lead to standard errors that are too small, which in turn, lead to p-values that are smaller than they should be, and thus, higher false positive (Type I error) rates. In some cases, it can lead to lower power, and thus a higher false negative (Type II error) rate. It is thus of critical importance to pay close attention to the random effects structure when performing analyses.

Linear mixed-effects models almost inevitably include random intercepts for any random factor included in the design. So if your random factors are subjects and stimuli identified by `subject_id` and `stimulus_id` respectively, then at the very least, your model syntax will include `(1 | subject_id) + (1 | stimulus_id)`. But you will have various predictors in the model, so key question becomes: what predictors should I allow to vary over what sampling units? For instance, if the fixed-effects part of your model is a 2x2 factorial design with factors A and B, `y ~ a * b + ...`, you could have a large variety of random effects structures, including (but not limited to):

1. random intercepts only: `y ~ a * b + (1 | subject_id) + (1 | stimulus_id)`
2. by-subjects random intercepts for a and by-stimulus random intercepts: `y ~ a * b + (a | subject_id) + (1 | stimulus_id)`
3. by-subjects random intercepts and slopes for a and b and the ab interaction, with by-stimulus random intercepts: `y ~ a * b + (a * b | subject_id) + (1 | stimulus_id)`
4. by-subjects random intercepts and slopes for a and b and the ab interaction, by-stimulus random intercepts and slopes for a and b and the ab interaction, `y ~ a * b + (a * b | subject_id) + (a * b | stimulus_id)`.

It is important to be clear about one thing. 

<div class="info">
The "maximal random effects structure justified by the design" is not the same as the "maximum possible random effects structure"; that is, it does not entail automatically putting in all random slopes for all random factors for all predictors in your model. You have to follow the guidelines for random effects in the next section to decide whether inclusion of a particular random slope is, in fact, "justified by the design."
</div>

Some authors suggest a "data-driven" alternative to design-driven random effects, suggesting that researchers should only include random slopes justified by the design if they are further justified by the data [@Matuschek_et_al_2017]. For example, you might use a null-hypothesis test to determine whether including a by-subject random slope for `x` significantly improves the model fit, and only include that effect if it does. Although this could potentially improve power for the test of theoretical interest when random slopes are very small, it also exposes you to additional unknown risk of false positives, so it is questionable whether this the right approach in a confirmatory context. Thus, we do not recommend a data-driven approach.

### Rules for choosing random effects for categorical factors

The random effects structure for a linear mixed-effects model---in other words, your assumptions about what effects vary over what sampling units---is absolutely critical for ensuring that your parameters reflect the uncertainty introduced by sampling [@Barr_et_al_2013]. First off, note that we are focused on predictors representing **design variables** that are of theoretical interest and on which you will perform inferential tests. If you have predictors that represent **control variables**, over which you do not intend to perform statistical tests, it is unlikely that random slopes are needed.

The following rules are derived from @Barr_et_al_2013 and @Barr_2013. Consult these papers if you wish to find out more about these guidelines. Keep in mind that you can only use a mixed effects model if you have repeated measures data, either because of pseudoreplications and/or the presence of within-subject (or within-stimulus) factors. With crossed random factors, you inevitably have pseudoreplications---multiple observations per subject due to multiple stimuli, multiple observations per stimulus due to multiple subjects. The key to determining random effects structure is figuring out which factors are within-subjects or within-stimuli, and where any pseudoreplications are located in the design. You apply the rules once for subjects to determine the form of the `(1 + ... | subject_id)` part of the formula, and once for stimuli to determine the form of the `(1 + ... | stimulus_id)` part of the formula. Where you see the word "unit" or "sampling unit" below, substitute "subject" or "stimuli" as needed.

Here are the rules:

1. If there are repeated measures on sampling units, you need a random intercept for that random factor: `(1 | unit_id)`;
2. If a factor `x` is between-unit, you do not need a random slope for that factor;
3. Determine the highest order interaction of within-subject factors for the unit under consideration. If you have pseudoreplications within each cell defined by those combinations (i.e., multiple observations per cell), then for that unit you will need a slope for that interaction as well as for all lower order effects. If there are no pseudoreplications, then you do not need any random slopes.

The first two rules are straightforward, but the third requires some explanation. Let's first ask: how do we know whether some factor is between or within unit?

A simple way to determine whether a factor is between or within is to use the `dplyr::count()` function, which gives frequency counts, and which is loaded when you load tidyverse. Let's say you are interested in whether factor $A$ is within or between subjects, for the imaginary 2x2x2 factorial data `abc_data` below where $A$, $B$, and $C$ name the factors of your design.


```r
library("tidyverse")

## run this code to create the table "abc_data"
abc_subj <- tibble(subject_id = 1:4,
                   B = rep(c("B1", "B2"), times = 2))

abc_item  <- tibble(stimulus_id = 1:4,
                    A = rep(c("A1", "A2"), each = 2),
                    C = rep(c("C1", "C2"), times = 2))

abc_data <- crossing(abc_subj, abc_item) %>%
  select(subject_id, stimulus_id, everything())
```

To see whether $A$ is within or between subjects, use:


```r
abc_data %>%
  count(subject_id, A)
```

```
## # A tibble: 8 x 3
##   subject_id A         n
##        <int> <chr> <int>
## 1          1 A1        2
## 2          1 A2        2
## 3          2 A1        2
## 4          2 A2        2
## 5          3 A1        2
## 6          3 A2        2
## 7          4 A1        2
## 8          4 A2        2
```

In the resulting table, you can see that each subject gets both levels of $A$, making it a within-subject factor. What about $B$ and $C$?


```r
abc_data %>%
  count(subject_id, B)
```

```
## # A tibble: 4 x 3
##   subject_id B         n
##        <int> <chr> <int>
## 1          1 B1        4
## 2          2 B2        4
## 3          3 B1        4
## 4          4 B2        4
```


```r
abc_data %>%
  count(subject_id, C)
```

```
## # A tibble: 8 x 3
##   subject_id C         n
##        <int> <chr> <int>
## 1          1 C1        2
## 2          1 C2        2
## 3          2 C1        2
## 4          2 C2        2
## 5          3 C1        2
## 6          3 C2        2
## 7          4 C1        2
## 8          4 C2        2
```

OK $B$ is between subjects (each subject gets only one level), and $C$ is within (each subject gets all levels).

<div class="try">

*Exercise*

Answer these question about `abc_data`.

* Are the levels of factor $A$ administered between or within stimuli? <select class='solveme' name='q_1' data-answer='["between"]'> <option></option> <option>between</option> <option>within</option></select>


<div class='solution'><button>Solution</button>



```r
abc_data %>%
  count(stimulus_id, A)
```

```
## # A tibble: 4 x 3
##   stimulus_id A         n
##         <int> <chr> <int>
## 1           1 A1        4
## 2           2 A1        4
## 3           3 A2        4
## 4           4 A2        4
```


</div>


* Are the levels of factor $B$ administered between or within stimuli? <select class='solveme' name='q_2' data-answer='["within"]'> <option></option> <option>between</option> <option>within</option></select>


<div class='solution'><button>Solution</button>



```r
abc_data %>%
  count(stimulus_id, B)
```

```
## # A tibble: 8 x 3
##   stimulus_id B         n
##         <int> <chr> <int>
## 1           1 B1        2
## 2           1 B2        2
## 3           2 B1        2
## 4           2 B2        2
## 5           3 B1        2
## 6           3 B2        2
## 7           4 B1        2
## 8           4 B2        2
```


</div>


* Are the levels of factor $C$ administered between or within stimuli? <select class='solveme' name='q_3' data-answer='["between"]'> <option></option> <option>between</option> <option>within</option></select>


<div class='solution'><button>Solution</button>



```r
abc_data %>%
  count(stimulus_id, C)
```

```
## # A tibble: 4 x 3
##   stimulus_id C         n
##         <int> <chr> <int>
## 1           1 C1        4
## 2           2 C2        4
## 3           3 C1        4
## 4           4 C2        4
```


</div>


</div>

OK, we've identified which factors are within and between subject, and which factors are within and between stimulus. 

The second rule tells us that if a factor is between-unit, you do not need a random slope for that factor. Indeed, it is not possible to estimate a random slope for a between unit factor. If you think about the fact that random slopes capture variation in the effect over units, then it makes sense that you have to measure your response variable across all levels of that factor to be able to estimate that variation. For instance, if you have a two-level factor called treatment group (experimental, control), you cannot estimate the effect of "treatment" for a particular subject unless the subject has experienced both levels of the factor (i.e., it would have to be within-subject).

How do we now apply the third rule above to determine what random slopes are needed for our within-unit factors?

Consider that $A$ and $C$ were within-subjects, and $B$ was between. So the highest-order interaction of within-subject factors is $AC$. We will need random slopes for the $AC$ interaction as well as for the main effects $A$ and $C$ if we have pseudoreplications for each subject in each combination of $AC$. How can we find out? 


```r
abc_data %>%
  count(subject_id, A, C)
```

```
## # A tibble: 16 x 4
##    subject_id A     C         n
##         <int> <chr> <chr> <int>
##  1          1 A1    C1        1
##  2          1 A1    C2        1
##  3          1 A2    C1        1
##  4          1 A2    C2        1
##  5          2 A1    C1        1
##  6          2 A1    C2        1
##  7          2 A2    C1        1
##  8          2 A2    C2        1
##  9          3 A1    C1        1
## 10          3 A1    C2        1
## 11          3 A2    C1        1
## 12          3 A2    C2        1
## 13          4 A1    C1        1
## 14          4 A1    C2        1
## 15          4 A2    C1        1
## 16          4 A2    C2        1
```

This shows us that we have *one* observation per combination of $AC$, so we do not need random slopes for $AC$, nor for $A$ or $C$. The random effects part of the formula for subjects would just be `(1 | subject_id)`.

<div class="try">

What random slopes do you need for the random factor of stimulus?


<div class='solution'><button>Solution</button>


You have one within-stimulus factor, $B$, which has pseudoreplications.


```r
abc_data %>%
  count(stimulus_id, B)
```

```
## # A tibble: 8 x 3
##   stimulus_id B         n
##         <int> <chr> <int>
## 1           1 B1        2
## 2           1 B2        2
## 3           2 B1        2
## 4           2 B2        2
## 5           3 B1        2
## 6           3 B2        2
## 7           4 B1        2
## 8           4 B2        2
```

Therefore the formula you need for stimuli is `(B | stimulus_id)`, making the full `lme4` formula:

`y ~ A * B * C + (1 | subject_id) + (B | stimulus_id)`.


</div>


</div>


## Simulating data with crossed random factors

For these exercises, we will generate simulated data corresponding to an experiment with a single, two-level factor (independent variable) that is within-subjects and between-items.  Let's imagine that the experiment involves lexical decisions to a set of words (e.g., is "PINT" a word or nonword?), and the dependent variable is response time (in milliseconds), and the independent variable is word type (noun vs verb).  We want to treat both subjects and words as random factors (so that we can generalize to the population of events where subjects encounter words).  You can play around with the web app (or [click here to open it in a new window](https://shiny.psy.gla.ac.uk/Dale/crossed){target="_blank"}), which allows you to manipulate the data-generating parameters and see their effect on the data.

By now, you should have all the pieces of the puzzle that you need to simulate data from a study with crossed random effects. @Debruine_Barr_2020 provides a more detailed, step-by-step walkthrough of the exercise below.

Here is the DGP for response time $Y_{si}$ for subject $s$ and item $i$:

*Level 1:*

\begin{equation}
Y_{si} = \beta_{0s} + \beta_{1} X_{i} + e_{si}
\end{equation}

*Level 2:*

\begin{equation}
\beta_{0s} = \gamma_{00} + S_{0s} + I_{0i}
\end{equation}

\begin{equation}
\beta_{1} = \gamma_{10} + S_{1s}
\end{equation}

*Variance Components:*

\begin{equation}
\langle S_{0s}, S_{1s} \rangle \sim N\left(\langle 0, 0 \rangle, \mathbf{\Sigma}\right) 
\end{equation}

\begin{equation}
\mathbf{\Sigma} = \left(\begin{array}{cc}{\tau_{00}}^2 & \rho\tau_{00}\tau_{11} \\
         \rho\tau_{00}\tau_{11} & {\tau_{11}}^2 \\
         \end{array}\right) 
\end{equation}

\begin{equation}
I_{0s} \sim N\left(0, {\omega_{00}}^2\right) 
\end{equation}

\begin{equation}
e_{si} \sim N\left(0, \sigma^2\right)
\end{equation}

In the above equation, $X_i$ is a numerical predictor coding which condition the item $i$ is in; e.g., -.5 for noun, .5 for verb.

We could just reduce levels 1 and 2 to 

$$Y_{si} = \beta_0 + S_{0s} + I_{0i} + (\beta_1 + S_{1s})X_{i} + e_{si}$$

where:

|Parameter    | Symbol| Description                                       |
|:------------|:------|:--------------------------------------------------|
| \(Y_{si}\)  | `Y`   | RT for subject \(s\) responding to item \(i\);    |
| \(\beta_0\) | `b0`  | grand mean;                                       |
| \(S_{0s}\)  | `S_0s` | random intercept for subject $s$ \(s\);               |
| \(I_{0i}\)  | `I_0i` | random intercept for item $i$ \(i\);                  |
| \(\beta_1\) | `b1` | fixed effect of word type (slope);                |
| \(S_{1s}\)  | `S_1s` | by-subject random slope;                          |
| \(X_{i}\)   | `cond` | deviation-coded predictor variable for word type; |
| \(\tau_{00}\) | `tau_00` | by-subject random intercept standard deviation |
| \(\tau_{11}\) | `tau_11` | by-subject random slope standard deviation |
| \(\rho\)    | `rho` | correlation between random intercept and slope |
| \(\omega_{00}\) | `omega_00` | by-item random intercept standard deviation |
| \(e_{si}\)  | `err` | residual for subject $s$ item $i$ error                                   |
| \(\sigma\)  | `sig` | residual error standard deviation                 |

### Set up the environment and define the parameters for the DGP

If you want to get the same results as everyone else for this exercise, then we all should seed the random number generator with the same value.  While we're at it, let's load in the packages we need.


```r
library("lme4")
library("tidyverse")

set.seed(11709)  
```

Now let's define the parameters for the DGP (data generating process).


```r
nsubj <- 100 # number of subjects
nitem <- 50  # must be an even number

b0 <- 800 # grand mean
b1 <- 80 # 80 ms difference
effc <- c(-.5, .5) # deviation codes

omega_00 <- 80 # by-item random intercept sd (omega_00)

## for the by-subjects variance-covariance matrix
tau_00 <- 100 # by-subject random intercept sd
tau_11 <- 40 # by-subject random slope sd
rho <- .2 # correlation between intercept and slope

sig <- 200 # residual (standard deviation)
```

You'll create three tables:

| Name       | Description                                                          |
|:-----------|:---------------------------------------------------------------------|
| `subjects` | table of subject data including `subj_id` and subject random effects |
| `items`    | table of stimulus data including `item_id` and item random effect    |
| `trials`   | table of trials enumerating encounters between subjects/stimuli      |

Then you will merge together the information in the three tables, and calculate the response variable according to the model formula above.

### Generate a sample of stimuli

Let's randomly generate our 50 items. Create a tibble called `item` like the one below, where `iri` are the by-item random intercepts (drawn from a normal distribution with variance \(\omega_{00}^2\) = 6400).  Half of the words are of type NOUN (`cond = -.5`) and half of type VERB (`cond = .5`).




<div class='solution'><button>Click to reveal full table</button>



```
## # A tibble: 50 x 3
##    item_id  cond    I_0i
##      <int> <dbl>   <dbl>
##  1       1  -0.5   14.9 
##  2       2   0.5  -86.3 
##  3       3  -0.5  -12.8 
##  4       4   0.5  -13.9 
##  5       5  -0.5   55.6 
##  6       6   0.5  -45.9 
##  7       7  -0.5  -42.0 
##  8       8   0.5  -87.6 
##  9       9  -0.5  -97.4 
## 10      10   0.5  -85.2 
## 11      11  -0.5  135.  
## 12      12   0.5   83.2 
## 13      13  -0.5  -44.7 
## 14      14   0.5    8.59
## 15      15  -0.5 -156.  
## 16      16   0.5  -57.6 
## 17      17  -0.5  -38.7 
## 18      18   0.5   39.6 
## 19      19  -0.5  105.  
## 20      20   0.5   30.3 
## 21      21  -0.5 -115.  
## 22      22   0.5   -3.40
## 23      23  -0.5 -218.  
## 24      24   0.5   53.0 
## 25      25  -0.5  -86.9 
## 26      26   0.5  -65.4 
## 27      27  -0.5  172.  
## 28      28   0.5 -152.  
## 29      29  -0.5   25.1 
## 30      30   0.5 -156.  
## 31      31  -0.5   47.7 
## 32      32   0.5  -46.3 
## 33      33  -0.5   48.0 
## 34      34   0.5   62.8 
## 35      35  -0.5  -75.4 
## 36      36   0.5  -35.9 
## 37      37  -0.5  -48.5 
## 38      38   0.5   29.3 
## 39      39  -0.5  -55.5 
## 40      40   0.5   69.5 
## 41      41  -0.5  196.  
## 42      42   0.5   77.6 
## 43      43  -0.5  -45.0 
## 44      44   0.5  204.  
## 45      45  -0.5   32.1 
## 46      46   0.5  -63.9 
## 47      47  -0.5  145.  
## 48      48   0.5   66.2 
## 49      49  -0.5  -23.9 
## 50      50   0.5   97.3
```


</div>



<div class='solution'><button>Hint for making cond</button>


`rep()`


</div>



<div class='solution'><button>Hint for making item random effects</button>


`rnorm()`


</div>



<div class='solution'><button>Solution</button>



```r
items <- tibble(item_id = 1:nitem,
                cond = rep(c(-.5, .5), times = nitem / 2),
                I_0i = rnorm(nitem, 0, sd = omega_00))
```


</div>


### Generate a sample of subjects

To generate the by-subject random effects, you will need to generate data from a *bivariate normal distribution*.  To do this, we will use the function `MASS::mvrnorm`.  

<div class="warning">

REMEMBER: do not run `library("MASS")` just to get this one function, because `MASS` has a function `select()` that will overwrite the tidyverse version. Since all we want from MASS is the `mvrnorm()` function, we can just access it directly by the `pkgname::function` syntax, i.e., `MASS::mvrnorm()`.

</div>

Your subjects table should look like this:


<div class='solution'><button>Click to reveal full table</button>





```
## # A tibble: 100 x 3
##     subj_id      S_0s     S_1s
##       <int>     <dbl>    <dbl>
##   1       1  -80.0      -0.763
##   2       2   44.6      54.5  
##   3       3    8.74    -20.4  
##   4       4  -38.6     -23.8  
##   5       5  -83.3      29.2  
##   6       6  -70.9     -13.8  
##   7       7  -21.4      46.0  
##   8       8    2.33      8.39 
##   9       9   62.3     -58.2  
##  10      10  238.        7.72 
##  11      11  -92.5       2.14 
##  12      12   58.5     -65.8  
##  13      13 -204.      -38.8  
##  14      14  -91.6       5.46 
##  15      15   51.1     -38.8  
##  16      16  142.      -12.9  
##  17      17   46.0       6.60 
##  18      18  -56.7     -54.8  
##  19      19  -10.1      62.1  
##  20      20 -226.      -19.3  
##  21      21 -158.      -18.5  
##  22      22  102.        8.99 
##  23      23  -12.7     -70.6  
##  24      24  135.       -9.50 
##  25      25   62.0     -52.5  
##  26      26    0.0653   32.8  
##  27      27 -117.       70.8  
##  28      28 -232.        3.43 
##  29      29   70.9      50.8  
##  30      30 -123.       22.8  
##  31      31  268.       30.0  
##  32      32  -18.7     -25.0  
##  33      33   50.8     -31.0  
##  34      34  -43.1     -28.9  
##  35      35  -10.1      28.3  
##  36      36   65.6      18.2  
##  37      37 -123.       -4.63 
##  38      38  -94.8      10.3  
##  39      39   77.7     -22.5  
##  40      40  -59.1      52.4  
##  41      41  -91.2    -103.   
##  42      42  -66.6      -2.14 
##  43      43   -4.40      0.305
##  44      44   69.7      10.2  
##  45      45  -77.5     -10.4  
##  46      46  -17.8     -48.2  
##  47      47 -103.       47.0  
##  48      48   22.8     -39.3  
##  49      49  -31.1     -34.9  
##  50      50  -26.4      40.0  
##  51      51   47.8      26.0  
##  52      52  -93.2     -42.7  
##  53      53   28.9      51.4  
##  54      54  -19.3      11.5  
##  55      55   53.6      21.5  
##  56      56  -27.4     -21.4  
##  57      57  -67.7     -32.1  
##  58      58   59.2      13.4  
##  59      59  -53.1       2.44 
##  60      60  104.        7.41 
##  61      61  -20.7     -78.7  
##  62      62   55.9     -15.7  
##  63      63  114.      -29.1  
##  64      64  -57.7     -34.7  
##  65      65  -38.7      -9.14 
##  66      66 -106.      -58.0  
##  67      67   99.1     -37.6  
##  68      68  -56.9      21.0  
##  69      69  -50.4      -0.407
##  70      70   27.5      -2.69 
##  71      71  139.      -32.2  
##  72      72   44.9       8.53 
##  73      73  -14.8      71.7  
##  74      74   33.7     -52.6  
##  75      75    2.03     27.8  
##  76      76 -134.       37.0  
##  77      77   24.4      20.7  
##  78      78  -60.6     -36.7  
##  79      79   31.1      16.9  
##  80      80  -34.9       9.68 
##  81      81  206.       17.3  
##  82      82   -7.19    -25.4  
##  83      83  182.       46.0  
##  84      84   55.7      21.7  
##  85      85 -149.      -44.0  
##  86      86 -193.      -73.2  
##  87      87  167.       13.9  
##  88      88  160.        3.87 
##  89      89   84.1      82.1  
##  90      90   97.2      -6.55 
##  91      91 -205.     -125.   
##  92      92  -75.1       6.76 
##  93      93  -95.3     -46.5  
##  94      94  106.       38.6  
##  95      95  -42.4      11.3  
##  96      96   74.0     -21.1  
##  97      97 -245.      -25.3  
##  98      98 -113.       -1.88 
##  99      99   68.8      30.6  
## 100     100  136.       44.2
```


</div>



<div class='solution'><button>Hint 1</button>


recall that:

* *`tau_00`*: by-subject random intercept standard deviation
* *`tau_11`*: by-subject random slope standard deviation
* *`rho`* : correlation between intercept and slope


</div>



<div class='solution'><button>Hint 2</button>


`covariance = rho * tau_00 * tau_11`


</div>



<div class='solution'><button>Hint 3</button>



```r
matrix(    tau_00^2,            rho * tau_00 * tau_11,
        rho * tau_00 * tau_11,      tau_11^2, ...)
```


</div>



<div class='solution'><button>Hint 4</button>



```r
as_tibble(mx) %>%
  mutate(subj_id = ...)
```


</div>



<div class='solution'><button>Solution</button>



```r
cov <- rho * tau_00 * tau_11

mx <- matrix(c(tau_00^2, cov,
               cov,      tau_11^2),
             nrow = 2)

by_subj_rfx <- MASS::mvrnorm(nsubj, mu = c(S_0s = 0, S_1s = 0), Sigma = mx)

subjects <- as_tibble(by_subj_rfx) %>%
  mutate(subj_id = row_number()) %>%
  select(subj_id, everything())
```


</div>


### Generate a sample of encounters (trials)

Each trial is an *encounter* between a particular subject and stimulus.  In this experiment, each subject will see each stimulus.  Generate a table `trials` that lists the encounters in the experiments. Note: each participant encounters each stimulus item once.  Use the `crossing()` function to create all possible encounters.

Now apply this example to generate the table below, where `err` is the residual term, drawn from \(N \sim \left(0, \sigma^2\right)\), where \(\sigma\) is `err_sd`.




```
## # A tibble: 5,000 x 3
##    subj_id item_id    err
##      <int>   <int>  <dbl>
##  1       1       1  382. 
##  2       1       2  283. 
##  3       1       3   30.4
##  4       1       4 -282. 
##  5       1       5 -239. 
##  6       1       6   73.4
##  7       1       7  -98.4
##  8       1       8 -189. 
##  9       1       9 -410. 
## 10       1      10  102. 
## # … with 4,990 more rows
```


<div class='solution'><button>Solution</button>



```r
trials <- crossing(subj_id = subjects %>% pull(subj_id),
                   item_id = items %>% pull(item_id)) %>%
  mutate(err = rnorm(nrow(.), mean = 0, sd = sig))
```


</div>


### Join `subjects`, `items`, and `trials`

Merge the information in `subjects`, `items`, and `trials` to create the full dataset `dat_sim`, which looks like this:




```
## # A tibble: 5,000 x 7
##    subj_id item_id  S_0s  I_0i   S_1s  cond    err
##      <int>   <int> <dbl> <dbl>  <dbl> <dbl>  <dbl>
##  1       1       1 -80.0  14.9 -0.763  -0.5  382. 
##  2       1       2 -80.0 -86.3 -0.763   0.5  283. 
##  3       1       3 -80.0 -12.8 -0.763  -0.5   30.4
##  4       1       4 -80.0 -13.9 -0.763   0.5 -282. 
##  5       1       5 -80.0  55.6 -0.763  -0.5 -239. 
##  6       1       6 -80.0 -45.9 -0.763   0.5   73.4
##  7       1       7 -80.0 -42.0 -0.763  -0.5  -98.4
##  8       1       8 -80.0 -87.6 -0.763   0.5 -189. 
##  9       1       9 -80.0 -97.4 -0.763  -0.5 -410. 
## 10       1      10 -80.0 -85.2 -0.763   0.5  102. 
## # … with 4,990 more rows
```


<div class='solution'><button>Hint</button>


`inner_join()`


</div>



<div class='solution'><button>Solution</button>



```r
dat_sim <- subjects %>%
  inner_join(trials, "subj_id") %>%
  inner_join(items, "item_id") %>%
  arrange(subj_id, item_id) %>%
  select(subj_id, item_id, S_0s, I_0i, S_1s, cond, err)
```


</div>


### Create the response variable

Add the response variable `Y` to dat according to the model formula:

$$Y_{si} = \beta_0 + S_{0s} + I_{0i} + (\beta_1 + S_{1s})X_{i} + e_{si}$$

so that the resulting table (`dat_sim2`) looks like this:




```
## # A tibble: 5,000 x 8
##    subj_id item_id     Y  S_0s  I_0i   S_1s  cond    err
##      <int>   <int> <dbl> <dbl> <dbl>  <dbl> <dbl>  <dbl>
##  1       1       1 1078. -80.0  14.9 -0.763  -0.5  382. 
##  2       1       2  957. -80.0 -86.3 -0.763   0.5  283. 
##  3       1       3  698. -80.0 -12.8 -0.763  -0.5   30.4
##  4       1       4  464. -80.0 -13.9 -0.763   0.5 -282. 
##  5       1       5  497. -80.0  55.6 -0.763  -0.5 -239. 
##  6       1       6  787. -80.0 -45.9 -0.763   0.5   73.4
##  7       1       7  540. -80.0 -42.0 -0.763  -0.5  -98.4
##  8       1       8  483. -80.0 -87.6 -0.763   0.5 -189. 
##  9       1       9  173. -80.0 -97.4 -0.763  -0.5 -410. 
## 10       1      10  776. -80.0 -85.2 -0.763   0.5  102. 
## # … with 4,990 more rows
```

Note: this is the full **decomposition table** for this model.


<div class='solution'><button>Hint</button>


```
... %>% 
  mutate(Y = ...) %>%
  select(...)
```


</div>



<div class='solution'><button>Solution</button>



```r
dat_sim2 <- dat_sim %>%
  mutate(Y = b0 + S_0s + I_0i + (S_1s + b1) * cond + err) %>%
  select(subj_id, item_id, Y, everything())
```


</div>


### Fitting the model

Now that you have created simulated data, estimate the model using `lme4::lmer()`, and run `summary()`.


<div class='solution'><button>Solution</button>



```r
mod_sim <- lmer(Y ~ cond + (1 + cond | subj_id) + (1 | item_id),
                dat_sim2, REML = FALSE)

summary(mod_sim, corr = FALSE)
```

```
## Linear mixed model fit by maximum likelihood  ['lmerMod']
## Formula: Y ~ cond + (1 + cond | subj_id) + (1 | item_id)
##    Data: dat_sim2
## 
##      AIC      BIC   logLik deviance df.resid 
##  67639.4  67685.0 -33812.7  67625.4     4993 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -3.6357 -0.6599 -0.0251  0.6767  3.7685 
## 
## Random effects:
##  Groups   Name        Variance Std.Dev. Corr
##  subj_id  (Intercept)  9464.8   97.29       
##           cond          597.7   24.45   0.68
##  item_id  (Intercept)  8087.0   89.93       
##  Residual             40305.0  200.76       
## Number of obs: 5000, groups:  subj_id, 100; item_id, 50
## 
## Fixed effects:
##             Estimate Std. Error t value
## (Intercept)   793.29      16.26  48.782
## cond           77.65      26.18   2.967
```


</div>


Now see if you can identify the data generating parameters in the output of `summary()`.



First, try to find \(\beta_0\) and \(\beta_1\).


<div class='solution'><button>Solution: Fixed effects</button>



|parameter         |variable | input| estimate|
|:-----------------|:--------|-----:|--------:|
|\(\hat{\beta}_0\) |`b0`     |   800|  793.293|
|\(\hat{\beta}_1\) |`b1`     |    80|   77.652|


</div>


Now try to find estimates of random effects parameters \(\tau_{00}\), \(\tau_{11}\), \(\rho\), \(\omega_{00}\), and \(\sigma\).


<div class='solution'><button>Solution: Random effects parameters</button>



|parameter             |variable   | input| estimate|
|:---------------------|:----------|-----:|--------:|
|\(\hat{\tau}_{00}\)   |`tau_00`   | 100.0|   97.287|
|\(\hat{\tau}_{11}\)   |`tau_11`   |  40.0|   24.448|
|\(\hat{\rho}\)        |`rho`      |   0.2|    0.675|
|\(\hat{\omega}_{00}\) |`omega_00` |  80.0|   89.928|
|\(\hat{\sigma}\)      |`sig`      | 200.0|  200.761|


</div>

