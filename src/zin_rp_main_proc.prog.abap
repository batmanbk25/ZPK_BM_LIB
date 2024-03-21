*&---------------------------------------------------------------------*
*&  Include           ZIN_RP_MAIN_PROC
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  MAIN_PROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MAIN_PROC .
  PERFORM GET_REPORT_DATA.
  PERFORM PROCESS_DATA.
  PERFORM OUTPUT_DATA.

ENDFORM.                    " MAIN_PROC

*&---------------------------------------------------------------------*
*&      Form  OUTPUT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM OUTPUT_DATA .

  CALL FUNCTION 'ZFM_RP_OUTPUT'
    EXPORTING
      I_DEFAULT_FILENAME = GW_DEFAULT_FILENAME
      I_SMARTFORM        = GC_SMFNAME
    CHANGING
      I_DATA             = GS_DATA.
ENDFORM.                    " OUTPUT_DATA
