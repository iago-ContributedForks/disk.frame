#' Set up disk.frame environment
#' @param workers the number of workers (background R processes in the
#' @param future_backend which future backend to use for parallelization
#' @param future.globals.maxSize The amount of memory that is allowed to be
#'   transferred between workers. Defaults to Inf for no limit.
#'   multiprocess environment)
#' @param gui Whether to use a Graphical User Interface (GUI) for selecting the options. Defaults to FALSE
#' @param ... passed to `future::plan`
#' @importFrom future plan multiprocess nbrOfWorkers sequential
#' @export
#' @examples 
#' if (interactive()) {
#'   # use a Shiny GUI to adjust settings
#'   setup_disk.frame(gui = TRUE)
#' 
#'   # set the number workers to 2
#'   setup_disk.frame(2)
#' 
#'   # set the future backend to sequential
#'   # these may use more than two cores, so it commented out
#'   # setup_disk.frame(future_backend = future::sequential)
#'   
#'   # setup disk.frame to use multiple workers
#'   # these may use more than two cores, so it commented out
#'   setup_disk.frame()
#' }
setup_disk.frame <- function(workers = parallel::detectCores(logical = FALSE), future_backend = multiprocess, future.globals.maxSize = Inf, ..., gui = FALSE) {
  #browser()
  if(!gui) {
    future::plan(future_backend, workers = workers, gc = TRUE, ...)
    print(sprintf("The number of workers available for disk.frame is %d", future::nbrOfWorkers()))
    options(future.globals.maxSize = future.globals.maxSize) # do not limit the amount of transfers to other workers
    options(disk.frame.nworkers = workers)
  } else if(gui) {
    if (!requireNamespace("shiny", quietly = TRUE)) {
      stop("Package \"shiny\" must be installed to use GUI. You can install shiny using install.packages('shiny')",
           call. = FALSE)
    }
    
    ui <- shiny::fluidPage(
      shiny::h1("disk.frame settings"),
      shiny::sliderInput(
        "nbrOfWorkers", 
        sprintf("Number of workers (recommendation = %d)", parallel::detectCores(logical = F)),
        1, 
        parallel::detectCores(), 
        value = future::nbrOfWorkers(), 
        step = 1),
      shiny::checkboxInput(
        "inf_fgm", 
        "Recommended: Set Maximum transfer size between workers to Inf (so ignore slider below)", 
        value = ifelse(
          is.null(getOption("future.globals.maxSize")), 
          TRUE, 
          is.infinite(getOption("future.globals.maxSize")))
      ),
      shiny::sliderInput(
        "future.globals.maxSize",
        "Maximum transfer size between workers (gb)",
        0,
        ifelse(is.infinite(memory.limit()), 3904, memory.limit()/1024/1024/1024),
        value = ifelse(is.infinite(getOption("future.globals.maxSize")), 3904, memory.limit()/1024/1024/1024),
        step = 0.5
      )
    )
    
    server <- function(input, output, session) {
      shiny::observe({
        future::plan(future_backend, workers = input$nbrOfWorkers, gc = TRUE, ...)
      })
      
      shiny::observe({
        if(input$inf_fgm) {
          options(future.globals.maxSize = Inf)
        } else {
          options(future.globals.maxSize = input$future.globals.maxSize*1024*1024*1024)
        }
      })
    }
    
    shiny::shinyApp(ui, server)
  } else {
    stop("setup_disk.frame: gui must be set to either TRUE or FALSE")
  }
}