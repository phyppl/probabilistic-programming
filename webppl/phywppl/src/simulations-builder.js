var log = console.log.bind(console)
var path = require('path')
var fs = require('fs')
var shell = require('shelljs')
var default_trials = 12

/**
 * Expands an array in the simulation recipe given by key
 *
 * { "alpha" : [0.1, 0.2] }
 * 
 * =>
 *
 * [ { "alpha" : 0.1 }, { "alpha": 0.2 } ]
 *
 * @param sim   a simulation a object
 * @param key   the key in the simulation object to expand
 * @return      an array of simulation objects
 */
const expand_parameter = function(sim, key)
{
    return sim.parameters[key].map(
	function(item, index)
	{
	    // item is a single value of a parameter
	    // the next line copies a simple JS object
	    var expanded_sim = JSON.parse(JSON.stringify(sim))
	    expanded_sim.parameters[key] = item
	    return expanded_sim
	}
    )
}


const expand_hyper_parameter = function(sim, key)
{
    return sim.hyper_parameters[key].map(
	function(item, index)
	{
	    // item is a single value of a parameter
	    // the next line copies a simple JS object
	    var expanded_sim = JSON.parse(JSON.stringify(sim))
	    expanded_sim.hyper_parameters[key] = item
	    return expanded_sim
	}
    )
}



/**
 * Expand simulation
 * 
 * @param sim   an unexpanded simulation object
 * @return      an array of simulation objects where all parameters have been expanded
 */
const expand_sim = function(sim)
{
    let keys = Object.keys(sim.parameters)
    let hyper_keys = Object.keys(sim.hyper_parameters)
    if (get_one_unexpanded_parameter_key(sim, keys) == false && get_one_unexpanded_hyper_parameter_key(sim, hyper_keys) == false) {
	return sim
    }
    else {
	if (get_one_unexpanded_parameter_key(sim, keys) != false) {
	    let key = get_one_unexpanded_parameter_key(sim, keys)
	    let expansion = expand_parameter(sim, key)
	    let ret = expansion.map(expand_sim)
	    if (Array.isArray(ret[0])) {
		//potentially we need to flatten here
		let flat = [].concat.apply([], ret)
		return flat
	    } else return ret // probably never happens :)
	}
	else {
	    let key = get_one_unexpanded_hyper_parameter_key(sim, hyper_keys)
	    let expansion = expand_hyper_parameter(sim, key)
	    let ret = expansion.map(expand_sim)
	    if (Array.isArray(ret[0])) {
		//potentially we need to flatten here
		let flat = [].concat.apply([], ret)
		return flat
	    } else return ret // probably never happens :)
	}
    }
}



/**
 * Get one exexpanded parameter key
 *
 * @param sim   a simulation object
 * @param keys  an array of keys to check
 * @return      an key of a parameter that is not expanded yet, or false if all parameters have been
                expanded
*/
const get_one_unexpanded_parameter_key = function(sim, keys)
{
    if (keys.length == 0) { // no more keys to check
	return false
    }
    else {
	if (Array.isArray(sim.parameters[keys[0]])) {
	    return keys[0]
	} else return get_one_unexpanded_parameter_key(sim, keys.slice(1, keys.length))
    }
}


const get_one_unexpanded_hyper_parameter_key = function(sim, keys)
{
    if (keys.length == 0) { // no more keys to check
	return false
    }
    else {
	if (Array.isArray(sim.hyper_parameters[keys[0]])) {
	    return keys[0]
	} else return get_one_unexpanded_hyper_parameter_key(sim, keys.slice(1, keys.length))
    }
}



/** 
 * Processes a JS Object (Associative Array) to a JS Variable Declaration String
 * 
 * { "toy" : "phyjs.example" }
 *
 * =>
 * 
 * [ "var toy = phyjs.example" ]
 * 
 * @param  v     JS object
 * @return       array of strings
 */
var to_variable_declaration = function(v) {
    let N = Object.keys(v).length
    return [ new Array(N).fill("var "),
	     Object.keys(v),
	     new Array(N).fill(" = "),
	     Object.values(v) ].reduce(
	function(x, y) {
	    return x.map(
		function(item, index) {
		    return x[index].concat(y[index])
		}
	    )
	})
}


/**
 * Stringify simulation
 * 
 * @param sim    a simulation object
 * @return       a probabilistic program
 */
