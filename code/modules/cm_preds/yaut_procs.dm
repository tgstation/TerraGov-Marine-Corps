//Update the power display thing. This is called in Life()
/mob/living/carbon/human/proc/update_power_display(var/perc)
	if(pred_power_icon)
		switch(perc)
			if(91 to INFINITY)
				pred_power_icon.icon_state = "powerbar100"
			if(81 to 91)
				pred_power_icon.icon_state = "powerbar90"
			if(71 to 81)
				pred_power_icon.icon_state = "powerbar80"
			if(61 to 71)
				pred_power_icon.icon_state = "powerbar70"
			if(51 to 61)
				pred_power_icon.icon_state = "powerbar60"
			if(41 to 51)
				pred_power_icon.icon_state = "powerbar50"
			if(31 to 41)
				pred_power_icon.icon_state = "powerbar40"
			if(21 to 31)
				pred_power_icon.icon_state = "powerbar30"
			if(11 to 21)
				pred_power_icon.icon_state = "powerbar20"
			else
				pred_power_icon.icon_state = "powerbar10"

//Uses the base hud_data, which is human, but just tweaks one lil thing.
/datum/hud_data/yautja
	is_yautja = 1

/mob/living/carbon/human/proc/butcher()
	set category = "Yautja"
	set name = "Butcher"
	set desc = "Butcher a corpse you're standing on for its tasty meats."

	if(stat || paralysis || stunned || weakened || lying || restrained() || buckled)
		src << "You're not able to do that right now."
		return

	var/list/choices = list()
	for(var/mob/living/carbon/M in view(1,src))
		if(Adjacent(M) && M.stat)
			if(istype(M,/mob/living/carbon/human))
				var/mob/living/carbon/human/Q = M
				if(Q.species && Q.species.name == "Yautja")
					continue
			choices += M

	if(src in choices)
		choices -= src

	var/mob/living/carbon/T = input(src,"What do you wish to butcher?") as null|anything in choices

	if(!T || !src || !T.stat)
		src << "Nope."
		return

	if(!Adjacent(T))
		src << "You have to be next to your target."
		return

	if(istype(T,/mob/living/carbon/Xenomorph/Larva))
		src << "This tiny worm is not even worth using your tools on."
		return

	if(stat || paralysis || stunned || weakened || lying || restrained() || buckled)
		src << "Not right now."
		return

	if(!T) return

	if(T.butchery_progress)
		playsound(loc, 'sound/weapons/pierce.ogg', 50)
		visible_message("<b>[src] goes back to butchering \the [T].</b>","<b>You get back to butchering \the [T].</b>")
	else
		playsound(loc, 'sound/weapons/pierce.ogg', 50)
		visible_message("<b>[src] begins chopping and mutilating \the [T].</b>","<b>You take out your tools and begin your gruesome work on \the [T]. Hold still.</b>")
		T.butchery_progress = 1


	if(T.butchery_progress == 1)
		if(do_after(src,70) && Adjacent(T))
			visible_message("[src] makes careful slices and tears out the viscera in \the [T]'s abdominal cavity.","You carefully vivisect \the [T], ripping out the guts and useless organs. What a stench!")
			T.butchery_progress = 2
			playsound(loc, 'sound/weapons/slash.ogg', 50)
		else
			src << "You pause your butchering for later."

	if(T.butchery_progress == 2)
		if(do_after(src,65) && Adjacent(T))
			visible_message("[src] hacks away at \the [T]'s limbs and slices off strips of dripping meat.","You slice off a few of \the [T]'s limbs, making sure to get the finest cuts.")
			if(istype(T,/mob/living/carbon/Xenomorph) && isturf(T.loc))
				new /obj/item/weapon/reagent_containers/food/snacks/xenomeat(T.loc)
			else if(istype(T,/mob/living/carbon/human) && isturf(T.loc))
				T.apply_damage(100,BRUTE,pick("r_leg","l_leg","r_arm","l_arm"),0,1,1) //Basically just rips off a random limb.
				new /obj/item/weapon/reagent_containers/food/snacks/meat(T.loc)
			T.butchery_progress = 3
			playsound(loc, 'sound/weapons/bladeslice.ogg', 50)
		else
			src << "You pause your butchering for later."

	if(T.butchery_progress == 3)
		if(do_after(src,70) && Adjacent(T))
			visible_message("[src] tears apart \the [T]'s ribcage and begins chopping off bit and pieces.","You rip open \the [T]'s ribcage and start tearing the tastiest bits out.")
			if(istype(T,/mob/living/carbon/Xenomorph) && isturf(T.loc))
				new /obj/item/weapon/reagent_containers/food/snacks/xenomeat(T.loc)
			else if(istype(T,/mob/living/carbon/human) && isturf(T.loc))
				new /obj/item/weapon/reagent_containers/food/snacks/meat(T.loc)
			T.apply_damage(100,BRUTE,"chest",0,0,0) //Does random serious damage, so we make sure they're dead.
			T.butchery_progress = 4
			playsound(loc, 'sound/weapons/wristblades_hit.ogg', 50)
		else
			src << "You pause your butchering for later."

	if(T.butchery_progress == 4)
		if(do_after(src,90) && Adjacent(T))
			if(istype(T,/mob/living/carbon/Xenomorph) && isturf(T.loc))
				visible_message("<b>[src] flenses the last of [T]'s exoskeleton, revealing only bones!</b>.","<b>You flense the last of [T]'s exoskeleton clean off!</b>")
				new /obj/effect/decal/remains/xeno(T.loc)
				new /obj/item/stack/sheet/animalhide/xeno(T.loc)
			else if(istype(T,/mob/living/carbon/human) && isturf(T.loc))
				visible_message("<b>[src] reaches down and rips out \the [T]'s spinal cord and skull!</b>.","<b>You firmly grip the revealed spinal column and rip [T]'s head off!</b>")
				var/mob/living/carbon/human/H = T
				if(H.get_organ("head"))
					H.apply_damage(150,BRUTE,"head",0,1,1)
				else
					new /obj/item/weapon/reagent_containers/food/snacks/meat(T.loc)
				new /obj/item/stack/sheet/animalhide/human(T.loc)
				new /obj/effect/decal/remains/human(T.loc)
			T.butchery_progress = 5 //Won't really matter.
			playsound(loc, 'sound/weapons/slice.ogg', 50)
			src << "\blue You finish butchering!"
			del(T)
		else
			src << "You pause your butchering for later."

	return

