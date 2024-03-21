FUNCTION ZFM_DATA_VALIDATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_FIELD) TYPE  ANY
*"     REFERENCE(I_DATATYPE) TYPE  DATATYPE_D
*"  CHANGING
*"     REFERENCE(C_OKCODE) TYPE  SYUCOMM OPTIONAL
*"  EXCEPTIONS
*"      INVALID_VALUE
*"--------------------------------------------------------------------
DATA:
    LW_ERROR      TYPE XMARK,
    LW_SCRNAME    TYPE SCRFNAME.
  FIELD-SYMBOLS:
    <LF_UDF>    TYPE ANY.

  PERFORM GET_DATA_TYPE
    USING I_DATATYPE.

* Check type
  PERFORM CHECK_DATA_TYPE
    USING    I_DATATYPE I_FIELD
    CHANGING LW_ERROR.

* Set cursor
  IF LW_ERROR = 'X'.
    DESCRIBE FIELD I_FIELD HELP-ID LW_SCRNAME.
    SET CURSOR FIELD LW_SCRNAME.
    RAISE INVALID_VALUE.
  ENDIF.





ENDFUNCTION.
