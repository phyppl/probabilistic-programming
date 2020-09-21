#' Correction to be applied to the RPANDA likelihooods
rpanda_correction =  function(lambda, sigma, nedges) {
  (nedges )* (dnorm(log(lambda), mean = log(lambda), sd = sigma, log = TRUE) )
}



#' Value of the Correction Needed for Fixing λ in the Beginning of Each Branch in the ClaDS[0-2] Models
#'
#' TODO not needed any more, to be removed
#'
#' The ClaDS[0-2] models have a PANDA version that fixes λ at the beginning of each branch of to the
#' initial λ and then factores that in. This is the sum of those factor weights.
#'
#' @param lambda
#' @param sigma
#' @param nedges
#'
#' @return
#' @export
#'
#' @examples
panda_correction = function(lambda, sigma, nedges) {
  nedges * dlnorm(lambda, meanlog = log(lambda), sdlog = sigma, log = TRUE)
}




#' ClaDS Diagnostic Plot
#' TODO currently not used, to be removed
clads_diagnostic_plot = function(data, means, title, colors = c("#000000B3", "#E69F00B3", "#56B4E9B3", "#009E73B3"), ptypes = 21:23, low = -260, high = -140) {
  plot(NULL, xlim = c(0, 1), ylim = c(low, high), main = title, xlab = "λ_0", ylab = "log Z")
  for (alphaix in 1:length(unique(data$alpha))) {
    for (sigmaix in 1:length(unique(data$sigma))) {
      print(alphaix)
      print(sigmaix)
      a = unique(data$alpha)[alphaix]
      s = unique(data$sigma)[sigmaix]
      with (data[data$sigma == s & data$alpha == a, ], {
        points(lambda, get(means), pch = ptypes[alphaix], col = colors[sigmaix])
      })
    }
  }
  #legend(x = 0.4, y = -220, legend = "○: α  = 0.4. △: α = 0.6. +: α = 1.0\nblack: σ = 0.15. red: σ = 0.60. green: σ  = 1.0\n")
  #legend(x = 0.4, y = -220, legend = c("○  α = 0.4", "△ α = 0.6", "+  α = 1.0"), pch = 1:3)
  legend(x = 0.2, y = -220, title = "α = 0.4", legend = c("σ = 0.15", "σ = 0.6", "σ = 1.0"), col = colors[1:3], pch = ptypes[1], bty = "n")
  legend(x = 0.45, y = -220, title = "α = 0.6", legend = c("σ = 0.15 ", "σ = 0.6", "σ = 1.0"), col = colors[1:3], pch = ptypes[2], bty = "n")
  legend(x = 0.7, y = -220, title = "α = 1.0", legend = c("σ = 0.15", "σ = 0.6", "σ = 1.0"), col = colors[1:3], pch = ptypes[3], bty = "n")
}