const stringify_simulation = function(sim)
{
    // particles handled as parameters
    // handle parameters
    var program = "".concat(to_variable_declaration(sim.hyper_parameters).reduce(	(x, y) => x.concat("\n\t").concat(y) )).concat(	"\nvar model = function()\n{\n\t").
	concat(to_variable_declaration(sim.parameters).reduce(	(x, y) => x.concat("\n\t").concat(y) )).
	concat("\n\t").
	concat(sim.model).
	concat("\n}\n")
	
    // Do we have inference or not
    if (sim.inference.method == false) {
	// if not, just run the model plain
	program = program.concat("model()")
    }
    else {

	// we build the infrence
	program = program.concat("var dist = Infer({method: '").
	    concat(sim.inference.method).
	    concat("', particles: particles").concat(", model: model})")
	
	// what do we want likelihood or model params
	if (sim.inference.likelihood) {
	    program = program.concat("\ndist.normalizationConstant")
	}
	else {
	    program = program.concat("\nJSON.stringify(dist.samples)")
	}	
    }
    return program
}

// 1. Read simulation from JSON
// process.argv[3] is the simulation
// let sim_path = path.resolve(process.argv[3])
let sim_path = process.argv[3]
fs.chmodSync(sim_path, "444") // read-only

// how many iterations
// the number of trials is at position in the process arguments vector
const ntrails = function(position) {
    if (process.argv.length < position + 1) return default_trials
    else return process.argv[position]
}
let trials = ntrails(4)

// 2. expand the simulation

let sim_template = JSON.parse(fs.readFileSync(sim_path))
var sim = expand_sim(sim_template)

// 3. we want to stringify all simulations given back by expand_sim
// this has a side-effect on sim
sim.map(
    function(s, index)
    {
	s.ppl  = stringify_simulation(s)
	s.label = s.label.concat("-").concat(index + 1)
    }
)

// 4. we then want to serialize them to disk in a subfolder of the folder where the simulation is read from



let sim_results = path.join(path.dirname(sim_path), sim_template.label.concat("-results.JSON"))

sim_dir = path.join(path.dirname(sim_path), sim_template.label)

if (!fs.existsSync(sim_dir)) {
    fs.mkdirSync(sim_dir);
}
else {
    console.log("Found an existing simulation. Archiving and removing...")
    let curdate = new Date()
    let datestring = curdate.getFullYear().toString().concat("-").concat(curdate.getMonth().toString()).concat("-").concat(curdate.getDate().toString()).concat("-").concat(curdate.getHours().toString()).concat("-").concat(curdate.getMinutes().toString())
    let zip_command = "zip -r ".concat(
	path.join(path.dirname(sim_path), sim_template.label.concat("-").concat(datestring).concat(".zip "))).concat(sim_dir).concat(" ").concat(sim_results)
    shell.exec(zip_command)
    shell.exec("rm -rf ".concat(sim_dir))
    fs.mkdirSync(sim_dir)
}

sim.map(
    function(s, index)
    {
	let filename = path.join(sim_dir, s.label).concat(".wppl")
	sim[index].command = "npm run wppl ".concat(filename).concat(" ").concat(trials)
	//output to disk s.ppl
	fs.writeFileSync(filename, s.ppl,
		    (err) => {
			if (err) throw err;
			console.log("Error while writing file!")
		    })
    }
)

// 5. then we want to run them with npm run wppl and capture the results, together with the simulations as JSON



var i = 0
while (i < sim.length) {
    log("Running simulation ", sim[i].command)

    sim[i].output = shell.exec(sim[i].command).stdout
    
    i++
}


// 6. then we want to serialize the JSON into this folder
// null 2 incantation means pretty print

fs.writeFileSync(sim_results,   JSON.stringify(sim, null, 2))


// 7. We want to archive everything, erase everything and unlock the simulation

let curdate = new Date()
let datestring = curdate.getFullYear().toString().concat("-").concat(curdate.getMonth().toString()).concat("-").concat(curdate.getDate().toString()).concat("-").concat(curdate.getHours().toString()).concat("-").concat(curdate.getMinutes().toString())
let zip_command = "zip -r ".concat(
    path.join(path.dirname(sim_path), sim_template.label.concat("-").concat(datestring).concat(".zip "))).concat(sim_dir).concat(" ").concat(sim_results).concat(" ").concat(sim_path)
shell.exec(zip_command)
shell.exec("rm -rf ".concat(sim_dir))

fs.chmodSync(sim_path, "644") // unlock the simulation
