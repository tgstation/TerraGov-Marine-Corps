var/global/list/all_type_pools = list()		// Associated list of lists, indexed by type. This holds all type pools currently initialized
#define POOL_SIZE_LIMIT	50

// Call this proc anywhere to pool anything.
// Datums should be pooled when it is likely that they will be used again
// within a relatively short period of time. Lights, bullets, etc.
/proc/pool(var/datum/D)
	if (!D)
		return

	// Retrieve the pool
	var/list/type_pool = all_type_pools[D.type]

	// Pool not retrieved, so initialize one
	if (!type_pool)
		type_pool = initialize_type_pool(D.type)

	// If there's a lot of this type pooled, we don't need more
	if (type_pool.len >= POOL_SIZE_LIMIT)
		cdel(D)

	type_pool += D
	D.pooled(D.type)

// Call this proc anywhere to unpool anything.
// This proc should never cause problems as long as a type is
// supplied to it, even if there is not an existing pool for
// the type to be unpooled, one will be created for it
/proc/unpool(var/type)
	if (!type)
		return null

	// Retrieve the pool
	var/list/type_pool = all_type_pools[type]

	// Pool not retrieved, so initailize one
	if (!type_pool)
		type_pool = initialize_type_pool(type)

	// Pool is empty, create a datum the normal way
	if (!type_pool.len)
		return new type

	// Remove the datum from the pool, return it
	var/datum/D = type_pool[type_pool.len]
	type_pool.len--
	D.unpooled(type)
	return D

// Helper proc, don't ever call this outside of this .dm file
/proc/initialize_type_pool(var/type)
	all_type_pools[type] = list()

	return all_type_pools[type]


// A datum will be cdel()'d after it's type is pooled
/datum/proc/pooled(var/type)
	cdel()

/datum/proc/unpooled(var/type)
	disposed = 0