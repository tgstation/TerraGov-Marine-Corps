//GLOBAL_LIST_INIT(badomens, list("roundstart"))
GLOBAL_LIST_INIT(badomens, list())

/datum/round_event_control/rogue
	name = null

/datum/round_event_control/rogue/canSpawnEvent()
	. = ..()
	if(!.)
		return .
	var/datum/game_mode/chaosmode/C = SSticker.mode
	if(istype(C))
		if(C.allmig || C.roguefight)
			return FALSE
	if(!name)
		return FALSE

/proc/addomen(input)
	if(!(input in GLOB.badomens))
		testing("Omen added: [input]")
		GLOB.badomens += input

/datum/round_event_control/proc/badomen(eventreason)
	var/used
	switch(eventreason)
		if("roundstart")
			used = "Zizo."
		if("importantdeath")
			used = "A Noble has perished."
		if("skellysiege")
			used = "Unwelcome visitors!"
		if("nolord")
			used = "The Monarch is dead! We need a new ruler."
		if("sunsteal")
			used = "The Sun, she is wounded!"
	if(eventreason && used)
		priority_announce(used, "Bad Omen", 'sound/misc/evilevent.ogg')

