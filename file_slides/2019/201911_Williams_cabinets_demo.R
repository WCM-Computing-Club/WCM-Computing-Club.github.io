
# Nick Williams
# cabinets demo (v0.3.1)
# GH repo: nt-williams/cabinets
# twitter: @nickWillyamz

# installation ------------------------------------------------------------

# from CRAN
install.packages("cabinets")

# development version (currently 0.3.1.9000)
devtools::install_github("nt-williams/cabinets")

# creating a cabinet ------------------------------------------------------

library(cabinets)

# this cabinet is based on a template by Elizabeth Mauer availble at
# https://wcm-computing-club.github.io/file_slides/201812_Mauer_Organization_and_Documentation_of_Workflow.html

# first, we specify where we want the cabinet to live (i.e., where future projects created
# using the cabinet will be created)

# in this case, I want to create a cabinet that will store projects in the folder cabinets_demo
cab_path1 <- "~/cabinets_demo"

# second, we define the cabinet structure
cab_str1 <- list('Common/Data/Source' = NULL,
                 'Common/Data/Derived' = NULL,
                 'Common/Documentation' = NULL,
                 'Common/Syntax' = NULL,
                 'Common/Log' = NULL)

# to create the cabinet we use create_cabinet(), mind blown right
# lets call the cabinet "common"
create_cabinet(name = "common",
               directory = cab_path1,
               structure = cab_str1)

# on first use, you have to give cabinets permission to write files

# if we close and re-open R, our cabinet, .common, will still exist in our global environment, crazy!
# ps. cabinets are referenced with . before their name and are a R6 class FileCabinet
.common

# to see all available cabinets, use get_cabinets()... ain't that intuitive
get_cabinets()

# using a cabinet ---------------------------------------------------------

# a FileCabinet object simply contains a template that new_cabinet_proj() uses to build project structures
# new_cabinet_proj() requires 2 arguments, the cabinet to use, and the new project's name
# optional arguments include whether an Rproject should be created and if that project should be opened.

# using our .common cabinet
new_cabinet_proj(cabinet = .common,
                 project_name = "hu_pirads",
                 r_project = FALSE)

# further examples --------------------------------------------------------

# the template this is based off of actually uses an extra layer

# lets create another
cab_path2 <- "~/cabinets_demo"

cab_str2 <- list('Data/Source' = NULL,
                 'Data/Derived' = NULL,
                 'Documentation' = NULL,
                 'Syntax' = NULL,
                 'Log' = NULL,
                 'Reports' = NULL,
                 'Output' = NULL,
                 'End_Products' = NULL,
                 'Scratch' = NULL)

# this cabinet will be called project
create_cabinet(name = "project",
               directory = cab_path2,
               structure = cab_str2)

# peek at the cabinet
.project

# use .project to start a new project within the existing project we already created
new_cabinet_proj(cabinet = .project,
                 project_name = "hu_pirads/hu_predicting_CSPC",
                 r_project = TRUE,
                 open = TRUE)

# how does this sorcery work ----------------------------------------------

# when create_cabinet() is run, the code to create a FileCabinet object is written to a .Rprofile file
# .Rprofile files are just R scripts that are automatically run when R is booted
# you can look at the .Rprofile with 
edit_r_profile()

# contributing ------------------------------------------------------------

# want to contribute? 
# the githup repo can be found at nt-williams/cabinets

# coming soon -------------------------------------------------------------

# version 1.0.0 will introduce the ability to initiate a git repository from new_cabinet_proj()

