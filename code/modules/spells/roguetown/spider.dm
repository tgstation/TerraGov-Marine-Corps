
/obj/effect/proc_holder/spell/targeted/spiderconjur
	name = "Conjure Web"
	range = 8
	overlay_state = "null"
	releasedrain = 5
	charge_max = 30
	max_targets = 0
	cast_without_targets = TRUE
	sound = 'sound/magic/webspin.ogg'
	associated_skill = /datum/skill/magic/holy
	req_items = list(/obj/item/clothing/neck/roguetown/psicross)
	invocation = null
	invocation_type = "shout" //can be none, whisper, emote and shout
	associated_skill = /datum/skill/magic/arcane

/obj/effect/proc_holder/spell/targeted/spiderconjur/cast(list/targets,mob/user = usr)
	if(isopenturf(user.loc))
		var/turf/open/T = user.loc
		var/foundwall
		for(var/X in GLOB.cardinals)
			var/turf/TU = get_step(T, X)
			if(TU && isclosedturf(TU))
				foundwall = TRUE
				break
		if(foundwall)
			if(!locate(/obj/structure/spider/stickyweb) in T)
				new /obj/structure/spider/stickyweb(T)

	return TRUE