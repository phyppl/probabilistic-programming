# NodeJS package for phylogenetics

This package is also available automatically when running code with  `npm run wppl` or `npm run sim`.
It is a pure Node package (JavaScript) and can be used independently. `phyjs` provides a library of functions for working with phylogenetics in JavaScript.
The central function it provides is `phyjs.read_phyjson(filename)`, a function for parsing a phylogenetic tree stored in the [PhyJSON](https://github.com/kudlicka/nexus2phyjson/blob/master/doc/phyjson_format_description.md) format, the novel format that we are using for storing phylogentic trees in this study.

The `phyjs` package also provides several phylogenetic trees as internal data structures (e.g. the Bisse\_32 tree that is used for verification of the model scripts).

For the remaining functions of the package, read further.

TODO

NodeJS functions for phylogenetic trees.

Features:
	- reading in PhyJSON trees
	- working with phylogenetic trees
	- some useful mathematical functions

## Reading a tree

```
var my_tree = phyjs.read_phyjson("node_modules/phylodata/mesquite.phyjson")
phylodata.print_tree(my_tree)
```

## Built-in trees

```
var my_tree = phylodata.example_2
```

| Tree           | Leaves | Age (Ma) |Description       
|:----------------  |:---|:---|:----------------------------------|
| `phyjs.bisse_32`     | 32  | 13.0 | [Example tree](https://github.com/MesquiteProject/MesquiteCore/blob/master/Resources/examples/Diversification/06-BiSSEtrees.nex) from Mesquite software |
| `phyjs.cetacean_87`  | 87  | 35.9 | [Cetacean tree](https://github.com/macroevolution/bamm/blob/master/examples/diversification/whales/whaletree.tre) from BAMMtools package | |
| `phyjs.primates_233` | 233 | 65.1 | [Primate tree](https://raw.githubusercontent.com/richfitz/diversitree/master/pub/example/data/primates-10.nex) from Diversitree package  |
| `phyjs.example_2`    | 2   | 2    | toy tree with two tips (no stalk)    |
| `phyjs.primates_61`  | 61 | | Primate tree from Mesquite software (no stalk)  |


   
## Usage

To use the package it must be isntalled via `npm install phyjs`.

Use the `phyjs.` prefix to access the data and functions.


