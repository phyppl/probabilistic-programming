# PhyJSON &ndash; a simple JSON format for phylogenetic data

Version 1.0 by Jan Kudlicka, Daniel Lundén and Fredrik Ronquist

**Draft**

February 27, 2018

## Format description

The PhyJSON format is based on the [JSON file format][1]. All keys are lowercase and the values are case-sensitive. It is recommended to use lowercase for both values and the keys of custom attributes.

### The root element

The root element is an object with the following attributes:

Key         | Type                                   | Mandatory | Description
---         | ---                                    | :-:       | ---
format      | string                                 | Yes       | Name of the format, always "phyjson"
version     | string                                 | Yes       | Version of the format, current version is "1.0"
description | string                                 | No        | Optional description of the file contents
characters  | array of character description records | No        | Information about characters, see [Character description record](#character-description-record)
taxa        | array of taxon records                 | Yes       | Information about taxa, see [Taxon record](#taxon-record)
trees       | array of tree records                  | No        | Information about trees, see [Tree record](#tree-record)

### Character description record

Taxons might have multiple characters. Each character must be described by a character description record which is an object with the following attributes: 

Key         | Type             | Mandatory                 | Description
---         | ---              | :-:                       | ---
id          | string           | Yes                       | Unique identifier of the character
description | string           | No                        | Optional description of the file contents
type        | string           | Yes                       | Type of data: "dna", "rna", "protein", "nucleotide", "standard" or "continuous"
aligned     | boolean          | No                        | True if the character sequences are aligned, false otherwise
missing     | string           | No                        | The missing symbol (defaults to "?")
gap         | string           | No                        | The gap symbol (defaults to "-")
symbols     | array of strings | Yes if type is "standard" | A list of allowed symbols. Symbols are ingored for any other type than "standard". The symbols must not contain the missing symbol, the gap symbol, parantheses and braces, quote marks (both single and double) and comma.

### Taxon record

Each taxon is represented as an object with the following attributes:

Key        | Type              | Mandatory | Description
---        | ---               | :-:       | ---
id         | string or integer | Yes       | Unique identifier of the taxon (used to refer to the taxon)
name       | string            | No        | Unique name of the taxon
characters | object            | No        | An object with the keys referring to the identifier of the character (see [Character description record](#character-description-record) above). Each value follows the description [below](#character-data).

#### Character data

For the dna, rna, protein, nucleotide and standard characters, the data for each taxon might be specified as a string. Symbols are separated by comma. The comma can be dropped if all symbols (including the missing and gap symbols) are single characters. Multiple states might be specified using the {} and () notation as in the NEXUS format.

Alternatively, the character data might be specified as an array of symbols. Multiple states might be specified using a string with {} and () notation or as an array, see the examples below.

Examples: Character data in the following two examples are equivalent:

```
"actg"
"a,c,t,g"
["a", "c", "t", "g"]
```

```
"a-c{ag}?"
"a,-,c,{a,g},?"
["a", "-", "c", "{ag}", "?"]
["a", "-", "c", ["a", "g"], "?"]
```

For the continuous characters, the data is specified as an array of numbers.

### Tree record

Key    | Type                | Mandatory | Description
---    | ---                 | :-:       | ---
name   | string              | No        | Unique name of the tree
rooted | boolean             | No        | True (default) if the tree is rooted, false otherwise.
root   | object of type node | Yes       | For a rooted tree: the root node. For an unrooted tree: the root of an arbitrary rooting

### Node record

Key           | Type                  | Mandatory | Description
---           | ---                   | :-:       | ---
taxon         | string                | No        | The taxon ID
branch_length | number                | No        | The length of the branch between the node's parent and the node (the stalk length for the root)
children      | array of node records | No        | Children of the node

### Custom attributes

The format allows to add custom attributes (to any object). Their keys must start with the underscore, followed by the namespace (identifying the software adding the attribute or its creator) and another underscore, e. g. `_mrbayes_prob`.

### PhyJSON files

The suffix for PhyJSON files is `.phyjson`.

## Examples

```
{
	"format": "phyjson",
	"version": "1.0",
	"taxa": [
		{"id": 1, "name": "Tarsius syrichta"},
		{"id": 2, "name": "Lemur catta"},
		{"id": 3, "name": "Homo sapiens"},
		{"id": 4, "name": "Pan"},
		{"id": 5, "name": "Gorilla"},
		{"id": 6, "name": "Pongo"},
		{"id": 7, "name": "Hylobates"},
		{"id": 8, "name": "Macaca fuscata"},
		{"id": 9, "name": "M mulatta"},
		{"id": 10, "name": "M fascicularis"},
		{"id": 11, "name": "M sylvanus"},
		{"id": 12, "name": "Saimiri sciureus"}
	]
}
```

```
{
	"format": "phyjson",
	"version": "1.0",
	"characters": [
		{"id": "dna", "type": "dna", "aligned": true},
		{"id": "state", description: "BiSSE state", "type": "standard", symbols: ["0", "1"]},
	],
	"taxa": [
		{"id": 1, "name": "Taxon 1", "characters": {"dna": "cgggtccctctggtgactggct?gatggac", "state": "0"}},
		{"id": 2, "name": "Taxon 2", "characters": {"dna": "ctctctattgatgtcacggcgaatgtcggg", "state": "1"}}
	],
	"trees": [
		{
			"name": "Some tree",
			"rooted": true,
			"root": {
				"branch_length": 0.7,
				"children": [
					{"taxon": 1, "branch_length": 1.2},
					{"taxon": 2, "branch_length": 1.2}
				]
			}
		}
	]
}
```

[1]: https://json.org/