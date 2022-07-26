install.packages("stringr")

library(stringr)

#Repetitions
strings <- c("b", "be", "bye", "byye", "byyye", "byyyyye")

grep("by*e", strings, value = TRUE)

grep("by+e", strings, value = TRUE)

grep("by?e", strings, value = TRUE)

grep("by{2}e", strings, value = TRUE)

grep("by{2,4}e", strings, value = TRUE)

grep("by{2,}e", strings, value = TRUE)


#Positions
strings <- c("byeb", "ebyb", "beby", "by eb") 

grep("by", strings, value = TRUE)

grep("^by", strings, value = TRUE)

grep("by$", strings, value = TRUE)

grep("\\bby", strings, value = TRUE)


#Operations
strings <- c("by", "bye", "byc", "byd", "by 5")

grep("by.", strings, value = TRUE)

grep("by[c-e]", strings, value = TRUE)

grep("by[^e]", strings, value = TRUE)

grep("bye|byc", strings, value = TRUE)
