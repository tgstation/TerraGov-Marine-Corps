/datum/language_holder
	var/list/languages = list(/datum/language/common) //Can speak and understand.
	var/list/shadow_languages = list() //Can't speak, can understand.
	var/only_speaks_language = null
	var/selected_default_language = null

	var/omnitongue = FALSE
	var/owner


/datum/language_holder/New(owner)
	src.owner = owner
	RegisterSignal(owner, COMSIG_PARENT_QDELETING, .proc/clean_language)

	languages = typecacheof(languages)
	shadow_languages = typecacheof(shadow_languages)


/datum/language_holder/Destroy()
	owner = null
	languages.Cut()
	shadow_languages.Cut()
	return ..()

///Clean src when it's owner is deleted
/datum/language_holder/proc/clean_language()
	SIGNAL_HANDLER
	qdel(src)

/datum/language_holder/proc/copy(newowner)
	var/datum/language_holder/copy = new(newowner)
	copy.languages = src.languages.Copy()
	copy.shadow_languages = src.shadow_languages.Copy()
	copy.only_speaks_language = src.only_speaks_language
	copy.selected_default_language = src.selected_default_language
	copy.omnitongue = src.omnitongue
	return copy


/datum/language_holder/proc/grant_language(datum/language/dt, shadow = FALSE)
	if(shadow)
		shadow_languages[dt] = TRUE
	else
		languages[dt] = TRUE


/datum/language_holder/proc/grant_all_languages(omnitongue = FALSE)
	for(var/la in GLOB.all_languages)
		grant_language(la)

	if(omnitongue)
		src.omnitongue = TRUE


/datum/language_holder/proc/get_random_understood_language()
	var/list/possible = list()
	for(var/dt in languages)
		possible += dt
	. = SAFEPICK(possible)


/datum/language_holder/proc/remove_language(datum/language/dt, shadow = FALSE)
	if(shadow)
		shadow_languages -= dt
	else
		languages -= dt


/datum/language_holder/proc/remove_all_languages()
	languages.Cut()


/datum/language_holder/proc/has_language(datum/language/dt)
	if(is_type_in_typecache(dt, languages))
		return LANGUAGE_KNOWN
	else if(is_type_in_typecache(dt, shadow_languages))
		return LANGUAGE_SHADOWED
	return FALSE


/datum/language_holder/proc/copy_known_languages_from(thing, replace = FALSE)
	var/datum/language_holder/other
	if(istype(thing, /datum/language_holder))
		other = thing

	else if(ismovableatom(thing))
		var/atom/movable/AM = thing
		other = AM.get_language_holder()

	if(replace)
		remove_all_languages()

	for(var/l in other.languages)
		grant_language(l)


/datum/language_holder/proc/get_atom()
	if(ismovableatom(owner))
		. = owner
	else if(istype(owner, /datum/mind))
		var/datum/mind/M = owner
		if(M.current)
			. = M.current


/datum/language_holder/empty
	languages = list()
	shadow_languages = list()


/datum/language_holder/xeno
	languages = list(/datum/language/xenocommon)


/datum/language_holder/universal/New()
	. = ..()
	grant_all_languages(omnitongue = TRUE)


/datum/language_holder/synthetic
	languages = list(/datum/language/common, /datum/language/machine, /datum/language/xenocommon)

/datum/language_holder/moth
	languages = list(/datum/language/common, /datum/language/moth)
	selected_default_language = /datum/language/moth

/datum/language_holder/sectoid
	languages = list(/datum/language/sectoid)

/datum/language_holder/zombie
	languages = list(/datum/language/zombie)


/mob/living/verb/language_menu()
	set category = "IC"
	set name = "Language Menu"

	var/datum/language_holder/H = get_language_holder()
	var/body = "<b>Known Languages:</b><br>"

	for(var/i in H.languages)
		var/datum/language/L = i
		body += "<b>[initial(L.name)]</b> - Key: <b>,[initial(L.key)]</b>"
		if(H.selected_default_language == L)
			body += " - Default"
		else
			body += " - <a href='?src=[REF(src)];default_language=[L]'>Set as Default</a>"
		body += "<br><b>Description:</b> <i>[initial(L.desc)]</i>"
		body += "<br><br>"


	var/datum/browser/popup = new(src, "languages", "<div align='center'>Language Menu</div>", 550, 615)
	popup.set_content(body)
	popup.open(FALSE)
