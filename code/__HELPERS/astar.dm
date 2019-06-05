/*
A Star pathfinding algorithm
Returns a list of tiles forming a path from A to B, taking dense objects as well as walls, and the orientation of
windows along the route into account.
Use:
your_list = AStar(start location, end location, adjacent proc, distance proc, max nodes, maximum node depth, minimum distance to target, atom id, turfs to exclude)

Optional extras to add on:
Distance proc : the distance used in every A* calculation (length of path and heuristic)
MaxNodes: The maximum number of nodes the returned path can be (0 = infinite)
Maxnodedepth: The maximum number of nodes to search (default: 30, 0 = infinite)
Mintargetdist: Minimum distance to the target before path returns, could be used to get
near a target, but not right to it - for an AI mob with a gun, for example.
Adjacent proc : returns the turfs to consider around the actually processed node

Also added 'exclude' turf to avoid travelling over; defaults to null

*/
#define PF_TIEBREAKER 0.005
//tiebreker weight.To help to choose between equal paths
//////////////////////
//datum/PathNode object
//////////////////////
#define MASK_ODD 85
#define MASK_EVEN 170


//A* nodes variables
/datum/PathNode
	var/turf/source //turf associated with the PathNode
	var/datum/PathNode/prevNode //link to the parent PathNode
	var/f		//A* Node weight (f = g + h)
	var/g		//A* movement cost variable
	var/h		//A* heuristic variable
	var/nt		//count the number of Nodes traversed
	var/bf		//bitflag for dir to expand.Some sufficiently advanced motherfuckery


/datum/PathNode/New(s,p,pg,ph,pnt,_bf)
	source = s
	prevNode = p
	g = pg
	h = ph
	f = g + h * (1 + PF_TIEBREAKER)
	nt = pnt
	bf = _bf


/datum/PathNode/proc/setp(p, pg, ph, pnt)
	prevNode = p
	g = pg
	h = ph
	f = g + h * (1 + PF_TIEBREAKER)
	nt = pnt


//the weighting function, used in the A* algorithm
/proc/PathWeightCompare(datum/PathNode/a, datum/PathNode/b)
	return a.f - b.f


//reversed so that the Heap is a MinHeap rather than a MaxHeap
/proc/HeapPathWeightCompare(datum/PathNode/a, datum/PathNode/b)
	return b.f - a.f


