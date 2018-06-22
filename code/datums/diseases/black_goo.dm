//Disease Datum
/datum/disease/black_goo
	name = "Black Goo"
	max_stages = 5
	cure = "Anti-Zed"
	cure_id = "antiZed"
	spread = "Bites"
	spread_type = SPECIAL
	affected_species = list("Human")
	curable = 0
	cure_chance = 100
	desc = ""
	severity = "Medium"
	agent = "Unknown Biological Organism X-65"
	hidden = list(1,0) //Hidden from med-huds, but not pandemic scanners.  BLOOD TESTS FOR THE WIN
	permeability_mod = 2
	stage_prob = 4
	stage_minimum_age = 150
	survive_mob_death = FALSE //switch to true to make dead infected humans still transform
	var/zombie_transforming = 0 //whether we're currently transforming the host into a zombie.
	var/goo_message_cooldown = 0 //to make sure we don't spam messages too often.


/datum/disease/black_goo/stage_act()
	..()
	if(!ishuman(affected_mob)) return
	var/mob/living/carbon/human/H = affected_mob
	if(!H.regenZ) return
	if(age > 1.5*stage_minimum_age) stage_prob = 100 //if it takes too long we force a stage increase
	else stage_prob = initial(stage_prob)
	if(H.stat == DEAD) stage_minimum_age = 75 //the virus progress faster when the host is dead.
	switch(stage)
		if(1)
			survive_mob_death = TRUE //changed because infection rate was REALLY horrible.
			if(goo_message_cooldown < world.time )
				if(prob(3))
					affected_mob << "\red You feel really warm..."
					goo_message_cooldown = world.time + 100
		if(2)
			if(goo_message_cooldown < world.time)
				if (prob(3)) affected_mob << "\red Your throat is really dry..."
				else if (prob(6)) affected_mob << "\red You feel really warm..."
				else if (prob(2)) H.vomit_on_floor()
				goo_message_cooldown = world.time + 100
		if(3)
			hidden = list(0,0)
			//survive_mob_death = TRUE //even if host dies now, the transformation will occur.
			H.next_move_slowdown = max(H.next_move_slowdown, 1)
			if(goo_message_cooldown < world.time)
				if (prob(3))
					affected_mob << "\red You cough up some black fluid..."
					goo_message_cooldown = world.time + 100
				else if (prob(6))
					affected_mob << "\red Your throat is really dry..."
					goo_message_cooldown = world.time + 100
				else if (prob(9))
					affected_mob << "\red You feel really warm..."
					goo_message_cooldown = world.time + 100
				else if(prob(5))
					goo_message_cooldown = world.time + 100
					H.vomit_on_floor()
		if(4)
			H.next_move_slowdown = max(H.next_move_slowdown, 2)
			if(prob(5) || age >= stage_minimum_age-1)
				if(!zombie_transforming)
					zombie_transform(H)
			else if(prob(5))
				H.vomit_on_floor()
		if(5)
			if(!zombie_transforming && prob(10))
				if(H.stat != DEAD)
					var/healamt = H.stat ? 5 : 1
					if(H.health < H.maxHealth)
						H.adjustFireLoss(-healamt)
						H.adjustBruteLoss(-healamt)
						H.adjustToxLoss(-healamt)
						H.adjustOxyLoss(-healamt)
				H.nutrition = 450 //never hungry
				if(goo_message_cooldown < world.time)
					goo_message_cooldown = world.time + 100
					affected_mob << "\green Spread... Consume... Infect..."


/datum/disease/black_goo/proc/zombie_transform(mob/living/carbon/human/H)
	set waitfor = 0
	zombie_transforming = TRUE
	H.vomit_on_floor()
	H.AdjustStunned(5)
	sleep(20)
	H.make_jittery(500)
	sleep(30)
	if(H && H.loc)
		if(H.stat == DEAD) H.revive(TRUE)
		playsound(H.loc, 'sound/hallucinations/wail.ogg', 25, 1)
		H.jitteriness = 0
		H.set_species("Zombie")
		stage = 5
		zombie_transforming = FALSE


