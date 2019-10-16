// Targets, the things that actually get shot!
/obj/item/target
	name = "shooting target"
	desc = "A shooting target."
	icon = 'icons/obj/objects.dmi'
	icon_state = "target_h"
	density = FALSE
	resistance_flags = INDESTRUCTIBLE

	Destroy()
		// if a target is deleted and associated with a stake, force stake to forget
		for(var/obj/structure/target_stake/T in view(3,src))
			if(T.pinned_target == src)
				T.pinned_target = null
				T.density = TRUE
				break
		. = ..() // delete target

	Move()
		..()
		// After target moves, check for nearby stakes. If associated, move to target
		for(var/obj/structure/target_stake/M in view(3,src))
			if(M.density == 0 && M.pinned_target == src)
				M.loc = loc

		// This may seem a little counter-intuitive but I assure you that's for a purpose.
		// Stakes are the ones that carry targets, yes, but in the stake code we set
		// a stake's density to 0 meaning it can't be pushed anymore. Instead of pushing
		// the stake now, we have to push the target.



	attackby(obj/item/W as obj, mob/user as mob)
		if (iswelder(W))
			var/obj/item/tool/weldingtool/WT = W
			if(WT.remove_fuel(0, user))
				overlays.Cut()
				to_chat(usr, "You slice off [src]'s uneven chunks of aluminum and scorch marks.")
				return


	attack_hand(mob/user as mob)
		// taking pinned targets off!
		var/obj/structure/target_stake/stake
		for(var/obj/structure/target_stake/T in view(3,src))
			if(T.pinned_target == src)
				stake = T
				break

		if(stake)
			if(stake.pinned_target)
				stake.density = TRUE
				density = FALSE
				layer = OBJ_LAYER

				loc = user.loc
				if(ishuman(user))
					if(!user.get_active_held_item())
						user.put_in_hands(src)
						to_chat(user, "You take the target out of the stake.")
				else
					src.loc = get_turf(user)
					to_chat(user, "You take the target out of the stake.")

				stake.pinned_target = null
				return

		else
			..()

	syndicate
		icon_state = "target_s"
		desc = "A shooting target that looks like a hostile agent."
	alien
		icon_state = "target_q"
		desc = "A shooting target with a threatening silhouette."
