//simple insertion sort - generally faster than merge for runs of 7 or smaller
/proc/sortInsert(list/L, cmp = /proc/cmp_numeric_asc, associative, fromIndex = 1, toIndex = 0, sortkey)
	if(length_char(L) >= 2)
		fromIndex = fromIndex % length_char(L)
		toIndex = toIndex % (length_char(L) + 1)
		if(fromIndex <= 0)
			fromIndex += length_char(L)
		if(toIndex <= 0)
			toIndex += length_char(L) + 1

		var/datum/sortInstance/SI = GLOB.sortInstance
		if(!SI)
			SI = new
		SI.L = L
		SI.cmp = cmp
		SI.associative = associative
		SI.sortkey = sortkey

		SI.binarySort(fromIndex, toIndex, fromIndex)

	return L
