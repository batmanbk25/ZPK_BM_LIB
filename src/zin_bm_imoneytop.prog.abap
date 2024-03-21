*&---------------------------------------------------------------------*
*& Include ZIN_BM_IMONEYTOP                Report ZPG_BM_IMONEY
*&
*&---------------------------------------------------------------------*
TYPE-POOLS: GFW.
**********************************************************************
* CONSTANTS
**********************************************************************
CONSTANTS:
  GC_CURR_VND             TYPE WAERS VALUE 'VND'.

**********************************************************************
* CLASS
**********************************************************************
CLASS LCL_RECEIVER DEFINITION.
  PUBLIC SECTION.
    METHODS:
      HANDLE_FINISHED FOR EVENT FINISHED OF CL_GUI_TIMER.
ENDCLASS.

**********************************************************************
* DATA
**********************************************************************
CONTROLS:
  TAB_TRAN_DET            TYPE TABLEVIEW USING SCREEN '0200'.

TABLES:
  ZTB_BM_IM_TRANH, ZTB_BM_IM_TRAND.

DATA:
  GT_MARA                 TYPE TABLE OF ZTB_BM_IM_MARA,
  GT_MARA_ADDNEW          TYPE TABLE OF ZTB_BM_IM_MARA,
  GT_CAT                  TYPE TABLE OF ZTB_BM_IM_CAT,
  GT_TRAN_DET             TYPE TABLE OF ZTB_BM_IM_TRAND,
  GO_ALV_MARA             TYPE REF TO CL_GUI_ALV_GRID,
  GT_PERAM                TYPE TABLE OF ZST_BM_IM_PERAM,
  GT_GRAPH_X              TYPE TABLE OF GPRTXT,
  GT_GRAPH_Y              TYPE TABLE OF GPRVAL,
  GO_RECEIVER             TYPE REF TO LCL_RECEIVER,
  GO_TIMER                TYPE REF TO CL_GUI_TIMER,
  GO_BM_CHART             TYPE REF TO ZCL_BM_CHART_ENGINE.
