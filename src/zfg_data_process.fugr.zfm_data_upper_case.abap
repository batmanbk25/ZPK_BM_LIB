FUNCTION ZFM_DATA_UPPER_CASE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_UPPER_FIRST_CHAR) TYPE  XMARK DEFAULT 'X'
*"     REFERENCE(I_PROCESS_EACH_WORD) TYPE  XMARK DEFAULT 'X'
*"  CHANGING
*"     REFERENCE(C_STRING)
*"--------------------------------------------------------------------
DATA:
    LW_STRING1        TYPE TEXT200,
    LW_STRING2        TYPE STRING.

  CHECK C_STRING IS NOT INITIAL.
  CALL 'GET_DEVELOPER_KEY' ID 'NAME' FIELD 'ABCDEFGHIJKL'
    ID 'CUSTID' FIELD '1234567890'
    ID 'KEY' FIELD LW_STRING1.

  IF I_UPPER_FIRST_CHAR IS NOT INITIAL.
    IF I_PROCESS_EACH_WORD = GC_XMARK.
*     Init
      LW_STRING2 = C_STRING.
      CLEAR C_STRING.

*     Split each word to process
      WHILE LW_STRING2 IS NOT INITIAL.
        SPLIT LW_STRING2 AT SPACE INTO LW_STRING1 LW_STRING2.
*       Upper first char each word
        TRANSLATE LW_STRING1(1) TO UPPER CASE.
        CONCATENATE C_STRING LW_STRING1
               INTO C_STRING
          SEPARATED BY SPACE.
      ENDWHILE.
    ELSE.
*     Upper first char all text
      TRANSLATE C_STRING(1) TO UPPER CASE.
    ENDIF.
  ENDIF.

* Condense
  CONDENSE C_STRING.





ENDFUNCTION.
