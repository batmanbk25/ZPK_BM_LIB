FUNCTION ZFM_DATE_CONV_TO_INTERNAL.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_DATE_STR)
*"     REFERENCE(I_EXT_FORMAT) TYPE  ZDD_BM_DATE_FORMAT DEFAULT
*"       'DD/MM/YYYY'
*"  EXPORTING
*"     REFERENCE(E_DATE) TYPE  DATUM
*"  EXCEPTIONS
*"      INVALID_DATE
*"      INVALID_FORMAT
*"----------------------------------------------------------------------
  DATA:
    BEGIN OF LW_DATE,
      YEAR                    TYPE CHAR4,
      MONTH                   TYPE CHAR2,
      DAY                     TYPE CHAR2,
    END OF LW_DATE,
    LW_OFFSET_DAY             TYPE I,
    LW_OFFSET_MONTH           TYPE I,
    LW_OFFSET_YEAR            TYPE I.

* Init
  CLEAR: E_DATE.

* Check date string contain only Number, separator and space
  IF I_DATE_STR CN '0123456789/.- '.
    RAISE INVALID_DATE.
  ENDIF.

* Check date format contain only D, M, Y, separator and space
  IF I_EXT_FORMAT CN 'DMY/.- '.
    RAISE INVALID_FORMAT.
  ENDIF.

* Find day position in format
  FIND GC_FORMAT_DAY IN I_EXT_FORMAT IGNORING CASE
    MATCH OFFSET LW_OFFSET_DAY.
  IF SY-SUBRC IS NOT INITIAL.
    RAISE INVALID_FORMAT.
  ENDIF.

* Find Month position in format
  FIND GC_FORMAT_MONTH IN I_EXT_FORMAT IGNORING CASE
    MATCH OFFSET LW_OFFSET_MONTH.
  IF SY-SUBRC IS NOT INITIAL.
    RAISE INVALID_FORMAT.
  ENDIF.

* Find year position in format
  FIND GC_FORMAT_YEAR IN I_EXT_FORMAT IGNORING CASE
    MATCH OFFSET LW_OFFSET_YEAR.
  IF SY-SUBRC IS NOT INITIAL.
    RAISE INVALID_FORMAT.
  ENDIF.

* Build date by Day, Month, Year positions
  LW_DATE-DAY                 = I_DATE_STR+LW_OFFSET_DAY(2).
  LW_DATE-MONTH               = I_DATE_STR+LW_OFFSET_MONTH(2).
  LW_DATE-YEAR                = I_DATE_STR+LW_OFFSET_YEAR(4).
  E_DATE                      = LW_DATE.

* Check date valid
  CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
    EXPORTING
      DATE                      = E_DATE
    EXCEPTIONS
      PLAUSIBILITY_CHECK_FAILED = 1
      OTHERS                    = 2.
  IF SY-SUBRC <> 0.
    CLEAR: E_DATE.
    RAISE INVALID_DATE.
  ENDIF.

ENDFUNCTION.
