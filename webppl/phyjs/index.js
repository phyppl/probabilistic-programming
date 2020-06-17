/**
  
  Lognormal {stats}	R Documentation
  The Log Normal Distribution
  Description
  Density, distribution function, quantile function and random generation for the log normal distribution whose logarithm has mean equal to meanlog and standard deviation equal to sdlog.
  Details
  The log normal distribution has density
  
f(x) = 1/(√(2 π) σ x) e^-((log x - μ)^2 / (2 σ^2))

where μ and σ are the mean and standard deviation of the logarithm. The mean is E(X) = exp(μ + 1/2 σ^2), the median is med(X) = exp(μ), and the variance Var(X) = exp(2*μ + σ^2)*(exp(σ^2) - 1) and hence the coefficient of variation is sqrt(exp(σ^2) - 1) which is approximately σ when that is small (e.g., σ < 1/2).

*/
var lognormal_logpdf = function ( x, sigma, mu )
{
    var term1 = -( Math.log(x) + Math.log( sigma ) + 0.5 * Math.log( (2 * 3.14159) ) )
    var term2 = -( Math.log(x) - mu)*( Math.log(x) - mu) / ( 2 * (sigma*sigma) )
    
    //	console.log("dlnorm(", x, ", meanlog = ", mu, ", sdlog = ", sigma, ", log = TRUE) = ", (term1 + term2))
    return (term1 + term2)
}


/** Calculate transition probabilities to a new state from the rate
 *  rate matrix
 * 
 * @param Q : rate matrix
 * 
 * @return a matrix encoding the transition probabilities
 * from one state to another
 */
var transition_probabilities = function(Q)
{
    var P = [ [0, 0, 0],
	      [0, 0, 0],
	      [0, 0, 0],
	      [0, 0, 0] ]
    var i
    var j
    for (i = 0; i < 4; i++)
    {
	var j_index = [0, 1, 2, 3]
	j_index.splice(i, 1)
	for (j = 0; j < 3; j++)
	{
	    P[i][j] = - Q[i][j_index[j]]/Q[i][i]
	}
    }
    return P
}


/** Jukes and Cantor 1969 Substitution Model
 *
 * @param mu : overall substitution rate
`* 
 * @return Q : transition matrix according to JC69
 */
var jc69 = function(mu) {
    return [ [ -3/4*mu, mu/4, mu/4, mu/4 ],
	     [ mu/4, -3/4*mu, mu/4, mu/4 ],
	     [ mu/4, mu/4, -3/4*mu, mu/4 ],
	     [ mu/4, mu/4, mu/4, -3/4*mu ] ]
}


/** 
 * Constructor for creating a leaf vertex
 * 
 * Note that index starts with 1 in the trees below
 *
 * @param v - age
 * @param i - index
 * 
 * @return a leaf
 */ 
var leaf = function(v,i)
{
    return {type:'leaf',age:v,index:i}
}


/**
 * Constructor for creating a node vertex
 *
 * @param v - age
 * @param l - left node
 * @param r - right node
 *
 * @return - a node
 */
var node = function(v,l,r)
{
    return {type:'node',left:l,right:r,age:v}
}


/**
 * Example tree of the following form
 *
 *           node(1.0)
 *         /          \  
 *       leaf(0.0,1)  leaf(0.0, 2)
 *
 * Toy tree with two tips (no stalk)
 */
var example_2 = node( 1.0, leaf( 0.0, 1 ), leaf( 0.0, 2 ) )



/**
 * Procedure adds an age property to the tree
 * Contributed by Jan
 *
 */
    
function add_age(node)
{
    var child_age = 0;
    for (child in node.children) {
	add_age(node.children[child]);
	    child_age = node.children[child].age;
    }
    node.age = child_age + node.branch_length;
}



/** 
 * Computes the age of a node by always descending to the left
 * 
 * @param node: Object   A Phylogenetic (sub-)tree
 *
 * @return Number        Tree age
 */
var get_root_age = function(node)
{
    if (is_leaf(node)) {
	return node.branch_length
    } else {
	return node.branch_length + get_root_age(node.children[0])
    }
}




