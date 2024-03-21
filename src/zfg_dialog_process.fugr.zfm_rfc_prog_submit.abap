FUNCTION ZFM_RFC_PROG_SUBMIT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_REPID) TYPE  REPID OPTIONAL
*"     VALUE(I_TCODE) TYPE  TCODE OPTIONAL
*"--------------------------------------------------------------------
IF I_TCODE IS NOT INITIAL.
    CALL TRANSACTION I_TCODE.
  ELSE.
    SUBMIT I_REPID AND RETURN.
  ENDIF.





ENDFUNCTION.