#' Verifies Model Results vs Analytical CRBD
#'
#' TODO can be renamed to plot_type_A
#'
#' Returns verification success and plots a visualization
#'
#' @param main
#' @param mtext
#' @param ylim has default
#' @param legendx has default
#' @param legendy has default
#' @param colors has default
#' @param datafr which data to plot
#' @param datafr_mean (string) what is the column name that holds the means
#' @param datafr_var (string) what is the column name holds the var
#'
plot_vs_crbd = function(main, mtext, ylab = "log Z", ylim = c(-200, -135), legengx = 0.1, legendy = -170, colors = c("#000000", "#E69F00", "#56B4E9", "#009E73"), datafr, datafr_mean, datafr_var, epsvals = unique(crbd_analytical$epsilon), novar = FALSE, xlab = "λ", xvar = "lambda", mtextcex = 0.9, crbd_analytical)
{
  res = data.frame()

  plot(NULL, xlim = c(0,1), ylim = ylim, ylab = ylab, xlab = xlab, main = main)
  mtext(mtext, cex = mtextcex)
  if (is.null(datafr$epsilon)) {
    datafr$epsilon = rep(0.0, nrow(datafr))
  }

  for (curre in epsvals) {

    lines(x = crbd_analytical[crbd_analytical$epsilon == curre,]$lambda, y = crbd_analytical[crbd_analytical$epsilon == curre,]$crbd_analytical_1, lty = "dotted",  col = colors[which(epsvals == curre)])
    #points(x = crbd_birch[crbd_birch$epsilon == curre,]$lambda, y = crbd_birch[crbd_birch$epsilon == curre,]$birch_mean, col = which(epsvals == curre), pch = 20)
    arrows(datafr[datafr$epsilon == curre, xvar] - 0.005, datafr[datafr$epsilon == curre, datafr_mean], datafr[datafr$epsilon == curre, xvar] + 0.005, datafr[datafr$epsilon == curre, datafr_mean] , length =0, angle = 90, code = 3, col = colors[which(epsvals == curre)], lwd = 2)
    if (!novar) {
      arrows(datafr[datafr$epsilon == curre, xvar], datafr[datafr$epsilon == curre, datafr_mean] - 2*sqrt(datafr[datafr$epsilon == curre, datafr_var]), datafr[datafr$epsilon == curre,xvar], datafr[datafr$epsilon == curre, datafr_mean] + 2*sqrt(datafr[datafr$epsilon == curre, datafr_var]), length = 0.02, angle = 90, code = 3, col = colors[which(epsvals == curre)])

      t = sapply(datafr[datafr$epsilon == curre, xvar], function(l) {
        a = datafr[datafr$epsilon == curre & datafr[[xvar]] == l, datafr_mean] - 2*sqrt(datafr[datafr$epsilon == curre & datafr[[xvar]] == l, datafr_var])
        b = datafr[datafr$epsilon == curre & datafr[[xvar]] == l, datafr_mean] + 2*sqrt(datafr[datafr$epsilon == curre & datafr[[xvar]] == l, datafr_var])
        c = crbd_analytical[crbd_analytical$epsilon == curre & crbd_analytical$lambda == l,]$crbd_analytical_1
        (a <= c) & (c <= b)
      })

      tt = data.frame(rep(curre, length(t)), datafr[datafr$epsilon == curre, xvar], t)
      names(tt) = c("eps", xvar, "PASS")
      res = rbind(res, tt)
    }


  }

  legend(legengx, legendy, legend=latex2exp::TeX(paste0("$\\epsilon = ", epsvals, "$")),
         col=colors[1:length(epsvals)], lty="dotted", bty = "n")

  cat("Testing: ", main, "\n")
  cat("# particles: ", unique(datafr$particles), "\n")
  cat("# of tests: ", nrow(res), "\n")
  testsum = test_summary(res)
  cat("Overall success rate: ", testsum$success_rate, "\n")
  cat("# NA's: ", testsum$na_nr, "\n")
  cat("# fails: ", testsum$fail_nr, "\nFailures:\n")
  print(testsum$failures)
  return(res)
}





#' Verify and Plot Model Results vs Analytical Solution
#'
#'  - based on plot_vs_crbd
#'  - there will be separate curves for each combination of grouping variables
#'
#'  TODO can be renamed
#'
#' Returns verification success and plots a visualization
#'
#' @param d1 data frame with simulation results
#' @param d2 data frame with analytical results
#' @param main has default
#' @param mtext has default
#' @param ylim has default
#' @param legendy has default
#' @param colors has default
#' @param meanvar (string) what is the column name that holds the means
#' @param variance_var (string) what is the column name holds the var
#' @param analytical_mean_var
#' @param xvar (string) column name that holds the x values
#' @param groupvar1 (string) column name that the first grouping variable
#' @param groupvar2 (string) column name that holds the second grouping variable
#' @param legengx
#' @param xlab has default
#'
plot_vs_analytical = function(d1,
                              d2,
                              meanvar,
                              variance_var,
                              analytical_mean_var,
                              xvar = "lambda",
                              groupvar1 = "z",
                              groupvar2 = "epsilon",
                              groupvar1_name = "z",
                              groupvar2_name = "ε",
                              main = "Analytical comparison",
                              mtext = "",
                              ylim = c(-220, -130),
                              legengx = 0.9,
                              legendy = -170,
                              colors = c("#000000", "#E69F00", "#56B4E9", "#009E73"),
                              xlab = "λ",
                              mtextcex = 0.9,
                              ylab =  "log Z"
)
{
  plot(NULL, xlim = c(0,1), ylim = ylim, ylab = ylab, xlab = xlab, main = main)
  mtext(mtext, cex = mtextcex)
  current_color = 1
  legend_text = c()

  for (g1 in unique(d1[,groupvar1]))
    for (g2 in unique(d2[,groupvar2])) {
      current_analytical  = d2[ d2[[groupvar1]] == g1 & d2[[groupvar2]] == g2,   ]
      current_simulation  = d1[ d1[[groupvar1]] == g1 & d1[[groupvar2]] == g2,   ]

      lines(x = current_analytical[[xvar]], y = current_analytical[[analytical_mean_var]], lty = "dotted",  col = colors[current_color])
      arrows(current_simulation[[xvar]] - 0.005, current_simulation[[meanvar]], current_simulation[[xvar]] + 0.005, current_simulation[[meanvar]], length =0, angle = 90, code = 3, col = colors[current_color], lwd = 2)

      arrows(current_simulation[[xvar]], current_simulation[[meanvar]] - 2*sqrt(current_simulation[[variance_var]]), current_simulation[[xvar]], current_simulation[[meanvar]] + 2*sqrt(current_simulation[[variance_var]]), length = 0.02, angle = 90, code = 3, col = colors[current_color])
      current_color = current_color + 1
      legend_text = c(legend_text, paste0(groupvar1_name, " = ",  g1, "\n", groupvar2_name, " = ", g2))
    }

  legend(legengx, legendy, legend=legend_text,
         col=colors, lty="dotted", bty = "n", y.intersp = 1.5)
}









