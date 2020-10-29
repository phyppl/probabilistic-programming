# Phylogenetic models in Birch

## Installation

[Birch](https://birch-lang.org) is run from the command line. Complete installation instructions are available on this [web page](https://birch-lang.org/getting-started/installing/).

We have used the following versions (referring to particular commits) in our experiments:

Birch: 9fd55ad
Birch.Standard: 0c4c453

Once Birch is installed on a computer, our phylogenetics package can be built and installed in the standard manner for a Birch package:

```
birch build
birch install
```

To improve the performance it is possible to specify different building options, e.g. `--disable-debug` to disable debugging. More information on these options can be found in the documentation for the [build](https://birch-lang.org/documentation/driver/commands/build/) and the [install](https://birch-lang.org/documentation/driver/commands/install/) commands. (Remember to use the same options when you are building the standard library.)

Files in the [`config`](config) directory allow the configuration of various options such as the model, the number of samples to draw, and the number of particles to use. Files in the [`input`](input) directory provide the data sets in an appropriate format for use, including the location of the tree (in the [PhyJSON format](https://github.com/kudlicka/nexus2phyjson/blob/master/doc/phyjson_format_description.md)) as well as the parameters for the prior distributions. Source files for all models can be found in the [`bi`](bi) directory.

## Running Birch code

Inference for the individual models can be run with (e.g. for the CRBD model and the Anatinae tree):

```
birch sample --config config/crbd.json --input input/anatinae.json --output output/anatinae_crbd.json
```

Output appears in the `output` directory, as specified in the command.
Our package also includes the `sampler` program which stores samples for all particles, rather than just a selected one as the `sample` program does. To run the included program, change `sample` to `sampler` in the above-mentioned command.
