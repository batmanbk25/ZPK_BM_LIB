FUNCTION ZFM_EMAIL_CHECK.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_EMAIL) TYPE  AD_SMTPADR
*"  EXCEPTIONS
*"      INVALID
*"--------------------------------------------------------------------
CONSTANTS:
   LC_ADDR_TYPE_EMAIL  TYPE SX_ADDRTYP  VALUE 'INT'.     " Email address
  DATA:
    LS_ADDRESS_UNSTRUCT TYPE SX_ADDRESS.

  LS_ADDRESS_UNSTRUCT-TYPE    = LC_ADDR_TYPE_EMAIL.
  LS_ADDRESS_UNSTRUCT-ADDRESS = I_EMAIL.

  CALL FUNCTION 'SX_INTERNET_ADDRESS_TO_NORMAL'
    EXPORTING
      ADDRESS_UNSTRUCT    = LS_ADDRESS_UNSTRUCT
      COMPLETE_ADDRESS    = 'X'
    EXCEPTIONS
      ERROR_ADDRESS_TYPE  = 1
      ERROR_ADDRESS       = 2
      ERROR_GROUP_ADDRESS = 3
      OTHERS              = 4.
  IF SY-SUBRC <> 0.
    RAISE INVALID.
  ENDIF.





ENDFUNCTION.
