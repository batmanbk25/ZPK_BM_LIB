FUNCTION ZFM_DATE_CONV_TSTAMP_DATETIME.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_CURRENT) TYPE  XMARK DEFAULT 'X'
*"     REFERENCE(I_TIMESTAMP) TYPE  TIMESTAMP OPTIONAL
*"     REFERENCE(I_SHORTDATE) TYPE  XMARK DEFAULT 'X'
*"  EXPORTING
*"     REFERENCE(E_DATETIME)
*"----------------------------------------------------------------------

  DATA:
    LW_TIME_STAMP             TYPE TIMESTAMP,
    LW_DATE                   TYPE DATUM,
    LW_TIME                   TYPE TIMS,
    LW_TIME_STR               TYPE CHAR8,
    LW_DATE_STR               TYPE CHAR16,
    LW_DATETIME               TYPE CHAR24.

* Get timestamp
  IF I_CURRENT IS INITIAL.
    LW_TIME_STAMP             = I_TIMESTAMP.
  ELSE.
    GET TIME STAMP FIELD LW_TIME_STAMP.
  ENDIF.

* Get date, time in timestamp
  CONVERT TIME STAMP LW_TIME_STAMP TIME ZONE SY-ZONLO
    INTO DATE LW_DATE TIME LW_TIME.

* Convert time to text
  WRITE LW_TIME TO LW_TIME_STR.

* Convert date to text
  IF I_SHORTDATE IS INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_LDATE_OUTPUT'
      EXPORTING
        INPUT  = LW_DATE
      IMPORTING
        OUTPUT = LW_DATE_STR.
  ELSE.
    CALL FUNCTION 'CONVERSION_EXIT_SDATE_OUTPUT'
      EXPORTING
        INPUT  = LW_DATE
      IMPORTING
        OUTPUT = LW_DATE_STR.
  ENDIF.
  REPLACE ALL OCCURRENCES OF '.' IN LW_DATE_STR WITH '-'.

* Output full datetime
  CONCATENATE LW_DATE_STR LW_TIME_STR INTO LW_DATETIME
    SEPARATED BY SPACE.
  E_DATETIME = LW_DATETIME.

ENDFUNCTION.