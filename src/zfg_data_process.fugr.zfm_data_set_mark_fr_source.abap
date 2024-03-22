FUNCTION ZFM_DATA_SET_MARK_FR_SOURCE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_SOURCE) TYPE  ANY
*"  CHANGING
*"     REFERENCE(C_DATA) TYPE  ANY
*"----------------------------------------------------------------------

  DATA:
    LW_TYPE  TYPE C,
    LW_COMPS TYPE I,
    LW_INDEX TYPE I,
    LT_FCAT  TYPE LVC_T_FCAT,
    LW_FNAME TYPE TABNAME.
  FIELD-SYMBOLS:
    <LF_SRC_VALUE>  TYPE ANY,
    <LF_MARK_VALUE> TYPE ANY.

  IF 1 = 2.
    DESCRIBE FIELD C_DATA TYPE LW_TYPE COMPONENTS LW_COMPS.
    DO LW_COMPS TIMES.
      LW_INDEX = SY-INDEX.
      ASSIGN COMPONENT LW_INDEX OF STRUCTURE I_SOURCE TO <LF_SRC_VALUE>.
      IF SY-SUBRC IS INITIAL AND <LF_SRC_VALUE> IS NOT INITIAL.
        ASSIGN COMPONENT LW_INDEX OF STRUCTURE C_DATA TO <LF_MARK_VALUE>.
        IF SY-SUBRC IS INITIAL.
          <LF_MARK_VALUE> = GC_XMARK.
        ENDIF.
      ENDIF.
    ENDDO.
  ELSE.
    DESCRIBE FIELD C_DATA HELP-ID LW_FNAME.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        I_STRUCTURE_NAME       = LW_FNAME
      CHANGING
        CT_FIELDCAT            = LT_FCAT
      EXCEPTIONS
        INCONSISTENT_INTERFACE = 1
        PROGRAM_ERROR          = 2
        OTHERS                 = 3.
    LOOP AT LT_FCAT INTO DATA(LS_FCAT).
      ASSIGN COMPONENT LS_FCAT-FIELDNAME OF STRUCTURE I_SOURCE TO <LF_SRC_VALUE>.
      IF SY-SUBRC IS INITIAL AND <LF_SRC_VALUE> IS NOT INITIAL.
        ASSIGN COMPONENT LS_FCAT-FIELDNAME OF STRUCTURE C_DATA TO <LF_MARK_VALUE>.
        IF SY-SUBRC IS INITIAL.
          IF LS_FCAT-INTTYPE = 'C' AND LS_FCAT-INTLEN = 1.
            <LF_MARK_VALUE> = GC_XMARK.
          ELSE.
            <LF_MARK_VALUE> = <LF_SRC_VALUE>.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFUNCTION.
