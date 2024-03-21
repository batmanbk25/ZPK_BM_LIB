FUNCTION ZFM_DATA_TABLE_MOVE_CORRESPOND.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(C_SRC_TAB) TYPE  TABLE
*"     REFERENCE(C_DES_TAB) TYPE  TABLE
*"--------------------------------------------------------------------
FIELD-SYMBOLS:
    <LF_SRC_STR>        TYPE ANY,
    <LF_DES_STR>        TYPE ANY.
  DATA:
    LR_DATA             TYPE REF TO DATA.

  CLEAR: C_DES_TAB[].

  CREATE DATA LR_DATA LIKE LINE OF C_DES_TAB.
  ASSIGN LR_DATA->* TO <LF_DES_STR>.

  LOOP AT C_SRC_TAB ASSIGNING <LF_SRC_STR>.
    MOVE-CORRESPONDING <LF_SRC_STR> TO <LF_DES_STR>.
    APPEND <LF_DES_STR> TO C_DES_TAB.
  ENDLOOP.





ENDFUNCTION.
