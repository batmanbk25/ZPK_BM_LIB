*&---------------------------------------------------------------------*
*& Include ZIN_MNG_EXCEL_TEMPLATETOP      Report ZPG_MNG_EXCEL_TEMPLATE
*&
*&---------------------------------------------------------------------*

INCLUDE ZIN_COMMONTOP.

**********************************************************************
* CONSTANTS                                                          *
**********************************************************************
CONSTANTS:
 GC_FC_IMPORT          TYPE SY-UCOMM VALUE 'FC_IMPORT',
 GC_FC_EXPORT          TYPE SY-UCOMM VALUE 'FC_EXPORT',
 GC_FC_SETFOLD         TYPE SY-UCOMM VALUE 'FC_SETFOLD',
 GC_FC_REMAP           TYPE SY-UCOMM VALUE 'FC_REMAP',
 GC_FC_SELALL          TYPE SY-UCOMM VALUE 'FC_SELALL',
 GC_FC_SELNONE         TYPE SY-UCOMM VALUE 'FC_SELNONE',
 GC_FC_REBUILD         TYPE SY-UCOMM VALUE 'FC_REBUILD'.


**********************************************************************
* DATA                                                               *
**********************************************************************
TABLES:
  RCGFILETR.

DATA:
  GT_PROG_EXCEL         TYPE TABLE OF ZST_BM_PROG_EXCEL,
  GT_PHYSIC_FILE        TYPE TABLE OF FILE_INFO,
  GW_FOLDER             TYPE STRING,
  GW_SEPARATOR          TYPE C,
  GO_ALV_FILE           TYPE REF TO CL_GUI_ALV_GRID,
  GO_CUS_FILE           TYPE REF TO CL_GUI_CUSTOM_CONTAINER.
