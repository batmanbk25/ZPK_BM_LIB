FUNCTION ZFM_FILE_EXCEL_COL_NUM2CHAR.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_COL_NUM) TYPE  I
*"  EXPORTING
*"     REFERENCE(E_COL_CHAR) TYPE  CHAR3
*"  EXCEPTIONS
*"      COLUMN_NAME_INVALID
*"      COLUMN_NAME_BLANK
*"--------------------------------------------------------------------
CONSTANTS:
    LC_ALPHABET     TYPE STRING VALUE ' ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
  DATA:
    LW_CHAR         TYPE C,
    LW_COLNUM       TYPE I,
    LW_NUM          TYPE I.
  FIELD-SYMBOLS : <LF_ASCII> TYPE X.

* Init
  LW_COLNUM = I_COL_NUM.
  CLEAR E_COL_CHAR.

* Check column number is not initial
  CHECK LW_COLNUM IS NOT INITIAL.

* Translate column number to text
  WHILE LW_COLNUM IS NOT INITIAL.
    LW_NUM = LW_COLNUM MOD 26.
    LW_COLNUM = LW_COLNUM DIV 26.
    LW_CHAR = LC_ALPHABET+LW_NUM(1).
    CONCATENATE LW_CHAR E_COL_CHAR INTO E_COL_CHAR.
  ENDWHILE.





ENDFUNCTION.
