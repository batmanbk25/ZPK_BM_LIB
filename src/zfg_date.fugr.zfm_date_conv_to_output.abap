FUNCTION ZFM_DATE_CONV_TO_OUTPUT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_DATE) TYPE  DATUM
*"     REFERENCE(I_ORDINAL) TYPE  XMARK DEFAULT 'X'
*"  EXPORTING
*"     REFERENCE(E_DATE)
*"----------------------------------------------------------------------
  DATA:
    BEGIN OF LS_DATE_STR,
      DAY     TYPE NUMC2,
      ORDINAL TYPE CHAR4,
      MONTH   TYPE CHAR3,
      YEAR    TYPE NUMC4,
    END OF LS_DATE_STR,
    LW_DATE_STR TYPE TEXT30.

  CALL FUNCTION 'CONVERSION_EXIT_LDATE_OUTPUT'
    EXPORTING
      INPUT  = I_DATE
    IMPORTING
      OUTPUT = LW_DATE_STR.

  SPLIT LW_DATE_STR AT SPACE
   INTO LS_DATE_STR-DAY
        LS_DATE_STR-MONTH
        LS_DATE_STR-YEAR.

  IF I_ORDINAL IS INITIAL.
    LS_DATE_STR-ORDINAL = LS_DATE_STR-DAY.
  ELSE.
    IF LS_DATE_STR-DAY BETWEEN 11 AND 13.
      LS_DATE_STR-ORDINAL = 'th'.
    ELSE.
      CASE LS_DATE_STR-DAY+1(1).
        WHEN 1.
          LS_DATE_STR-ORDINAL = 'st'.
        WHEN 2.
          LS_DATE_STR-ORDINAL = 'nd'.
        WHEN 3.
          LS_DATE_STR-ORDINAL = 'rd'.
        WHEN OTHERS.
          LS_DATE_STR-ORDINAL = 'th'.
      ENDCASE.
    ENDIF.

    IF LS_DATE_STR-DAY < 10.
      CONCATENATE LS_DATE_STR-DAY+1(1) LS_DATE_STR-ORDINAL
             INTO LS_DATE_STR-ORDINAL.
    ELSE.
      CONCATENATE LS_DATE_STR-DAY LS_DATE_STR-ORDINAL
             INTO LS_DATE_STR-ORDINAL.
    ENDIF.
  ENDIF.

  CONCATENATE LS_DATE_STR-ORDINAL
        LS_DATE_STR-MONTH
        LS_DATE_STR-YEAR INTO E_DATE SEPARATED BY SPACE.

ENDFUNCTION.
