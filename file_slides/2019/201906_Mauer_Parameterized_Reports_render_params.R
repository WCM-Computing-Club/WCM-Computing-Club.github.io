

render_report = function(levels, continent, Var, type) {
  rmarkdown::render(
    "World_countries.Rmd", params = list(
      levels = levels,
      continent = continent,
      Var=Var,
      type=type
    ),
    output_file = "Test.html"
  )
}

# library('here')
# setwd(here('Syntax/'))
# render_report(levels=3, continent="Asia", Var="lifeExp", type="colors")