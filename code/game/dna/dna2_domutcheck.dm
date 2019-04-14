// (Re-)Apply mutations.
// TODO: Turn into a /mob proc, change inj to a bitflag for various forms of differing behavior.
// M: Mob to mess with
// connected: Machine we're in, type unchecked so I doubt it's used beyond monkeying
// flags: See below, bitfield.
#define MUTCHK_FORCED        1
/proc/domutcheck(mob/living/carbon/M, connected, flags)
	for(var/datum/dna/gene/gene in dna_genes)
		if(!M || !M.dna)
			return
		if(!gene.block)
			continue

		// Sanity checks, don't skip.
		if(!gene.can_activate(M,flags))
			//testing("[M] - Failed to activate [gene.name] (can_activate fail).")
			continue

		// Current state
		var/gene_active = (gene.flags & GENE_ALWAYS_ACTIVATE)
		if(!gene_active)
			gene_active = M.dna.GetSEState(gene.block)

		// Prior state
		var/gene_prior_status = (gene.type in M.active_genes)
		var/changed = gene_active != gene_prior_status || (gene.flags & GENE_ALWAYS_ACTIVATE)

		// If gene state has changed:
		if(changed)
			// Gene active (or ALWAYS ACTIVATE)
			if(gene_active || (gene.flags & GENE_ALWAYS_ACTIVATE))
//				testing("[gene.name] activated!")
				gene.activate(M,connected,flags)
				if(M)
					domutcheck_toggle_gene(M, gene, TRUE)
			// If Gene is NOT active:
			else
//				testing("[gene.name] deactivated!")
				gene.deactivate(M,connected,flags)
				if(M)
					domutcheck_toggle_gene(M, gene, FALSE)


/proc/domutcheck_toggle_gene(mob/living/carbon/M, datum/dna/gene/gene, activate)
	if(isnull(M.active_genes))
		M.active_genes = list() // Just to avoid initializing this unused var. To be removed, this whole thing.
	if(activate)
		M.active_genes |= gene.type
	else
		M.active_genes -= gene.type