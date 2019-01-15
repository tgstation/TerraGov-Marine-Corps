/*

Miscellaneous traitor devices

BATTERER


*/

/*

The Batterer, like a flashbang but 50% chance to knock people over. Can be either very
effective or pretty fucking useless.

*/

/obj/item/device/batterer
	name = "mind batterer"
	desc = "A strange device with twin antennas."
	icon_state = "batterer"
	throwforce = 5
	w_class = 1.0
	throw_speed = 4
	throw_range = 10
	flags_atom = CONDUCT
	item_state = "electronic"
	origin_tech = "magnets=3;combat=3;syndicate=3"

	var/times_used = 0 //Number of times it's been used.
	var/max_uses = 2


/obj/item/device/batterer/attack_self(mob/living/carbon/user as mob, flag = 0, emp = 0)
	if(!user) 	return
	if(times_used >= max_uses)
		to_chat(user, "\red The mind batterer has been burnt out!")
		return

	user.log_message("used [key_name(src)] to knock down people in the area", LOG_ATTACK)

	for(var/mob/living/carbon/human/M in orange(10, user))
		spawn()
			if(prob(50))

				M.KnockDown(rand(10,20))
				if(prob(25))
					M.Stun(rand(5,10))
				to_chat(M, "\red <b>You feel a tremendous, paralyzing wave flood your mind.</b>")

			else
				to_chat(M, "\red <b>You feel a sudden, electric jolt travel through your head.</b>")

	playsound(src.loc, 'sound/misc/interference.ogg', 25, 1)
	to_chat(user, "\blue You trigger [src].")
	times_used += 1
	if(times_used >= max_uses)
		icon_state = "battererburnt"