#' Verify and Plot Model Results vs Analytical Solution
#'
#' TODO can be renamed
#'
#'  - based on plot_vs_crbd
#'  - there will be separate curves for each combination of grouping variables
#'
#' Returns verification success and plots a visualization
#'
#' @param d1 data frame with simulation results
#' @param d2 data frame with analytical results
#' @param main has default
#' @param mtext has default
#' @param ylim has default
#' @param legendy has default
#' @param colors has default
#' @param meanvar (string) what is the column name that holds the means
#' @param variance_var (string) what is the column name holds the var
#' @param analytical_mean_var
#' @param xvar (string) column name that holds the x values
#' @param groupvar1 (string) column name that the first grouping variable
#' @param groupvar2 (string) column name that holds the second grouping variable
#' @param legengx
#' @param xlab has default
#'
plot_vs_analytical_nogroup = function(d1,
                                      d2,
                                      meanvar,
                                      variance_var,
                                      analytical_mean_var,
                                      xvar = "lambda",
                                      legend_text = "RPANDA ClaDS0 (analytical)",
                                      main = "Analytical comparison",
                                      mtext = "",
                                      ylim = c(-220, -130),
                                      legengx = 0.9,
                                      legendy = -170,
                                      colors = c("#000000", "#E69F00", "#56B4E9", "#009E73"),
                                      xlab = "λ",
                                      ylab  = "log Z",
                                      mtextcex = 0.9
)
{
  plot(NULL, xlim = c(0,1), ylim = ylim, ylab = ylab, xlab = xlab, main = main)
  mtext(mtext, cex = mtextcex)
  current_color = 1



  current_analytical  = d2
  current_simulation  = d1

  lines(x = current_analytical[[xvar]], y = current_analytical[[analytical_mean_var]], lty = "dotted",  col = colors[current_color])
  arrows(current_simulation[[xvar]] - 0.005, current_simulation[[meanvar]], current_simulation[[xvar]] + 0.005, current_simulation[[meanvar]], length =0, angle = 90, code = 3, col = colors[current_color], lwd = 2)

  arrows(current_simulation[[xvar]], current_simulation[[meanvar]] - 2*sqrt(current_simulation[[variance_var]]), current_simulation[[xvar]], current_simulation[[meanvar]] + 2*sqrt(current_simulation[[variance_var]]), length = 0.02, angle = 90, code = 3, col = colors[current_color])
  current_color = current_color + 1


  legend(legengx, legendy, legend=legend_text,
         lty="dotted", bty = "n", y.intersp = 1.5)
}




