
var/list/upgrades = typesof(/datum/upgrade) - /datum/upgrade //Removes the initial one
var/list/datum/upgrade/upgrade_list = list()

//Initializes upgrade datums. Always called at round start.
proc/initialize_upgrades()
	if(!upgrade_list.len)
		for(var/U in upgrades)
			upgrade_list += new U()

//The basic upgrade datums which hold pretty generic data.
/datum/upgrade
	var/name = "NOPE"
	var/cost = 0 //Cost in EP
	var/list/which_castes = list() //Which castes can buy this upgrade?
	var/is_global = 0
	var/is_verb = 0 //Is this a bonus verb that they get?
	var/procpath = null //Path to a proc, these will actually do all of the things.
	var/prev_required = null //Does this upgrade need a previous one bought to buy it?
	var/u_tag = null //A u_tag string so we can grab it easily off a xeno. Must be unique.
	var/helptext = ""

/datum/upgrade/claws1
	name = "Enhanced Claws"
	cost = 20
	which_castes = list(
						/mob/living/carbon/Xenomorph/Carrier,
						/mob/living/carbon/Xenomorph/Drone,
						/mob/living/carbon/Xenomorph/Hivelord,
						/mob/living/carbon/Xenomorph/Lurker,
						/mob/living/carbon/Xenomorph/Praetorian,
						/mob/living/carbon/Xenomorph/Ravager,
						/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Sentinel,
						/mob/living/carbon/Xenomorph/Spitter
					)
	procpath = /mob/living/carbon/Xenomorph/proc/upgrade_claws
	u_tag = "eclaws"
	helptext = "Your claws become sharper and lighter, making your slash attacks deal more damage."

//More useful on weaker xenos since it's a flat bonus
/mob/living/carbon/Xenomorph/proc/upgrade_claws()
	melee_damage_lower += 10
	melee_damage_upper += 10
	src << "<span class='xenonotice'>Your claws feel sharper.</span>"
	update_icons()

/datum/upgrade/claws2
	name = "Razor Claws"
	cost = 30
	which_castes = list(
						/mob/living/carbon/Xenomorph/Lurker,
						/mob/living/carbon/Xenomorph/Praetorian,
						/mob/living/carbon/Xenomorph/Ravager,
						/mob/living/carbon/Xenomorph/Runner
					)
	prev_required = "Enhanced Claws"
	procpath = /mob/living/carbon/Xenomorph/proc/upgrade_claws2
	u_tag = "zclaws"
	helptext = "Your claws become razor-sharp, allowing you to cut through a foe's armor."

/mob/living/carbon/Xenomorph/proc/upgrade_claws2()
	melee_damage_lower += 10
	melee_damage_upper += 10
	src << "<span class='xenonotice'>Your claws feel razor sharp.</span>"

/datum/upgrade/claws3
	name = "Corrosive Claws"
	cost = 40
	which_castes = list(
						/mob/living/carbon/Xenomorph/Praetorian,
						/mob/living/carbon/Xenomorph/Sentinel,
						/mob/living/carbon/Xenomorph/Spitter
					)
	prev_required = "Enhanced Claws"
	procpath = /mob/living/carbon/Xenomorph/proc/upgrade_claws3
	u_tag = "tclaws"
	helptext = "Your claws are cut and dripping with acid blood, dealing damage over time to slashed enemies."

/mob/living/carbon/Xenomorph/proc/upgrade_claws3()
	melee_damage_lower += 5
	src << "<span class='xenonotice'>Your claws drip with corrosive acid.</span>"

/datum/upgrade/claws4
	name = "Resin Claws"
	cost = 40
	which_castes = list(
						/mob/living/carbon/Xenomorph/Carrier,
						/mob/living/carbon/Xenomorph/Drone,
						/mob/living/carbon/Xenomorph/Hivelord
					)
	prev_required = "Enhanced Claws"
	procpath = /mob/living/carbon/Xenomorph/proc/upgrade_claws4
	u_tag = "rclaws"
	helptext = "Your claws are coated with fibrous resin, dealing less damage but allowing easy knockdowns."

