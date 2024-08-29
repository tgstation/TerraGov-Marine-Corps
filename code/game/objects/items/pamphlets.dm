//skill modifying item
/obj/item/pamphlet
	name = "generic phamplet"
	desc = "you shouldnt see this"
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "paper_words"
	w_class = WEIGHT_CLASS_TINY
	var/unarmed
	var/melee_weapons
	var/combat
	var/pistols
	var/shotguns
	var/rifles
	var/smgs
	var/heavy_weapons
	var/smartgun
	var/engineer
	var/construction
	var/leadership
	var/medical
	var/surgery
	var/pilot
	var/police
	var/powerloader
	var/large_vehicle
	var/stamina

	///assoc list list(SKILL = MAXIMUM_INT) for when we dont want to let them read this
	var/list/max_skills

/obj/item/pamphlet/attack_self(mob/living/user)
	. = ..()
	for(var/skill in max_skills)
		if(user.skills.getRating(skill) >= max_skills[skill])
			balloon_alert(user, "nothing to learn!")
			return
	if(!do_after(user, 5 SECONDS, NONE, user))
		return
	user.set_skills(user.skills.modifyRating(unarmed, melee_weapons, combat, pistols, shotguns, rifles, smgs, heavy_weapons, smartgun, \
	engineer, construction, leadership, medical, surgery, pilot, police, powerloader, large_vehicle, stamina))
	user.temporarilyRemoveItemFromInventory(src)
	qdel(src)


/obj/item/pamphlet/tank_loader
	name = "loader's instruction manual"
	desc = "A crude drawing depicting what you think is loading a tank gun. Is that crayon?"
	large_vehicle = 1
	max_skills = list(SKILL_LARGE_VEHICLE = SKILL_LARGE_VEHICLE_TRAINED)

/obj/item/pamphlet/tank_crew
	name = "tank crew instruction manual"
	desc = "Operating tanks for dummies."
	large_vehicle = 3
	max_skills = list(SKILL_LARGE_VEHICLE = SKILL_LARGE_VEHICLE_VETERAN)