/**
 * Compute Age at End of Branch by Descending to Left
 *
 * We do not add the current branch length to the computation.
 *
 * @param node: Object   A phylogenetic tree
 *
 * @return Number        The age of immediately below the node
 */    
var get_left_age = function(node)
{
    if (is_leaf(node)) {
	return 0
    } else {
	return node.children[0].branch_length + get_left_age(node.children[0])
    }
}


/**
 * Is leaf?
 *
 * @param json_node: Object   A phylgenetic tree
 *
 * @return Boolean
 */
var is_leaf = function(json_node)
{
    return json_node.children.length == 0
}
   

/** 
 * Read a PhyJSON file
 *
 * @param phyjson: String   Stores the path to the PhyJSON file containing a tree
 *
 * @return Object           A phylogenetic tree in the format used by phylomodels
 */
var read_phyjson = function(phyjson)
{
    var fs = require("fs")
    var obj = JSON.parse(fs.readFileSync(phyjson, "utf8"))

    // Need to set the counter to enumerate the leafes
    Counter(0) 
    var root_age = get_left_age(obj.trees[0].root)
    
    /**
     * Recursively constructs a tree node
     * 
     * Assumes all leafs have age 0
     *
     * @param json_node the phyJSON node to convert from
     * 
     * @return a node (tree) or a leaf
     */
    var construct_tree = function(json_node) {
	// Is it a leaf?
	if (is_leaf(json_node)) {
	    return leaf(0, json_node.taxon + 1)
	} else {
	    return node(
		get_left_age(json_node),
		construct_tree(json_node.children[0]),
		construct_tree(json_node.children[1])
	    )
	}
    }
    
    return node(root_age,
		construct_tree(obj.trees[0].root.children[0]),
		construct_tree(obj.trees[0].root.children[1])
	       )
    
}


var Counter = function(start) {
    global_count = start
}

var count = function() {
    global_count = global_count + 1
    return global_count
}


/** Prints a phylogenetic tree */
var print_tree = function(tree) {
    if (tree.type == 'leaf') {
	return("leaf(" + tree.age + "," + count() + ")")
    }
    else {
	return("node(" + tree.age + "," + print_tree(tree.left) + "," + print_tree(tree.right) + ")")
    }
}


/** Counts the number of leaves in a tree */
var count_leaves = function( tree )
{
    if (tree == undefined) return 0
    
    if(  tree.type == 'leaf' )
        return 1

    if ( !tree.right )
        return count_leaves( tree.left )
    else
        return count_leaves( tree.left ) + count_leaves( tree.right )
}


/**
 *  Function to compute log(n!)
 *
 *  @param n
 *  @return log(n!)
 */
var lnFactorial = function( n )
{
    if ( n == 1 )
        return 0.0
    else
        return Math.log(n) + lnFactorial( n - 1 )
}


/* From here on in the source file we enter the trees.
   The naming convention for naming the trees is to give the taxon,
   followed by the  number of tips */
var bisse_32 = node(13.016,node(10.626,node(8.352,node(7.679,node(5.187,leaf(0,7),leaf(0,22)),node(5.196,leaf(0,2),node(4.871,node(2.601,leaf(0,31),leaf(0,14)),leaf(0,26)))),node(7.361,node(3.818,node(1.143,node(0.829,leaf(0,6),leaf(0,9)),leaf(0,16)),node(1.813,node(0.452,node(0.203,leaf(0,15),leaf(0,12)),leaf(0,8)),leaf(0,32))),node(1.868,node(0.866,leaf(0,23),node(0.001,leaf(0,17),leaf(0,24))),node(1.06,leaf(0,18),leaf(0,4))))),node(10.536,node(8.291,node(1.396,node(0.215,leaf(0,10),leaf(0,29)),leaf(0,21)),leaf(0,27)),node(8.192,node(0.56,leaf(0,11),leaf(0,19)),leaf(0,3)))),node(8.958,node(3.748,leaf(0,5),node(0.033,leaf(0,20),leaf(0,1))),node(7.775,node(0.584,leaf(0,28),leaf(0,13)),node(1.589,leaf(0,25),leaf(0,30)))))


