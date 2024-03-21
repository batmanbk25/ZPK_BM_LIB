*&---------------------------------------------------------------------*
*& Report  ZPG_DEMO_IMP_EXCEL
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZPG_DEMO_IMP_EXP_EXCEL MESSAGE-ID BT.
INCLUDE ZIN_DEMO_IMP_EXP_EXCELTOP.              " global Data
INCLUDE ZIN_DEMO_IMP_EXP_EXCELF01.              " FORM-Routines

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_LOFILE.
  PERFORM SELECT_FILE CHANGING P_LOFILE.

START-OF-SELECTION.
  PERFORM MAIN_PROC.

*&---------------------------------------------------------------------*
*&      Form  MAIN_PROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAIN_PROC .

*  PERFORM EXPORT_EXCELS_MT.
*  RETURN.
* Import data from file
  PERFORM IMPORT_FILE.

* Output
  PERFORM OUTPUT_DATA.
*
** Export data to file
*  PERFORM EXPORT_FILE2.
ENDFORM.                    " MAIN_PROC
