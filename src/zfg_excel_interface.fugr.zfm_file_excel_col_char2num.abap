FUNCTION ZFM_FILE_EXCEL_COL_CHAR2NUM.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_COL_CHAR) TYPE  CHAR3
*"  EXPORTING
*"     REFERENCE(E_COL_NUM) TYPE  I
*"  EXCEPTIONS
*"      COLUMN_NAME_INVALID
*"      COLUMN_NAME_BLANK
*"--------------------------------------------------------------------
CONSTANTS:
    LC_ALPHABET     TYPE STRING VALUE ' ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
  DATA:
    LW_COL_CHAR     TYPE CHAR3,
    LW_STRLEN       TYPE I,
    LW_STRPOS       TYPE I,
    LW_CHAR         TYPE C,
*    LW_CHAR2        TYPE CHAR2,
    LW_NUM          TYPE I,
    LW_FIND_RESULT  TYPE MATCH_RESULT.
*  FIELD-SYMBOLS : <LF_ASCII> TYPE X.

* Init
  LW_COL_CHAR = I_COL_CHAR.
  CLEAR E_COL_NUM.

* Get upper case and condense
  TRANSLATE LW_COL_CHAR TO UPPER CASE.
  CONDENSE LW_COL_CHAR.

* Check column name is not initial
  IF LW_COL_CHAR IS INITIAL.
    RAISE COLUMN_NAME_BLANK.
  ENDIF.

* Check column name is only numeric
  IF LW_COL_CHAR CO '0123456789 '.
    E_COL_NUM = LW_COL_CHAR.
  ENDIF.

* Check column name is only characteric
  IF LW_COL_CHAR CN LC_ALPHABET.
    RAISE COLUMN_NAME_INVALID.
  ENDIF.

* Get length
  LW_STRLEN = STRLEN( LW_COL_CHAR ).

* Calculate column number
  DO LW_STRLEN TIMES.
*   Get each char from end
    LW_STRPOS = LW_STRLEN - SY-INDEX.
    LW_CHAR   = LW_COL_CHAR+LW_STRPOS(1).

**   Convert char to hex number
*    ASSIGN LW_CHAR TO <LF_ASCII> CASTING.
**   Write hex number to char
*    WRITE <LF_ASCII> TO LW_CHAR2.
**   Get decimal value
*    LW_NUM = LW_CHAR2(1) * 16 + LW_CHAR2+1(1) - 64.

    FIND FIRST OCCURRENCE OF LW_CHAR IN LC_ALPHABET
      RESULTS LW_FIND_RESULT.
    LW_NUM = LW_FIND_RESULT-OFFSET.

*   Calculate column number
    E_COL_NUM = E_COL_NUM + LW_NUM
                * EXP( LOG( 26 ) * ( LW_STRLEN - LW_STRPOS - 1 ) ).
  ENDDO.





ENDFUNCTION.
