GLOBAL_REAL(GLOB, /datum/controller/global_vars)

/datum/controller/global_vars
	name = "Global Variables"

	var/static/list/gvars_datum_protected_varlist
	var/list/gvars_datum_in_built_vars
	var/list/gvars_datum_init_order

/datum/controller/global_vars/New()
	if(GLOB)
		CRASH("Multiple instances of global variable controller created")
	GLOB = src

	var/datum/controller/exclude_these = new
	// I know this is dumb but the nested vars list hangs a ref to the datum. This fixes that
	var/list/controller_vars = exclude_these.vars.Copy()
	controller_vars["vars"] = null
	gvars_datum_in_built_vars = controller_vars + list(NAMEOF(src, gvars_datum_protected_varlist), NAMEOF(src, gvars_datum_in_built_vars), NAMEOF(src, gvars_datum_init_order))

	QDEL_IN(exclude_these, 1) //signal logging isn't ready

	log_world("[length(vars) - length(gvars_datum_in_built_vars)] global variables")

	Initialize()

/datum/controller/global_vars/Destroy(force)
	// This is done to prevent an exploit where admins can get around protected vars
	SHOULD_CALL_PARENT(FALSE)
	return QDEL_HINT_IWILLGC

/datum/controller/global_vars/stat_entry(msg)
	msg = "Edit"
	return msg

/datum/controller/global_vars/vv_edit_var(var_name, var_value)
	if(gvars_datum_protected_varlist[var_name])
		return FALSE
	return ..()

/datum/controller/global_vars/Initialize()
	gvars_datum_init_order = list()
	gvars_datum_protected_varlist = list(NAMEOF(src, gvars_datum_protected_varlist) = TRUE)
	var/list/global_procs = typesof(/datum/controller/global_vars/proc)
	var/expected_len = length(vars) - length(gvars_datum_in_built_vars)
	if(length(global_procs) != expected_len)
		warning("Unable to detect all global initialization procs! Expected [expected_len] got [length(global_procs)]!")
		if(length(global_procs))
			var/list/expected_global_procs = vars - gvars_datum_in_built_vars
			for(var/I in global_procs)
				expected_global_procs -= replacetext("[I]", "InitGlobal", "")
			log_world("Missing procs: [expected_global_procs.Join(", ")]")
	for(var/I in global_procs)
		var/start_tick = world.time
		call(src, I)()
		var/end_tick = world.time
		if(end_tick - start_tick)
			warning("Global [replacetext("[I]", "InitGlobal", "")] slept during initialization!")

	// Someone make it so this call isn't necessary
	make_datum_reference_lists()
