FUNCTION ZFM_DATA_COMPARE_TABLE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_NEW_DATA) TYPE  TABLE
*"     REFERENCE(I_OLD_DATA) TYPE  TABLE
*"     REFERENCE(I_STRUCTURE) TYPE  TABNAME
*"  EXPORTING
*"     REFERENCE(E_CHANGE_X) TYPE  ANY
*"     REFERENCE(E_DIFFERENT) TYPE  XMARK
*"  EXCEPTIONS
*"      NO_STRUCTURE
*"--------------------------------------------------------------------
DATA: LW_INDEX        TYPE INT4.
  FIELD-SYMBOLS: <LF_NEW_DATA>   TYPE ANY,
                 <LF_OLD_DATA>   TYPE ANY,
                 <LF_FIELD_X>    TYPE ANY,
                 <LF_FIELD_NEW>  TYPE ANY,
                 <LF_FIELD_OLD>  TYPE ANY.

*----------------------------------------------------*
  CLEAR: E_DIFFERENT, E_CHANGE_X.
  IF I_STRUCTURE IS INITIAL.
    RAISE NO_STRUCTURE.
  ENDIF.

  LOOP AT I_NEW_DATA ASSIGNING <LF_NEW_DATA>.
    LW_INDEX = SY-TABIX.
    READ TABLE I_OLD_DATA ASSIGNING <LF_OLD_DATA> INDEX LW_INDEX.
    IF SY-SUBRC IS INITIAL.
      CALL FUNCTION 'ZFM_DATA_COMPARE_STR'
        EXPORTING
          I_NEW_DATA         = <LF_NEW_DATA>
          I_OLD_DATA         = <LF_OLD_DATA>
          I_STRUCTURE        = I_STRUCTURE
        IMPORTING
          E_DIFFERENT        = E_DIFFERENT
        EXCEPTIONS
          NO_STRUCTURE       = 1
          OTHERS             = 2.
      IF E_DIFFERENT IS NOT INITIAL.
        RETURN.
      ENDIF.
    ELSE.
      E_DIFFERENT = GC_MARK.
      RETURN.
    ENDIF.
  ENDLOOP.





ENDFUNCTION.
