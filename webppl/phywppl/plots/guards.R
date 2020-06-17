rm(list = ls())
source("src/plotting-functions.R")
library(rppl)

cairo_pdf("plots/guards.pdf", onefile = TRUE, width = 5, height = 5, pointsize = 8, fallback_resolution = 600)

diag_plot = function(modelf, reps, name, test) {
    mod = read_model(name, modelf = modelf, reps = reps)
    description = read_model_description(modelf = modelf)
    mod$tree = sapply(mod$tree, strip_read_phyjson)
    numpar = numpar_model(modelf)

    plot(log(x = mod[[test]], base = 10), mod[,numpar + 1], pch = 20,
         main =  description, xlab = paste("log", test), ylab = "log(Z)")
    
    sapply(
        seq(from = 2, to = reps, by = 1), function(i) {

            points(
                log(x = mod[[test]], base = 10), mod[,numpar + i],  pch = 20 )
        }
    )

    mtext(paste(reps, "replicates; log: base 10"))

}

diag_plot(modelf = "verification/guards/clads2-MAX_LAMBDA-results.JSON", reps = 10, name = "ClaDS2-MAX_LAMBDA", test = "MAX_LAMBDA")

diag_plot(modelf = "verification/guards/clads2-MAX_DIV-results.JSON", reps = 10, name = "ClaDS2-MAX_DIV", test = "MAX_DIV")

dev.off()



