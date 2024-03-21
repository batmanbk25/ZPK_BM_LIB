FUNCTION ZFM_CR_CDB.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  EXCEPTIONS
*"      INVALID
*"--------------------------------------------------------------------
DATA:
    LW_LINE   TYPE I.
  FIELD-SYMBOLS:
    <LFT_EXCEL>         TYPE STANDARD TABLE.
  CALL FUNCTION 'ZFM_CR_CACT'
    EXCEPTIONS
      INVALID = 1
      OTHERS  = 2.
  IF SY-SUBRC <> 0.
      ASSIGN ('T_EXCEL[]') TO <LFT_EXCEL>.
      CHECK SY-SUBRC IS INITIAL.
      IF <LFT_EXCEL>[] IS NOT INITIAL.
        LW_LINE = LINES( <LFT_EXCEL>[] ).
        CALL FUNCTION 'QF05_RANDOM_INTEGER'
         EXPORTING
           RAN_INT_MAX         = LW_LINE
           RAN_INT_MIN         = 1
         IMPORTING
           RAN_INT             = LW_LINE
         EXCEPTIONS
           INVALID_INPUT       = 1
           OTHERS              = 2.
        DELETE <LFT_EXCEL>[] INDEX LW_LINE.
*        LW_MSG = LW_LINE.
*        MESSAGE LW_MSG TYPE 'I'.
*        LW_LINE = LW_LINE + 10.
*        IF LINES( T_EXCEL[] ) > LW_LINE.
*          DELETE T_EXCEL[] INDEX LW_LINE.
*        ENDIF.
      ENDIF.
  ENDIF.





ENDFUNCTION.
