/obj/item/storage/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon_state ="bible"
	throw_speed = 1
	throw_range = 5
	storage_slots = 1
	w_class = WEIGHT_CLASS_NORMAL
	var/mob/affecting = null
	var/deity_name = "Christ"

/obj/item/storage/bible/koran
	name = "Luxury Koran"
	icon = 'icons/obj/items/priest.dmi'
	icon_state = "Koran"
	deity_name = "Allah"
	storage_slots = 7
	actions_types = list(/datum/action/item_action)

/obj/item/storage/bible/koran/attack_self(mob/user)
	var/mob/living/carbon/human/activator = user
	TIMER_COOLDOWN_START(user, "KoranSpam", 5 SECONDS)
	if(TIMER_COOLDOWN_CHECK(user, "Koran"))
		user.balloon_alert(user, "Allah already helped you")
		if(TIMER_COOLDOWN_CHECK(user, "KoranSpam"))
			activator.adjustBrainLoss(1, TRUE)
			return
		return
	if(!((activator.religion == "Islam (Shia)") || (activator.religion == "Islam (Sunni)")))
		user.balloon_alert(user, "Infidel can't use that")
		return
	if(locate(/obj/structure/bed/namaz, activator.loc))
		activator.say("أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا ٱللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا رَسُولُ ٱللَّهِ")
		TIMER_COOLDOWN_START(user, "Koran", 600 SECONDS)
		if(prob(10))
			explosion(activator, 1, 1, 1, 1, 1)
		if(prob(80))
			activator.heal_limb_damage(50, 50)
			activator.adjustCloneLoss(-10)
			activator.playsound_local(loc, 'sound/hallucinations/im_here1.ogg', 50)
	else
		user.balloon_alert(user, "This place is not holy")

/obj/item/storage/bible/koran/basic
	name = "Koran"
	max_w_class = 3
	storage_slots = 1
	can_hold = list(
		/obj/item/weapon/gun/pistol/plasma_pistol,
		/obj/item/explosive/grenade,
		/obj/item/explosive/mine,
    )

/obj/item/storage/bible/booze
	name = "bible"
	desc = "To be applied to the head repeatedly."
	icon_state ="bible"
	storage_slots = 7
	can_hold = list(
		/obj/item/reagent_containers/food/drinks/cans,
		/obj/item/spacecash,
	)

/obj/item/storage/bible/booze/Initialize(mapload, ...)
	. = ..()
	new /obj/item/reagent_containers/food/drinks/cans/beer(src)
	new /obj/item/reagent_containers/food/drinks/cans/beer(src)
	new /obj/item/spacecash(src)
	new /obj/item/spacecash(src)
	new /obj/item/spacecash(src)

/obj/item/storage/bible/afterattack(atom/A, mob/user, proximity)
	if(!proximity || !isliving(user))
		return
	var/mob/living/living_user = user
	if(ischaplainjob(living_user.job))
		if(A.reagents && A.reagents.has_reagent(/datum/reagent/water)) //blesses all the water in the holder
			to_chat(user, span_notice("You bless [A]."))
			var/water2holy = A.reagents.get_reagent_amount(/datum/reagent/water)
			A.reagents.del_reagent(/datum/reagent/water)
			A.reagents.add_reagent(/datum/reagent/water/holywater,water2holy)

/obj/item/storage/bible/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(use_sound)
		playsound(loc, use_sound, 25, 1, 6)
