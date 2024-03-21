*&---------------------------------------------------------------------*
*& Report  ZPG_DTG99_012
*&
*&---------------------------------------------------------------------*
*&  Create user: TuanBA8
*&  Create date: 21/04/2015
*&---------------------------------------------------------------------*

REPORT ZPG_MASSCHANGE_TABLE.
INCLUDE ZIN_MASSCHANGE_TABLETOP. " global Data
INCLUDE ZIN_MASSCHANGE_TABLEF01. " FORM-Routines

AT SELECTION-SCREEN OUTPUT.
  PERFORM 1000_PBO.

START-OF-SELECTION.
  PERFORM 0000_MAIN_PROC.