/proc/AStar(caller, _end, adjacent = /turf/proc/reachableTurftest, dist, maxnodes, maxnodedepth = 30, mintargetdist, id, turf/exclude)
	var/turf/end = get_turf(_end)
	var/turf/start = get_turf(caller)
	if(!start || !end)
		stack_trace("Invalid A* start or destination")
		return FALSE
	if(start.z != end.z || start == end) //no pathfinding between z levels
		return FALSE
	if(maxnodes)
		//if start turf is farther than maxnodes from end turf, no need to do anything
		if(call(start, dist)(end) > maxnodes)
			return FALSE
		maxnodedepth = maxnodes //no need to consider path longer than maxnodes
	var/datum/Heap/open = new /datum/Heap(/proc/HeapPathWeightCompare) //the open list
	var/list/openc = new() //open list for node check
	var/list/path = null //the returned path, if any
	//initialization
	var/datum/PathNode/cur = new /datum/PathNode(start, null, 0, call(start, dist)(end), 0, 15, 1)//current processed turf
	open.Insert(cur)
	openc[start] = cur
	//then run the main loop
	while(!open.IsEmpty() && !path)
		cur = open.Pop() //get the lower f turf in the open list
		//get the lower f node on the open list
		//if we only want to get near the target, check if we're close enough
		var/closeenough
		if(mintargetdist)
			closeenough = call(cur.source, dist)(end) <= mintargetdist

		//found the target turf (or close enough), let's create the path to it
		if(cur.source == end || closeenough)
			path = new()
			path.Add(cur.source)
			while(cur.prevNode)
				cur = cur.prevNode
				path.Add(cur.source)
			break
		//get adjacents turfs using the adjacent proc, checking for access with id
		if(!maxnodedepth || cur.nt <= maxnodedepth)//if too many steps, don't process that path
			for(var/i in 0 to 3)
				var/f = 1 << i //get cardinal directions.1,2,4,8
				if(cur.bf & f)
					var/T = get_step(cur.source,f)
					if(T != exclude)
						var/datum/PathNode/CN = openc[T]  //current checking turf
						var/r = ((f & MASK_ODD) << 1) | ((f & MASK_EVEN) >> 1) //getting reverse direction throught swapping even and odd bits.((f & 01010101)<<1)|((f & 10101010)>>1)
						var/newg = cur.g + call(cur.source,dist)(T)
						if(CN)
						//is already in open list, check if it's a better way from the current turf
							CN.bf &= 15^r //we have no closed, so just cut off exceed dir.00001111 ^ reverse_dir.We don't need to expand to checked turf.
							if(newg < CN.g)
								if(call(cur.source,adjacent)(caller, T, id))
									CN.setp(cur, newg, CN.h, cur.nt + 1)
									open.ReSort(CN)//reorder the changed element in the list
						else
						//is not already in open list, so add it
							if(call(cur.source,adjacent)(caller, T, id))
								CN = new(T, cur, newg, call(T, dist)(end),cur.nt + 1, 15 ^ r)
								open.Insert(CN)
								openc[T] = CN
		cur.bf = 0
		CHECK_TICK
	//reverse the path to get it from start to finish
	if(path)
		for(var/i in 1 to round(0.5 * length(path)))
			path.Swap(i, length(path) - i + 1)
	openc = null
	//cleaning after us
	return path


/turf/proc/reachableTurftest(caller, turf/T, ID)
	if(T && !T.density && !(SSpathfinder.space_type_cache[T.type]) && !LinkBlockedWithAccess(T, caller, ID))
		return TRUE


/datum/Heap
	var/list/L
	var/cmp


/datum/Heap/New(compare)
	L = new()
	cmp = compare


/datum/Heap/proc/IsEmpty()
	return !length(L)


//Insert and place at its position a new node in the heap
/datum/Heap/proc/Insert(atom/A)
	L.Add(A)
	Swim(length(L))


//removes and returns the first element of the heap
//(i.e the max or the min dependant on the comparison function)
/datum/Heap/proc/Pop()
	if(!length(L))
		return 0
	. = L[1]

	L[1] = L[length(L)]
	L.Cut(length(L))
	if(length(L))
		Sink(1)


//Get a node up to its right position in the heap
/datum/Heap/proc/Swim(index)
	var/parent = round(index * 0.5)

	while(parent > 0 && (call(cmp)(L[index], L[parent]) > 0))
		L.Swap(index,parent)
		index = parent
		parent = round(index * 0.5)


//Get a node down to its right position in the heap
/datum/Heap/proc/Sink(index)
	var/g_child = GetGreaterChild(index)

	while(g_child > 0 && (call(cmp)(L[index], L[g_child]) < 0))
		L.Swap(index,g_child)
		index = g_child
		g_child = GetGreaterChild(index)


//Returns the greater (relative to the comparison proc) of a node children
//or 0 if there's no child
/datum/Heap/proc/GetGreaterChild(index)
	if(index * 2 > length(L))
		return 0

	if(index * 2 + 1 > length(L))
		return index * 2

	if(call(cmp)(L[index * 2], L[index * 2 + 1]) < 0)
		return index * 2 + 1
	else
		return index * 2


//Replaces a given node so it verify the heap condition
/datum/Heap/proc/ReSort(atom/A)
	var/index = L.Find(A)

	Swim(index)
	Sink(index)


/datum/Heap/proc/List()
	. = L.Copy()
