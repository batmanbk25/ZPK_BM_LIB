FUNCTION ZFM_DATA_COND_CHECK_RECORD.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_REPID) TYPE  REPID DEFAULT SY-CPROG
*"     REFERENCE(I_RECORD) TYPE  ANY
*"     REFERENCE(I_TAB_RANGE) TYPE  RSDSRANGE_S_SSEL
*"  EXPORTING
*"     REFERENCE(E_FIT) TYPE  XMARK
*"----------------------------------------------------------------------
  DATA:
    LS_FLD_RANGE              TYPE RSDSFRANGE_S_SSEL,
    LS_RANGE                  TYPE RSDSSELOPT,
    LT_RANGE                  TYPE RSDSSELOPT_T.
  FIELD-SYMBOLS:
    <LW_FIELD>                TYPE ANY.

* Init
  E_FIT   = GC_XMARK.

* Check conditions of ech field
  LOOP AT I_TAB_RANGE-FRANGE_T INTO LS_FLD_RANGE.
    CALL FUNCTION 'ZFM_DATA_COND_CHECK_FIT'
      EXPORTING
        I_REPID       = I_REPID
        I_RECORD      = I_RECORD
        I_FIELD_RANGE = LS_FLD_RANGE
      IMPORTING
        E_FIT         = E_FIT.
*   Neu ko thoa man thi DK khong hop le
    IF E_FIT IS INITIAL.
      RETURN.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
