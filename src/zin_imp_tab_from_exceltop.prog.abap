*&---------------------------------------------------------------------*
*& Include ZIN_IMP_TAB_FROM_EXCELTOP      Report ZPG_IMP_TAB_FROM_EXCEL
*&
*&---------------------------------------------------------------------*

INCLUDE ZIN_COMMONTOP.

**********************************************************************
* PARAMETERS                                                         *
**********************************************************************
PARAMETERS:
  P_TABNM                 TYPE TABNAME OBLIGATORY,
  P_FILENM                TYPE ESEFTFRONT OBLIGATORY
                                MATCHCODE OBJECT ICL_DIAGFILENAME,
  P_RLINES                TYPE INT4 DEFAULT 1000,
  P_GETORG                TYPE XMARK DEFAULT 'X'.
.

**********************************************************************
* DATA                                                               *
**********************************************************************
FIELD-SYMBOLS:
  <GFT_NEW_DATA>          TYPE STANDARD TABLE,
  <GFT_ORG_DATA>          TYPE STANDARD TABLE,
  <GFT_ORG_DATA_TMP>      TYPE STANDARD TABLE.
DATA:
  GT_FIELDCAT             TYPE LVC_T_FCAT.
