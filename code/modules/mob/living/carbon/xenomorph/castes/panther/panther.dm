/mob/living/carbon/xenomorph/panther
	caste_base_type = /mob/living/carbon/xenomorph/panther
	name = "Panther"
	desc = "What you have done with this cute little rouny?"
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Panther Walking" //Panther sprites by Drawsstuff (CC BY-NC-SA 3.0)
	health = 50
	maxHealth = 100
	plasma_stored = 10
	flags_pass = PASSTABLE
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO
	pixel_x = -16
	old_x = -16
	bubble_icon = "alien"
	gib_chance = 0
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

/mob/living/carbon/xenomorph/panther/set_stat()
	. = ..()
	if(isnull(.))
		return
	if(. == CONSCIOUS && layer != initial(layer))
		layer = MOB_LAYER

/mob/living/carbon/xenomorph/panther/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/adrenalin), 1 SECONDS, TIMER_LOOP)

/mob/living/carbon/xenomorph/panther/proc/adrenalin()
    if(m_intent == MOVE_INTENT_RUN)
        if(last_move_time + 1 SECONDS >= world.time)
            gain_plasma(2)
            return
    if(plasma_stored >= 40)
        use_plasma(3)

/obj/item/reagent_containers/food/drinks/pantherheart
	name = "Panther heart"
	desc = "This is Panther heart... Wait, what?"
	icon_state = "pantherheart"
	w_class = WEIGHT_CLASS_NORMAL
	force = 0
	throwforce = 0
	amount_per_transfer_from_this = 2
	possible_transfer_amounts = null
	volume = 20
	list_reagents = list(/datum/reagent/medicine/synaptizine/adrenaline = 20)

/obj/item/reagent_containers/food/drinks/pantherheart/on_reagent_change()
	if(!reagents.total_volume)
		icon_state = "pantherheart_e"

/mob/living/carbon/xenomorph/panther/on_death()
	. = ..()
	if(prob(44.81))
		new /obj/item/reagent_containers/food/drinks/pantherheart(loc)
		gib()

/datum/reagent/medicine/synaptizine/adrenaline
	name = "Adrenaline"
	color = "#f14a17"

/datum/reagent/medicine/synaptizine/adrenaline/on_mob_add(mob/living/L, metabolism)
	. = ..()
	var/mob/living/carbon/human/H = L
	if(TIMER_COOLDOWN_CHECK(L, name) || L.stat == DEAD)
		return
	if(L.health < H.health_threshold_crit && volume >= 2)
		to_chat(L, span_userdanger("Heart explosion! Power running in your veins!"))
		L.adjustBruteLoss(-L.getBruteLoss(TRUE) * 0.40)
		L.adjustFireLoss(-L.getFireLoss(TRUE) * 0.20)
		L.adjustToxLoss(5)
		L.jitter(5)
		TIMER_COOLDOWN_START(L, name, 180 SECONDS)
