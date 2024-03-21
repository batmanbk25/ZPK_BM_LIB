FUNCTION ZFM_SCR_CHECK_DATE_TODAY.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_PROG) TYPE  SYCPROG DEFAULT SY-CPROG
*"     REFERENCE(I_DYNNR) TYPE  DYNNR DEFAULT SY-DYNNR
*"     REFERENCE(I_DATE) TYPE  ANY
*"     REFERENCE(I_OPTION) TYPE  TVARV_OPTI DEFAULT 'LE'
*"     REFERENCE(I_FIELDNAME) TYPE  CHAR61 OPTIONAL
*"     REFERENCE(I_ROW) TYPE  BAPI_LINE OPTIONAL
*"--------------------------------------------------------------------
DATA:
    LW_FNAME      TYPE CHAR61.

* Get label by type of screen element
  DESCRIBE FIELD I_DATE HELP-ID LW_FNAME.

  CASE I_OPTION.
    WHEN 'LE'.
      IF NOT I_DATE LE SY-DATUM.
        CALL FUNCTION 'ZFM_SCR_PAI_PUT_ERR_FIELD'
          EXPORTING
            I_PROG            = I_PROG
            I_DYNNR           = I_DYNNR
            I_FIELDNAME       = LW_FNAME"I_FIELDNAME
            I_ROW             = I_ROW
            I_MSGID           = GC_MSG_CL
            I_MSGNO           = '007'
            I_GETFTEXT        = GC_XMARK
            I_MSGV2           = TEXT-CLE.
      ENDIF.
    WHEN 'GE'.
      IF NOT I_DATE GE SY-DATUM.
        CALL FUNCTION 'ZFM_SCR_PAI_PUT_ERR_FIELD'
          EXPORTING
            I_PROG            = I_PROG
            I_DYNNR           = I_DYNNR
            I_FIELDNAME       = LW_FNAME"I_FIELDNAME
            I_ROW             = I_ROW
            I_MSGID           = GC_MSG_CL
            I_MSGNO           = '007'
            I_GETFTEXT        = GC_XMARK
            I_MSGV2           = TEXT-CGE.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.





ENDFUNCTION.
