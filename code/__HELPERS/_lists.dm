#define LAZYINITLIST(L) if (!L) L = list()
#define UNSETEMPTY(L) if (L && !length(L)) L = null
#define LAZYREMOVE(L, I) if(L) { L -= I; if(!length(L)) { L = null; } }
#define LAZYADD(L, I) if(!L) { L = list(); } L += I;
#define LAZYDISTINCTADD(L, I) if(!L) { L = list(); } L |= I;
#define LAZYOR(L, I) if(!L) { L = list(); } L |= I;
#define LAZYFIND(L, V) L ? L.Find(V) : 0
#define LAZYACCESS(L, I) (L ? (isnum(I) ? (I > 0 && I <= length(L) ? L[I] : null) : L[I]) : null)
#define LAZYSET(L, K, V) if(!L) { L = list(); } L[K] = V;
#define LAZYLEN(L) length(L)
#define LAZYCLEARLIST(L) if(L) L.Cut()
#define SANITIZE_LIST(L) ( islist(L) ? L : list() )
#define reverseList(L) reverseRange(L.Copy())
#define LAZYADDASSOCSIMPLE(L, K, V) if(!L) { L = list(); } L[K] += V;
#define LAZYADDASSOC(L, K, V) if(!L) { L = list(); } L[K] += list(V);
///This is used to add onto lazy assoc list when the value you're adding is a /list/. This one has extra safety over lazyaddassoc because the value could be null (and thus cant be used to += objects)
#define LAZYADDASSOCLIST(L, K, V) if(!L) { L = list(); } L[K] += list(V);
#define LAZYREMOVEASSOC(L, K, V) if(L) { if(L[K]) { L[K] -= V; if(!length(L[K])) L -= K; } if(!length(L)) L = null; }
#define LAZYACCESSASSOC(L, I, K) L ? L[I] ? L[I][K] ? L[I][K] : null : null : null
#define LAZYINCREMENT(L, K) if(!L) { L = list(); } L[K]++;
#define LAZYDECREMENT(L, K) if(L) { if(L[K]) { L[K]--; if(!L[K]) L -= K; } if(!length(L)) L = null; }
/// Performs an insertion on the given lazy list with the given key and value. If the value already exists, a new one will not be made.
#define LAZYORASSOCLIST(lazy_list, key, value) \
	LAZYINITLIST(lazy_list); \
	LAZYINITLIST(lazy_list[key]); \
	lazy_list[key] |= value;

//Checks for specific types in specifically structured (Assoc "type" = TRUE) lists ('typecaches')
#define is_type_in_typecache(A, L) (A && length(L) && L[(ispath(A) ? A : A:type)])

/// Passed into BINARY_INSERT to compare keys
#define COMPARE_KEY __BIN_LIST[__BIN_MID]
/// Passed into BINARY_INSERT to compare values
#define COMPARE_VALUE __BIN_LIST[__BIN_LIST[__BIN_MID]]

/****
	* Binary search sorted insert
	* INPUT: Object to be inserted
	* LIST: List to insert object into
	* TYPECONT: The typepath of the contents of the list
	* COMPARE: The object to compare against, usualy the same as INPUT
	* COMPARISON: The variable on the objects to compare
	* COMPTYPE: How should the values be compared? Either COMPARE_KEY or COMPARE_VALUE.
	*/
#define BINARY_INSERT(INPUT, LIST, TYPECONT, COMPARE, COMPARISON, COMPTYPE) \
	do {\
		var/list/__BIN_LIST = LIST;\
		var/__BIN_CTTL = length(__BIN_LIST);\
		if(!__BIN_CTTL) {\
			__BIN_LIST += INPUT;\
		} else {\
			var/__BIN_LEFT = 1;\
			var/__BIN_RIGHT = __BIN_CTTL;\
			var/__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			var ##TYPECONT/__BIN_ITEM;\
			while(__BIN_LEFT < __BIN_RIGHT) {\
				__BIN_ITEM = COMPTYPE;\
				if(__BIN_ITEM.##COMPARISON <= COMPARE.##COMPARISON) {\
					__BIN_LEFT = __BIN_MID + 1;\
				} else {\
					__BIN_RIGHT = __BIN_MID;\
				};\
				__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
			};\
			__BIN_ITEM = COMPTYPE;\
			__BIN_MID = __BIN_ITEM.##COMPARISON > COMPARE.##COMPARISON ? __BIN_MID : __BIN_MID + 1;\
			__BIN_LIST.Insert(__BIN_MID, INPUT);\
		};\
	} while(FALSE)

