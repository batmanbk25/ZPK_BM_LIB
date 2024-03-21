*&---------------------------------------------------------------------*
*& Report  ZPG_SYS_001
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZPG_SYS_001.


INCLUDE ZIN_SYS_001TOP                        .    " global Data

*INCLUDE ZIN_SYS_001O01                        .  " PBO-Modules
*INCLUDE ZIN_SYS_001I01                        .  " PAI-Modules
INCLUDE ZIN_SYS_001F01                        .  " FORM-Routines

INITIALIZATION.
  PERFORM 0000_INIT_PROC.

AT SELECTION-SCREEN OUTPUT.
  CALL FUNCTION 'ZFM_SCR_PBO'
    EXPORTING
      I_SET_LIST_VALUES = GC_XMARK.

START-OF-SELECTION.
  PERFORM 0000_MAIN_PROC.
