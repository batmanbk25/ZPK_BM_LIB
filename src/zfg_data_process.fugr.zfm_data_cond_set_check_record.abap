FUNCTION ZFM_DATA_COND_SET_CHECK_RECORD.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_REPID) TYPE  REPID DEFAULT SY-CPROG
*"     REFERENCE(I_RECORD) TYPE  ANY
*"     REFERENCE(T_CONDITIONS) TYPE  ZTT_BM_FIELD_COND
*"     REFERENCE(I_TABNAME) TYPE  TABNAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_FIT) TYPE  XMARK
*"----------------------------------------------------------------------

  DATA:
    LS_TAB_RANGE              TYPE RSDSRANGE_S_SSEL,
    LS_COND_SET               TYPE ZST_BM_COND_SET,
    LT_COND_SET               TYPE ZTT_BM_COND_SET.

  IF T_CONDITIONS IS INITIAL.
    E_FIT = GC_XMARK.
    RETURN.
  ENDIF.

* Aggregate conditions to set
  CALL FUNCTION 'ZFM_DATA_COND_AGG_TO_SET'
    EXPORTING
      T_CONDITIONS = T_CONDITIONS
    IMPORTING
      T_COND_SET   = LT_COND_SET.

  LOOP AT LT_COND_SET INTO LS_COND_SET.
    LOOP AT LS_COND_SET-TAB_COND INTO LS_TAB_RANGE.
      IF I_TABNAME IS NOT INITIAL
      AND LS_TAB_RANGE-TABLENAME <> I_TABNAME.
        CONTINUE.
      ENDIF.
*     Check record fit 1 condition set
      CALL FUNCTION 'ZFM_DATA_COND_CHECK_RECORD'
        EXPORTING
          I_REPID     = SY-REPID
          I_RECORD    = I_RECORD
          I_TAB_RANGE = LS_TAB_RANGE
        IMPORTING
          E_FIT       = E_FIT.
*     Neu ko thoa man thi bo DK hop le, thoat
      IF E_FIT IS INITIAL.
        EXIT.
      ENDIF.
    ENDLOOP.
*   Neu thoa man 1 bo DK thi hop le
    IF E_FIT IS NOT INITIAL.
      RETURN.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
