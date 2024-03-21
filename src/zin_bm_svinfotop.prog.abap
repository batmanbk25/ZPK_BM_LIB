*&---------------------------------------------------------------------*
*& Include ZIN_BM_SVINFOTOP                        Report ZPG_BM_SVINFO
*&
*&---------------------------------------------------------------------*

  INCLUDE ZIN_COMMONTOP.

**********************************************************************
* DATA
**********************************************************************
  TABLES:
    ZST_BM_USR_ACCOUNT.

  DATA:
    GW_LBL_USR_AMOUNT           TYPE TEXT50,
    GT_SVUSR                    TYPE TABLE OF ZTB_BM_SV_USR,
    GT_BM_SV_TRANS              TYPE TABLE OF ZTB_BM_SV_TRANS,
    GT_BM_SV_TRAND              TYPE TABLE OF ZTB_BM_SV_TRAND,
    GT_BM_USR_TRAND             TYPE TABLE OF ZST_BM_USR_TRAND,
    GT_BM_ALL_TRAND             TYPE TABLE OF ZST_BM_USR_TRAND,
    GO_CUS_ALV_TRANS            TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
    GO_ALV_TRANS                TYPE REF TO CL_GUI_ALV_GRID.
