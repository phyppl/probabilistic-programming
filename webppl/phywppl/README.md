# Phylogenetic WebPPL

## Running phylogenetic WebPPL code

All WebPPL programs and R scripts from the paper can be run from the shell with the tools that are found in the repository. We assume that it has been [downloaded and the tools have been installed](../../README.md). To run programs from the shell, first set your working directory to `webppl/phywppl`. Two npm commands have been provided for running WebPPL code:

1. `npm run wppl` to run a single WebPPL probabilistic program.
2. `npm run sim` to run a set of related probabilistic programs (experiment).

### Running a single probabilistic program

A `phywppl` program is a text file with the `.wppl` extension containing a regular WebPPL probabilistic program. To execute such a program, you may use the following syntax in the shell (accessible only in the `phywppl` package directory):

```
npm run wppl EXAMPLE [N]
```

Here, `EXAMPLE` is the path to the program that will be executed, and  `[N]` is an optional integer (< 64) specifying the number of times the program should be executed. We refer to the `N` independent executions of the program as runs or sometimes replicates; they are not to be confused with the number of particles in SMC inference. The default value is `1`. If you want to run many analyses in parallel on your working computer, it is advisable to set `N` to the number of cores of your system minus 1 or 2 depending on how responsive you would like your system to be while the replicates are running.

In addition to all language constructs available through WebPPL (and JavaScript), `run wppl` makes available to the program all functions in any of the files in the directory `webppl/phywppl/models`, in particular all the conditional simulations, such as `simCRBD`, a function for simulating the constant rate birth death (CRBD) model. In addition, a second phylogenetic package, `phyjs`, is also included automatically. It offers several JavaScript functions for handling phylogenetic data, such as `phyjs.read_phyjson()`. Finally, as phylogenetic probabilistic programs require a large amount of heap space to be allocated, the run-command makes sure that this memory is available to Node.

A simple example is provided here to illustrate how this works in practice.
It simulates the CRBD model.
The source code that runs the analysis is available in the file `webppl/phywppl/examples/crbd.wppl`.
The code in this file sets up the priors and selects the data to condition the simulation on, and then calls the simulation function `simCRBD` defined in the `crbd.wppl` file in the `phywppl/models` directory.
To run the program from the command line in the environment we provide, you can, for instance, type: 

```
npm run wppl examples/crbd.wppl 10
```

This will run the program independently 10 times.

Each time, the program samples the posterior probability distribution and returns the parameters of interest.

### Running a probabilistic simulation experiment

Sometimes it is necessary to repeatedly run a probabilistic program with some minimal changes: for example, to process different phylogenetic trees with the same model, explore several inference strategies, or change other model parameters. For this reason we have provided another npm command `npm run sim`, which processes a JSON file (a text file in JSON format) that sets up an array of related probabilistic programs and runs them. To invoke processing of the JSON file, you use

```
npm run sim SIMULATION [N]
```

where `SIMULATION` is the path to the JSON script. The JSON script specifying a simulation experiment has the following format (example):

```
{
    "label": "crbd",
    "description": "Constant rate birth-death model.",

    "hyper_parameters": {
        "particles": 5000,			
        "tree": "phyjs.bisse_32",
        "MAX_LAMBDA": 5,
        "MAX_DIV": 5
    },
    
    "parameters": {
        "lambda": [0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1],
        "epsilon": [ 0.0, 0.1,   0.5,   0.9 ],	
        "rho": 1.0,
        "mu": "epsilon*lambda"
    },
    
    "model": "simCRBD( tree, lambda, mu, rho )\n\t var max_M = 10000\n\t var M = M_crbdGoesUndetected( tree.age, lambda, mu, rho, max_M )\n\t factor(Math.log(M))\n\t return [lambda, mu]",
    
    "inference": {
        "method": "SMC",
        "likelihood": true
    }
}
```

A brief description of the fields in this file:gf

  * `label` A label for the simulation. Should be one word, which will be used as a base for some filenames.
  * `description` A longer description of the simulation.
  * `hyper_parameters` A JSON object containing the hyper-parameters (which may be scalars or JSON arrays themselves). The object will be expanded to create a variable definition for each value in each array in a separate WebPPL program. Hyper-parameter definitions will be placed outside of the model function. Note that with hyper-parameters, we refer to control parameters rather than parameters of hyper-priors of the model.
  * `parameters` Similar to `hyper_parameters`. Expansion of the arrays is the same as in the case of the hyper-parameters, but it will result in different variable definitions placed inside the model function. This block is used to set random variables in the model to specific values.
  * `model` Used to indicate which simulation script from the `phywppl/models` library to use. After the simulation call, it is possible to add code that will be appended to the end of the model function, before the return. The example code provided here corrects for survivorship bias in the model, then returns the parameters `lambda` and `mu`.
  * `inference` 
    * `method` One of the supported methods of inference in WebPPL. If set to `false`, then no inference is carried out---the model function is simply executed.
    * `likelihood` Whether to return the normalization constant. Setting it to `false` will return whatever parameters the model function returns.
    
The execution of the simulation script above will result in the creation of 80 WebPPL programs (20 x 4 to create every possible combination of `lambda` and `epsilon`). The generated programs will have the following structure (only the first program is given, as an example):

```
/** crbd-1.wppl */
 
/* Hyper-parameter expansion */
var particles = 5000
var tree = phyjs.bisse_32
var MAX_LAMBDA = 5
var MAX_DIV = 5

var model = function()
{
  /* Parameter expansion */
  var lambda = 0.05
  var epsilon = 0
  var rho = 1
  var mu = epsilon * lambda

  /* Model */
  simCRBD( tree, lambda, mu, rho )
  var max_M = 10000
  var M = M_crbdGoesUndetected( tree.age, lambda, mu, rho, max_M )
  factor(Math.log(M))
  return [lambda, mu]
}
 
/* Inference */
var dist = Infer({method: 'SMC', particles: particles, model: model})
dist.normalizationConstant
\end{lstlisting}
```

Each of the programs will be run `N` times and their output stored in a file named `$label-results.JSON`, where `$label` is the value of the `label` field in the simulation JSON file. The accompanying R package `rppl` contains a function for parsing the outputs of such a file, `rppl::read_model()`. 

## Available models

When running a program with `npm run wppl` or `npm run sim`, the library of phylogenetic models from `webppl/phywppl/models` is automatically available. The main simulation functions are named `sim` followed by the acronym of a diversification model. For the CRB, CRBD, TDB abd TDBD models, we also provide functions that compute analytical likelihoods for specific parameter values. Adetailed description of the available functions follows

TODO

## Extended examples

TODO
