open Ast
module Int = struct
	type t = int
	let compare = compare
end
module IntSet = Set.Make (Int)

type label =
| Chr of char
| Eps

type nfa = {
	states: int; (* all states will be 0, 1, ..., states-1 *)
	graph: (int*label, IntSet.t) Hashtbl.t;
	start: int;
	accept: IntSet.t
}

let addTransition hashtbl (i: int) (c: label) (target: int) : unit =
(*if (i,c) is already in the hashtbl, then its value must be changed.
if it is not already in the hashtbl, then it must be added.*)
match Hashtbl.find_opt hashtbl (i,c) with
| None -> Hashtbl.add hashtbl (i,c) @@ IntSet.singleton target
| Some set -> Hashtbl.replace hashtbl (i,c) @@ IntSet.add target set

let rec nfa_of_regexpr r = match r with
| Epsilon -> {
	states = 1;
	graph = Hashtbl.create 128;
	start = 0;
	accept = IntSet.singleton 0;
	}
| String s -> 
	(*
	  s0   s1   s2 ... s(n-1)
	0 -> 1 -> 2 -> ... -> n
	*)
	let hashtbl = Hashtbl.create 128 in
	let len = String.length s in
	String.iteri (fun i c ->
		(*add (i,c) -> singleton i+1  to hashtbl *)
		(*don't have to use addTransition here because the hashtbl starts off empty*)
		Hashtbl.add hashtbl (i,Chr c) (IntSet.singleton (i+1));
	) s;
	{
		states = len + 1;
		graph = hashtbl;
		start = 0;
		accept = IntSet.singleton len;
	}
| Union(r1,r2) ->
	(*TODO: 0 doesn't have to be the start state, can just add nfa2.graph to nfa1.graph,
	make nfa1.states+nfa2.states the new starting state*)
	let nfa1, nfa2 = nfa_of_regexpr r1, nfa_of_regexpr r2 in
	(*make a new hashtbl, add all edges from nfa1 incremented by 1,
	and all edges from nfa2 incremented by nfa1.states+1*)
	let newHashtbl = Hashtbl.create 128 in
	Hashtbl.iter (fun (state, chr) adjSet ->
		Hashtbl.add newHashtbl (state+1,chr) @@ IntSet.map ((+) 1) adjSet;
	) nfa1.graph;
	Hashtbl.iter (fun (state, chr) adjSet ->
		Hashtbl.add newHashtbl (state+1+nfa1.states, chr) @@ IntSet.map (fun n -> n + 1 + nfa1.states) adjSet;
	) nfa2.graph;
	(*0 will be the new start state with epsilon-transitions to the start state of nfa1.graph and nfa2.graph*)
	Hashtbl.add newHashtbl (0, Eps) @@ IntSet.of_list [nfa1.start+1; nfa2.start+1+nfa1.states];
	{
		states = nfa1.states + nfa2.states + 1;
		graph = newHashtbl;
		start = 0;
		accept = IntSet.union (IntSet.map ((+) 1) nfa1.accept) (IntSet.map (fun n -> n + 1 + nfa1.states) nfa2.accept);
	}
| Concat(r1, r2) ->
	let nfa1, nfa2 = nfa_of_regexpr r1, nfa_of_regexpr r2 in
	(*change nfa1.graph in place, adding eps-transitions from each state in nfa1.accept to nfa2.start
	then add all of nfa2.graph incremented by nfa1.states to nfa1.graph
	*)
	IntSet.iter (fun i ->
		Hashtbl.add nfa1.graph (i, Eps) @@ IntSet.singleton @@ nfa2.start + nfa1.states;
	) nfa1.accept;
	Hashtbl.iter (fun (state, chr) adjSet ->
		Hashtbl.add nfa1.graph (state+nfa1.states, chr) @@ IntSet.map ((+) nfa1.states) adjSet;
	) nfa2.graph;
	{
		states = nfa1.states + nfa2.states;
		graph = nfa1.graph;
		start = nfa1.start;
		accept = IntSet.map ((+) nfa1.states) nfa2.accept;
	}
| Star r1 ->
	let nfa1 = nfa_of_regexpr r1 in
	(*make a new start state, nfa1.states.
	make an eps-transition from this state to the old start state
	make an eps-transition from all accept states to the old start state
	*)
	Hashtbl.add nfa1.graph (nfa1.states, Eps) @@ IntSet.singleton nfa1.start;
	IntSet.iter (fun i ->
		addTransition nfa1.graph i Eps nfa1.start;
	) nfa1.accept;
	{
		states = nfa1.states + 1;
		graph = nfa1.graph;
		start = nfa1.states;
		accept = IntSet.union nfa1.accept @@ IntSet.singleton nfa1.states;
	}

let dot_of_nfa nfa = 
	(*
	digraph {
		node [shape = doublecircle]; $ACCEPT_STATES;
		node [shape = circle];
		0 -> 7 [label = "$(chr)"];
		...
	}
	*)
	let string_of_label : label -> string = function
		| Eps -> "epsilon"
		| Chr c -> String.make 1 c
	in
	let edgeStr (i: int) (c: label) (target: int) : string =
		Printf.sprintf "\t%d -> %d [label=\"%s\"];\n" i target @@ string_of_label c
	in
	let edges_str (i: int) (c: label) (set: IntSet.t) : string =
		IntSet.elements set |> List.map (edgeStr i c) |> String.concat ""
	in
	let acceptNodePrefix = IntSet.elements nfa.accept
		|> List.map string_of_int
		|> String.concat " "
		|> Printf.sprintf "\tnode [shape = doublecircle]; %s;\n"
	in
	let edges = Hashtbl.fold (fun (i,lbl) set str ->
		(edges_str i lbl set) ^ str
	) nfa.graph "" in
"digraph {
	size=\"8,5\"
"^acceptNodePrefix
^"	node [shape = circle];\n"
^edges
^"	node [style=invis, fixedsize=true, shape=\"\", height=0, width=0]; start;\n"
^"	start -> " ^ string_of_int nfa.start ^ "\n"
^"}"

let lex s = Lexing.from_string s |> Lexer.read
let parse s = Lexing.from_string s |> Parser.handleEOF Lexer.read