// binary search sorted insert
// IN: Object to be inserted
// LIST: List to insert object into
#define BINARY_INSERT_NUM(IN, LIST) \
	var/__BIN_CTTL = length(LIST);\
	if(!__BIN_CTTL) {\
		LIST += IN;\
	} else {\
		var/__BIN_LEFT = 1;\
		var/__BIN_RIGHT = __BIN_CTTL;\
		var/__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
		var/__BIN_ITEM;\
		while(__BIN_LEFT < __BIN_RIGHT) {\
			__BIN_ITEM = LIST[__BIN_MID];\
			if(__BIN_ITEM <= IN) {\
				__BIN_LEFT = __BIN_MID + 1;\
			} else {\
				__BIN_RIGHT = __BIN_MID;\
			};\
			__BIN_MID = (__BIN_LEFT + __BIN_RIGHT) >> 1;\
		};\
		__BIN_ITEM = LIST[__BIN_MID];\
		__BIN_MID = __BIN_ITEM > IN ? __BIN_MID : __BIN_MID + 1;\
		LIST.Insert(__BIN_MID, IN);\
	}

//Returns a list in plain english as a string
/proc/english_list(list/L, nothing_text = "nothing", and_text = " and ", comma_text = ", ", final_comma_text = "" )
	var/total = length(L)
	if(!total)
		return "[nothing_text]"
	else if(total == 1)
		return "[L[1]]"
	else if(total == 2)
		return "[L[1]][and_text][L[2]]"
	else
		var/output = ""
		var/index = 1
		while(index < total)
			if(index == total - 1)
				comma_text = final_comma_text

			output += "[L[index]][comma_text]"
			index++

		return "[output][and_text][L[index]]"


//Returns list element or null. Should prevent "index out of bounds" error.
/proc/listgetindex(list/L, index)
	if(!istype(L))
		return

	if(isnum(index) && ISINTEGER(index) && ISINRANGE(index, 1, length(L)))
		return L[index]

	else if(index in L)
		return L[index]


//Return either pick(list) or null if list is not of type /list or is empty
#define SAFEPICK(L) (length(L) ? pick(L) : null)


//Checks if the list is empty
/proc/isemptylist(list/L)
	if(!length(L))
		return TRUE
	return FALSE


//Checks for specific types in a list
/proc/is_type_in_list(atom/A, list/L)
	for(var/type in L)
		if(istype(A, type))
			return TRUE
	return FALSE

/**
 * Removes any null entries from the list
 * Returns TRUE if the list had nulls, FALSE otherwise
**/

#define listclearnulls(list) list?.RemoveAll(null)

/*
* Returns list containing all the entries from first list that are not present in second.
* If skiprep = 1, repeated elements are treated as one.
* If either of arguments is not a list, returns null
*/
/proc/difflist(list/first, list/second, skiprep = FALSE)
	if(!islist(first) || !islist(second))
		return
	var/list/result = list()
	if(skiprep)
		for(var/e in first)
			if((e in result) || (e in second))
				continue
			result += e
	else
		result = first - second

	return result


/**
 * Picks a random element from a list based on a weighting system.
 * For example, given the following list:
 * A = 6, B = 3, C = 1, D = 0
 * A would have a 60% chance of being picked,
 * B would have a 30% chance of being picked,
 * C would have a 10% chance of being picked,
 * and D would have a 0% chance of being picked.
 * You should only pass integers in.
 */
