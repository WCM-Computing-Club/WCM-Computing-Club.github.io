library(tidyverse)
library(brickr)
library(png)
library(ggplot2)

#################################
##                             ##
##        LEGO Mosaics         ##
##                             ##
#################################

# read in png/jpg
anj_mosaic <- readPNG("anjile.png") %>% 
  image_to_mosaic(img_size = 36) # length of each side of mosaic in "bricks"

# plot 2D mosaic
anj_mosaic %>% build_mosaic()

# steps for mosiac
anj_mosaic %>% build_instructions(9)

# piece list and count
anj_mosaic %>% build_pieces()


#################################
##                             ##
##     Plotting with LEGO      ##
##                             ##
#################################

df <- data.frame(trt = c("a", "b", "c"), outcome = c(2.3, 1.9, 3.2))

# for official LEGO colors, use with scale_fill_brick and theme_brick
ggplot(df, aes(trt, outcome)) +
  geom_brick_col(aes(fill = trt)) +
  scale_fill_brick() +
  coord_brick() +
  theme_brick()


#################################
##                             ##
##    Bonus: cheer package     ##
##                             ##
#################################

devtools::install_github("jeff-goldsmith/cheer")
library(cheer)
cheer:cheer()



