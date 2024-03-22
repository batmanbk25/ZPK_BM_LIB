*&---------------------------------------------------------------------*
*& Include ZIN_DEMO_IMP_EXCELTOP              Report ZPG_DEMO_IMP_EXCEL
*&
*&---------------------------------------------------------------------*

CONSTANTS:
  GC_LOGICAL_FILE     TYPE ESEFTAPPL VALUE 'ZDEMO_EXP_EXCEL',
  GC_STRUCTURE        TYPE TABNAME VALUE 'ZST_EXCEL_DEMO',
  GC_STRUCTURE_ITM    TYPE TABNAME VALUE 'ZST_EXCEL_DEMO_L'.
DATA:
  GT_IMP_DATA         TYPE TABLE OF ZST_EXCEL_DEMO_L,
  GT_EXP_DATA         TYPE TABLE OF ZST_EXCEL_DEMO_L,
  GS_DATA             TYPE ZST_EXCEL_DEMO,
  GT_FIELDCAT         TYPE LVC_T_FCAT.

SELECTION-SCREEN BEGIN OF BLOCK IMPORT WITH FRAME TITLE TEXT-004.
PARAMETERS:
  P_LOFILE            TYPE LOCALFILE
                  DEFAULT 'C:\Users\BATMAN\Desktop\ZDEMO_EXP_EXCEL.xls'.
SELECTION-SCREEN END OF BLOCK IMPORT.
SELECTION-SCREEN BEGIN OF BLOCK EXPORT WITH FRAME TITLE TEXT-005.
PARAMETERS:
  P_ALV               TYPE XMARK RADIOBUTTON GROUP EXP DEFAULT 'X',
  P_EXC               TYPE XMARK RADIOBUTTON GROUP EXP.
SELECTION-SCREEN END OF BLOCK EXPORT.