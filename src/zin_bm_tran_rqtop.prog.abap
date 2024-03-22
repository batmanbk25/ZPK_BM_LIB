*&---------------------------------------------------------------------*
*& Include ZIN_BM_TRAN_RQTOP       - Module Pool      ZPG_BM_TRAN_RQ
*&---------------------------------------------------------------------*

**********************************************************************
* DATA
**********************************************************************
DATA: GW_KFILE_LOCAL    LIKE RCGFILETR-FTFRONT,
      GW_RFILE_LOCAL    LIKE RCGFILETR-FTFRONT,
      GW_KFILE_SERVER   LIKE RCGFILETR-FTAPPL,
      GW_RFILE_SERVER   LIKE RCGFILETR-FTAPPL,
      GW_MESSAGE_OUTPUT TYPE STRING.

**********************************************************************
* PARAMETERS AND SELECT-OPTIONS
**********************************************************************
  " Parameter
  PARAMETERS:
    P_TRKORR  TYPE TRKORR,
    P_PATH    TYPE ESEFTFRONT OBLIGATORY,
    P_KPATH   TYPE ESEFTAPPL DEFAULT '/usr/sap/trans/cofiles/',
    P_RPATH   TYPE ESEFTAPPL DEFAULT '/usr/sap/trans/data/'.

  " Parameter for action processing
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS:
      P_DOWRQ  RADIOBUTTON GROUP RG1 DEFAULT 'X' USER-COMMAND RAD.
    SELECTION-SCREEN COMMENT 3(13) text-001.
    PARAMETERS:
      P_UPLRQ  RADIOBUTTON GROUP RG1.
    SELECTION-SCREEN COMMENT 19(13) text-002.
  SELECTION-SCREEN END OF LINE.
