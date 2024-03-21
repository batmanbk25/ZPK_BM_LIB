FUNCTION ZFM_BM_BINARY_TO_BINARY.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_SOURCE_BIN) TYPE  TABLE
*"  EXPORTING
*"     REFERENCE(ET_DESTINATION_BIN) TYPE  TABLE
*"     REFERENCE(E_LENGTH) TYPE  I
*"----------------------------------------------------------------------
  DATA:
    LW_XSTRING                TYPE XSTRING.
  FIELD-SYMBOLS:
    <LF_LINE>                 TYPE ANY.

* Calculate length
  IF IT_SOURCE_BIN IS NOT INITIAL.
    READ TABLE IT_SOURCE_BIN INDEX 1 ASSIGNING <LF_LINE>.
    IF SY-SUBRC IS INITIAL.
      DESCRIBE FIELD <LF_LINE> LENGTH E_LENGTH IN BYTE MODE.
      E_LENGTH = E_LENGTH * LINES( IT_SOURCE_BIN ).
    ENDIF.
  ENDIF.

* Convert source bin tab to xstring
  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      INPUT_LENGTH = E_LENGTH
    IMPORTING
      BUFFER       = LW_XSTRING
    TABLES
      BINARY_TAB   = IT_SOURCE_BIN.

* Convert xstring to destination bin tab
  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      BUFFER        = LW_XSTRING
    IMPORTING
      OUTPUT_LENGTH = E_LENGTH
    TABLES
      BINARY_TAB    = ET_DESTINATION_BIN.

ENDFUNCTION.
