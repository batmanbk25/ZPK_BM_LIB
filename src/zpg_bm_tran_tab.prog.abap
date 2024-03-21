*&---------------------------------------------------------------------*
*& Report  ZPG_CE104_08
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZPG_BM_TRAN_TAB.
INCLUDE ZIN_BM_TRAN_TAB_TOP.                      .  " global Data

* INCLUDE ZPG_CE104_08_O01                        .  " PBO-Modules
* INCLUDE ZPG_CE104_08_I01                        .  " PAI-Modules
INCLUDE ZIN_BM_TRAN_TAB_F01.                      .  " FORM-Routines

AT SELECTION-SCREEN OUTPUT.
  PERFORM 1000_PBO.

START-OF-SELECTION.
  PERFORM MAIN_PRO.
