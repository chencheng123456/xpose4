#' @describeIn GAM_summary_and_plot Individual influence on GAM fit.
#' @export


"xp.ind.inf.fit" <-
  function(gamobj=NULL,
           plot.ids=TRUE,
           idscex=0.7,
           ptscex=0.7,
           title = "Default",
           recur = FALSE,
           xlb = NULL,
           ylb = NULL,
           ...){
    
    if(is.null(gamobj)){
      gamobj <- check.gamobj()
      if(is.null(gamobj)){
        return()
      } else {
      }
    } else {
      c1 <- call("assign",pos=1, "current.gam", gamobj,immediate=T)
      eval(c1)
    }
    
    
    sd <- sqrt(eval(parse(text=paste("current.gam","$deviance",sep="")))/eval(parse(text=paste("current.gam","$df.residual",sep=""))))
    
    #sd   <- sqrt(current.gam$deviance/current.gam$df.residual)
    
    
    #pear <- residuals(current.gam,type="pearson")/sd
    #h    <- lm.influence(current.gam)$hat
    #p    <- current.gam$rank
    
    pear <- residuals(eval(parse(text="current.gam")),type="pearson")/sd
    h    <- lm.influence(eval(parse(text="current.gam")))$hat
    p    <- eval(parse(text=paste("current.gam","$rank",sep="")))
    
    rp   <- pear/sqrt(1-h)
    #for (i in 1:length(rp)){
    #  if(is.na(rp[i])){
    #    rp[i] <- pear[i]
    #  }
    #}
    cook <- (h*rp^2)/((1-h)*p)
    
    #for (i in 1:length(cook)){
    #  if(is.na(cook[i])){
    #    cook[i] <- h[i]*rp[i]^2
    #  }
    #}
    
    
    #n    <- p + current.gam$df.residual
    n    <- p + eval(parse(text=paste("current.gam","$df.residual",sep="")))
    cooky <- 8/(n-2*p)
    ##    hy   <- (2*p)/(n-2*p)
    hy   <- (2*p)/n
    leve <- h/(1-h)
    #for (i in 1:length(leve)){
    #  if(!is.finite(leve[i])){
    #    leve[i] <- h[i]
    #  }
    #}
    
    
    if(is.null(xlb))
      xlb <- "Leverage (h/(1-h))"
    if(is.null(ylb))
      ylb <- "Cooks distance"
    
    
    
    
    if(!is.null(title) && title == "Default") {
      title <- paste("Individual influence on the GAM fit for ",
                     eval(parse(text=paste("current.gam","$pars",sep=""))),
                     " (run ",
                     #current.gam$runno,
                     eval(parse(text="current.gam$runno")),
                     ")",sep="")
    }
    
    ## Get the idlabs
    if(any(is.null(eval(parse(text="current.gam$data$ID"))))){
      ids <- "n"
    } else {
      ids <- eval(parse(text="current.gam$data$ID"))
    }
    
    ## inform about NaN and INF values
    for (i in 1:length(cook)){
      if(is.na(cook[i])||!is.finite(cook[i])||
         is.na(leve[i])||!is.finite(leve[i])){
        cat("\nFor ID ",ids[i], ":\n", sep="")
        cat("   Cook distance is ", cook[i],"\n",sep="")
        cat("   Leverage is ", leve[i],"\n",sep="")
        cat("   => the point is not included in the plot\n")
      }
    }
    
    xplot <- xyplot(cook~leve,
                    ylab=ylb,
                    xlab=xlb,
                    main=title,
                    aspect="fill",
                    cooky=cooky,
                    hy=hy,
                    scales = list(cex=0.7,tck=-0.01),
                    ids = eval(parse(text="current.gam$data[,1]")),
                    panel=
                      function(x,y,ids,...) {
                        if(!any(ids == "n")&& plot.ids==TRUE) {
                          addid(x,y,ids=ids,
                                idsmode=TRUE,
                                idsext =0.05,
                                idscex = idscex,
                                idsdir = "both")
                        } else {
                          panel.xyplot(x,y,cex=ptscex,col="black")
                        }
                      }
    )
    
    return(xplot)
    
  }

