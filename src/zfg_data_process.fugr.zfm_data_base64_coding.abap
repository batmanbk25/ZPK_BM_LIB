FUNCTION ZFM_DATA_BASE64_CODING.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_ENCODE) TYPE  XMARK DEFAULT 'X'
*"     REFERENCE(I_INPUT) TYPE  STRING
*"  EXPORTING
*"     REFERENCE(E_OUTPUT) TYPE  STRING
*"----------------------------------------------------------------------
  DATA:
    LW_HEX_STRING             TYPE XSTRING.

  IF I_ENCODE IS INITIAL.
*   Decode Base64 to hex
    CALL METHOD CL_HTTP_UTILITY=>IF_HTTP_UTILITY~DECODE_X_BASE64
      EXPORTING
        ENCODED = I_INPUT
      RECEIVING
        DECODED = LW_HEX_STRING.

*   Decode hex to string
    CALL FUNCTION 'ECATT_CONV_XSTRING_TO_STRING'
      EXPORTING
        IM_XSTRING = LW_HEX_STRING
      IMPORTING
        EX_STRING  = E_OUTPUT.
  ELSE.
*   Encode hex to string
    CALL FUNCTION 'ECATT_CONV_STRING_TO_XSTRING'
      EXPORTING
        IM_STRING  = I_INPUT
      IMPORTING
        EX_XSTRING = LW_HEX_STRING.

*   Encode hex to Base64 string
    CALL METHOD CL_HTTP_UTILITY=>IF_HTTP_UTILITY~ENCODE_X_BASE64
      EXPORTING
        UNENCODED = LW_HEX_STRING
      RECEIVING
        ENCODED   = E_OUTPUT.
  ENDIF.

ENDFUNCTION.