var primates_233 = node(65.0917,node(51.8705,node(20.9224,node(8.5207,node(3.64498,leaf(0,102),node(1.44986,leaf(0,99),leaf(0,98))),node(7.32733,node(3.5741,leaf(0,106),leaf(0,105)),node(6.31619,node(5.40351,leaf(0,100),node(2.36434,node(1.46116,leaf(0,104),leaf(0,103)),leaf(0,101))),node(4.24264,leaf(0,167),leaf(0,166))))),node(16.3413,node(4.70363,leaf(0,171),node(1.88177,leaf(0,21),leaf(0,22))),node(9.20057,leaf(0,139),node(2.67248,leaf(0,165),leaf(0,164))))),node(39.4824,leaf(0,91),node(27.5162,node(22.0348,node(17.1722,node(11.1999,leaf(0,135),node(7.6009,leaf(0,137),node(5.02863,leaf(0,136),node(3.00293,leaf(0,133),node(1.36316,node(0.453228,leaf(0,132),leaf(0,134)),leaf(0,131)))))),node(13.0595,node(6.22907,leaf(0,126),node(5.66245,node(5.34291,leaf(0,108),leaf(0,110)),leaf(0,109))),node(11.8927,leaf(0,233),node(6.37658,node(3.07403,leaf(0,97),leaf(0,96)),node(3.75691,leaf(0,93),node(3.68402,leaf(0,95),leaf(0,94))))))),node(13.6168,leaf(0,29),node(7.43524,leaf(0,123),node(5.87983,leaf(0,192),node(1.54142,leaf(0,194),leaf(0,193)))))),node(17.0354,leaf(0,172),node(11.4707,node(7.05337,leaf(0,2),node(4.09979,leaf(0,158),node(2.73742,leaf(0,160),leaf(0,159)))),node(9.40047,leaf(0,83),leaf(0,82))))))),node(62.6001,node(35.1825,node(15.3009,node(0.257424,leaf(0,219),leaf(0,220)),leaf(0,221)),node(8.68355,leaf(0,222),leaf(0,218))),node(51.225,node(30.1522,node(25.3163,node(20.9726,node(11.8807,node(8.12242,node(3.68845,leaf(0,85),leaf(0,84)),node(3.70051,leaf(0,32),leaf(0,31))),node(10.2338,leaf(0,177),node(6.54958,leaf(0,175),node(3.78989,leaf(0,173),node(1.75563,leaf(0,176),leaf(0,174)))))),node(16.4714,leaf(0,45),node(13.303,node(7.32881,leaf(0,40),node(3.08581,node(0.655408,leaf(0,42),leaf(0,43)),leaf(0,37))),node(10.3035,leaf(0,44),node(8.00036,node(4.72442,leaf(0,38),node(1.98277,leaf(0,36),leaf(0,34))),node(5.32729,node(2.35055,leaf(0,39),leaf(0,33)),node(2.32372,leaf(0,41),leaf(0,35)))))))),node(20.6835,node(12.7299,node(0.502263,leaf(0,7),leaf(0,5)),node(6.92635,leaf(0,4),node(4.52731,leaf(0,8),node(2.9471,leaf(0,6),node(1.75869,node(0.793145,leaf(0,10),leaf(0,9)),leaf(0,3)))))),node(11.2865,node(4.69295,node(3.0384,leaf(0,28),node(2.03735,leaf(0,23),node(1.215,leaf(0,26),leaf(0,25)))),node(2.88507,leaf(0,27),leaf(0,24))),node(9.03084,leaf(0,30),node(2.92191,leaf(0,125),leaf(0,124)))))),node(25.6929,node(23.1866,node(7.26239,node(3.96378,leaf(0,59),leaf(0,57)),node(0.141184,leaf(0,58),leaf(0,56))),node(8.42087,leaf(0,212),node(6.82414,leaf(0,216),node(3.94301,leaf(0,214),node(1.76531,leaf(0,215),leaf(0,213)))))),node(22.0289,node(15.7873,node(3.41619,leaf(0,15),leaf(0,13)),node(11.7461,node(4.52272,leaf(0,20),leaf(0,12)),node(8.66891,leaf(0,17),node(6.28987,leaf(0,16),node(4.1643,leaf(0,14),node(2.63152,leaf(0,18),node(1.23779,leaf(0,19),leaf(0,11)))))))),node(18.9876,node(18.377,leaf(0,46),node(11.365,node(3.70601,leaf(0,55),node(2.0792,leaf(0,51),leaf(0,47))),node(11.2002,node(3.43336,leaf(0,49),leaf(0,48)),node(0.510546,node(0.265543,leaf(0,53),leaf(0,50)),node(0.256348,leaf(0,54),leaf(0,52)))))),node(15.6463,node(7.67865,leaf(0,128),node(6.62527,leaf(0,127),node(3.83734,leaf(0,130),leaf(0,129)))),node(12.6827,node(7.8782,node(3.27913,leaf(0,210),leaf(0,202)),node(3.30921,leaf(0,207),leaf(0,200))),node(9.81877,leaf(0,206),node(7.67803,node(4.38689,leaf(0,203),node(1.95379,leaf(0,208),leaf(0,205))),node(5.07992,leaf(0,204),node(3.03886,leaf(0,209),node(1.3832,leaf(0,211),leaf(0,201)))))))))))),node(32.417,node(19.6369,node(15.8446,leaf(0,178),node(6.41449,leaf(0,107),node(5.0674,leaf(0,111),node(1.95369,leaf(0,169),leaf(0,168))))),node(5.87586,node(4.01158,leaf(0,115),node(3.53901,node(3.51683,leaf(0,119),node(3.10084,leaf(0,117),leaf(0,112))),node(2.02926,leaf(0,121),node(0.881927,leaf(0,120),leaf(0,116))))),node(4.01897,leaf(0,122),node(1.80653,leaf(0,114),node(0.788242,leaf(0,118),leaf(0,113)))))),node(18.3368,node(13.6067,node(8.89218,node(8.8866,node(6.92967,node(6.80864,node(5.1224,leaf(0,227),node(3.73466,leaf(0,224),node(2.89694,leaf(0,226),node(0.794848,leaf(0,225),node(0.752118,leaf(0,231),node(0.69434,leaf(0,230),leaf(0,229))))))),leaf(0,217)),node(6.5521,node(3.80739,node(1.89428,leaf(0,184),node(1.58886,node(0.220763,leaf(0,179),leaf(0,181)),node(1.55073,node(0.527182,leaf(0,180),leaf(0,183)),node(0.532444,leaf(0,185),leaf(0,186))))),leaf(0,182)),node(5.19939,leaf(0,228),leaf(0,232)))),node(8.00142,leaf(0,198),node(3.87109,leaf(0,195),node(2.60969,leaf(0,199),node(1.03785,leaf(0,197),leaf(0,196)))))),node(3.48386,leaf(0,163),leaf(0,162))),node(11.9581,node(5.26084,node(3.49501,leaf(0,189),leaf(0,191)),node(4.31325,leaf(0,190),node(1.75508,leaf(0,188),leaf(0,187)))),node(6.03735,leaf(0,90),node(3.49057,leaf(0,87),node(0.805245,leaf(0,89),leaf(0,88)))))),node(11.2546,node(9.24085,node(6.71001,node(5.44218,node(1.96589,leaf(0,157),leaf(0,156)),node(2.3131,leaf(0,62),node(0.503238,leaf(0,60),leaf(0,61)))),node(2.22804,leaf(0,138),node(1.54275,leaf(0,223),leaf(0,170)))),node(7.49111,leaf(0,153),node(6.25647,node(3.58071,node(2.64826,node(0.135277,leaf(0,155),leaf(0,145)),node(1.65329,leaf(0,149),leaf(0,148))),node(2.24477,leaf(0,151),leaf(0,147))),node(4.43266,node(2.801,leaf(0,140),node(1.70814,node(0.716125,leaf(0,150),leaf(0,141)),node(1.05538,leaf(0,154),leaf(0,152)))),node(2.2296,leaf(0,143),node(0.912748,leaf(0,144),node(0.269011,leaf(0,146),leaf(0,142)))))))),node(8.28299,leaf(0,1),node(6.74964,leaf(0,161),node(5.7251,node(5.18071,leaf(0,92),leaf(0,86)),node(4.91227,node(0.841441,leaf(0,80),node(0.00861709,leaf(0,78),leaf(0,71))),node(4.21532,leaf(0,70),node(3.63333,node(2.55883,leaf(0,74),node(1.24026,node(0.786479,leaf(0,73),leaf(0,64)),node(0.778254,leaf(0,81),leaf(0,77)))),node(2.95357,node(2.32297,node(1.70858,node(1.0323,node(0.50272,leaf(0,69),leaf(0,79)),node(0.488649,leaf(0,65),leaf(0,63))),node(0.753017,leaf(0,76),leaf(0,68))),node(0.954775,leaf(0,75),leaf(0,72))),node(1.23446,leaf(0,67),leaf(0,66)))))))))))))))


