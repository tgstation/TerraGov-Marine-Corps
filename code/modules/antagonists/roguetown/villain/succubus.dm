
/datum/antagonist/villain
	name = "Assassin"
	roundend_category = "villains"
	antagpanel_category = "Villain"
	job_rank = ROLE_VILLAIN
	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "villain"
	var/special_role = ROLE_VILLAIN

/mind/

/datum/antagonist/villain/on_gain()
	SSticker.mode.villains += owner
	owner.special_role = special_role
	var/yea = pick(/obj/item/rogueweapon/huntingknife/idagger,/obj/item/rogueweapon/huntingknife/idagger/steel,/obj/item/rogueweapon/huntingknife/idagger/silver)
	owner.special_items["Dagger"] = yea
	owner.special_items["Poison"] = /obj/item/reagent_containers/glass/bottle/rogue/poison
	if(ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		H.change_stat("speed", 4)
		H.change_stat("endurance", 1)
		H.change_stat("constitution", 1)
		owner.adjust_experience(/datum/skill/combat/knives, SKILL_EXP_EXPERT, TRUE)
	forge_villain_objectives()
	finalize_villain()
	return ..()

/datum/antagonist/villain/on_removal()
	SSticker.mode.villains -= owner
	if(!silent && owner.current)
		to_chat(owner.current,"<span class='danger'>I am no longer a [special_role]!</span>")
	owner.special_role = null
	return ..()

/datum/antagonist/villain/proc/add_objective(datum/objective/O)
	objectives += O

/datum/antagonist/villain/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/villain/proc/forge_villain_objectives()
	forge_single_human_objective()

	if(!(locate(/datum/objective/escape) in objectives))
		var/datum/objective/escape/boat/escape_objective = new
		escape_objective.owner = owner
		add_objective(escape_objective)
		return

/datum/antagonist/succubus/proc/forge_single_human_objective() //Returns how many objectives are added
	.=1
	var/datum/objective/assassinate/kill_objective = new
	kill_objective.owner = owner
	var/list/atypes = list("King", "Queen", "Sheriff", "Priest", "Manor Guard", "Knight", "Concubine")
	for(var/X in shuffle(atypes))
		if(kill_objective.find_target_by_role(X))
			break
	add_objective(kill_objective)

/datum/antagonist/succubus/greet()
	to_chat(owner.current, "<span class='alertsyndie'>I am a succubus! Long since have I consumed this mortal form, and now I will feast on the souls of men.</span>")
	owner.announce_objectives()
	..()

/datum/antagonist/succubus/proc/finalize_succubus()
	owner.current.playsound_local(get_turf(owner.current), 'sound/music/traitor.ogg', 80, FALSE, pressure_affected = FALSE)
	ADD_TRAIT(owner.current, RTRAIT_ANTAG, TRAIT_GENERIC)
