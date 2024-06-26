FUNCTION ZFM_DATA_STR_USER_LOG.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_ACTION) TYPE  C
*"  CHANGING
*"     REFERENCE(CS_DATA) TYPE  ANY
*"----------------------------------------------------------------------

  CASE I_ACTION.
    WHEN 'I'.
      ASSIGN COMPONENT 'CRUSR' OF STRUCTURE CS_DATA TO FIELD-SYMBOL(<LF_FIELD>).
      IF SY-SUBRC IS INITIAL.
        <LF_FIELD> = SY-UNAME.
      ENDIF.
      ASSIGN COMPONENT 'CRDAT' OF STRUCTURE CS_DATA TO <LF_FIELD>.
      IF SY-SUBRC IS INITIAL.
        <LF_FIELD> = SY-DATUM.
      ENDIF.
      ASSIGN COMPONENT 'CRTIM' OF STRUCTURE CS_DATA TO <LF_FIELD>.
      IF SY-SUBRC IS INITIAL.
        <LF_FIELD> = SY-UZEIT.
      ENDIF.
    WHEN 'U' OR 'D'.
      ASSIGN COMPONENT 'CHUSR' OF STRUCTURE CS_DATA TO <LF_FIELD>.
      IF SY-SUBRC IS INITIAL.
        <LF_FIELD> = SY-UNAME.
      ENDIF.
      ASSIGN COMPONENT 'CHDAT' OF STRUCTURE CS_DATA TO <LF_FIELD>.
      IF SY-SUBRC IS INITIAL.
        <LF_FIELD> = SY-DATUM.
      ENDIF.
      ASSIGN COMPONENT 'CHTIM' OF STRUCTURE CS_DATA TO <LF_FIELD>.
      IF SY-SUBRC IS INITIAL.
        <LF_FIELD> = SY-UZEIT.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

ENDFUNCTION.