/proc/pickweight(list/list_to_pick)
	var/total = 0
	var/item
	for(item in list_to_pick)
		if(!list_to_pick[item])
			list_to_pick[item] = 1
		total += list_to_pick[item]

	total = rand(1, total)
	for(item in list_to_pick)
		total -= list_to_pick[item]
		if(total <= 0 && list_to_pick[item])
			return item

	return null


//Pick a random element from the list and remove it from the list.
/proc/pick_n_take(list/L)
	RETURN_TYPE(L[_].type)
	if(!length(L))
		return

	var/picked = pick(L)
	L -= picked
	return picked


//Returns the top(last) element from the list and removes it from the list (typical stack function)
/proc/pop(list/L)
	if(length(L))
		. = L[length(L)]
		L.len--

/proc/popleft(list/L)
	if(length(L))
		. = L[1]
		L.Cut(1,2)


//Returns the next element in parameter list after first appearance of parameter element. If it is the last element of the list or not present in list, returns first element.
/proc/next_in_list(element, list/L)
	for(var/i in 1 to length(L)-1)
		if(L[i] == element)
			return L[i + 1]
	return L[1]


//Randomize: Return the list in a random order
/proc/shuffle(list/L, ref) //Reference override for indexed lists.
	if(!L)
		return
	L = L.Copy()

	for(var/i in 1 to length(L)-1)
		L.Swap(i,rand(i, length(L)))

	return L


//Return a list with no duplicate entries
/proc/uniquelist(list/L)
	var/list/K = list()
	for(var/item in L)
		if((item in K))
			continue
		K += item
	return K


//for sorting clients or mobs by ckey
/proc/sortKey(list/L, order = 1)
	return sortTim(L, order >= 0 ? /proc/cmp_ckey_asc : /proc/cmp_ckey_dsc)


//Specifically for record datums in a list.
/proc/sortRecord(list/L, field = "name", order = 1)
	return sortTim(L, order >= 0 ? /proc/cmp_records_asc : /proc/cmp_records_dsc, sortkey=field)


//any value in a list
/proc/sortList(list/L, cmp=/proc/cmp_text_asc)
	return sortTim(L.Copy(), cmp)


/proc/sortListUsingKey(list/L, cmp=/proc/cmp_list_asc, sortKey)
	return sortTim(L.Copy(), cmp, sortkey=sortKey)


//uses sortList() but uses the var's name specifically. This should probably be using mergeAtom() instead
/proc/sortNames(list/L, order=1)
	return sortTim(L, order >= 0 ? /proc/cmp_name_asc : /proc/cmp_name_dsc)


/proc/count_by_type(list/L, type)
	var/i = 0
	for(var/T in L)
		if(istype(T, type))
			i++
	return i


//Move a single element from position fromIndex within a list, to position toIndex
//All elements in the range [1,toIndex) before the move will be before the pivot afterwards
//All elements in the range [toIndex, length(L) + 1) before the move will be after the pivot afterwards
//In other words, it's as if the range [fromIndex,toIndex) have been rotated using a <<< operation common to other languages.
//fromIndex and toIndex must be in the range [1,length(L) + 1]
//This will preserve associations ~Carnie
/proc/moveElement(list/L, fromIndex, toIndex)
	if(fromIndex == toIndex || fromIndex + 1 == toIndex)	//no need to move
		return
	if(fromIndex > toIndex)
		++fromIndex	//since a null will be inserted before fromIndex, the index needs to be nudged right by one

	L.Insert(toIndex, null)
	L.Swap(fromIndex, toIndex)
	L.Cut(fromIndex, fromIndex + 1)


