FUNCTION-POOL ZFG_MCBA.                     "MESSAGE-ID ..

INCLUDE ZIN_COMMONTOP.
* INCLUDE LZFG_MCBAD...                      " Local class definition


CONSTANTS:
* Fix value
  GC_MCTYP_FIXVAL       TYPE ZDD_MCTYP VALUE '',
* Map value
  GC_MCTYP_MAPVAL       TYPE ZDD_MCTYP VALUE '1',
* FM process
  GC_MCTYP_FMPRC        TYPE ZDD_MCTYP VALUE '2',
* Key groups
  GC_MCTYP_KEYGR        TYPE ZDD_MCTYP VALUE '3'.

DATA:
  GS_MC_BUSAREA         TYPE ZST_MCCF_BUSAREA,
  GT_MC_BUSMAP          TYPE TABLE OF ZTB_MC_BUSMAP,
  GT_MC_BUSKEYG         TYPE TABLE OF ZTB_MC_BUSKEYG,
  GT_MC_BUSKEYE         TYPE TABLE OF ZTB_MC_BUSKEYE,
  GT_MC_BUSKEYM         TYPE TABLE OF ZTB_MC_BUSKEYGM,
  GS_MCCF_BUSTAB        TYPE ZST_MCCF_BUSTAB.

**********************************************************************
* TABLE Input
**********************************************************************
DATA:
  GO_ALV_TABINP         TYPE REF TO CL_GUI_ALV_GRID,
  GW_TABNMINP           TYPE TABNAME.
FIELD-SYMBOLS:
  <GT_TABINP>           TYPE TABLE.
