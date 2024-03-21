FUNCTION ZFM_VARIANT_GET.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_VAR_NAME) TYPE  RVARI_VNAM
*"  EXPORTING
*"     REFERENCE(E_VAR_VALUE)
*"  EXCEPTIONS
*"      NOT_FOUND
*"--------------------------------------------------------------------
DATA:
    LW_VAR_VALUE      TYPE TVARV_LOW.
* Clear export parameters
  CLEAR E_VAR_VALUE.

* Get value of var
  SELECT LOW          " Value
    FROM TVARVC
    INTO LW_VAR_VALUE
    UP TO 1 ROWS
  WHERE TYPE = 'P'
    AND NAME = I_VAR_NAME.  " Variant ID
  ENDSELECT.

* Raise exception in case of no value found
  IF SY-SUBRC IS NOT INITIAL.
    CLEAR: E_VAR_VALUE.
*    RAISE NOT_FOUND.
  ENDIF.

  E_VAR_VALUE = LW_VAR_VALUE.





ENDFUNCTION.
