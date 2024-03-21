FUNCTION ZFM_DATA_VALUE2TEXT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_FIELDCAT) TYPE  LVC_S_FCAT OPTIONAL
*"     REFERENCE(I_DATASTR)
*"     REFERENCE(I_FIELDNAME) TYPE  FIELDNAME
*"     REFERENCE(I_FOR_EXCEL) TYPE  XMARK OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_VALUET)
*"--------------------------------------------------------------------
DATA:
    BEGIN OF LS_DATE,
      YEAR        TYPE GJAHR,
      MONTH       TYPE MONTH,
      DAY(2)      TYPE N,
    END OF LS_DATE,
    LW_TABNAME    TYPE TABNAME,
    LT_FIELDCAT   TYPE TABLE OF LVC_S_FCAT,
    LS_FIELDCAT   TYPE LVC_S_FCAT,
    LT_RETURN     TYPE TABLE OF BAPIRET2.

  FIELD-SYMBOLS:
    <LF_VALUE>      TYPE ANY,
    <LF_CURKY>      TYPE ANY,
    <LF_QUAN>       TYPE ANY.

  IF GS_DEFAULTS IS INITIAL.
    CALL FUNCTION 'BAPI_USER_GET_DETAIL'
      EXPORTING
        USERNAME = SY-UNAME
      IMPORTING
        DEFAULTS = GS_DEFAULTS
      TABLES
        RETURN   = LT_RETURN.
  ENDIF.

  IF I_FIELDCAT IS INITIAL.
    DESCRIBE FIELD I_DATASTR HELP-ID LW_TABNAME.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        I_STRUCTURE_NAME   = LW_TABNAME
        I_INTERNAL_TABNAME = LW_TABNAME
      CHANGING
        CT_FIELDCAT        = LT_FIELDCAT
      EXCEPTIONS
        OTHERS             = 3.
    READ TABLE LT_FIELDCAT INTO LS_FIELDCAT
      WITH KEY FIELDNAME = I_FIELDNAME.
  ELSE.
    LS_FIELDCAT = I_FIELDCAT.
  ENDIF.

  ASSIGN COMPONENT I_FIELDNAME OF STRUCTURE I_DATASTR TO <LF_VALUE>.
  CHECK SY-SUBRC IS INITIAL.
  E_VALUET = <LF_VALUE>.

* Process with leading 0 and =
  IF E_VALUET CP '==*'
  OR ( E_VALUET CP '0*' AND E_VALUET CO '0' ).
    CONCATENATE '''' E_VALUET INTO E_VALUET.
  ENDIF.

  CASE LS_FIELDCAT-DATATYPE.
    WHEN 'CURR'.
      ASSIGN COMPONENT LS_FIELDCAT-CFIELDNAME OF STRUCTURE I_DATASTR
        TO <LF_CURKY>.
      IF <LF_CURKY> IS INITIAL.
        CLEAR E_VALUET.
      ELSE.
        WRITE <LF_VALUE> TO E_VALUET
          CURRENCY <LF_CURKY> NO-SIGN.
        CONDENSE E_VALUET.

        IF I_FOR_EXCEL = 'X'.
          CASE GS_DEFAULTS-DCPFM.
            WHEN SPACE.
              REPLACE ALL OCCURRENCES OF '.' IN E_VALUET WITH ''.
              REPLACE ',' IN E_VALUET WITH '.'.
            WHEN 'X'.
              REPLACE ALL OCCURRENCES OF ',' IN E_VALUET WITH ''.
            WHEN 'Y'.
              CONDENSE E_VALUET.
              REPLACE ',' IN E_VALUET WITH '.'.
          ENDCASE.
        ENDIF.

        IF <LF_VALUE> < 0.
          CONCATENATE '-' E_VALUET INTO E_VALUET.
        ENDIF.
      ENDIF.
    WHEN 'QUAN'.
      ASSIGN COMPONENT LS_FIELDCAT-QFIELDNAME OF STRUCTURE I_DATASTR
        TO <LF_QUAN>.
      IF <LF_QUAN> IS INITIAL.
        E_VALUET = 0.
      ELSE.
        WRITE <LF_VALUE> TO E_VALUET UNIT <LF_QUAN> NO-SIGN.
        CONDENSE E_VALUET.
        IF <LF_VALUE> < 0.
          CONCATENATE '-' E_VALUET INTO E_VALUET.
        ENDIF.
      ENDIF.
    WHEN 'DATS'.
      IF <LF_VALUE> IS INITIAL.
        CLEAR: E_VALUET.
      ELSE.
        IF I_FOR_EXCEL = 'X'.
          LS_DATE = <LF_VALUE>.
          CONCATENATE LS_DATE-YEAR LS_DATE-MONTH LS_DATE-DAY
            INTO E_VALUET SEPARATED BY '/'.
        ELSE.
          WRITE <LF_VALUE> TO E_VALUET.
        ENDIF.
      ENDIF.
    WHEN 'NUMC'.
      IF <LF_VALUE> IS INITIAL.
        E_VALUET = 0.
      ENDIF.
    WHEN 'DEC'.
      IF <LF_VALUE> IS INITIAL.
        E_VALUET = 0.
      ELSE.
        IF I_FOR_EXCEL = 'X'.
          WRITE <LF_VALUE> TO E_VALUET NO-SIGN NO-GROUPING.
          CASE GS_DEFAULTS-DCPFM.
            WHEN SPACE.
              REPLACE ALL OCCURRENCES OF '.' IN E_VALUET WITH ''.
              REPLACE ',' IN E_VALUET WITH '.'.
            WHEN 'X'.
              REPLACE ALL OCCURRENCES OF ',' IN E_VALUET WITH ''.
            WHEN 'Y'.
              CONDENSE E_VALUET.
              REPLACE ',' IN E_VALUET WITH '.'.
          ENDCASE.
        ELSE.
          WRITE <LF_VALUE> TO E_VALUET NO-SIGN.
        ENDIF.
        IF <LF_VALUE> < 0.
          CONCATENATE '-' E_VALUET INTO E_VALUET.
        ENDIF.
      ENDIF.
      CONDENSE E_VALUET.
    WHEN OTHERS.
  ENDCASE.





ENDFUNCTION.
