
///helper that converts greyscale mech slots and types into typepaths
/proc/get_mech_limb(slot, mech_type)
	switch(slot)
		if(MECH_GREY_HEAD)
			switch(mech_type)
				if(MECH_RECON)
					return /datum/mech_limb/head/recon
				if(MECH_ASSAULT)
					return /datum/mech_limb/head/assault
				if(MECH_VANGUARD)
					return /datum/mech_limb/head/vanguard
		if(MECH_GREY_L_ARM, MECH_GREY_R_ARM)
			switch(mech_type)
				if(MECH_RECON)
					return /datum/mech_limb/arm/recon
				if(MECH_ASSAULT)
					return /datum/mech_limb/arm/assault
				if(MECH_VANGUARD)
					return /datum/mech_limb/arm/vanguard
		if(MECH_GREY_TORSO)
			switch(mech_type)
				if(MECH_RECON)
					return /datum/mech_limb/torso/recon
				if(MECH_ASSAULT)
					return /datum/mech_limb/torso/assault
				if(MECH_VANGUARD)
					return /datum/mech_limb/torso/vanguard
		if(MECH_GREY_LEGS)
			switch(mech_type)
				if(MECH_RECON)
					return /datum/mech_limb/legs/recon
				if(MECH_ASSAULT)
					return /datum/mech_limb/legs/assault
				if(MECH_VANGUARD)
					return /datum/mech_limb/legs/vanguard
	CRASH("Error getting mech type: [slot], [mech_type]")