var primates_61 = node(0.106195,leaf(0,1),node(0.101094,node(0.0958959,node(0.0905502,leaf(0,2),node(0.0586295,node(0.0401652,node(0.0379268,leaf(0,3),node(0.0332042,leaf(0,4),node(0.0301782,leaf(0,5),leaf(0,6)))),node(0.0392226,node(0.0346577,leaf(0,7),node(0.0327925,leaf(0,8),node(0.032125,leaf(0,9),leaf(0,10)))),node(0.0365468,node(0.0303611,leaf(0,11),node(0.0295462,leaf(0,12),node(0.026754,leaf(0,13),leaf(0,14)))),node(0.0361695,leaf(0,15),node(0.0342505,leaf(0,16),leaf(0,17)))))),node(0.0512462,node(0.0474721,node(0.0411942,leaf(0,18),node(0.0408786,leaf(0,19),leaf(0,20))),node(0.0460226,leaf(0,21),node(0.042394,leaf(0,22),node(0.0418415,leaf(0,23),leaf(0,24))))),node(0.0427258,node(0.0399164,node(0.0381464,leaf(0,25),node(0.0377291,node(0.0363782,leaf(0,26),leaf(0,27)),node(0.0371656,leaf(0,28),leaf(0,29)))),node(0.038921,node(0.0378658,leaf(0,30),leaf(0,31)),node(0.0388686,leaf(0,32),node(0.0379197,leaf(0,33),leaf(0,34))))),node(0.0404512,node(0.0392285,leaf(0,35),leaf(0,36)),node(0.0394287,leaf(0,37),node(0.0392993,node(0.0366504,leaf(0,38),leaf(0,39)),node(0.0386101,leaf(0,40),node(0.0384165,leaf(0,41),leaf(0,42)))))))))),node(0.0827704,node(0.0783974,leaf(0,43),node(0.0659509,node(0.0597016,leaf(0,44),node(0.0559496,leaf(0,45),node(0.0449837,leaf(0,46),leaf(0,47)))),node(0.0647547,node(0.0516022,leaf(0,48),leaf(0,49)),node(0.0612976,leaf(0,50),node(0.0571017,leaf(0,51),node(0.0465375,leaf(0,52),leaf(0,53))))))),node(0.0319856,node(0.0293809,node(0.014042,leaf(0,54),leaf(0,55)),node(0.0203923,leaf(0,56),leaf(0,57))),node(0.013504,leaf(0,58),leaf(0,59))))),node(0.0480665,leaf(0,60),leaf(0,61))))


