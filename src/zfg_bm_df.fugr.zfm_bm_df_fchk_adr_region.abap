FUNCTION ZFM_BM_DF_FCHK_ADR_REGION .
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
    LW_COUNTRY                TYPE LAND1,
    LW_REGIO                  TYPE REGIO.

* Init address data if need
  PERFORM 9999_INIT_ADR.

  LW_REGIO = I_FIELD.

* Get region for checking
  CALL FUNCTION 'ZFM_BM_DF_FCHK_GRP_GET'
    EXPORTING
      I_DF_FIELD    = I_DF_FIELD
      I_FIELDCODE   = GC_FIELD_COUNTRY
    IMPORTING
      E_FCODE_VALUE = LW_COUNTRY.
  IF LW_COUNTRY = GC_COUNTRY_VN
  AND LW_REGIO IS INITIAL.
    PERFORM DF_FIELD_SET_ERR_INIT
      USING I_FIELD
            I_DF_FIELD
      CHANGING E_RETURN
               ET_FIELD_EC.
  ENDIF.

* Check region exists in DB
  IF LW_REGIO IS NOT INITIAL.
    READ TABLE GT_REGIONS TRANSPORTING NO FIELDS
      WITH KEY LAND1 = GC_COUNTRY_VN
               BLAND = LW_REGIO BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.
    ELSE.
*     Put error validate DB
      PERFORM DF_FIELD_SET_ERR_VALIDATE_DB
        USING I_FIELD
              I_DF_FIELD
        CHANGING E_RETURN
                 ET_FIELD_EC.
    ENDIF.
  ENDIF.

* Put value for next step checking
  CALL FUNCTION 'ZFM_BM_DF_FCHK_GRP_PUT'
    EXPORTING
      I_FIELD           = I_FIELD
      I_DF_FIELD        = I_DF_FIELD
      I_FIELDCODE       = GC_FIELD_REGION.

ENDFUNCTION.