/mob/living/carbon/Xenomorph/proc/upgrade_claws4()
	src << "<span class='xenonotice'>Your claws drip with sticky resin.</span>"

/datum/upgrade/armor
	name = "Hardened Carapace"
	cost = 20
	which_castes = list(
						/mob/living/carbon/Xenomorph/Carrier,
						/mob/living/carbon/Xenomorph/Drone,
						/mob/living/carbon/Xenomorph/Hivelord,
						/mob/living/carbon/Xenomorph/Lurker,
						/mob/living/carbon/Xenomorph/Praetorian,
						/mob/living/carbon/Xenomorph/Ravager,
						/mob/living/carbon/Xenomorph/Sentinel,
						/mob/living/carbon/Xenomorph/Spitter
					)
	procpath = /mob/living/carbon/Xenomorph/proc/upgrade_armor
	u_tag = "cara"
	helptext = "Your exoskeleton becomes thicker, protecting you from projectiles."

/mob/living/carbon/Xenomorph/proc/upgrade_armor()
	if(src.armor_deflection > 0)
		armor_deflection += 15
	else
		armor_deflection = 60
	src << "<span class='xenonotice'>Your exoskeleton feels thicker.</span>"

/datum/upgrade/armor2
	name = "Increased Musclemass"
	cost = 30
	which_castes = list(
						/mob/living/carbon/Xenomorph/Hivelord,
						/mob/living/carbon/Xenomorph/Lurker,
						/mob/living/carbon/Xenomorph/Praetorian,
						/mob/living/carbon/Xenomorph/Ravager
					)
	prev_required = "Hardened Carapace"
	procpath = /mob/living/carbon/Xenomorph/proc/upgrade_health
	u_tag = "health"
	helptext = "You become bulkier, granting you increased maximum health."

/mob/living/carbon/Xenomorph/proc/upgrade_health()
	src.maxHealth = round(maxHealth * 5 / 4) + 10 //20% + 10
	src << "<span class='xenonotice'>You feel bulkier.</span>"

/datum/upgrade/armor3
	name = "Blast Resistance"
	cost = 60
	which_castes = list(
						/mob/living/carbon/Xenomorph/Carrier,
						/mob/living/carbon/Xenomorph/Drone,
						/mob/living/carbon/Xenomorph/Hivelord,
						/mob/living/carbon/Xenomorph/Lurker,
						/mob/living/carbon/Xenomorph/Praetorian,
						/mob/living/carbon/Xenomorph/Ravager,
						/mob/living/carbon/Xenomorph/Sentinel,
						/mob/living/carbon/Xenomorph/Spitter
					)
	prev_required = "Hardened Carapace"
	procpath = /mob/living/carbon/Xenomorph/proc/upgrade_bombs
	u_tag = "antibomb"
	helptext = "You grow a layer of insulation under your exoskeleton, protecting you from explosions."

/mob/living/carbon/Xenomorph/proc/upgrade_bombs()
	src.maxHealth = round(maxHealth * 8 / 7)
	src << "<span class='xenonotice'>You grow a new layer on your exoskeleton.</span>"

/datum/upgrade/armor4
	name = "Reinforced Exoskeleton"
	cost = 70
	which_castes = list(
						/mob/living/carbon/Xenomorph/Hivelord,
						/mob/living/carbon/Xenomorph/Lurker,
						/mob/living/carbon/Xenomorph/Praetorian,
						/mob/living/carbon/Xenomorph/Ravager
					)
	prev_required = "Increasd Musclemass"
	procpath = /mob/living/carbon/Xenomorph/proc/upgrade_armor2
	u_tag = "cara2"
	helptext = "Your exoskeleton is further hardened, protecting you from projectiles and melee attacks."

