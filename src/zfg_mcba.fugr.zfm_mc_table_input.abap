FUNCTION ZFM_MC_TABLE_INPUT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_TABNAME) TYPE  TABNAME OPTIONAL
*"  CHANGING
*"     REFERENCE(C_TABLE) TYPE  TABLE
*"--------------------------------------------------------------------
DATA:
    LREF_DATA                 TYPE REF TO DATA.
  FIELD-SYMBOLS:
    <LF_RECORD_INP>           TYPE ANY,
    <LF_TABLE_INP>            TYPE TABLE.

  CREATE DATA LREF_DATA TYPE TABLE OF (I_TABNAME).
  ASSIGN LREF_DATA->* TO <GT_TABINP>.
  DO 1000 TIMES.
    APPEND INITIAL LINE TO <GT_TABINP>.
  ENDDO.
  GW_TABNMINP = I_TABNAME.
  CALL SCREEN 100.

*  LOOP AT <GT_TABINP> ASSIGNING <LF_RECORD_INP>.
**    MOVE-CORRESPONDING
*  ENDLOOP.

* EHP7 up
* MOVE-CORRESPONDING <GT_TABINP> TO C_TABLE.
* EPH6 down
  CALL FUNCTION 'ZFM_DATA_TABLE_MOVE_CORRESPOND'
    CHANGING
      C_SRC_TAB       = <GT_TABINP>
      C_DES_TAB       = C_TABLE.





ENDFUNCTION.
