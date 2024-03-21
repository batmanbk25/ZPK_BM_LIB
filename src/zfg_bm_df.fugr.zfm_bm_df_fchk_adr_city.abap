FUNCTION ZFM_BM_DF_FCHK_ADR_CITY .
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
    LW_REGIO                  TYPE REGIO,
    LW_CITYCODE               TYPE CITY_CODE.

* Init address data if need
  PERFORM 9999_INIT_ADR.

  LW_CITYCODE = I_FIELD.

* Get region for checking
  CALL FUNCTION 'ZFM_BM_DF_FCHK_GRP_GET'
    EXPORTING
      I_DF_FIELD    = I_DF_FIELD
      I_FIELDCODE   = GC_FIELD_COUNTRY
    IMPORTING
      E_FCODE_VALUE = LW_COUNTRY.
  IF LW_COUNTRY = GC_COUNTRY_VN
  AND LW_CITYCODE IS INITIAL.
    PERFORM DF_FIELD_SET_ERR_INIT
      USING I_FIELD
            I_DF_FIELD
      CHANGING E_RETURN
               ET_FIELD_EC.
  ENDIF.

* Get region for checking
  CALL FUNCTION 'ZFM_BM_DF_FCHK_GRP_GET'
    EXPORTING
      I_DF_FIELD    = I_DF_FIELD
      I_FIELDCODE   = GC_FIELD_REGION
    IMPORTING
      E_FCODE_VALUE = LW_REGIO.

* Check region exists in DB
  IF LW_CITYCODE IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = LW_CITYCODE
      IMPORTING
        OUTPUT = LW_CITYCODE.

    READ TABLE GT_CITY TRANSPORTING NO FIELDS
      WITH KEY COUNTRY    = GC_COUNTRY_VN
               CITY_CODE  = LW_CITYCODE BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.
      READ TABLE GT_CITY TRANSPORTING NO FIELDS
        WITH KEY COUNTRY    = GC_COUNTRY_VN
                 REGION     = LW_REGIO
                 CITY_CODE  = LW_CITYCODE BINARY SEARCH.
      IF SY-SUBRC IS INITIAL.
        E_FIELD               = LW_CITYCODE.
      ELSE.
*       Put error validate DB
        PERFORM DF_FIELD_SET_ERR_VALIDATE_DB
          USING I_FIELD
                I_DF_FIELD
          CHANGING E_RETURN
                   ET_FIELD_EC.
      ENDIF.
    ELSE.
*     Put error validate DB
      PERFORM DF_CITY_SET_ERR_DB
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
      I_FIELDCODE       = GC_FIELD_CITY.

ENDFUNCTION.
