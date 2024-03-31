/obj/item/clothing/under/plasmaman/cargo
	name = "cargo plasma envirosuit"
	desc = ""
	icon_state = "cargo_envirosuit"
	item_state = "cargo_envirosuit"

/obj/item/clothing/under/plasmaman/mining
	name = "mining plasma envirosuit"
	desc = ""
	icon_state = "explorer_envirosuit"
	item_state = "explorer_envirosuit"


/obj/item/clothing/under/plasmaman/chef
	name = "chef's plasma envirosuit"
	desc = ""
	icon_state = "chef_envirosuit"
	item_state = "chef_envirosuit"

/obj/item/clothing/under/plasmaman/enviroslacks
	name = "enviroslacks"
	desc = ""
	icon_state = "enviroslacks"
	item_state = "enviroslacks"

/obj/item/clothing/under/plasmaman/chaplain
	name = "chaplain's plasma envirosuit"
	desc = ""
	icon_state = "chap_envirosuit"
	item_state = "chap_envirosuit"

/obj/item/clothing/under/plasmaman/curator
	name = "curator's plasma envirosuit"
	desc = ""
	icon_state = "prototype_envirosuit"
	item_state = "prototype_envirosuit"

/obj/item/clothing/under/plasmaman/janitor
	name = "janitor's plasma envirosuit"
	desc = ""
	icon_state = "janitor_envirosuit"
	item_state = "janitor_envirosuit"

/obj/item/clothing/under/plasmaman/botany
	name = "botany envirosuit"
	desc = ""
	icon_state = "botany_envirosuit"
	item_state = "botany_envirosuit"


/obj/item/clothing/under/plasmaman/mime
	name = "mime envirosuit"
	desc = ""
	icon_state = "mime_envirosuit"
	item_state = "mime_envirosuit"

/obj/item/clothing/under/plasmaman/clown
	name = "clown envirosuit"
	desc = ""
	icon_state = "clown_envirosuit"
	item_state = "clown_envirosuit"

/obj/item/clothing/under/plasmaman/clown/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.on_fire)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message("<span class='warning'>[H]'s suit spews out a tonne of space lube!</span>","<span class='warning'>My suit spews out a tonne of space lube!</span>")
			H.ExtinguishMob()
			new /obj/effect/particle_effect/foam(loc) //Truely terrifying.
	return 0