// TODO this tree is probably stalked?
var cetaceans_87 = node(40,node(35.4248,node(27.8341,node(8.57687,leaf((0,1)),node(1.27866,leaf((0,2)),node(0.188389,leaf((0,3)),leaf((0,4))))),node(25.8432,leaf((0,5)),node(18.0947,leaf((0,6)),node(16.169,node(15.2139,node(5.36058,leaf((0,7)),leaf((0,8))),node(10.6031,leaf((0,9)),leaf((0,10)))),node(12.9642,leaf((0,11)),node(11.4896,leaf((0,12)),node(5.34343,leaf((0,13)),node(4.38115,leaf((0,14)),leaf((0,15)))))))))),node(33.4157,node(22.167,leaf((0,16)),node(8.85313,leaf((0,17)),leaf((0,18)))),node(32.3769,node(0.335479,leaf((0,19)),leaf((0,20))),node(31.7146,node(19.0147,leaf((0,21)),node(17.8581,node(6.34314,leaf((0,22)),leaf((0,23))),node(15.5499,leaf((0,24)),node(14.393,node(11.0056,leaf((0,25)),node(8.05967,leaf((0,26)),leaf((0,27)))),node(12.9165,leaf((0,28)),node(11.0576,leaf((0,29)),node(8.94251,leaf((0,30)),node(8.23509,leaf((0,31)),node(7.71938,leaf((0,32)),node(7.20224,node(4.77541,leaf((0,33)),node(4.19742,leaf((0,34)),leaf((0,35)))),node(6.36511,leaf((0,36)),node(5.78569,node(4.89284,leaf((0,37)),leaf((0,38))),node(5.07855,leaf((0,39)),node(4.11628,leaf((0,40)),leaf((0,41)))))))))))))))),node(25.7272,node(24.3338,leaf((0,42)),node(18.2519,leaf((0,43)),leaf((0,44)))),node(17.5865,node(13.6965,node(5.12629,leaf((0,45)),leaf((0,46))),node(5.30772,node(4.60801,leaf((0,47)),node(3.71002,leaf((0,48)),leaf((0,49)))),node(4.66373,leaf((0,50)),node(3.38146,leaf((0,51)),leaf((0,52)))))),node(10.5348,leaf((0,53)),node(9.37282,node(8.1714,leaf((0,54)),node(5.99285,leaf((0,55)),node(5.41429,leaf((0,56)),node(4.38744,leaf((0,57)),node(2.97717,leaf((0,58)),node(1.4389,leaf((0,59)),leaf((0,60)))))))),node(8.65426,leaf((0,61)),node(8.06569,node(6.86684,leaf((0,62)),node(5.19829,node(1.29976,leaf((0,63)),leaf((0,64))),node(4.48887,node(3.21317,leaf((0,65)),node(1.73918,leaf((0,66)),leaf((0,67)))),node(3.71631,leaf((0,68)),node(2.81775,leaf((0,69)),node(1.98318,leaf((0,70)),node(1.46919,leaf((0,71)),leaf((0,72))))))))),node(7.40827,node(5.81486,leaf((0,73)),node(3.06089,leaf((0,74)),leaf((0,75)))),node(4.26573,node(3.31117,leaf((0,76)),leaf((0,77))),node(3.49202,node(2.92089,leaf((0,78)),node(2.0869,leaf((0,79)),leaf((0,80)))),node(2.71917,leaf((0,81)),node(1.81976,leaf((0,82)),node(1.36833,node(0.859479,leaf((0,83)),leaf((0,84))),node(1.10919,leaf((0,85)),node(0.786909,leaf((0,86)),leaf((0,87)))))))))))))))))))))




/* Here are the trees exported:
   
   example_2:       Toy tree with two tips (2 tips, without stalk)
   unknown_32:      Bisse32 tree of unknown origin (32 tips, without stalk), alternative tree
   bisse_32:        Bisse32 tree of unknown origin (32 tips, without stalk)
   primates_233:    primate tree (diversitree example) (233 tips, without stalk)
   primates_61:     primate tree from Mesquite (61 tips, without stalk) 
*/

const MAX_DIV = 5
const MAX_LAMBDA = 5
const MIN_T   = 1e-5


module.exports = {
    leaf: leaf,
    node: node,
    read_phyjson: read_phyjson,
    print_tree: print_tree,
    jc69: jc69,
    transition_probabilities: transition_probabilities,
    countLeaves: count_leaves,
    lnFactorial: lnFactorial,
    lognormal_logpdf: lognormal_logpdf,

    example_2: example_2,
    bisse_32: bisse_32,
    primates_233: primates_233,
    primates_61: primates_61,
    cetaceans_87: cetaceans_87,

    MAX_DIV : MAX_DIV,
    MAX_LAMBDA : MAX_LAMBDA,
    MIN_T : MIN_T,

    Counter: Counter,
    count: count
}