//Move elements [fromIndex,fromIndex+len) to [toIndex-len, toIndex)
//Same as moveElement but for ranges of elements
//This will preserve associations ~Carnie
/proc/moveRange(list/L, fromIndex, toIndex, len = 1)
	var/distance = abs(toIndex - fromIndex)
	if(len >= distance)	//there are more elements to be moved than the distance to be moved. Therefore the same result can be achieved (with fewer operations) by moving elements between where we are and where we are going. The result being, our range we are moving is shifted left or right by dist elements
		if(fromIndex <= toIndex)
			return	//no need to move
		fromIndex += len	//we want to shift left instead of right

		for(var/i in 1 to distance)
			L.Insert(fromIndex, null)
			L.Swap(fromIndex, toIndex)
			L.Cut(toIndex, toIndex + 1)
	else
		if(fromIndex > toIndex)
			fromIndex += len

		for(var/i in 1 to len)
			L.Insert(toIndex, null)
			L.Swap(fromIndex, toIndex)
			L.Cut(fromIndex, fromIndex + 1)



/proc/dd_sortedObjectList(list/incoming)
	/*
	Use binary search to order by dd_SortValue().
	This works by going to the half-point of the list, seeing if the node in
	question is higher or lower cost, then going halfway up or down the list
	and checking again. This is a very fast way to sort an item into a list.
	*/
	var/list/sorted_list = new()
	var/low_index
	var/high_index
	var/insert_index
	var/midway_calc
	var/current_index
	var/current_item
	var/current_item_value
	var/current_sort_object_value
	var/list/list_bottom

	var/current_sort_object
	for (current_sort_object in incoming)
		low_index = 1
		high_index = length(sorted_list)
		while (low_index <= high_index)
			// Figure out the midpoint, rounding up for fractions.  (BYOND rounds down, so add 1 if necessary.)
			midway_calc = (low_index + high_index) / 2
			current_index = round(midway_calc)
			if(midway_calc > current_index)
				current_index++
			current_item = sorted_list[current_index]

			current_item_value = current_item:dd_SortValue()
			current_sort_object_value = current_sort_object:dd_SortValue()
			if(current_sort_object_value < current_item_value)
				high_index = current_index - 1
			else if(current_sort_object_value > current_item_value)
				low_index = current_index + 1
			else
				// current_sort_object == current_item
				low_index = current_index
				break

		// Insert before low_index.
		insert_index = low_index

		// Special case adding to end of list.
		if(insert_index > length(sorted_list))
			sorted_list += current_sort_object
			continue

		// Because BYOND lists don't support insert, have to do it by:
		// 1) taking out bottom of list, 2) adding item, 3) putting back bottom of list.
		list_bottom = sorted_list.Copy(insert_index)
		sorted_list.Cut(insert_index)
		sorted_list += current_sort_object
		sorted_list += list_bottom
	return sorted_list


/datum/proc/dd_SortValue()
	return "[src]"


/obj/machinery/dd_SortValue()
	return "[sanitize(name)]"


/proc/reverseRange(list/L, start = 1, end = 0)
	if(length(L))
		start = start % length(L)
		end = end % (length(L) + 1)
		if(start <= 0)
			start += length(L)
		if(end <= 0)
			end += length(L) + 1

		--end
		while(start < end)
			L.Swap(start++,end--)

	return L


/* Definining a counter as a series of key -> numeric value entries

* All these procs modify in place.
*/
/proc/counterlist_scale(list/L, scalar)
	var/list/out = list()
	for(var/key in L)
		out[key] = L[key] * scalar
	. = out


/proc/counterlist_sum(list/L)
	. = 0
	for(var/key in L)
		. += L[key]


/proc/counterlist_normalise(list/L)
	var/avg = counterlist_sum(L)
	if(avg != 0)
		. = counterlist_scale(L, 1 / avg)
	else
		. = L


/proc/counterlist_combine(list/L1, list/L2)
	for(var/key in L2)
		var/other_value = L2[key]
		if(key in L1)
			L1[key] += other_value
		else
			L1[key] = other_value


/// Turns an associative list into a flat list of keys
/proc/assoc_to_keys(list/input)
	var/list/keys = list()
	for(var/key in input)
		keys += key
	return keys

///flat list comparison, checks if two lists have the same contents
/proc/compare_list(list/l,list/d)
	if(!islist(l) || !islist(d))
		return FALSE

	if(length(l) != length(d))
		return FALSE

	for(var/i in 1 to length(l))
		if(l[i] != d[i])
			return FALSE

	return TRUE

