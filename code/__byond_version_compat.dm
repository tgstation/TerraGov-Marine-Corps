// This file contains defines allowing targeting byond versions newer than the supported
// TODO: Remove once we move completely over to 515
#if DM_VERSION < 515
// 514 version
#define PROC_REF(X) (.proc/##X)
#define TYPE_PROC_REF(TYPE, X) (##TYPE.proc/##X)
#define GLOBAL_PROC_REF(X) (.proc/##X)
#else
// 515 versions
#define PROC_REF(X) (nameof(.proc/##X))
#define TYPE_PROC_REF(TYPE, X) (nameof(##TYPE.proc/##X))
#define GLOBAL_PROC_REF(X) (/proc/##X)
#endif
