#define NOTHING_SPECIAL 0
#define RELOAD_GUN 1
#define HEAL_MARINE 2
#define GETTING_GUN 3
#define RUN_AWAY 4

/mob/living/carbon/human/AI //It's like AI xenomorphs but now humans
	name = "boi" //Placeholder name, name is applied dynamically when this is created
	var/role = "Marine" //Type of thing it is, can be a medic, leader or engineer
	a_intent = "hurt" //All shall die
	var/doingaction = 0 //If it's doing an action that has a delay IE dousing an object in acid, certain abilities
	var/queuedmovement //The direction you want the AI to go on next, if it wanted to go NW the CustomMove() will go North then West
	var/mob/living/carbon/human/target_mob
	var/mob/living/carbon/human/LeaderToFollow //A mob that this AI will follow
	var/obj/item/weapon/gun/thegun //This is my gun, it's good
	var/move_to_delay = 2
	var/skills_type = /datum/skills/early_synthetic

/obj/item/weapon/gun/rifle/m41a/gyro //Starts with a gyro, for AI marines
	starting_attachment_types = list(/obj/item/attachable/gyro)
	current_mag = /obj/item/ammo_magazine/rifle/iff

/datum/ammo/bullet/rifle/iff
	iff_signal = ACCESS_IFF_MARINE
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SKIPS_HUMANS

/datum/ammo/bullet/rifle/iff/New()
	..()
	accurate_range = CONFIG_GET(number/combat_define/short_shell_range)
	damage = CONFIG_GET(number/combat_define/llow_hit_damage)
	penetration = CONFIG_GET(number/combat_define/min_armor_penetration)

/obj/item/ammo_magazine/rifle/iff //Special magazine that has no friendly fire bullets; does horrible damage
	name = "\improper M41A magazine (10x24mm)"
	desc = "A 10mm assault rifle magazine."
	caliber = "10x24mm"
	icon_state = "m41a"
	w_class = 3
	default_ammo = /datum/ammo/bullet/rifle/iff
	max_rounds = 40
	gun_type = /obj/item/weapon/gun/rifle/m41a

/mob/living/carbon/human/AI/New()
	..()
	real_name = "AI [role] Number [rand(1, 999999)]"
	ConsiderMovement()
<<<<<<< HEAD
	equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(), SLOT_EARS)
	equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(), SLOT_W_UNIFORM)
	equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC(), SLOT_WEAR_SUIT)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(), SLOT_GLOVES)
	equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC(), SLOT_HEAD)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(), SLOT_SHOES)
	equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(), SLOT_WEAR_MASK)
	equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(), SLOT_BACK)
	equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3/vp70(), SLOT_BELT)
	thegun = new /obj/item/weapon/gun/rifle/m41a/gyro()
	equip_to_slot(thegun, SLOT_S_STORE)
=======
	equip_to_slot_or_del(new /obj/item/device/radio/headset/distress/PMC(), WEAR_EAR)
	equip_to_slot_or_del(new /obj/item/clothing/under/marine/veteran/PMC(), WEAR_BODY)
	equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine/veteran/PMC(), WEAR_JACKET)
	equip_to_slot_or_del(new /obj/item/clothing/gloves/marine/veteran/PMC(), WEAR_HANDS)
	equip_to_slot_or_del(new /obj/item/clothing/head/helmet/marine/veteran/PMC(), WEAR_HEAD)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/veteran/PMC(), WEAR_FEET)
	equip_to_slot_or_del(new /obj/item/clothing/mask/gas/PMC(), WEAR_FACE)
	equip_to_slot_or_del(new /obj/item/storage/backpack/satchel(), WEAR_BACK)
	equip_to_slot_or_del(new /obj/item/storage/belt/gun/m4a3/vp70(), WEAR_WAIST)
	thegun = new /obj/item/weapon/gun/rifle/m41a/gyro()
	equip_to_slot(thegun, WEAR_J_STORE)
>>>>>>> parent of fa8f5121f... Revert "good bye master"
	//equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m39/elite(), WEAR_J_STORE)
	//equip_to_slot_or_del(new /obj/item/storage/pouch/firstaid/full(), WEAR_L_STORE)
	//equip_to_slot_or_del(new /obj/item/storage/pouch/magazine/large/pmc_m39(), WEAR_R_STORE)
	mind.set_cm_skills(skills_type)
<<<<<<< HEAD
	var/obj/item/card/id/someid = new/obj/item/card/id()
	someid.access = ALL_MARINE_ACCESS
	equip_to_slot(someid, SLOT_WEAR_ID)
=======
>>>>>>> parent of fa8f5121f... Revert "good bye master"

