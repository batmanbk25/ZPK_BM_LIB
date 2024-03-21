FUNCTION ZFM_BM_DF_FCHK_ADR_COUNTRY_INI .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_FIELD)
*"     REFERENCE(I_RECORD)
*"     REFERENCE(I_DF_FIELD) TYPE  ZST_BM_DF_FIELD
*"  EXPORTING
*"     REFERENCE(E_FIELD)
*"     REFERENCE(E_RETURN) TYPE  BAPIRET2
*"     REFERENCE(ET_FIELD_EC) TYPE  ZTT_BM_DF_FIELD_EC
*"----------------------------------------------------------------------

  DATA:
    LW_COUNTRY                  TYPE LAND1.

* Init address data if need
  PERFORM 9999_INIT_ADR.

* Check region exists in DB
  LW_COUNTRY = I_FIELD.
  IF LW_COUNTRY IS NOT INITIAL.
    READ TABLE GT_COUNTRY TRANSPORTING NO FIELDS
      WITH KEY LAND1 = LW_COUNTRY BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.

    ELSE.
*     Put error validate DB
      PERFORM DF_FIELD_SET_ERR_VALIDATE_DB
        USING I_FIELD
              I_DF_FIELD
        CHANGING E_RETURN
                 ET_FIELD_EC.
    ENDIF.
  ELSE.
* Check required, length
    PERFORM DF_FIELD_CHECK_REQ_LEN
      USING I_FIELD
              I_DF_FIELD
      CHANGING E_RETURN
               ET_FIELD_EC.
  ENDIF.

* Put value for next step checking
  CALL FUNCTION 'ZFM_BM_DF_FCHK_GRP_PUT'
    EXPORTING
      I_FIELD     = I_FIELD
      I_DF_FIELD  = I_DF_FIELD
      I_FIELDCODE = GC_FIELD_COUNTRY.

ENDFUNCTION.
