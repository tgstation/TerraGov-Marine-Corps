/obj/item/stack/nanopaste
	name = "nanopaste"
	singular_name = "nanite swarm"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "tube"
	origin_tech = "materials=4;engineering=3"
	amount = 10
	max_amount = 10
	w_class = 2


/obj/item/stack/nanopaste/attack(mob/living/M as mob, mob/user as mob)
	if (!istype(M) || !istype(user))
		return 0

	if (istype(M,/mob/living/carbon/human))		//Repairing robolimbs
		if(issynth(M) && M == user)
			return
		var/mob/living/carbon/human/H = M
		var/datum/limb/S = H.get_limb(user.zone_selected)

		if(S.surgery_open_stage == 0)
			if (S && (S.limb_status & LIMB_ROBOT))
				if(S.get_damage())
					S.heal_damage(15, 15, robo_repair = 1)
					H.updatehealth()
					use(1)
					user.visible_message("<span class='notice'>\The [user] applies some nanite paste at [user != M ? "\the [M]'s" : "\the"] [S.display_name] with \the [src].</span>",\
					"<span class='notice'>You apply some nanite paste at [user == M ? "your" : "[M]'s"] [S.display_name].</span>")
				else
					to_chat(user, "<span class='notice'>Nothing to fix here.</span>")
		else
			if (H.can_be_operated_on())
				if (do_surgery(H,user,src))
					return
			else
				to_chat(user, "<span class='notice'>Nothing to fix in here.</span>")
