# Probabilistic Programming: A Powerful New Approach to Statistical Phylogenetics 

Fredrik Ronquist, [Jan Kudlicka](https://jan.kudlicka.eu), [Viktor Senderov](https://github.com/vsenderov), Johannes Borgström, Nicolas Lartillot, Daniel Lundén, Lawrence Murray, Thomas B. Schön, David Broman (F.R., J.K., and V.S. contributed equally to this work)

This is the source code repository accompanying the paper.

  * TODO link to paper
  * TODO email of corresponding author

## Contents

| Directory | Description                             |
|:----------|:----------------------------------------|
| `birch`   | Phylogenetic models in Birch            |
| `data`    | Phylogenetic trees used in the analysis |
| `R`       | Auxilliary R package for testing        |
| `webppl`  | Phylogenetic models in WebPPL           |

## How to download this repository?

```
git clone http://github.com/phyppl/probabilistic-programming
```

## Phylogenetic models in Birch

To install and use the models in [Birch](https://birch-lang.org/), please download and install the Birch compiler, library, (optional) examples, and their dependencies. Installation instructions can be found on the [getting started with Birch webpage](https://birch-lang.org/getting-started/installing/). The [phylogenetic models](birch/) presented in this paper can then be run like regular Birch packages. Follow the [Birch README](birch/README.md) in the `birch` directory for detailed instructions.


## Phylogenetic models in WebPPL

To install and use the models in WebPPL, the following packages have been provided:

  * [phywppl](webppl/phywppl/README.md) main package containing the models (implemented in WebPPL)
  * [phyjs](webppl/phyjs/README.md) dependency package with shared library functions (implemented in JavaScript)
  * [rppl](R/rppl/README.md) (optional) R package used in verification

### Installing phylogenetic WebPPL (phywppl)

An npm package `phywppl` has been provided. To install it:

1. Download and install [Node](https://nodejs.org/en/download/), if it has not been installed already.
2. Download and install [WebPPL](http://docs.webppl.org/en/master/installation.html), if it has not been installed already.
3. Download this repository (see above), if it has not been downloaded already.
4. Change to the `webppl/phywppl` package directory:

```
cd webppl/phywwpl
```

5. Install dependency packages `phyjs` (local) and `shelljs`:

```
npm install ../phyjs
npm install shelljs
```

Now, all WebPPL programs from the paper can be run from the shell with the tools that are found in the repository. Consult the [phywppl README](webppl/phywppl/README.md) for instructions.

### Installing optional R package (rppl)

An optional R package `rppl` is provided, which is needed to generate the verification plots from the WebPPL source tree.

1. Install [R](https://cran.r-project.org/).
2. From R, type

```
install.packages(file.choose(), repos = NULL, type = "source")
```
3. When R prompts you to select the desired package, indicate the `rppl_1.0.0.tar.gz` package from the `R` directory.
  
## Phylogenetic data

The WebPPL and Birch scripts we provide simulate diversification along observed reconstructed trees.
We use a new JSON format for phylogenetic trees named [PhyJSON](https://github.com/kudlicka/nexus2phyjson/blob/master/doc/phyjson_format_description.md).
Supported by the resources we provide in the repository, both WebPPL and Birch have mechanisms for reading in phylogenetic trees stored in the PhyJSON format.
We also provide a stand-alone tool, [nexus2phyjson](https://github.com/kudlicka/nexus2phyjson), which can be used to convert trees in Nexus tree files to PhyJSON format.

For convenience, we provide several [built-in phylogenetic trees](webppl/phyjs/README.md#built-in-trees) in the phyjs package for purposes such as testing and verification.
They can be used directly, without the need to input them from a PhyJSON file.