#' Verify and Plot Model Results vs Analytical Solution
#'
#'  - based on plot_vs_crbd
#'  - there will be separate curves for each combination of grouping variables
#'
#' Returns verification success and plots a visualization
#'
#' @param d1 data frame with simulation results
#' @param d2 data frame with analytical results
#' @param main has default
#' @param mtext has default
#' @param ylim has default
#' @param legendy has default
#' @param colors has default
#' @param meanvar (string) what is the column name that holds the means
#' @param variance_var (string) what is the column name holds the var
#' @param analytical_mean_var
#' @param xvar (string) column name that holds the x values
#' @param groupvar1 (string) column name that the first grouping variable
#' @param groupvar2 (string) column name that holds the second grouping variable
#' @param legengx
#' @param xlab has default
#'
plot_vs_analytical_onegroup = function(d1,
                                       d2,
                                       meanvar,
                                       variance_var,
                                       analytical_mean_var,
                                       xvar = "lambda",
                                       groupvar1 = "epsilon",
                                       groupvar1_name = "$\\mu$",
                                       main = "Analytical comparison",
                                       mtext = "",
                                       ylim = c(-220, -130),
                                       legendx = 0.9,
                                       legendy = -170,
                                       colors = c("#000000B3", "#E69F00B3", "#56B4E9B3", "#009E73B3"),
                                       xlab = "λ",
                                       mtextcex = 0.9,
                                       ylab =  "log Z",
                                       legend_suff = "(RPANDA)",
                                       xlim = c(0, 1), tickw = 0.005, intersp = 1.5)
{
  plot(NULL, xlim = xlim, ylim = ylim, ylab = ylab, xlab = xlab, main = main)
  mtext(mtext, cex = mtextcex)
  current_color = 1
  legend_text = c()

  for (g1 in unique(d1[,groupvar1])) {
    current_analytical  = d2[ d2[[groupvar1]] == g1,   ]
    current_simulation  = d1[ d1[[groupvar1]] == g1,   ]

    lines(x = current_analytical[[xvar]], y = current_analytical[[analytical_mean_var]], lty = "dotted",  col = colors[current_color])
    arrows(current_simulation[[xvar]] - tickw, current_simulation[[meanvar]], current_simulation[[xvar]] + tickw, current_simulation[[meanvar]], length =0, angle = 90, code = 3, col = colors[current_color], lwd = 2)

    arrows(current_simulation[[xvar]], current_simulation[[meanvar]] - 2*sqrt(current_simulation[[variance_var]]), current_simulation[[xvar]], current_simulation[[meanvar]] + 2*sqrt(current_simulation[[variance_var]]), length = 0.02, angle = 90, code = 3, col = colors[current_color])
    current_color = current_color + 1
    legend_text =  c(legend_text, paste0(groupvar1_name, " = ",  g1))
  }

  legend(legendx, legendy, legend=latex2exp::TeX(paste(legend_text, legend_suff)),
         col=colors, lty="dotted", bty = "n", y.intersp = intersp)
}






#' Verify and Plot Model Results vs Analytical Solution
#'
#' TODO can be renamed. possibly not used: remove
#'
#'  - based on plot_vs_crbd
#'  - there will be separate curves for each combination of grouping variables
#'
#' Returns verification success and plots a visualization
#'
#' @param d1 data frame with simulation results
#' @param d2 data frame with analytical results
#' @param main has default
#' @param mtext has default
#' @param ylim has default
#' @param legendy has default
#' @param colors has default
#' @param meanvar (string) what is the column name that holds the means
#' @param variance_var (string) what is the column name holds the var
#' @param analytical_mean_var
#' @param xvar (string) column name that holds the x values
#' @param groupvar1 (string) column name that the first grouping variable
#' @param groupvar2 (string) column name that holds the second grouping variable
#' @param legengx
#' @param xlab has default
#'
rpanda_vs_rpanda = function(d1,
                            d2,
                            meanvar,
                            variance_var,
                            analytical_mean_var,
                            xvar = "lambda",
                            legend_text = c("RPANDA Sim", "RPANDA (analytical)"),
                            main = "Analytical comparison",
                            mtext = "",
                            ylim = c(-220, -130),
                            legengx = 0.9,
                            legendy = -170,
                            colors = c("#000000B3", "#E69F00B3", "#56B4E9B3", "#009E73B3"),
                            xlab = "λ",
                            ylab = "log Z",
                            mtextcex = 0.9
)
{
  plot(NULL, xlim = c(0,1), ylim = ylim, ylab = ylab, xlab = xlab, main = main)
  mtext(mtext, cex = mtextcex)
  current_color = 1



  current_analytical  = d2
  current_simulation  = d1

  lines(x = current_analytical[[xvar]], y = current_analytical[[analytical_mean_var]],    lty = "dotted")
  points(current_simulation[[xvar]], current_simulation[[meanvar]], pch = 3)

  legend(legengx, legendy, legend=legend_text,
         pch = c(3, NA), lty = c(NA, "dotted"),
         bty = "n", y.intersp = 1.5)
}




