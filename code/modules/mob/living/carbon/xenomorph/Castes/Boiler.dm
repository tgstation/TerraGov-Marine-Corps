/datum/xeno_caste/boiler
	caste_name = "Boiler"
	display_name = "Boiler"
	upgrade_name = "Young"
	caste_desc = "Gross!"

	caste_type_path = /mob/living/carbon/Xenomorph/Boiler

	tier = 3
	upgrade = 0

	// *** Melee Attacks *** //
	melee_damage_lower = 20
	melee_damage_upper = 25

	// *** Tackle *** //
	tackle_damage = 25 

	// *** Speed *** //
	speed = 0.7

	// *** Plasma *** //
	plasma_max = 800
	plasma_gain = 30

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	upgrade_threshold = 400

	deevolves_to = /mob/living/carbon/Xenomorph/Spitter

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA

	// *** Defense *** //
	armor_deflection = 30 

	// *** Ranged Attack *** //
	spit_delay = 4 SECONDS

	// *** Boiler Abilities *** //
	bomb_strength = 1 //Multiplier to the effectiveness of the boiler glob. Improves by 0.5 per upgrade
	acid_delay = 9 SECONDS //9 seconds delay on acid. Reduced by -1 per upgrade down to 5 seconds
	bomb_delay = 20 SECONDS //20 seconds per glob at Young, -2.5 per upgrade down to 10 seconds

/datum/xeno_caste/boiler/mature
	upgrade_name = "Mature"
	caste_desc = "Some sort of abomination. It looks a little more dangerous."
	upgrade = 1

	// *** Melee Attacks *** //
	melee_damage_lower = 25
	melee_damage_upper = 30

	// *** Tackle *** //
	tackle_damage = 25 

	// *** Speed *** //
	speed = 0.6

	// *** Plasma *** //
	plasma_max = 900
	plasma_gain = 35

	// *** Health *** //
	max_health = 220

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 35

	// *** Ranged Attack *** //
	spit_delay = 3 SECONDS

	// *** Boiler Abilities *** //
	bomb_strength = 1.5 
	acid_delay = 9 SECONDS //9 seconds delay on acid. Reduced by -1 per upgrade down to 5 seconds
	bomb_delay = 20 SECONDS //20 seconds per glob at Young, -2.5 per upgrade down to 10 seconds

/datum/xeno_caste/boiler/elder
	upgrade_name = "Elder"
	caste_desc = "Some sort of abomination. It looks pretty strong."
	upgrade = 2

	// *** Melee Attacks *** //
	melee_damage_lower = 30
	melee_damage_upper = 35

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = 0.5

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 40

	// *** Health *** //
	max_health = 240

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor_deflection = 35

	// *** Ranged Attack *** //
	spit_delay = 2 SECONDS

	// *** Boiler Abilities *** //
	bomb_strength = 2 
	acid_delay = 9 SECONDS //9 seconds delay on acid. Reduced by -1 per upgrade down to 5 seconds
	bomb_delay = 20 SECONDS //20 seconds per glob at Young, -2.5 per upgrade down to 10 seconds

/datum/xeno_caste/boiler/ancient
	upgrade_name = "Ancient"
	caste_desc = "A devestating piece of alien artillery."
	upgrade = 3
	ancient_message = "You are the master of ranged artillery. Bring death from above."

	// *** Melee Attacks *** //
	melee_damage_lower = 35
	melee_damage_upper = 40

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = 0.4

	// *** Plasma *** //
	plasma_max = 1000
	plasma_gain = 50

	// *** Health *** //
	max_health = 245

	// *** Defense *** //
	armor_deflection = 35

	// *** Ranged Attack *** //
	spit_delay = 1 SECONDS

	// *** Boiler Abilities *** //
	bomb_strength = 2.5
	acid_delay = 9 SECONDS //9 seconds delay on acid. Reduced by -1 per upgrade down to 5 seconds
	bomb_delay = 20 SECONDS //20 seconds per glob at Young, -2.5 per upgrade down to 10 seconds

