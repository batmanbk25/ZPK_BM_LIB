FUNCTION ZFM_GET_FIRST_LAST_DAY_QUARTER.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_QUARTER) TYPE  I OPTIONAL
*"     REFERENCE(I_YEAR) TYPE  GJAHR OPTIONAL
*"     REFERENCE(I_DATE) TYPE  DATUM OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_BEGDA) TYPE  DATUM
*"     REFERENCE(E_ENDDA) TYPE  DATUM
*"     REFERENCE(E_BEGMO) TYPE  SPMON
*"     REFERENCE(E_ENDMO) TYPE  SPMON
*"--------------------------------------------------------------------
DATA:
    LW_YEAR   TYPE GJAHR,
    LW_QUATER TYPE I,
    LW_MONTH  TYPE I.

  IF I_DATE IS NOT INITIAL.
*   Get month
    LW_MONTH = I_DATE+4(2).

*   Get quarter
    LW_QUATER = TRUNC( ( LW_MONTH - 1 ) DIV 3 ) + 1.

*   Set year
    LW_YEAR = I_DATE(4).
  ELSE.
    LW_YEAR = I_YEAR.
    LW_QUATER = I_QUARTER.
  ENDIF.

  E_BEGDA     = E_ENDDA    = LW_YEAR.
  E_BEGMO(4)  = E_ENDMO(4) = LW_YEAR.

  CASE LW_QUATER.
    WHEN '1'.
      E_BEGDA+4(4) = '0101'.
      E_ENDDA+4(4) = '0331'.
      E_BEGMO+4(2) = '01'.
      E_ENDMO+4(2) = '03'.

    WHEN '2'.
      E_BEGDA+4(4) = '0401'.
      E_ENDDA+4(4) = '0630'.
      E_BEGMO+4(2) = '04'.
      E_ENDMO+4(2) = '06'.

    WHEN '3'.
      E_BEGDA+4(4) = '0701'.
      E_ENDDA+4(4) = '0930'.
      E_BEGMO+4(2) = '07'.
      E_ENDMO+4(2) = '09'.

    WHEN '4'.
      E_BEGDA+4(4) = '1001'.
      E_ENDDA+4(4) = '1231'.
      E_BEGMO+4(2) = '10'.
      E_ENDMO+4(2) = '12'.

    WHEN OTHERS.
      CLEAR: E_BEGDA, E_ENDDA.

  ENDCASE.





ENDFUNCTION.
