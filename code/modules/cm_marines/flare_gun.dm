	//Physical flare shot          note:may not be necessary, it does not show
obj/item/projectile/flareburst
		density = 1
		unacidable=1
		anchored=1  //SEE modules/projectiles/projectile.dm
		layer = 10  //random high layer to show visibillity above other icons
		flags_pass = PASSTABLE
		mouse_opacity=0
		icon='icons/Marine/flaregun.dmi'
		icon_state = "horrible"
		damage = 3
		stun=1
		damage_type = BURN
		/*						//May come back to this
		New(loc,dir)
			src.dir = dir
			..()
			spawn()
				while(1)
					if(src.x <= 1 || src.x >= world.maxx || src.y <= 1 || src.y >= world.maxy) del(src) //should del FLARE if it reaches the end of world x&y
					step(src,src.dir) //continue to move forward
					sleep(1)
*/
//Survival purposes only, unless you want to make it dual purpose with shotgun shells
/obj/item/weapon/flaregun
	name = "Signal Flare Gun"
	icon = 'icons/Marine/flaregun.dmi'
	item_state = "flare_g"
	origin_tech = "combat=1;materials=2"
	force = 3.0
	w_class = 1.0
	flags = FPRINT|TABLEPASS|CONDUCT
	flags_equip_slot = SLOT_WAIST
	var/loaded_s = 0 //any shell loaded
	var/shell_name = "nothing"
	desc = "Save your life in one shot."
	attack_verb = list("struck", "hit", "bashed")


	//Load Shell
	attackby(obj/item/S as obj, mob/user as mob)
		if( istype ( S,/obj/item/flareround_s ))
			if( src.loaded_s == 0)
				src.shell_name = S.name
				src.loaded_s = 1
				user.visible_message( "[user] loads the gun with [shell_name]" )
				src.desc = "Save your life in one shot.<I> Loaded with [shell_name]."
				playsound( user, 'gun_shotgun_shell_insert.ogg', 50,1 )
				del(S)
			else
				usr << "<B><I>It's already loaded with [shell_name]."
		if( istype( S,/obj/item/flareround_sp ))
			if(src.loaded_s == 0)
				src.shell_name = S.name
				src.loaded_s = 1
				user.visible_message( "[user] loads the gun with [shell_name]" )
				src.desc = "Save your life in one shot.<I> Loaded with [shell_name]."
				playsound ( user, 'gun_shotgun_shell_insert.ogg', 50,1 )
				del(S)
			else
				usr << "<B><I>It's already loaded with [shell_name]."
		else
			..()

	//Fire
	afterattack(atom/target as turf|area, mob/living/user, flag)
		var/lit = /obj/item/projectile/flareburst
		var/initial_dir = get_dir(user,target)  //since dir is using numerals instead of NORTH SOUTH, etc.
		if( istype( user,/mob/living/carbon/human ))
			if(src.loaded_s == 1)
				switch( src.shell_name )
					if("Howl Flare Shell") //which shell is loaded
						src.visible_message( "<font color=red>[user] fires a [shell_name] towards the sky." )
						src.loaded_s = 0
						src.shell_name ="nothing"
						new lit(src.loc,src.dir,src)
						target.l_color = "#bb0303"
						playsound (user, 'sound/weapons/gun_flare_explode.ogg',75,1 )
						target.SetLuminosity(3 + rand(0,3)) //rand() means random
						sleep(10) // 1 second
						target.SetLuminosity(4 + rand(0,3))
						playsound (user, 'sound/effects/fire_crackle.ogg',100,1 )
						sleep(30) //3 seconds
						target.SetLuminosity(3 + rand(0,3))
						sleep(30)
						target.SetLuminosity(5 + rand(0,3))
						if(user in view(25))  // glimpse of red light,view() instead of range()
							user.client.screen+=global_hud.thermal
							var/direction
							switch(initial_dir)        //number equivalent to dir
								if(1)
									direction = "North"
								if(2)
									direction = "South"
								if(4)
									direction = "East"
								if(5)
									direction = "Northeast"
								if(6)
									direction = "Southeast"
								if(8)
									direction = "West"
								if(9)
									direction = "Northwest"
								if(10)
									direction = "Southwest"
								else
									direction = "sky"
							user<<"<B><I><font color=red>You see a signal flare light up in the [direction]!"
						sleep(600)
						target.SetLuminosity(3 + rand(0,3))
						sleep(30)
						target.SetLuminosity(0)
						user.client.screen-=global_hud.thermal

					else //standard shell
						src.visible_message( "<font color=red>[user] fires a [shell_name] towards the sky." )
						src.loaded_s = 0
						src.shell_name ="nothing"
						new lit(src.loc,src.dir,src)
						target.l_color = "#bb0303"
						playsound (user, 'sound/weapons/gun_flare_explode.ogg',75,1 )
						target.SetLuminosity(3 + rand(0,3))
						sleep(10) // 1 second
						target.SetLuminosity(4 + rand(0,3))
						sleep(30)
						target.SetLuminosity(3 + rand(0,3))
						sleep(30)
						target.SetLuminosity(5 + rand(0,3))
						if(user in view(25))
							user.client.screen+=global_hud.thermal
							var/direction
							switch(initial_dir)
								if(1)
									direction = "North"
								if(2)
									direction = "South"
								if(4)
									direction = "East"
								if(5)
									direction = "Northeast"
								if(6)
									direction = "Southeast"
								if(8)
									direction = "West"
								if(9)
									direction = "Northwest"
								if(10)
									direction = "Southwest"
								else
									direction = "sky"
							user<<"<B><I><font color=red>You see a signal flare light up in the [direction]!"
						sleep(600)
						target.SetLuminosity(3 + rand(0,3))
						sleep(30)
						target.SetLuminosity(0)
						user.client.screen-=global_hud.thermal
			else
				usr << "<B> Empty..."
				playsound(user, 'sound/weapons/gun_empty.ogg', 100, 1)
		else
			..()



/obj/item/flareround_s
	name = "Standard Flare Shell"
	icon = 'icons/Marine/flaregun.dmi'
	desc = "Standard for spess-side assistance.<I> For flare guns only."
	icon_state = "shell"
	w_class =0.5
	origin_tech="combat=1;materials=1"
	flags = FPRINT|TABLEPASS|CONDUCT
	flags_equip_slot = SLOT_WAIST|SLOT_STORE

/obj/item/flareround_sp
	name = "Howl Flare Shell"
	icon = 'icons/Marine/flaregun.dmi'
	desc = "Good for getting someone's attention when shot.<I> For flare guns only."
	icon_state = "shell"
	w_class =0.5
	origin_tech="combat=1;materials=1"
	flags = FPRINT|TABLEPASS|CONDUCT
	flags_equip_slot = SLOT_WAIST|SLOT_STORE
