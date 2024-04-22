

/obj/screen/swarmer
	icon = 'icons/mob/swarmer.dmi'

/obj/screen/swarmer/FabricateTrap
	icon_state = "ui_trap"
	name = "Create trap (Costs 5 Resources)"
	desc = ""

/obj/screen/swarmer/FabricateTrap/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateTrap()

/obj/screen/swarmer/Barricade
	icon_state = "ui_barricade"
	name = "Create barricade (Costs 5 Resources)"
	desc = ""

/obj/screen/swarmer/Barricade/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateBarricade()

/obj/screen/swarmer/Replicate
	icon_state = "ui_replicate"
	name = "Replicate (Costs 50 Resources)"
	desc = ""

/obj/screen/swarmer/Replicate/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateSwarmer()

/obj/screen/swarmer/RepairSelf
	icon_state = "ui_self_repair"
	name = "Repair self"
	desc = ""

/obj/screen/swarmer/RepairSelf/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.RepairSelf()

/obj/screen/swarmer/ToggleLight
	icon_state = "ui_light"
	name = "Toggle light"
	desc = ""

/obj/screen/swarmer/ToggleLight/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.ToggleLight()

/obj/screen/swarmer/ContactSwarmers
	icon_state = "ui_contact_swarmers"
	name = "Contact swarmers"
	desc = ""

/obj/screen/swarmer/ContactSwarmers/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.ContactSwarmers()

/datum/hud/swarmer/New(mob/owner)
	..()
	var/obj/screen/using

	using = new /obj/screen/swarmer/FabricateTrap()
	using.screen_loc = ui_hand_position(2)
	using.hud = src
	static_inventory += using

	using = new /obj/screen/swarmer/Barricade()
	using.screen_loc = ui_hand_position(1)
	using.hud = src
	static_inventory += using

	using = new /obj/screen/swarmer/Replicate()
	using.screen_loc = ui_zonesel
	using.hud = src
	static_inventory += using

	using = new /obj/screen/swarmer/RepairSelf()
	using.screen_loc = ui_storage1
	using.hud = src
	static_inventory += using

	using = new /obj/screen/swarmer/ToggleLight()
	using.screen_loc = ui_back
	using.hud = src
	static_inventory += using

	using = new /obj/screen/swarmer/ContactSwarmers()
	using.screen_loc = ui_inventory
	using.hud = src
	static_inventory += using
