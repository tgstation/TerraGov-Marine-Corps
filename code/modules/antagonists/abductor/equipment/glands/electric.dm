/obj/item/organ/heart/gland/electric
	true_name = "electron accumulator/discharger"
	cooldown_low = 800
	cooldown_high = 1200
	icon_state = "species"
	uses = -1
	mind_control_uses = 2
	mind_control_duration = 900

/obj/item/organ/heart/gland/electric/Insert(mob/living/carbon/M, special = 0)
	..()
	ADD_TRAIT(owner, TRAIT_SHOCKIMMUNE, "abductor_gland")

/obj/item/organ/heart/gland/electric/Remove(mob/living/carbon/M, special = 0)
	REMOVE_TRAIT(owner, TRAIT_SHOCKIMMUNE, "abductor_gland")
	..()

/obj/item/organ/heart/gland/electric/activate()
	owner.visible_message("<span class='danger'>[owner]'s skin starts emitting electric arcs!</span>",\
	"<span class='warning'>I feel electric energy building up inside you!</span>")
	playsound(get_turf(owner), "sparks", 100, TRUE, -1)
	addtimer(CALLBACK(src, PROC_REF(zap)), rand(30, 100))

/obj/item/organ/heart/gland/electric/proc/zap()
	tesla_zap(owner, 4, 8000, TESLA_MOB_DAMAGE | TESLA_OBJ_DAMAGE | TESLA_MOB_STUN)
	playsound(get_turf(owner), 'sound/blank.ogg', 50, TRUE)
