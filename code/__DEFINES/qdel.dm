//defines that give qdel hints. these can be given as a return in destory() or by calling


#define QDEL_HINT_QUEUE 		0 //qdel should queue the object for deletion.
#define QDEL_HINT_LETMELIVE		1 //qdel should let the object live after calling destory.
#define QDEL_HINT_IWILLGC		2 //functionally the same as the above. qdel should assume the object will gc on its own, and not check it.
#define QDEL_HINT_HARDDEL		3 //qdel should assume this object won't gc, and queue a hard delete using a hard reference.
#define QDEL_HINT_HARDDEL_NOW	4 //qdel should assume this object won't gc, and hard del it post haste.
#define QDEL_HINT_FINDREFERENCE	5 //functionally identical to QDEL_HINT_QUEUE if TESTING is not enabled in _compiler_options.dm.
								  //if TESTING is enabled, qdel will call this object's find_references() verb.
#define QDEL_HINT_IFFAIL_FINDREFERENCE 6		//Above but only if gc fails.
//defines for the gc_destroyed var

#define GC_QUEUE_CHECK 1
#define GC_QUEUE_HARDDELETE 2
#define GC_QUEUE_COUNT 2 //increase this when adding more steps.

#define GC_QUEUED_FOR_QUEUING -1
#define GC_CURRENTLY_BEING_QDELETED -2

// Defines for the ssgarbage queue items
#define GC_QUEUE_ITEM_QUEUE_TIME 1 //! Time this item entered the queue
#define GC_QUEUE_ITEM_REF 2 //! Ref to the item
#define GC_QUEUE_ITEM_GCD_DESTROYED 3 //! Item's gc_destroyed var value. Used to detect ref reuse.
#define GC_QUEUE_ITEM_INDEX_COUNT 3 //! Number of item indexes, used for allocating the nested lists. Don't forget to increase this if you add a new queue item index

// Defines for the time an item has to get its reference cleaned before it fails the queue and moves to the next.
#define GC_FILTER_QUEUE (1 SECONDS)
#define GC_CHECK_QUEUE (5 MINUTES)
#define GC_DEL_QUEUE (10 SECONDS)

#define QDELING(X) (X.gc_destroyed)
#define QDELETED(X) (!X || QDELING(X))
#define QDESTROYING(X) (!X || X.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)