/obj/item/weapon/zombie_claws
	name = "claws"
	icon = 'icons/mob/human_races/r_zombie.dmi'
	icon_state = "claw_l"
	flags_item = NODROP|DELONDROP
	force = 15
	w_class = 6
	sharp = 1
	attack_verb = list("slashed", "bite", "tore", "scraped", "nibbled")
	pry_capable = IS_PRY_CAPABLE_FORCE

/obj/item/weapon/zombie_claws/attack(mob/living/M, mob/living/carbon/human/user, def_zone)
	if(user.species == "Human")
		return 0
	. = ..()
	playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1, 5)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.name == "Human")
			for(var/datum/disease/black_goo/BG in H.viruses)
				user.show_message(text("\green <B>You sense your target is infected</B>"))
				return
			if(prob(75))
				M.contract_disease(new /datum/disease/black_goo)
				user.show_message(text("\green <B>You sense your target is now infected</B>"))


/obj/item/weapon/zombie_claws/afterattack(obj/O as obj, mob/user as mob, proximity)
	if (istype(O, /obj/machinery/door/airlock) && get_dist(src, O) <= 1)
		var/obj/machinery/door/airlock/D = O
		if(!D.density)
			return

		user.visible_message("<span class='danger'>[user] jams \his [name] into [O] and strains to rip it open.</span>",
		"<span class='danger'>You jam your [name] into [O] and strain to rip it open.</span>")
		playsound(user, 'sound/weapons/wristblades_hit.ogg', 15, 1)
		if(do_after(user, 30, TRUE, 5, BUSY_ICON_HOSTILE))
			user.visible_message("<span class='danger'>[user] forces [O] open with \his [name].</span>",
			"<span class='danger'>You force [O] open with your [name].</span>")
			D.open(1)

/obj/item/reagent_container/food/drinks/bottle/black_goo
	name = "strange bottle"
	desc = "A strange bottle of unknown origin."
	icon = 'icons/obj/black_goo/black_goo_stuff.dmi'
	icon_state = "blackgoo"
	New()
		..()
		reagents.add_reagent("blackgoo", 30)


/obj/item/reagent_container/food/drinks/bottle/black_goo_cure
	name = "even stranger bottle"
	desc = "A bottle of black labeled CURE..."
	icon = 'icons/obj/black_goo/black_goo_stuff.dmi'
	icon_state = "blackgoo"
	New()
		..()
		reagents.add_reagent("antiZed", 30)

/datum/language/zombie
	name = "Zombie"
	desc = "If you select this from the language screen, expect a ban."
	colour = "green"
	key = "4"
	flags = RESTRICTED


/obj/item/clothing/glasses/zombie_eyes
	name = "zombie eyes"
	icon = null
	w_class = 2.0
	vision_flags = SEE_MOBS
	darkness_view = 7
	flags_item = NODROP|DELONDROP
	fullscreen_vision = /obj/screen/fullscreen/nvg



/obj/item/storage/fancy/blackgoo
	icon = 'icons/obj/black_goo/black_goo_stuff.dmi'
	icon_state = "goobox"
	icon_type = "goo"
	name = "strange canister"
	desc = "A strange looking metal container."
	storage_slots = 3
	can_hold = list("/obj/item/reagent_container/food/drinks/bottle/black_goo")


	examine(mob/user)
		user << "A strange looking metal container..."
		if(contents.len <= 0)
			user << "There are no bottles left inside it."
		else if(contents.len == 1)
			user << "There is one bottles left inside it."
		else
			user << "There are [src.contents.len] bottles inside the container."


/obj/item/storage/fancy/blackgoo/New()
	..()
	for(var/i=1; i <= storage_slots; i++)
		new /obj/item/reagent_container/food/drinks/bottle/black_goo(src)
	return

//zombie ice-proofing
/obj/item/clothing/mask/rebreather/scarf/zombie
	name = "zombie mouth"
	icon_state = "BLANK"
	item_state = "BLANK"
	flags_item = NODROP|DELONDROP

