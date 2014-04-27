library(lubridate)
library(knitr)

MakePost <- function(title){
    filetitle <- gsub("[[:space:]]+", "-", title)
    oldwd <- getwd()
    setwd("~/github/dasonk.github.com/Rmd")
    filename <- paste0(today(), "-", filetitle, ".Rmd")
    outtext <- paste(gsub("default", title, readLines("default.txt")), collapse="\n")
    cat(outtext, file = filename)
    setwd(oldwd)
}

KnitPost <- function(input, base.url = "/") {

    opts_knit$set(base.url = base.url)
    in.file <- sub(".Rmd$", "", basename(input))
    fig.path <- paste0("../figs/", in.file, "/")
    opts_chunk$set(fig.path = fig.path)
    opts_chunk$set(fig.cap = "center")

    
    render_jekyll()
    opts_chunk$set(dev="bmp")
    opts_chunk$set(dev.args=list(bg="white"))
    out.file <- paste0("../_posts/", in.file, ".md")
    
    knit(input, output = out.file, envir = parent.frame())
}

DeletePost <- function(input){
    in.file <- sub(".Rmd$", "", basename(input))
    out.file <- paste0("../_posts/", in.file, ".md")
    if(file.exists(out.file)){
        file.remove(out.file)
    }
    tmp1 <- paste0(in.file, ".md")
    tmp2 <- paste0(in.file, ".html")
    if(file.exists(tmp1)){
        file.remove(tmp1)
    }
    if(file.exists(tmp2)){
        file.remove(tmp2)
    }
}

Update <- function(file){    
    newfile <- gsub("^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}", today(), file)
    file.rename(file, newfile)
}

setwd("~/github/dasonk.github.com/Rmd/")
