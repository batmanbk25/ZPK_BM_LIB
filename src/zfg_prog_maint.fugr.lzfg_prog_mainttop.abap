FUNCTION-POOL ZFG_PROG_MAINT             MESSAGE-ID SV.

* INCLUDE LZFG_PROG_MAINTD...                " Local class definition
  INCLUDE LSVIMDAT                                . "general data decl.
*  INCLUDE ZZFG_PROG_MAINTT00                      . "view rel. datadcl.
  INCLUDE LZFG_PROG_MAINTT00                      . "view rel. datadcl.


** general table data declarations..............
*  INCLUDE LSVIMTDT                .
*  DATA:
*    GT_PROG_SIGNBUK       TYPE TABLE OF ZTB_PROG_SIGNBUK,
*    GT_T001               TYPE TABLE OF ZST_T001_USR.
* base table related FORM-routines.............
