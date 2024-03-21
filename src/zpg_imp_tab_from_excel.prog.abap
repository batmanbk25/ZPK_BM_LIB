*&---------------------------------------------------------------------*
*& Report  ZPG_IMP_TAB_FROM_EXCEL
*&
*&---------------------------------------------------------------------*
*&  Created date: 26/5/2015
*&  Created by  : TuanBA8
*&---------------------------------------------------------------------*

REPORT ZPG_IMP_TAB_FROM_EXCEL.
INCLUDE ZIN_IMP_TAB_FROM_EXCELTOP               .    " global Data

* INCLUDE ZIN_IMP_TAB_FROM_EXCELO01               .  " PBO-Modules
* INCLUDE ZIN_IMP_TAB_FROM_EXCELI01               .  " PAI-Modules
INCLUDE ZIN_IMP_TAB_FROM_EXCELF01               .  " FORM-Routines

AT SELECTION-SCREEN.
  PERFORM 1000_PAI.

START-OF-SELECTION.
  PERFORM 0000_MAIN_PROC.
