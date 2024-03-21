FUNCTION VIEWPROC_ZVI_EXCEL_SHEETS.
*"--------------------------------------------------------------------
*"*"Global Interface:
*"  IMPORTING
*"     VALUE(FCODE) DEFAULT 'RDED'
*"     VALUE(VIEW_ACTION) DEFAULT 'S'
*"     VALUE(VIEW_NAME) LIKE  DD02V-TABNAME
*"     VALUE(CORR_NUMBER) LIKE  E070-TRKORR DEFAULT ' '
*"  EXPORTING
*"     VALUE(LAST_ACT_ENTRY)
*"     VALUE(UCOMM)
*"     VALUE(UPDATE_REQUIRED)
*"  TABLES
*"      CORR_KEYTAB STRUCTURE  E071K
*"      DBA_SELLIST STRUCTURE  VIMSELLIST
*"      DPL_SELLIST STRUCTURE  VIMSELLIST
*"      EXCL_CUA_FUNCT STRUCTURE  VIMEXCLFUN
*"      EXTRACT
*"      TOTAL
*"      X_HEADER STRUCTURE  VIMDESC
*"      X_NAMTAB STRUCTURE  VIMNAMTAB
*"  EXCEPTIONS
*"      NO_VALUE_FOR_SUBSET_IDENT
*"      MISSING_CORR_NUMBER
*"      SAVING_CORRECTION_FAILED
*"--------------------------------------------------------------------
*---------------------------------------------------------------------*
*    program for:   VIEWPROC_ZVI_EXCEL_SHEETS
*   generation date: 22.01.2014 at 18:32:21 by user TUANBA
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Initialization: set field-symbols etc.                               *
*----------------------------------------------------------------------*
   IF LAST_VIEW_INFO NE VIEW_NAME.
ASSIGN ZVI_EXCEL_SHEETS TO <TABLE1>.
ASSIGN *ZVI_EXCEL_SHEETS TO <INITIAL>.
ASSIGN STATUS_ZVI_EXCEL_SHEETS TO <STATUS>.
     PERFORM INITIALISIEREN.
   ENDIF.
   PERFORM JUSTIFY_ACTION_MODE.
   MOVE: VIEW_ACTION TO MAINT_MODE,
         CORR_NUMBER TO CORR_NBR.

*----------------------------------------------------------------------*
* Get data from database                                               *
*----------------------------------------------------------------------*
  IF FCODE EQ READ OR FCODE EQ READ_AND_EDIT.
    PERFORM PREPARE_READ_REQUEST.
    IF X_HEADER-FRM_RP_GET NE SPACE.
            PERFORM (X_HEADER-FRM_RP_GET) IN PROGRAM.
    ELSE.
PERFORM GET_DATA_ZVI_EXCEL_SHEETS.
    ENDIF.
    IF FCODE EQ READ_AND_EDIT. FCODE = EDIT. ENDIF.
  ENDIF.

  CASE FCODE.
    WHEN  EDIT.                          " Edit read data
      PERFORM CALL_DYNPRO.
      PERFORM CHECK_UPD.
*....................................................................*

    WHEN SAVE.                           " Write data into database
      PERFORM PREPARE_SAVING.
      IF <STATUS>-UPD_FLAG NE SPACE.
        IF X_HEADER-FRM_RP_UPD NE SPACE.
          PERFORM (X_HEADER-FRM_RP_UPD) IN PROGRAM.
        ELSE.
          IF SY-SUBRC EQ 0.
PERFORM DB_UPD_ZVI_EXCEL_SHEETS.
          ENDIF.
        ENDIF.
        PERFORM AFTER_SAVING.
      ENDIF.
*....................................................................*

    WHEN RESET_LIST.     " Refresh all marked entries of EXTRACT from db
      PERFORM RESET_ENTRIES USING LIST_BILD.
*....................................................................*

    WHEN RESET_ENTRY.               " Refresh single entry from database
      PERFORM RESET_ENTRIES USING DETAIL_BILD.
*.......................................................................
  ENDCASE.
MOVE STATUS_ZVI_EXCEL_SHEETS-UPD_FLAG TO UPDATE_REQUIRED.





ENDFUNCTION.