/area/yautja
	name = "\improper Yautja Ship"
	icon_state = "teleporter"
	music = "signal"

/mob/living/carbon/human/proc/pred_buy()
	set category = "Yautja"
	set name = "Claim Equipment"
	set desc = "When you're on the Predator ship, claim some gear. You can only do this ONCE."

	if(stat || paralysis || stunned || weakened || lying || restrained() || buckled)
		src << "You're not able to do that right now."
		return

	if(!isYautja(src))
		src << "How did you get this verb?"
		return

	if(!istype(get_area(src),/area/yautja))
		src << "Not here. Only on the ship."
		return

	if(pred_bought)
		return

	var/sure = alert("An array of powerful weapons are displayed to you. Pick your gear carefully. If you cancel at any point, you will not claim your equipment.","Sure?","Begin the Hunt","No, not now")
	if(sure == "Begin the Hunt")
		var/list/melee = list("The Lumbering Glaive", "The Rending Chain-Whip","The Piercing Hunting Sword","The Cleaving War-Scythe", "The Adaptive Combi-Stick")
		var/list/other = list("The Fleeting Speargun", "The Brutal Plasma Rifle", "The Purifying Smart-Disc","The Enhanced Bracer")//, "The Clever Hologram")

		var/msel = input("Which weapon shall you use on your hunt?:","Melee Weapon") as null|anything in melee
		if(!msel) return //We don't want them to cancel out then get nothing.
		var/mother_0 = input("Which secondary gear shall you take?","Item 1 (of 2)") as null|anything in other
		if(!mother_0) return
		var/mother_1 = input("And the last piece of equipment?:","Item 2 (of 2)") as null|anything in other
		if(!mother_1) return

		if(pred_bought) return //Tried to run it several times in the same loop. That's not happening.

		var/obj/item/clothing/gloves/yautja/Y = src.gloves
		pred_bought = 1		//vvvvv This is the laziest fucking way. Ever. Jesus. I am genuinely sorry (it's okai abbi) //This should be a gauntlet variable.
		switch(msel)
			if("The Lumbering Glaive")
				new /obj/item/weapon/twohanded/glaive(src.loc)
			if("The Rending Chain-Whip")
				new /obj/item/weapon/melee/yautja_chain(src.loc)
			if("The Piercing Hunting Sword")
				new /obj/item/weapon/melee/yautja_sword(src.loc)
			if("The Cleaving War-Scythe")
				new /obj/item/weapon/melee/yautja_scythe(src.loc)
			if("The Adaptive Combi-Stick")
				new /obj/item/weapon/melee/combistick(src.loc)

		switch(mother_0)
			if("The Fleeting Speargun")
				new /obj/item/weapon/gun/launcher/speargun(src.loc)
			if("The Brutal Plasma Rifle")
				new /obj/item/weapon/gun/launcher/plasmarifle(src.loc)
			if("The Purifying Smart-Disc")
				new /obj/item/weapon/grenade/spawnergrenade/smartdisc(src.loc)
			if("The Enhanced Bracer")
				if(istype(Y))
					Y.charge_max += 500
					Y.upgrades++

		switch(mother_1)
			if("The Fleeting Speargun")
				new /obj/item/weapon/gun/launcher/speargun(src.loc)
			if("The Brutal Plasma Rifle")
				new /obj/item/weapon/gun/launcher/plasmarifle(src.loc)
			if("The Purifying Smart-Disc")
				new /obj/item/weapon/grenade/spawnergrenade/smartdisc(src.loc)
			if("The Enhanced Bracer")
				if(istype(Y))
					Y.charge_max += 500
					Y.upgrades++

		if(istype(Y))
			if(Y.upgrades >= 1)
				src << "\green <B>Your [Y.name] hums as it receives a battery and translator upgrade.</b>"
				var/newverb = /obj/item/clothing/gloves/yautja/proc/translate
				Y.verbs |= newverb
			if (Y.upgrades == 2)
				src << "\green <B>Your [Y.name] can now translate to xenomorph hives as well.</b>"
				src << "\green <B>Your [Y.name] has been upgraded to carry a scimitar instead of blades.</b>"
	return

