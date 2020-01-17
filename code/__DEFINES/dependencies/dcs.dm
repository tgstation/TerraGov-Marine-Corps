#define COMPONENT_COMPAT_DATUM_CLEANUP Destroy()

#define COMPONENT_COMPAT_DELETE(thing) qdel(thing)

#define COMPONENT_COMPAT_DELETED(thing) QDELETED(thing)

#define COMPONENT_COMPAT_CREATE_GLOBAL(name, typepath, value) GLOBAL_DATUM_INIT(name, typepath, value)

#define COMPONENT_COMPAT_ACCESS_GLOBAL(name) GLOB.##name

#define COMPONENT_COMPAT_STACK_TRACE(msg) stack_trace(msg)
