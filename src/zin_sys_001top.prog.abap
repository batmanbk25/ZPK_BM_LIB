*&---------------------------------------------------------------------*
*&  Include           ZIN_SYS_001TOP
*&---------------------------------------------------------------------*

INCLUDE ZIN_COMMONTOP.

CONSTANTS:
  GC_PERFM_YYYYMMDD   TYPE ZDD_BM_PERFM VALUE '1',
  GC_PERFM_YYYYMM     TYPE ZDD_BM_PERFM VALUE '2',
  GC_PERFM_YYMM       TYPE ZDD_BM_PERFM VALUE '3'.

**********************************************************************
* DATA
**********************************************************************
TABLES:
  ZST_SYS_001.
DATA:
  GT_SYS_001          TYPE ZTT_SYS_001,
  GT_DATGROUP         TYPE TABLE OF ZTB_BM_DATGROUP,
  GT_DATTYPE_ALL      TYPE TABLE OF ZTB_BM_DATTYPE,
  GT_DATTYPE          TYPE TABLE OF ZTB_BM_DATTYPE,
  GT_DATCON           TYPE TABLE OF ZTB_BM_DATCON.",
*  GT_ALL_BUK          TYPE TABLE OF ZST_T001_USR.

**********************************************************************
* PARAMETERS AND SELECT-OPTIONS
**********************************************************************
PARAMETERS:
  P_DATGR             TYPE ZTB_BM_DATGROUP-DATGR AS LISTBOX
                            VISIBLE LENGTH 30.
SELECT-OPTIONS:
  S_BUKRS             FOR ZST_SYS_001-BUKRS,
  S_CRDAT             FOR ZST_SYS_001-CRDAT DEFAULT SY-DATUM.
PARAMETERS:
  P_SHOWUS            TYPE XMARK.
