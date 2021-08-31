# book-specific code to include on every page

chapter_status <- function(status = "finished") {
  if (status == "incomplete") {
    cat(":::{.warning}",
        paste0("This chapter is under construction as of ",
               format(Sys.Date(), format = "%B %d, %Y"),
               "; contents may change!"),
        ":::\n", sep = "\n")
  } else if (status == "archived") {
  } else {
    ## do nothing; chapter is finished
  }
}
