FUNCTION ZFM_BM_DF_FCHK_IND_DATE_CHK .
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
      LW_VALUE                  TYPE STRING,
      LW_FIELD                  TYPE STRING,
      LW_DATESTRING             TYPE STRING,
      LW_DATE                   TYPE DATS,
      LS_RETURN                 TYPE BAPIRET2,
      LS_DF_FIELD               TYPE ZST_BM_DF_FIELD.

  FIELD-SYMBOLS:
    <LF_FIELD>                TYPE ANY.

  E_FIELD = LW_FIELD = I_FIELD.
  LS_DF_FIELD = I_DF_FIELD.

  IF LW_FIELD IS NOT INITIAL.
    PERFORM DF_FIELD_CHECK_FORMAT_DATE
        USING LS_DF_FIELD
              GC_REGEX_D3
              GC_REGEX_REPLACE_D3
              GC_TFORMAT_D3
        CHANGING LW_FIELD
                 LS_RETURN
                 ET_FIELD_EC.

    IF LS_RETURN IS NOT INITIAL.
      E_RETURN = LS_RETURN.
    ELSE.
      REPLACE ALL OCCURRENCES OF '-'
        IN LW_FIELD  WITH ''.

      E_FIELD = LW_DATE = LW_FIELD.
      IF LW_DATE IS NOT INITIAL.
        IF LW_DATE > SY-DATUM.
          PERFORM DF_FIELD_SET_ERR_FORMAT
          USING LW_FIELD
                LS_DF_FIELD
                GC_TFORMAT_D3
          CHANGING E_RETURN
                   ET_FIELD_EC.
        ENDIF.
      ELSE.
        LS_RETURN-ID             = 'ZMS_COL_LIB'.
        LS_RETURN-TYPE           = GC_MTYPE_E.
        LS_RETURN-NUMBER         = '001'.
        PERFORM 9999_SPLIT_GET_SINGLE_FIELD
          USING LS_DF_FIELD-FNAME
          CHANGING LS_RETURN-FIELD.
        LS_RETURN-MESSAGE_V1     = LS_RETURN-FIELD.
        MESSAGE E001(ZMS_COL_LIB) WITH LS_RETURN-MESSAGE_V1
          INTO LS_RETURN-MESSAGE.

*       Get error code
        CALL FUNCTION 'ZFM_BM_DF_MAP_ERRCODE'
          EXPORTING
            I_DF_FIELD  = LS_DF_FIELD
            I_RETURN    = LS_RETURN
            I_EINIT     = GC_XMARK
          IMPORTING
            ET_FIELD_EC = ET_FIELD_EC.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFUNCTION.
