

##----------------------------------------------------------------
##                          tidylog demo                         -
##----------------------------------------------------------------

library(tidyverse)
# install.packages("tidylog")
library(tidylog)

data(mtcars)

mtcars_tidy <- mtcars %>%
  filter(mpg >= 15) %>%
  mutate(
    hp_category = case_when(
      hp < 100 ~ "< 100",
      hp %in% 100:200 ~ "100-200",
      hp > 200 ~ "> 200"
    )
  ) %>%
  group_by(cyl, hp_category, am) %>%
  tally() %>%
  filter(n >= 1)