#' Plots Two Experiments Against Each Other
#'
#' TODO rename
#'
#' Values are merged, so cannot be used if you want to plot a higher resolution for one of the experiments.
#'
#' @param d1 (dataframe) experiment 1 data
#' @param d2 (dataframe) experiment 2 data
#' @param x (string) column name of x-axis
#' @param d1_z (string) column name of mean log Z in exp. 1
#' @param d1_var (string) column name of variation in exp. 1
#' @param d2_z (string)
#' @param d2_var (string)
#' @param  main (string) title text
#' @param mtext (string) text below title
#' @param ylab (string) the label of the Y-axis
#' @param low (numeric) y-axis lower bound (default -200)
#' @param high (numeric) y-axis upper bound (default -100)
#'
merge_plot = function(d1, d2, x, d1_z, d1_var, d2_z, d2_var, main, mtext, mtextcex = 1, ylab = "log Z", low = -200, high = -100, xlab = x,
                      colors = c("#000000B3", "#E69F00B3", "#56B4E9B3", "#009E73B3"), legendx = 15, legendy = -220, legend = NA, arrowl = 0.01, tickw = NA)
{
  dummy = NA

  with(merge(d1, d2), {
    # get everything that is in the data frame
    nms = ls()
    dd = as.data.frame(lapply(nms, function(x) { get(x)}))
    names(dd) = nms

    if (is.na(tickw)) {
      tickw = 30/length(get(x))*0.1
    }
    #cat(x, ": ", get(x), "\n")
    plot(NULL, xlim = range(get(x)), ylim = c(low, high), xlab = xlab, main = main, ylab = ylab)
    #plot(get(x), get(d1_z), col = 1, main = main, ylab = ylab, xlab = xlab, ylim = c(low, high))
    arrows(get(x) - tickw, get(d1_z), get(x) + tickw, get(d1_z) , length =0, angle = 90, code = 3, col = colors[1], lwd = 2)
    arrows(get(x), get(d1_z) - 2*sqrt(get(d1_var)), get(x), get(d1_z) + 2*sqrt(get(d1_var)), length = arrowl, angle = 90, code = 3, col = colors[1])
    mtext(mtext, cex = mtextcex)
    #points(get(x), get(d2_z), col = 2)
    arrows(get(x) - 2*tickw , get(d2_z), get(x), get(d2_z) , length =0, angle = 90, code = 3, col = colors[3], lwd = 2)
    arrows(get(x) - tickw, get(d2_z) - 2*sqrt(get(d2_var)), get(x) - tickw, get(d2_z) + 2*sqrt(get(d2_var)), length = arrowl, angle = 90, code = 3, col = colors[3])
    legend(x = legendx, y = legendy, legend = legend, col = c(colors[1], colors[3]), pch = "-", bty = "n")

    if (!is.na(get(d2_var))) {
      a = (get(d1_z) - 2*sqrt(get(d1_var)))
      b = (get(d1_z) + 2*sqrt(get(d1_var)))
      c = (get(d2_z) - 2*sqrt(get(d2_var)))
      d = (get(d2_z) + 2*sqrt(get(d2_var)))

      res = data.frame(get(x), ((a < d) & (c < b)) )
      names(res) = c(x, "PASS")
    } else {
      a = (get(d1_z) - 2*sqrt(get(d1_var)))
      b = (get(d1_z) + 2*sqrt(get(d1_var)))
      c = get(d2_z)

      res = data.frame(get(x), ((a < c) & (c < b)) )
      names(res) = c(x, "PASS")
    }

    cat("Testing: ", main, "\n")
    cat("# particles: ", unique(particles), "\n")
    cat("# of tests: ", nrow(res), "\n")
    testsum = test_summary(cbind(dd, res))
    cat("Overall success rate: ", testsum$success_rate, "\n")
    cat("# NA's: ", testsum$na_nr, "\n")
    cat("# fails: ", testsum$fail_nr, "\nFailures:\n")
    print(testsum$failures)
    return(cbind(dd, res))
  })

}



#' Model vs model plot
#'
#'  TODO see if needed
#'
#' Plots the information of two experiments vs each other.
#'  - likelihood vs likelihood plot
#'
#' @param model1  the name of the first model
#' @param model1f filename of first JSON file
#' @param r1      number of replicates in model1f
#' @param model2 the name of the second model
#' @param model2f filename of second JSON file
#' @param r2      number of replicates in model2f
model_vs_model_likelihood_plot = function(model1, model1f, r1, model2, model2f, r2, augment)
{

  data = merge_models(model1, model1f, r1, model2, model2f, r2, augment)

  plot(data$M1_means, data$M2_means,
       xlab = model1,
       ylab = model2,
       main = "Log-likelihood comparison")

  # lines(data$M1_means, data$M2_means)

}


#' Plot the model difference as a function of single parameter
#'
#'  TODO see if needed
#'
#' @param param the name of the parameter to investigate
#'
difference_vs_parameter_plot = function(model1, model1f, r1, model2, model2f, r2, param)
{
  data = merge_models(model1, model1f, r1, model2, model2f, r2)
  plot(
    data[[param]],
    data$M1_means - data$M2_means ,
    ylab = paste(model1, "-", model2),
    xlab = param,
    main = paste("Difference between", model1, "and", model2, "as a function of", param)
  )

  abline(a = c(0,0), h = TRUE)

}
