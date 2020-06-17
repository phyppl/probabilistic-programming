#' Summarizes unit test results
#'
#' @param r data frame that has the unit test results (must have a column called PASS)
#'
#' @return a list of the summaries
test_summary = function(r)
{
  success_rate = sum(r$PASS == TRUE, na.rm = TRUE) / nrow(r)
  na_nr = sum(is.na(r$PASS))
  fail_nr = sum(r$PASS == FALSE, na.rm = TRUE)
  failures = r[r$PASS == FALSE & !is.na(r$PASS),]
  R = list(success_rate, na_nr, fail_nr, failures)
  names(R) = c("success_rate", "na_nr", "fail_nr", "failures")
  return(R)
}



#' Updates database
#'
#' TODO modelname and reps should probably be parsed automatically
#'
#' @param dataf where the database is stored
#' @param newjs new data in json format
#' @param modelname the name of the model
#' @param reps the number of reps
#'
#' @return data frame with updated db
update_db = function(dataf, newjs, modelname, reps)
{
  dataname = load(dataf)

  assign(dataname, unique(rbind(
    eval(parse(text = dataname)),
    read_model(model = modelname, modelf = newjs, reps = reps)
  )))

  save(list = dataname, file = dataf)
}



#' Compute the summary statistic
#'
#' @param data data frame
#' @param npar number of parameter columns
#' @param reps number of replicates
#'
#' @return a vector of the row means of the replicates
sumstat = function(data, npar, reps) {
  sapply(
    1:nrow(data),
    function(row) {
      mean(as.numeric(  data[row, (npar + 1):(npar + reps)]), na.rm = TRUE  )
    }
  )
}



#' Compute the summary statistic variance
#'
#' @param data data frame
#' @param npar number of parameter columns
#' @param reps number of replicates
#'
#' @return a vector of the row means of the replicates
sumstat_var = function(data, npar, reps) {
  sapply(
    1:nrow(data),
    function(row) {
      var(as.numeric(  data[row, (npar + 1):(npar + reps)]), na.rm = TRUE  )
    }
  )
}



#' Get the number of parameters of model
#'
#' @param modelf  model file
#'
#' @return the number of parameters
numpar_model = function(modelf)
{
  m = rjson::fromJSON(file = modelf)
  return(length(m[[1]]$parameters) + length(m[[1]]$hyper_parameters))
}



#' Reads Simulation Results
#'
#' Simulations that are stored in *-results.JSON are read via this function.
#'
#' @param model (string) model name - will be used as a prefix in the data frame columns
#' @param modelf (string)  model file - path to *-results.JSON file
#' @param reps (integer) the number of replicates (independent runs of the probabilistic program) that the model has been run; corresponds to the last parameter of 'npm run sim' and 'npm run wppl'
#'
#' @return data frame with *-results.JSON file parsed
#'
#' @export
read_model = function(model, modelf, reps)
{
  m = rjson::fromJSON(file = modelf)
  npar_m = numpar_model(modelf = modelf)
  data_m = json_processor(m, npar = npar_m, reps = reps, name = paste0(model, "_"))
  data_m[[paste0(model, "_means")]] = sumstat(data_m, npar = npar_m, reps = reps)
  data_m[[paste0(model, "_var")]] = sumstat_var(data_m, npar = npar_m, reps = reps)
  return(data_m)
}


#' Read Verbose Model Description
#'
#' @param modelf  model file
#'
#' @return character
read_model_description = function(modelf)
{
  m = rjson::fromJSON(file = modelf)
  return ( m[[1]]$description )
}



#' Augments a data frame with dummy variables
#'
#' @param data data frame
#' @param l a list of vectors to augment with
#'
#' @return data frame
augment_data = function(data, l)
{
  augmentation = do.call(expand.grid, l)
  do.call(rbind, lapply(1:nrow(data), function(row_i)
    {
    do.call(rbind, lapply(1:nrow(augmentation), function(row_j) {
      cbind(data[row_i,], augmentation[row_j,])
    }))
  }))
}


#' Merge two models
#'
#' @param augment values used to augment model1 to be mergable with model
#'
#' @return merged augmented models
merge_models = function(data_m1, data_m2, augment) {

  # data frame augmentation for merging purposes
  data_m1 = cbind(data_m1, lapply(augment, function(v) {
    rep(v, nrow(data_m1))
  }))

  return( merge(data_m1, data_m2))
}





# JSON Processing ---------------------------------------------------------

#' Processes the JSON simulation output by npm run sim
#'
#' @param sim simulation object (JSON)
#' @param npar the number of parameters that simulation had (tree is counted)
#' @param name string to be used for the values
#'
#' @return a data frame
json_processor = function(sim, npar, reps, name = "R")
{
  is_number = function(numstr) { !is.na(as.numeric(numstr)) }

  as_number = function(numstr) {
    if (is_number(numstr)) return(as.numeric(numstr))
    else return(numstr)
  }

  as_numberv = function(numstrv) {
    sapply(numstrv, as_number)
  }

  do.call(rbind, lapply(sim, function(item) {
    v = readLines(con = textConnection(item[["output"]]))
    v = v[1:reps]
    f = data.frame(t(as_numberv(v)), t(rep("", reps + 1 - length(v))), stringsAsFactors = FALSE)
    names(f) = paste0(name, seq(1:(reps + 1)))
    cbind(data.frame(item$parameters, stringsAsFactors = FALSE), data.frame(item$hyper_parameters, stringsAsFactors = FALSE), f)
  }))[, 1:(npar + reps)]
}


#' Check sort order
#'
#'  TODO check if needed
#'
#' @param data a data frame that should be sorted
#' @param params a list of params that have to be checked
#'
#' @return TRUE if no problem was found, false otherwise
check_sort_order = function(data, params)
{
  sorting_index0 = do.call(order, params)

  if ( !all(sorting_index0 == seq(1:nrow(data))) ) {
    warning("Problem exists in simulation! Sorting order is wrong!")
    return (FALSE)
  } else return( TRUE)

}


#' Impose sort order
#'
#'  TODO check if needed
#'
#' @param data a data frame that should be sorted
#' @param params a list of params that have to be checked
#'
#' @return TRUE if no problem was found, false otherwise
impose_sort_order = function(data, params)
{
  sorting_index0 = do.call(order, params)

  data[sorting_index0, ]
}



#' Strip PhyJSON Reading Function
#'
#' Converts strings such as
#'
#'   phyjs.read_phyjson('../../data/bird-phyjson/Accipitridae.MCC.tre.phyjson')
#'
#' to simply the tree name, e.g. to 'Accipitridae.MCC.tre'.
#'
#' @param x character(1)  A JS string for reading a PhyJSON tree.
#'
#' @return character(1)   The pure tree name.
#'
#' @examples
#'
#' strip_read_phyjson(x = "phyjs.read_phyjson(../../data/bird-phyjson/Accipitridae.MCC.tre.phyjson')")
strip_read_phyjson = function(x)
{
  x1 = unlist(strsplit(x, "/")) # separate filepath
  x2 = x1[length(x1)] # get only last item
  x3 = unlist(strsplit(x2, "\\.")) # separate file extension
  x4 = x3[1:(length(x3) - 1)] # remove file extension
  return (do.call(paste, c(as.list(x4), sep = "."))) # reassemble
}

