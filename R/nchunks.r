#' Return the number of chunks
#' @param df a disk.frame
#' @param skip.ready.check NOT implemented
#' @param ... passed ...
#' @export
nchunks <- function(...) {
  UseMethod("nchunks")
}

#' Returns the number of chunks in a disk.frame
#' @rdname nchunks
#' @export
nchunk <- function(...) {
  UseMethod("nchunk")
}

#' @rdname nchunks
#' @export
nchunk.disk.frame <- function(...) {
  nchunks.disk.frame(...)
}

#' @import fs
#' @rdname nchunks
#' @export
nchunks.disk.frame <- function(df, skip.ready.check = F) {
  #if(!skip.ready.check) stopifnot(is_ready(df))
  fpath <- attr(df,"path")
  if(is.dir.disk.frame(df)) {
    return(length(fs::dir_ls(fpath, type="file")))
  } else {
    return(1)
  }
}