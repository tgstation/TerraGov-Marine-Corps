/obj/structure/campaign
	name = "GENERIC CAMPAIGN STRUCTURE"
	desc = "THIS SHOULDN'T BE VISIBLE"
	density = TRUE
	anchored = TRUE
	allow_pass_flags = PASSABLE
	//resistance_flags = RESIST_ALL
	destroy_sound = 'sound/effects/meteorimpact.ogg'

	icon = 'icons/obj/structures/structures.dmi'


/obj/structure/campaign/destruction_objective
	name = "GENERIC CAMPAIGN DESTRUCTION OBJECTIVE"
	soft_armor = list(MELEE = 200, BULLET = 200, LASER = 200, ENERGY = 200, BOMB = 200, BIO = 200, FIRE = 200, ACID = 200)

/obj/structure/campaign/destruction_objective/Initialize(mapload)
	. = ..()
	GLOB.campaign_destroy_objectives += src

/obj/structure/campaign/destruction_objective/Destroy()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_OBJECTIVE_DESTROYED)
	GLOB.campaign_destroy_objectives -= src
	return ..()
