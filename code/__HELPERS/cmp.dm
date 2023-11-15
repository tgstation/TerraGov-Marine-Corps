/proc/cmp_numeric_dsc(a,b)
	return b - a

/proc/cmp_numeric_asc(a,b)
	return a - b

/proc/cmp_text_asc(a,b)
	return sorttext(b,a)

/proc/cmp_text_dsc(a,b)
	return sorttext(a,b)

/proc/cmp_name_asc(atom/a, atom/b)
	return sorttext(b.name, a.name)

/proc/cmp_name_dsc(atom/a, atom/b)
	return sorttext(a.name, b.name)

/proc/cmp_list_numeric_asc(list/a, list/b, sortkey)
	return cmp_numeric_asc(a[sortkey], b[sortkey])

/proc/cmp_list_numeric_dsc(list/a, list/b, sortkey)
	return cmp_numeric_dsc(a[sortkey], b[sortkey])

/proc/cmp_list_asc(list/a, list/b, sortkey)
	return sorttext(b[sortkey], a[sortkey])

/proc/cmp_list_dsc(list/a, list/b, sortkey)
	return sorttext(a[sortkey], b[sortkey])

// Datum cmp with vars is always slower than a specialist cmp proc, use your judgement.
/proc/cmp_datum_numeric_asc(datum/a, datum/b, variable)
	return cmp_numeric_asc(a.vars[variable], b.vars[variable])

/proc/cmp_datum_numeric_dsc(datum/a, datum/b, variable)
	return cmp_numeric_dsc(a.vars[variable], b.vars[variable])

/proc/cmp_datum_text_asc(datum/a, datum/b, variable)
	return sorttext(b.vars[variable], a.vars[variable])

/proc/cmp_datum_text_dsc(datum/a, datum/b, variable)
	return sorttext(a.vars[variable], b.vars[variable])

/proc/cmp_records_asc(datum/data/record/a, datum/data/record/b, sortkey)
	return sorttext(b.fields[sortkey], a.fields[sortkey])

/proc/cmp_records_dsc(datum/data/record/a, datum/data/record/b, sortkey)
	return sorttext(a.fields[sortkey], b.fields[sortkey])


/proc/cmp_ckey_asc(client/a, client/b)
	return sorttext(b.ckey, a.ckey)


/proc/cmp_ckey_dsc(client/a, client/b)
	return sorttext(a.ckey, b.ckey)


/proc/cmp_subsystem_init(datum/controller/subsystem/a, datum/controller/subsystem/b)
	return initial(b.init_order) - initial(a.init_order)	//uses initial() so it can be used on types


/proc/cmp_subsystem_display(datum/controller/subsystem/a, datum/controller/subsystem/b)
	return sorttext(b.name, a.name)


/proc/cmp_subsystem_priority(datum/controller/subsystem/a, datum/controller/subsystem/b)
	return a.priority - b.priority

/proc/cmp_filter_data_priority(list/A, list/B)
	return A["priority"] - B["priority"]

/proc/cmp_timer(datum/timedevent/a, datum/timedevent/b)
	return a.timeToRun - b.timeToRun


/proc/cmp_qdel_item_time(datum/qdel_item/A, datum/qdel_item/B)
	. = B.hard_delete_time - A.hard_delete_time
	if(!.)
		. = B.destroy_time - A.destroy_time
	if(!.)
		. = B.failures - A.failures
	if(!.)
		. = B.qdels - A.qdels


/proc/cmp_generic_stat_item_time(list/A, list/B)
	. = B[STAT_ENTRY_TIME] - A[STAT_ENTRY_TIME]
	if(!.)
		. = B[STAT_ENTRY_COUNT] - A[STAT_ENTRY_COUNT]

/proc/cmp_reagents_asc(datum/reagent/a, datum/reagent/b)
	return sorttext(initial(b.name),initial(a.name))

/proc/cmp_job_display_asc(datum/job/A, datum/job/B)
	return A.display_order - B.display_order

/proc/cmp_path_step(datum/path_step/a, datum/path_step/b)
	return a.distance_to_goal + a.distance_walked - b.distance_to_goal - b.distance_walked

/proc/cmp_typepaths_asc(A, B)
	return sorttext("[B]","[A]")