#define LAZY_LISTS_OR(left_list, right_list)\
	( length(left_list)\
		? length(right_list)\
			? (left_list | right_list)\
			: left_list.Copy()\
		: length(right_list)\
			? right_list.Copy()\
			: null\
	)


//Like typesof() or subtypesof(), but returns a typecache instead of a list
/proc/typecacheof(path, ignore_root_path, only_root_path = FALSE)
	if(ispath(path))
		var/list/types = list()
		if(only_root_path)
			types = list(path)
		else
			types = ignore_root_path ? subtypesof(path) : typesof(path)
		var/list/L = list()
		for(var/T in types)
			L[T] = TRUE
		return L
	else if(islist(path))
		var/list/pathlist = path
		var/list/L = list()
		if(ignore_root_path)
			for(var/P in pathlist)
				for(var/T in subtypesof(P))
					L[T] = TRUE
		else
			for(var/P in pathlist)
				if(only_root_path)
					L[P] = TRUE
				else
					for(var/T in typesof(P))
						L[T] = TRUE
		return L


//Copies a list, and all lists inside it recusively
//Does not copy any other reference type
/proc/deepCopyList(list/L)
	if(!islist(L))
		return L
	. = L.Copy()
	for(var/i in 1 to length(L))
		var/key = .[i]
		if(isnum(key))
			// numbers cannot ever be associative keys
			continue
		var/value = .[key]
		if(islist(value))
			value = deepCopyList(value)
			.[key] = value
		if(islist(key))
			key = deepCopyList(key)
			.[i] = key
			.[key] = value


//Return a list with no duplicate entries
/proc/uniqueList(list/L)
	. = list()
	for(var/i in L)
		. |= i


//same, but returns nothing and acts on list in place
/proc/shuffle_inplace(list/L)
	if(!L)
		return

	for(var/i in 1 to length(L)-1)
		L.Swap(i, rand(i, length(L)))


//same, but returns nothing and acts on list in place (also handles associated values properly)
/proc/uniqueList_inplace(list/L)
	var/temp = L.Copy()
	L.len = 0
	for(var/key in temp)
		if (isnum(key))
			L |= key
		else
			L[key] = temp[key]


/proc/typecache_filter_list_reverse(list/atoms, list/typecache)
	RETURN_TYPE(/list)
	. = list()
	for(var/thing in atoms)
		var/atom/A = thing
		if(!typecache[A.type])
			. += A

/**
 * Like pickweight, but allowing for nested lists.
 *
 * For example, given the following list:
 * list(A = 1, list(B = 1, C = 1))
 * A would have a 50% chance of being picked,
 * and list(B, C) would have a 50% chance of being picked.
 * If list(B, C) was picked, B and C would then each have a 50% chance of being picked.
 * So the final probabilities would be 50% for A, 25% for B, and 25% for C.
 *
 * Weights should be integers. Entries without weights are assigned weight 1 (so unweighted lists can be used as well)
 */
/proc/pick_weight_recursive(list/list_to_pick)
	var/result = pickweight(list_to_pick)
	while(islist(result))
		result = pickweight(result)
	return result

/**
 * Removes any null entries from the list
 * Returns TRUE if the list had nulls, FALSE otherwise
**/
/proc/list_clear_nulls(list/list_to_clear)
	var/start_len = length(list_to_clear)
	var/list/new_list = new(start_len)
	list_to_clear -= new_list
	return length(list_to_clear) < start_len

///sort any value in a list
/proc/sort_list(list/list_to_sort, cmp=/proc/cmp_text_asc)
	return sortTim(list_to_sort.Copy(), cmp)

///uses sort_list() but uses the var's name specifically. This should probably be using mergeAtom() instead
/proc/sort_names(list/list_to_sort, order=1)
	return sortTim(list_to_sort.Copy(), order >= 0 ? GLOBAL_PROC_REF(cmp_name_asc) : GLOBAL_PROC_REF(cmp_name_dsc))
