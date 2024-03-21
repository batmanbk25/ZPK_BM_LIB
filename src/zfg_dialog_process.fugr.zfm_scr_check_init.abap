FUNCTION ZFM_SCR_CHECK_INIT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_AUTO_STOP) TYPE  XMARK DEFAULT 'X'
*"     REFERENCE(I_DYNNR) TYPE  DYNNR DEFAULT SY-DYNNR
*"  CHANGING
*"     REFERENCE(T_FIELD) TYPE  ZTT_ERR_FIELD
*"--------------------------------------------------------------------
DATA:
      LS_FIELD      TYPE ZST_ERR_FIELD,
      LW_FULLFIELD  TYPE CHAR100,
      LW_SCRTEXT_L  TYPE SCRTEXT_L,
      LW_MEMID      TYPE CHAR70.
  FIELD-SYMBOLS:
    <LF_ERR_FIELD>    TYPE ANY.

  LOOP AT T_FIELD INTO LS_FIELD.
    CONCATENATE '(' SY-CPROG ')' LS_FIELD-FIELD INTO LW_FULLFIELD.
    ASSIGN (LW_FULLFIELD) TO <LF_ERR_FIELD>.
    IF <LF_ERR_FIELD> IS INITIAL.
*     Set message Field need input
      CLEAR LS_FIELD.
      LS_FIELD-DYNNR   = I_DYNNR.
      LS_FIELD-TYPE    = 'E'.
      LS_FIELD-ID      = GC_MSG_CL.
      LS_FIELD-NUMBER  = '001'.

*     Get field label
      PERFORM GET_FIELD_LABEL
        USING LS_FIELD-FIELD
              <LF_ERR_FIELD>
              SY-CPROG
              I_DYNNR
     CHANGING LW_SCRTEXT_L.

      CLEAR: T_FIELD[].
      UNASSIGN <LF_ERR_FIELD>.
      APPEND LS_FIELD TO T_FIELD.
      EXIT.
    ENDIF.
  ENDLOOP.

* Export error fields to memory name:
* "[ProgramName][ScreenNo]_ERR_FIELDS"
  PERFORM ERROR_FIELDS_EXPORT
    USING SY-CPROG I_DYNNR T_FIELD I_AUTO_STOP.





ENDFUNCTION.