/mob/living/carbon/human/AI/proc/ConsiderMovement() //Ah damm not this again
	if(stat == DEAD || !src)
		return //Ded forever feelsbad
	if(canmove)
		if(doingaction)
			switch(doingaction)
				if(RELOAD_GUN)
					HandleReload()

				if(GETTING_GUN) //Get the damm gun
					if(queuedmovement)
						CustomMove(src, get_step(src, queuedmovement), queuedmovement)
					else
						var/turf/turftogun = get_step(src, get_turf(thegun))
						CustomMove(src, turftogun, get_dir(src, thegun))
						queuedmovement = 0

				if(RUN_AWAY) //Target mob is way too close, we gotta run away and kite it
					if(queuedmovement)
						CustomMove(src, get_step(src, queuedmovement), queuedmovement)
					else
						var/turf/turfaway = get_step_to(src, target_mob, rand(2, 3)) //Keep some distance
						CustomMove(src, turfaway, get_dir(src, turfaway))
						queuedmovement = 0

		else
			if(doingaction == NOTHING_SPECIAL) //Follow the leader if possible
				if(queuedmovement)
					CustomMove(src, get_step(src, queuedmovement), queuedmovement)
				else
					if(LeaderToFollow)
						if(LeaderToFollow && get_dist(src, LeaderToFollow) < 14) //Follow the leader!
							var/turf/turftoleader = get_step_to(src, LeaderToFollow, rand(2, 3)) //Keep some distance
							CustomMove(src, turftoleader, get_dir(src, turftoleader))
							queuedmovement = 0
		ConsiderActions()
		ConsiderAttack()
		GetAndSetTarget(7)
	spawn(move_to_delay + movement_delay() + 1) //Worst way to program a AI for 500 points
		ConsiderMovement()


/mob/living/carbon/human/AI/proc/ConsiderActions() //Special things like healing or throwing things or repairing
	return

/mob/living/carbon/human/AI/proc/RemoveTarget() //Removes all of the target_mob and things associated with it
	if(target_mob)
		target_mob = null

/mob/living/carbon/human/AI/proc/GetAndSetTarget(range) //Attempts to get and set the target
	for(var/mob/living/carbon/Xenomorph/xeno in hearers(range, src))
		if(xeno)
			if(target_mob && (target_mob != xeno) && (get_dist(src, xeno) < get_dist(src, target_mob)))
				SetTarget(xeno)
			else
				if(!target_mob)
					SetTarget(xeno)
				else
					continue
	if(target_mob && target_mob.stat >= DEAD) //It ded and no nearby targets found, it's idle time
		RemoveTarget()

/mob/living/carbon/human/AI/proc/SetTarget(mob/living/carbon/Xenomorph/target) //Gives the mob this specific target
	if(target)
		target_mob = target
	ConsiderAttack() //Try seeing if it's actually nearby and attack

/mob/living/carbon/human/AI/proc/ConsiderAttack() //We gotta be shooting something man
	if(target_mob.stat == DEAD)
		RemoveTarget()
		return
	if(target_mob && thegun)	//We want to see if the gun is in our hands, wielded, loaded with ammo and actually shoot
		if(get_dist(src, target_mob) < 2)
			doingaction = RUN_AWAY
		else
			if(doingaction == RUN_AWAY)
				doingaction = NOTHING_SPECIAL
		if((r_hand == thegun || l_hand == thegun) && (thegun.able_to_fire())) //See if the guns already in the hand
			thegun.wield(src) //Hacky
			if(thegun.current_mag.current_rounds <= 5 || !thegun.current_mag) //If this doesn't work, there's a **high** chance it gotta be reloaded
				HandleReload()
			//if(IsClearPath(get_turf(src), target_mob, TRUE, thegun.in_chamber))
			face_atom(target_mob)
			thegun.Fire(target_mob, src)
			//thegun.afterattack(target_mob, src) //Finally we can shoot the gun and hope it kills

		else //Gun ain't in hand but it exists, grab the gun that's hopefully in the suit storage
			if(get_dist(src, thegun) < 2)
				put_in_hands(thegun)
				doingaction = NOTHING_SPECIAL
				ConsiderAttack()
			else //Gun is far away, we gotta pick up the damm gun by getting close to it
				doingaction = GETTING_GUN
	else //No gun? screwed marine
		if(target_mob.stat == DEAD)
			RemoveTarget()
		return

/mob/living/carbon/human/AI/examine(mob/examiner)
	if(istype(examiner, /mob/living/carbon/human))
		if(LeaderToFollow == examiner)
			LeaderToFollow = null
			say("I no longer follow [examiner]!")
		else
			LeaderToFollow = examiner
			say("I follow [examiner]!")
	..()

/mob/living/carbon/human/AI/proc/HandleReload()
	say(pick("RELOADING!", "SWAPPING MAGS!", "COVER ME I'M RELOADING!", "SWITCHING MAGS!"))
	thegun.unload(src, TRUE, TRUE) //Chances are there could still be a magazine inside
	var/obj/item/ammo_magazine/rifle/iff/mag = new/obj/item/ammo_magazine/rifle/iff()
	thegun.replace_magazine(src, mag)
	doingaction = NOTHING_SPECIAL

/mob/living/carbon/human/AI/medic
	role = "Medic" //It's a medic, new ConsiderAbilities for it to heal things
