FUNCTION ZFM_DATA_COND_STANDARDLIZE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_REPID) TYPE  REPID DEFAULT SY-CPROG
*"     REFERENCE(I_RECORD) TYPE  ANY
*"  CHANGING
*"     REFERENCE(C_RANGE) TYPE  RSDSSELOPT
*"----------------------------------------------------------------------

* Standard low value
  PERFORM 9999_STANDARD_COND_VALUE
    USING I_REPID
          I_RECORD
    CHANGING C_RANGE-LOW.

* Standard high value
  PERFORM 9999_STANDARD_COND_VALUE
    USING I_REPID
          I_RECORD
    CHANGING C_RANGE-HIGH.

ENDFUNCTION.
