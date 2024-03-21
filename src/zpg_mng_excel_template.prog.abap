*&---------------------------------------------------------------------*
*& Report  ZPG_MNG_EXCEL_TEMPLATE
*&
*&---------------------------------------------------------------------*
*&  Create date :25.05.2015
*&  Creator     :TuanBA8
*&---------------------------------------------------------------------*

REPORT ZPG_MNG_EXCEL_TEMPLATE.
INCLUDE ZIN_MNG_EXCEL_TEMPLATETOP               .    " global Data

* INCLUDE ZIN_MNG_EXCEL_TEMPLATEO01               .  " PBO-Modules
* INCLUDE ZIN_MNG_EXCEL_TEMPLATEI01               .  " PAI-Modules
INCLUDE ZIN_MNG_EXCEL_TEMPLATEF01               .  " FORM-Routines

INITIALIZATION.
  PERFORM 0000_INIT_PROC.

START-OF-SELECTION.
  PERFORM 0000_MAIN_PROC.