/mob/living/carbon/Xenomorph/proc/upgrade_armor2()
	src.maxHealth = round(maxHealth * 6 / 5) + 20
	src << "<span class='xenonotice'>Your exoskeleton grows thick as stone.</span>"

/datum/upgrade/armor5
	name = "Razors"
	cost = 70
	which_castes = list(
						/mob/living/carbon/Xenomorph/Carrier,
						/mob/living/carbon/Xenomorph/Drone,
						/mob/living/carbon/Xenomorph/Hivelord,
						/mob/living/carbon/Xenomorph/Lurker,
						/mob/living/carbon/Xenomorph/Praetorian,
						/mob/living/carbon/Xenomorph/Ravager,
						/mob/living/carbon/Xenomorph/Sentinel,
						/mob/living/carbon/Xenomorph/Spitter
					)
	prev_required = "Hardened Carapace"
	procpath = /mob/living/carbon/Xenomorph/proc/upgrade_armor3
	u_tag = "cara3"
	helptext = "You have sharp spines on your exoskeleton, damaging enemies you bump into."

/mob/living/carbon/Xenomorph/proc/upgrade_armor3()
	src << "<span class='xenonotice'>Razor sharp spikes spring from your exoskeleton.</span>"

/datum/upgrade/jelly
	name = "Quickened Evolution"
	cost = 50
	which_castes = list(
						/mob/living/carbon/Xenomorph/Carrier,
						/mob/living/carbon/Xenomorph/Drone,
						/mob/living/carbon/Xenomorph/Hivelord,
						/mob/living/carbon/Xenomorph/Lurker,
						/mob/living/carbon/Xenomorph/Praetorian,
						/mob/living/carbon/Xenomorph/Ravager,
						/mob/living/carbon/Xenomorph/Runner,
						/mob/living/carbon/Xenomorph/Sentinel,
						/mob/living/carbon/Xenomorph/Spitter
					)
	procpath = /mob/living/carbon/Xenomorph/proc/upgrade_jelly
	u_tag = "jelly"
	helptext = "Quicken the speed at which royal jelly metabolizes, granting you new forms faster."

/mob/living/carbon/Xenomorph/proc/upgrade_jelly()
	if(evolution_allowed)
		evolution_stored += 50
	else
		evolution_allowed = 1
		evolution_stored += 10

	src << "<span class='xenonotice'>You feel royal jelly ripple through your haemolymph.</span>"

//Changes a xeno's evolution points.
/mob/living/carbon/Xenomorph/proc/change_ep(var/amount)
	if(!src || !amount)
		return
	if(stat == DEAD)
		return //Dead xenos do not change at all.

	evo_points += amount
	if(evo_points < 0)
		evo_points = 0
	if(evo_points > 1000)
		evo_points = 1000

//Checks to see if they can spend some EP, and removes or adds it.
/mob/living/carbon/Xenomorph/proc/check_ep(var/amount)
	if(!src)
		return 0

	if(evo_points - amount < 0)
		src << "<span class='warning'>You lack the required amount of evolution points - you need <B>[amount]</b> but have only <B>[evo_points]</b>.</span>"
		return 0

	change_ep(amount)
	return 1

/mob/living/carbon/Xenomorph/proc/has_upgrade(var/u_tag)
	if(!src || !u_tag)
		return 0

	if(u_tag in upgrades_bought)
		return 1

	return 0

proc/get_upgrade_by_u_tag(var/u_tag)
	for(var/datum/upgrade/U in upgrade_list)
		if(U.u_tag == u_tag)
			return U
	return null

//Also reduces evo points.
/mob/living/carbon/Xenomorph/proc/add_upgrade(var/datum/upgrade/U)
	if(!src)
		return 0
	if(stat == DEAD)
		return 0
	if(!U || !istype(U) || U.u_tag == null)
		return 0
	if(has_upgrade(U.u_tag))
		return 0 //They already have it.

	upgrades_bought += U.u_tag
	change_ep(U.cost * -1) //Negative value of cost
	call(src, U.procpath)()
