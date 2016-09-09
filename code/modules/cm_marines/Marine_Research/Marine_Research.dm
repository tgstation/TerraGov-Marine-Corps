//MARINE RESEARCH MAIN 15JAN2016 BY APOP

//This is the research main topic for marine research.  If you don't understand something here, check research.dm.  I've basically cut/mashed and reworked the code from the basic research
//system to fit my evil needs and cleaned up a tiny bit.


/datum/XenoResearch								//Holder for all the existing, archived, and known tech. Individual to console.

									//Datum/tech go here.
	var/list/possible_tech = list()			//List of all tech in the game that players have access to (barring special events).
	var/list/known_tech = list()				//List of locally known tech.
	var/list/possible_designs = list()		//List of all designs (at base reliability).
	var/list/known_designs = list()			//List of available designs (at base reliability).


/datum/XenoResearch/New()		//Insert techs into possible_tech here. Known_tech automatically updated.
	for(var/T in typesof(/datum/tech) - /datum/tech)
		possible_tech += new T(src)
	for(var/D in typesof(/datum/design) - /datum/design)
		possible_designs += new D(src)
	RefreshResearch()


//Checks to see if tech has all the required pre-reqs.
//Input: datum/tech; Output: 0/1 (false/true)
/datum/XenoResearch/proc/TechHasReqs(var/datum/tech/T)
	if(T.req_tech.len == 0)
		return 1
	var/matches = 0
	for(var/req in T.req_tech)
		for(var/datum/tech/known in known_tech)
			if((req == known.id) && (known.level >= T.req_tech[req]))
				matches++
				break
	if(matches == T.req_tech.len)
		return 1
	else
		return 0

//Checks to see if design has all the required pre-reqs.
//Input: datum/design; Output: 0/1 (false/true)
/datum/XenoResearch/proc/DesignHasReqs(var/datum/design/D)
	if(D.req_tech.len == 0)
		return 1
	var/matches = 0
	var/list/k_tech = list()
	for(var/datum/tech/known in known_tech)
		k_tech[known.id] = known.level
	for(var/req in D.req_tech)
		if(!isnull(k_tech[req]) && k_tech[req] >= D.req_tech[req])
			matches++
	if(matches == D.req_tech.len)
		return 1
	else
		return 0
/*
//Checks to see if design has all the required pre-reqs.
//Input: datum/design; Output: 0/1 (false/true)
/datum/research/proc/DesignHasReqs(var/datum/design/D)
	if(D.req_tech.len == 0)
		return 1
	var/matches = 0
	for(var/req in D.req_tech)
		for(var/datum/tech/known in known_tech)
			if((req == known.id) && (known.level >= D.req_tech[req]))
				matches++
				break
	if(matches == D.req_tech.len)
		return 1
	else
		return 0
*/
//Adds a tech to known_tech list. Checks to make sure there aren't duplicates and updates existing tech's levels if needed.
//Input: datum/tech; Output: Null
/datum/XenoResearch/proc/AddTech2Known(var/datum/tech/T)
	for(var/datum/tech/known in known_tech)
		if(T.id == known.id)
			if(T.level > known.level)
				known.level = T.level
			return
	known_tech += T
	return

/datum/XenoResearch/proc/AddDesign2Known(var/datum/design/D)
	for(var/datum/design/known in known_designs)
		if(D.id == known.id)
			if(D.reliability_mod > known.reliability_mod)
				known.reliability_mod = D.reliability_mod
			return
	known_designs += D
	return

//Refreshes known_tech and known_designs list. Then updates the reliability vars of the designs in the known_designs list.
//Input/Output: n/a
/datum/XenoResearch/proc/RefreshResearch()
	for(var/datum/tech/PT in possible_tech)
		if(TechHasReqs(PT))
			AddTech2Known(PT)
	for(var/datum/design/PD in possible_designs)
		if(DesignHasReqs(PD))
			AddDesign2Known(PD)
	for(var/datum/tech/T in known_tech)
		T = between(1,T.level,20)
	for(var/datum/design/D in known_designs)
		D.CalcReliability(known_tech)
	return

//Refreshes the levels of a given tech.
//Input: Tech's ID and Level; Output: null
/datum/XenoResearch/proc/UpdateTech(var/ID, var/level)
	for(var/datum/tech/KT in known_tech)
		if(KT.id == ID)
			if(KT.level <= level) KT.level = max((KT.level + 1), (level - 1))
	return

/datum/XenoResearch/proc/UpdateDesign(var/path)
	for(var/datum/design/KD in known_designs)
		if(KD.build_path == path)
			KD.reliability_mod += rand(1,2)
			break
	return




/***************************************************************
**						Technology Datums					  **
**	Includes all the various technoliges and what they make.  **
***************************************************************/


//FOR REFERENCE ONLY.  Defined in research.dm.  ENABLE IF YOU REMOVE RESEARCH.DM.
/*datum/tech	//Datum of individual technologies.
	var/name = "name"					//Name of the technology.
	var/desc = "description"			//General description of what it does and what it makes.
	var/id = "id"						//An easily referenced ID. Must be alphanumeric, lower-case, and no symbols.
	var/level = 1						//A simple number scale of the research level. Level 0 = Secret tech.
	var/list/req_tech = list()			//List of ids associated values of techs required to research this tech. "id" = #
*/


//Trunk Technologies (don't require any other techs and you start knowning them).

//Everything will be biological for the moment.  The final version, will split between the "castes" with the plan of:  Queen, Melee, Ranged, Support.  Also, we'll have a "Constructions"
//for things like weed samples and such.


datum/tech/XenoFauna
	name = "Biological"
	desc = "Analysis of alien biology"
	id = "Bio"