/proc/get_whitelisted_predators(var/readied = 1)
	// Assemble a list of active players who are whitelisted.
	var/list/players = list()

	for(var/mob/player in player_list)
		if(!player.client) continue //No client. DCed.
		if(isYautja(player)) continue //Already a predator. Might be dead, who knows.
		if(readied) //Ready check for new players.
			var/mob/new_player/new_pred = player
			if(!istype(new_pred)) continue //Have to be a new player here.
			if(!new_pred.ready) continue //Have to be ready.
		else
			if(!istype(player,/mob/dead)) continue //Otherwise we just want to grab the ghosts.

		if(is_alien_whitelisted(player,"Yautja") || is_alien_whitelisted(player,"Yautja Elder"))  //Are they whitelisted?
			if(!player.client.prefs)
				player.client.prefs = new /datum/preferences(player.client) //Somehow they don't have one.

			if(player.client.prefs.be_special & BE_PREDATOR) //Are their prefs turned on?
				if(!player.mind) //They have to have a key if they have a client.
					player.mind_initialize() //Will work on ghosts too, but won't add them to active minds.
				players += player.mind
	return players

/proc/transform_predator(var/datum/mind/ghost_mind)

	var/mob/living/carbon/human/new_predator

	if( is_alien_whitelisted(ghost_mind.current,"Yautja Elder") ) new_predator = new (pick(pred_elder_spawn))
	else new_predator = new (pick(pred_spawn))

	new_predator.key = ghost_mind.key //This will initialize their mind.

	if(!new_predator.key) //Something went wrong.
		message_admins("\red <b>Warning</b>: null client in transform_predator, key: [new_predator.key]")
		del(new_predator)
		return

	new_predator.set_species("Yautja")

	if(new_predator.client.prefs) //They should have these set, but it's possible they don't have them.
		new_predator.real_name = new_predator.client.prefs.predator_name
		new_predator.gender = new_predator.client.prefs.predator_gender
	else
		new_predator.client.prefs = new /datum/preferences(new_predator.client) //Let's give them one.
		new_predator.gender = "male"

	if(!new_predator.real_name) //In case they don't have a name set or no prefs, there's a name.
		new_predator.real_name = "Le'pro"
		new_predator << "<b>\red You forgot to set your name in your preferences. Please do so next time.</b>"

	if(is_alien_whitelisted(new_predator,"Yautja Elder"))
		new_predator.real_name = "Elder [new_predator.real_name]"
		new_predator.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/yautja/full(new_predator), slot_wear_suit)
		new_predator.equip_to_slot_or_del(new /obj/item/weapon/twohanded/glaive(new_predator), slot_l_hand)

		spawn(10)
			new_predator << "\red <B> Welcome Elder!</B>"
			new_predator << "You are responsible for the well-being of your pupils. Hunting is secondary in priority."
			new_predator << "That does not mean you can't go out and show the youngsters how it's done."
			new_predator << "<B>You come equipped as an Elder should, with a bonus glaive and heavy armor.</b>"
	else
		spawn(12)
			new_predator << "You are <B>Yautja</b>, a great and noble predator!"
			new_predator << "Your job is to first study your opponents. A hunt cannot commence unless intelligence is gathered."
			new_predator << "Hunt at your discretion, yet be observant rather than violent."
			new_predator << "And above all, listen to your Elders!"

	new_predator.mind.assigned_role = "MODE"
	new_predator.mind.special_role = "Predator"
	new_predator.update_icons()

	if(ticker && ticker.mode) //Let's get them set up.
		var/datum/game_mode/predator_round = ticker.mode
		predator_round.initialize_predator(new_predator)

	if(ghost_mind.current) del(ghost_mind.current) //Get rid of the old body if it still exists.

	return new_predator