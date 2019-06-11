/datum/faction
	var/name = "Faction"

	var/list/squads
	var/list/friendly_factions


/datum/faction/New()
	. = ..()
	if(islist(squads))
		for(var/i in squads)
			var/datum/squad/S = new i()
			squads -= i
			squads[S.name] = S
	else
		squads = list()
	friendly_factions = list()


/datum/faction/proc/friendly_check(datum/faction/other)
	return (other in friendly_factions)


/datum/faction/marine
	name = "Marine"
	squads = list(/datum/squad/marine/alpha, /datum/squad/marine/bravo, /datum/squad/marine/charlie, /datum/squad/marine/delta)


/datum/faction/xeno
	name = "Xenomorphs"


/datum/faction/neutral
	name = "Neutral"


/datum/faction/hostile
	name = "Hostile"


/datum/faction/clf
	name = "Colonial Liberation Force"


/datum/faction/deathsquad
	name = "Deathsquad"


/datum/faction/freelancers
	name = "Freelancers"


/datum/faction/imperium
	name = "Imperium of Mankind"


/datum/faction/mercenary
	name = "Unknown Mercenary Group"


/datum/faction/nanotrasen
	name = "Nanotrasen"


/datum/faction/upp
	name = "Union of Progressive People"