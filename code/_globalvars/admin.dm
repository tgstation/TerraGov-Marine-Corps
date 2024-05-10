GLOBAL_VAR_INIT(ooc_allowed, TRUE)
GLOBAL_VAR_INIT(dooc_allowed, TRUE)
GLOBAL_VAR_INIT(dsay_allowed, TRUE)
GLOBAL_VAR_INIT(enter_allowed, TRUE)
GLOBAL_VAR_INIT(respawn_allowed, TRUE)
GLOBAL_VAR_INIT(valhalla_allowed, TRUE)
GLOBAL_VAR_INIT(ssd_posses_allowed, TRUE)
GLOBAL_VAR_INIT(xeno_enter_allowed, TRUE)

GLOBAL_VAR_INIT(respawntime, 30 MINUTES)
GLOBAL_VAR_INIT(fileaccess_timer, 0)

GLOBAL_VAR_INIT(custom_info, "")
GLOBAL_VAR_INIT(motd, "")

///Regex for detecting non-ASCII symbols
GLOBAL_VAR_INIT(non_ascii_regex, regex(@"[^\x00-\x7F]"))
GLOBAL_PROTECT(non_ascii_regex)

///Returns true if this contains text that is not ASCII
#define NON_ASCII_CHECK(text) (findtext(text, GLOB.non_ascii_regex))

GLOBAL_LIST_EMPTY(custom_loadouts)

GLOBAL_LIST_EMPTY(admin_datums)
GLOBAL_PROTECT(admin_datums)
GLOBAL_LIST_EMPTY(protected_admins)
GLOBAL_PROTECT(protected_admins)

GLOBAL_VAR_INIT(href_token, GenerateToken())
GLOBAL_PROTECT(href_token)

GLOBAL_LIST_EMPTY(admin_ranks)
GLOBAL_PROTECT(admin_ranks)

GLOBAL_LIST_EMPTY(protected_ranks)
GLOBAL_PROTECT(protected_ranks)

// A list of all the special byond lists that need to be handled different by vv
GLOBAL_LIST_INIT(vv_special_lists, init_special_list_names())

/proc/init_special_list_names()
	var/list/output = list()
	var/obj/sacrifice = new
	for(var/varname in sacrifice.vars)
		var/value = sacrifice.vars[varname]
		if(!islist(value))
			if(!isdatum(value) && hascall(value, "Cut"))
				output += varname
			continue
		if(isnull(locate(REF(value))))
			output += varname
	return output
