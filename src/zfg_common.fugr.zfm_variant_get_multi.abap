FUNCTION ZFM_VARIANT_GET_MULTI.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(C_TVARVC) TYPE  TVARVC_T
*"  EXCEPTIONS
*"      NOT_FOUND
*"--------------------------------------------------------------------
* Check table variant name contain values
  IF C_TVARVC[] IS NOT INITIAL.

*   Get variant value
    SELECT *
      INTO TABLE C_TVARVC
      FROM TVARVC
      FOR ALL ENTRIES IN C_TVARVC
      WHERE TYPE = 'P'
        AND NAME = C_TVARVC-NAME.  " Variant ID

    IF SY-SUBRC IS NOT INITIAL.
      RAISE NOT_FOUND.
    ENDIF.

  ENDIF.





ENDFUNCTION.
