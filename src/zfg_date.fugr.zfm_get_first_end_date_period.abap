FUNCTION ZFM_GET_FIRST_END_DATE_PERIOD.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_DATE) TYPE  DATUM DEFAULT SY-DATUM
*"     VALUE(I_FOR_MONTH) TYPE  XMARK OPTIONAL
*"     VALUE(I_FOR_QUARTER) TYPE  XMARK OPTIONAL
*"     VALUE(I_FOR_YEAR) TYPE  XMARK OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_BEGDA) TYPE  DATUM
*"     REFERENCE(E_ENDDA) TYPE  DATUM
*"  EXCEPTIONS
*"      NO_TYPE_TO_GET
*"--------------------------------------------------------------------
IF  I_FOR_MONTH IS INITIAL
  AND I_FOR_QUARTER IS INITIAL
  AND I_FOR_YEAR IS INITIAL.
    RAISE NO_TYPE_TO_GET.
  ENDIF.

  IF I_FOR_MONTH = 'X'.
    CALL FUNCTION 'OIL_MONTH_GET_FIRST_LAST'
      EXPORTING
        I_DATE      = I_DATE
      IMPORTING
        E_FIRST_DAY = E_BEGDA
        E_LAST_DAY  = E_ENDDA
      EXCEPTIONS
        WRONG_DATE  = 1
        OTHERS      = 2.
  ENDIF.

  IF I_FOR_QUARTER = 'X'.
    CALL FUNCTION 'ZFM_GET_FIRST_LAST_DAY_QUARTER'
      EXPORTING
        I_DATE  = I_DATE
      IMPORTING
        E_BEGDA = E_BEGDA
        E_ENDDA = E_ENDDA.
  ENDIF.

  IF I_FOR_YEAR = 'X'.
    E_BEGDA(4) = E_ENDDA(4) = I_DATE(4).
    E_BEGDA+4(2) = E_BEGDA+6(2) = 1.
    E_ENDDA+4(2) = 12.
    E_ENDDA+6(2) = 31.
  ENDIF.





ENDFUNCTION.
