//skill modifying item
/obj/item/pamphlet
	name = "generic phamplet"
	desc = "you shouldnt see this"
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "paper_words"
	var/cqc
	var/melee_weapons
	var/firearms
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

/obj/item/pamphlet/attack_self(mob/living/user)
	. = ..()
	if(!do_after(user, 5 SECONDS, NONE, user))
		return
	user.set_skills(user.skills.modifyRating(cqc, melee_weapons, firearms, pistols, shotguns, rifles, smgs, heavy_weapons, smartgun, \
	engineer, construction, leadership, medical, surgery, pilot, police, powerloader, large_vehicle, stamina))
	user.temporarilyRemoveItemFromInventory(src)
	qdel(src)


/obj/item/pamphlet/tank_loader
	name = "loader's instruction manual"
	desc = "A crude drawing depicting what you think is loading a tank gun. Is that crayon?"
	large_vehicle = 1

