FUNCTION ZFM_BM_DF_FCHK_ADR_STREET .
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
    LW_REGION                 TYPE REGIO,
    LW_CITYCODE               TYPE CITY_CODE,
    LW_CITYPCODE              TYPE CITYP_CODE,
    LS_COUN_DAT               TYPE ZST_BM_DF_CHKGRP_DAT,
    LS_REG_DAT                TYPE ZST_BM_DF_CHKGRP_DAT,
    LS_CITY_DAT               TYPE ZST_BM_DF_CHKGRP_DAT,
    LS_DIST_DAT               TYPE ZST_BM_DF_CHKGRP_DAT,
    LT_FIELDNAME              TYPE FIELDNAME_TAB,
    LW_FIELDS                 TYPE STRING,
    LS_RETURN                 TYPE BAPIRET2.

* Get city for checking
  CALL FUNCTION 'ZFM_BM_DF_FCHK_GRP_GET':
    EXPORTING
      I_DF_FIELD    = I_DF_FIELD
      I_FIELDCODE   = GC_FIELD_COUNTRY
    IMPORTING
      E_FCODE_VALUE = LW_COUNTRY
      E_CHKGRP_DAT  = LS_COUN_DAT,
    EXPORTING
      I_DF_FIELD    = I_DF_FIELD
      I_FIELDCODE   = GC_FIELD_REGION
    IMPORTING
      E_FCODE_VALUE = LW_REGION
      E_CHKGRP_DAT  = LS_REG_DAT,
    EXPORTING
      I_DF_FIELD    = I_DF_FIELD
      I_FIELDCODE   = GC_FIELD_CITY
    IMPORTING
      E_FCODE_VALUE = LW_CITYCODE
      E_CHKGRP_DAT  = LS_CITY_DAT,
    EXPORTING
      I_DF_FIELD    = I_DF_FIELD
      I_FIELDCODE   = GC_FIELD_DISTRICT
    IMPORTING
      E_FCODE_VALUE = LW_CITYPCODE
      E_CHKGRP_DAT  = LS_DIST_DAT.
* Neu quoc gia <> 'VN' thi chi kiem tra truong so nha <> null
  IF LW_COUNTRY = 'VN'
    OR LW_COUNTRY IS INITIAL.
    IF I_FIELD IS INITIAL
     AND LW_REGION IS INITIAL
     AND LW_CITYCODE IS INITIAL
     AND LW_CITYPCODE IS INITIAL
      OR I_FIELD IS NOT INITIAL
     AND LW_REGION IS NOT INITIAL
     AND LW_CITYCODE IS NOT INITIAL
     AND LW_CITYPCODE IS NOT INITIAL.
*   OK: All empty or All not empty

    ELSE.
*   Put error validate DB
      PERFORM DF_FIELD_SET_ERR_GROUP_SAME
        USING I_FIELD
              I_DF_FIELD
        CHANGING E_RETURN.

      LS_RETURN = E_RETURN.

      IF LW_REGION IS INITIAL.
        APPEND LS_REG_DAT-FNAME TO LT_FIELDNAME.
      ENDIF.

      IF LW_CITYCODE IS INITIAL.
        APPEND LS_CITY_DAT-FNAME TO LT_FIELDNAME.
      ENDIF.

      IF LW_CITYPCODE IS INITIAL.
        APPEND LS_DIST_DAT-FNAME TO LT_FIELDNAME.
      ENDIF.

      IF I_FIELD IS INITIAL.
        PERFORM 9999_SPLIT_GET_SINGLE_FIELD
          USING I_DF_FIELD-FNAME
          CHANGING LS_DIST_DAT-FNAME.
        APPEND LS_DIST_DAT-FNAME TO LT_FIELDNAME.
      ENDIF.

      CONCATENATE LINES OF LT_FIELDNAME INTO LW_FIELDS SEPARATED BY ', '.

      LS_RETURN-MESSAGE_V1 = TEXT-001.

      LS_RETURN-MESSAGE_V2 = LW_FIELDS.

      CALL FUNCTION 'ZFM_BM_DF_MAP_ERRCODE'
        EXPORTING
          I_DF_FIELD  = I_DF_FIELD
          I_RETURN    = LS_RETURN
          I_EINIT     = GC_XMARK
        IMPORTING
          ET_FIELD_EC = ET_FIELD_EC.
    ENDIF.
  ELSE.
    IF I_FIELD IS INITIAL.
      LS_RETURN-MESSAGE_V1 = TEXT-001.

      LS_RETURN-MESSAGE_V2 = I_DF_FIELD-FNAME.

      CALL FUNCTION 'ZFM_BM_DF_MAP_ERRCODE'
        EXPORTING
          I_DF_FIELD  = I_DF_FIELD
          I_RETURN    = LS_RETURN
          I_EINIT     = GC_XMARK
        IMPORTING
          ET_FIELD_EC = ET_FIELD_EC.
    ENDIF.
  ENDIF.


ENDFUNCTION.