/mob/living/carbon/Xenomorph/Boiler
	caste_base_type = /mob/living/carbon/Xenomorph/Boiler
	name = "Boiler"
	desc = "A huge, grotesque xenomorph covered in glowing, oozing acid slime."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Boiler Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 450
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_BIG
	tier = 3
	upgrade = 0
	gib_chance = 100
	drag_delay = 6 //pulling a big dead xeno is hard
	var/is_bombarding = 0
	var/obj/item/explosive/grenade/grenade_type = "/obj/item/explosive/grenade/xeno"
	var/bomb_cooldown = 0
	var/datum/effect_system/smoke_spread/xeno_acid/smoke
	var/turf/bomb_turf = null

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid/Boiler,
		/datum/action/xeno_action/bombard,
		/datum/action/xeno_action/toggle_long_range,
		/datum/action/xeno_action/toggle_bomb,
		/datum/action/xeno_action/activable/spray_acid,
		)

/mob/living/carbon/Xenomorph/Boiler/New()
	..()
	SetLuminosity(3)
	smoke = new /datum/effect_system/smoke_spread/xeno_acid
	smoke.attach(src)
	see_in_dark = 20
	ammo = ammo_list[/datum/ammo/xeno/boiler_gas]

/mob/living/carbon/Xenomorph/Boiler/Destroy()
	SetLuminosity(0)
	if(smoke)
		qdel(smoke)
		smoke = null
	return ..()


/mob/living/carbon/Xenomorph/Boiler/proc/bomb_turf(var/turf/T)
	if(!istype(T) || T.z != src.z || T == get_turf(src))
		to_chat(src, "<span class='warning'>This is not a valid target.</span>")
		return

	if(!isturf(loc)) //In a locker
		return

	var/turf/U = get_turf(src)

	if(bomb_turf && bomb_turf != U)
		is_bombarding = 0
		if(client)
			client.mouse_pointer_icon = initial(client.mouse_pointer_icon) //Reset the mouse pointer.
		return

	if(!check_state())
		return

	if(!is_bombarding)
		to_chat(src, "<span class='warning'>You must dig yourself in before you can do this.</span>")
		return

	if(bomb_cooldown)
		to_chat(src, "<span class='warning'>You are still preparing another spit. Be patient!</span>")
		return

	if(get_dist(T, U) <= 5) //Magic number
		to_chat(src, "<span class='warning'>You are too close! You must be at least 7 meters from the target due to the trajectory arc.</span>")
		return

	if(!check_plasma(200))
		return

	var/offset_x = rand(-1, 1)
	var/offset_y = rand(-1, 1)

	if(prob(30))
		offset_x = 0
	if(prob(30))
		offset_y = 0

	var/turf/target = locate(T.x + offset_x, T.y + offset_y, T.z)

	if(!istype(target))
		return

	to_chat(src, "<span class='xenonotice'>You begin building up acid.</span>")
	if(client)
		client.mouse_pointer_icon = initial(client.mouse_pointer_icon) //Reset the mouse pointer.
	bomb_cooldown = 1
	is_bombarding = 0
	use_plasma(200)

	if(do_after(src, 50, FALSE, 5, BUSY_ICON_HOSTILE))
		if(!check_state())
			bomb_cooldown = 0
			return
		bomb_turf = null
		visible_message("<span class='xenowarning'>\The [src] launches a huge glob of acid hurling into the distance!</span>", \
		"<span class='xenowarning'>You launch a huge glob of acid hurling into the distance!</span>", null, 5)

		var/obj/item/projectile/P = new /obj/item/projectile(loc)
		P.generate_bullet(ammo)
		P.fire_at(target, src, null, ammo.max_range, ammo.shell_speed)
		playsound(src, 'sound/effects/blobattack.ogg', 25, 1)
		if(ammo.type == /datum/ammo/xeno/boiler_gas/corrosive)
			round_statistics.boiler_acid_smokes++
		else
			round_statistics.boiler_neuro_smokes++


		spawn(xeno_caste.bomb_delay) //20 seconds cooldown.
			bomb_cooldown = 0
			to_chat(src, "<span class='notice'>You feel your toxin glands swell. You are able to bombard an area again.</span>")
			update_action_button_icons()
		return
	else
		bomb_cooldown = 0
		to_chat(src, "<span class='warning'>You decide not to launch any acid.</span>")
	return
