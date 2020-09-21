# Reads all the CRBD data

# needed libraries

# The rppl package is in R/rppl
suppressPackageStartupMessages({
  require(rppl)
  require(vioplot)
  require(readr)
})

# Setup -------------------------------------------------------------------

crbd_analytical_f = "verification/crbd/crbd-analytical-results.JSON"
crbd_analytical_rho_f = "verification/crbd/crbd-analytical-rho-results.JSON"

crbd_f = "verification/crbd/crbd-results.JSON"
crbd_rho_f = "verification/crbd/crbd-rho-results.JSON"

crbd_birch_f = "verification/crbd/birch-crbd-sb.csv"
crbd_birch_rho_f = "verification/crbd/birch_crbd_rho.csv"


crbd_analytical_align_f = "verification/crbd/alignment/crbd-analytical-results.JSON"
crbd_align_f = "verification/crbd/alignment/crbd-results.JSON"
crbd_naive_align_f = "verification/crbd/alignment/crbd-naive-results.JSON"

clads2_f = "verification/crbd/clads2-results.JSON"
clads2_rho_f = "verification/crbd/clads2-rho-results.JSON"
clads1_f = "verification/crbd/clads1-results.JSON"
clads1_rho_f = "verification/crbd/clads1-rho-results.JSON"
clads0_f = "verification/crbd/clads0-results.JSON"
clads0_rho_f = "verification/crbd/clads0-rho-results.JSON"


clads0_panda_f = "verification/crbd/clads0-panda-results.JSON"
clads1_panda_f = "verification/crbd/clads1-panda-results.JSON"
clads2_panda_f = "verification/crbd/clads2-panda-results.JSON"

clads2_rpanda_f = "verification/crbd/clads2-rpanda-results.csv"
clads1_rpanda_f = "verification/crbd/clads1-rpanda-results.csv"
clads0_rpanda_f = "verification/crbd/clads0-rpanda-results.csv"

lsbds_f = "verification/crbd/lsbds-results.JSON"
lsbds_rho_f = "verification/crbd/lsbds-rho-results.JSON"
lsbds_revbayes_f = "~/Work/ppl-phylogenetics/webppl/phywppl/verification/crbd/lsbds-results.csv"

bamm_f = "verification/crbd/bamm-results.JSON"
bamm_rho_f  = "verification/crbd/bamm-rho-results.JSON"
tdbd_f = "verification/crbd/tdbd-results.JSON"
tdbd_rho_f = "verification/crbd/tdbd-rho-results.JSON"

crbd_naive_f = "verification/alignment/crbd-naive-results.JSON"
crbd_plots_f = "verification/crbd/crbd-plots.pdf"

# Input -------------------------------------------------------------------


crbd_analytical = rppl::read_model("crbd_analytical", modelf = crbd_analytical_f, reps = 1)
crbd = rppl::read_model("crbd", modelf = crbd_f, reps = 12)
crbd = crbd[crbd$rho == 1.0,]
epsvals = unique(crbd_analytical$epsilon)

crbd_analytical_rho = rppl::read_model("crbd_analytical", modelf = crbd_analytical_rho_f, reps = 1)
crbd_rho = rppl::read_model("crbd", modelf = crbd_rho_f, reps = 12)



suppressMessages({
  crbd_birch = readr::read_delim(crbd_birch_f, "|", escape_double = FALSE, trim_ws = TRUE)
})
# ./output/vt_clads0_${lambda}_${epsislon}.json
crbd_birch$lambda = as.numeric( sapply(strsplit(x = crbd_birch$File, split = "_"), function(l) { l[3] } ) )
crbd_birch$epsilon = as.numeric( sub(pattern = ".json", replacement = "", x = sapply(strsplit(x = crbd_birch$File, split = "_"), function(l) { l[4] } ) ) )
crbd_birch[crbd_birch$epsilon == 0.000001, "epsilon"] = 0
crbd_birch = as.data.frame(crbd_birch)


suppressMessages({
  crbd_birch_rho = readr::read_delim(crbd_birch_rho_f, "|", escape_double = FALSE, trim_ws = TRUE)
})
crbd_birch_rho$lambda = as.numeric( sapply(strsplit(x = crbd_birch_rho$File, split = "_"), function(l) { l[2] } ) )
crbd_birch_rho$epsilon = as.numeric( sub(pattern = ".json", replacement = "", x = sapply(strsplit(x = crbd_birch_rho$File, split = "_"), function(l) { l[3] } ) ) )
crbd_birch_rho[crbd_birch_rho$epsilon == 0.0001, "epsilon"] = 0
crbd_birch_rho = as.data.frame(crbd_birch_rho)

clads2 = rppl::read_model("clads2", modelf = clads2_f, reps = 12)
clads2_rho = rppl::read_model("clads2", modelf = clads2_rho_f, reps = 12)
clads1 = rppl::read_model("clads1", modelf = clads1_f, reps = 12)
clads1_rho = rppl::read_model("clads1", modelf = clads1_rho_f, reps = 12)
clads0 = rppl::read_model("clads0", modelf = clads0_f, reps = 12)
clads0_rho = rppl::read_model("clads0", modelf = clads0_rho_f, reps = 12)

clads0_panda = read_model("clads0", modelf = clads0_panda_f, reps = 12)
clads0_panda$ld = with(clads0_panda,
                       {
                         return (panda_correction(lambda = lambda_0, sigma = sigma, nedges = 62))
                       })

clads1_panda = read_model("clads1", modelf = clads1_panda_f, reps = 12)
clads1_panda$ld = with(clads1_panda,
                       {
                         return (panda_correction(lambda = lambda_0, sigma = sigma, nedges = 62))
                       })

clads2_panda = read_model("clads2", modelf = clads2_panda_f, reps = 12)
clads2_panda$ld = with(clads2_panda,
                       {
                         return (panda_correction(lambda = lambda_0, sigma = sigma, nedges = 62))
                       })

clads2_rpanda = read.table(file = clads2_rpanda_f)
clads2_rpanda$ld = with(clads2_rpanda,
                        {
                          return (rpanda_correction(lambda = lambda, sigma = sigma, nedges = 62))
                        })

clads1_rpanda = read.table(file = clads1_rpanda_f)
clads1_rpanda$ld = with(clads1_rpanda,
                        {
                          return (rpanda_correction(lambda = lambda, sigma = sigma, nedges = 62))
                        })

clads0_rpanda = read.table(file = clads0_rpanda_f)
clads0_rpanda$ld = with(clads0_rpanda,
                        {
                          return (rpanda_correction(lambda = lambda, sigma = sigma, nedges = 62))
                        })

lsbds = read_model("lsbds", modelf = lsbds_f, reps = 12)
lsbds_rho = read_model("lsbds", modelf = lsbds_rho_f, reps = 12)

library(readr)
suppressMessages({
  lsbds_revbayes = readr::read_delim(lsbds_revbayes_f,
                                     "\t", escape_double = FALSE, trim_ws = TRUE)
})
lsbds_revbayes = as.data.frame(lsbds_revbayes)

bamm = read_model("bamm", modelf = bamm_f, reps = 10)
bamm_rho = read_model("bamm", modelf = bamm_rho_f, reps = 12)
tdbd = read_model("tdbd", modelf = tdbd_f, reps = 12)
tdbd_rho = read_model("tdbd", modelf = tdbd_rho_f, reps = 12)


cat("Input complete.\n")
cat("\n")
