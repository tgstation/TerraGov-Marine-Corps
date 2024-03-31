/// DEFINITIONS ///
#define CLERIC_T0 0
#define CLERIC_T1 1
#define CLERIC_T2 2
#define CLERIC_T3 3

#define CLERIC_REQ_1 100
#define CLERIC_REQ_2 250
#define CLERIC_REQ_3 500

// Cleric Holder Datums

/datum/devotion/cleric_holder
	var/holder_mob = null
	var/patron = null
	var/devotion = 0
	var/progression = 0
	var/level = CLERIC_T0

/datum/devotion/cleric_holder/New(var/mob/living/carbon/human/holder, god)
	holder_mob = holder
	holder.cleric = src
	patron = god

/datum/devotion/cleric_holder/proc/check_devotion(req)
	if(abs(req) <= devotion)
		return TRUE
	else
		return FALSE

/datum/devotion/cleric_holder/proc/update_devotion(dev_amt, prog_amt)
	var/datum/patrongods/P = patron
	devotion += dev_amt
	if(!prog_amt) // no point in the rest if it's just an expenditure
		return
	progression += prog_amt
	switch(level)
		if(CLERIC_T0)
			if(progression >= CLERIC_REQ_1)
				level = CLERIC_T1
				usr.mind.AddSpell(new P.t1)
				return
		if(CLERIC_T1)
			if(progression >= CLERIC_REQ_2)
				level = CLERIC_T2
				usr.mind.AddSpell(new P.t2)
				return
		if(CLERIC_T2)
			if(progression >= CLERIC_REQ_3)
				level = CLERIC_T3
				usr.mind.AddSpell(new P.t3)
				return
		if(CLERIC_T3) // already maxed out
			return

// Devotion Debugs

/mob/living/carbon/human/proc/devotionreport()
	set name = "Check Devotion"
	set category = "Cleric"

	var/datum/devotion/cleric_holder/C = src.cleric
	to_chat(src,"My devotion is [C.devotion].")

/mob/living/carbon/human/proc/devotionchange()
	set name = "(DEBUG)Change Devotion"
	set category = "Special Verbs"

	var/datum/devotion/cleric_holder/C = src.cleric
	var/changeamt = input(src, "My devotion is [C.devotion]. How much to change?", "How much to change?") as null|num
	if(!changeamt)
		return
	C.devotion += changeamt

// Generation Procs

/mob/living/carbon/human/proc/clericpray()
	set name = "Give Prayer"
	set category = "Cleric"
	
	var/datum/devotion/cleric_holder/C = src.cleric
	var/prayersesh = 0

	visible_message("[src] kneels their head in prayer to the Gods.", "I kneel my head in prayer to [PATRON]")
	for(var/i in 1 to 20)
		if(do_after(src, 30))
			C.update_devotion(2, 2)
			prayersesh += 2
		else
			visible_message("[src] concludes their prayer.", "I conclude my prayer.")
			to_chat(src, "<font color='purple'>I gained [prayersesh] devotion!</font>")
			return
	to_chat(src, "<font color='purple'>I gained [prayersesh] devotion!</font>")
