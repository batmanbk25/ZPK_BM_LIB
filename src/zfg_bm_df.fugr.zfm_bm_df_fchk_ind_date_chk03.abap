FUNCTION ZFM_BM_DF_FCHK_IND_DATE_CHK03 .
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
      LW_EDATE                  TYPE DATS,
      LW_SDATE                  TYPE DATS,
      LW_DATE                  TYPE CHAR10,
      LW_ODATE                  TYPE DATS,

      LS_RETURN                 TYPE BAPIRET2,
      LS_DF_FIELD               TYPE ZST_BM_DF_FIELD,

      V_DURMM_DD                TYPE PSEN_DURATION,
      V_DURMM_YY                TYPE PSEN_DURATION.

  FIELD-SYMBOLS:
      <LF_FIELD>                TYPE ANY.

  LW_FIELD = I_FIELD.
  LS_DF_FIELD = I_DF_FIELD.
* Set temp value to compare
  V_DURMM_DD-DURDD = 1.
  V_DURMM_YY-DURYY = 1.
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
* Check ngay bat dau la ngay dau tien cua quy
      LW_EDATE = LW_FIELD.

      IF LW_EDATE IS NOT INITIAL.
        CALL FUNCTION 'ZFM_BM_DF_FCHK_GRP_GET'
          EXPORTING
            I_DF_FIELD    = I_DF_FIELD
            I_FIELDCODE   = GC_FIELD_DATE_CHK02
          IMPORTING
            E_FCODE_VALUE = LW_DATE.

        REPLACE ALL OCCURRENCES OF '-'
            IN LW_DATE  WITH ''.
        LW_SDATE = LW_DATE.
        IF LW_SDATE IS NOT INITIAL.
*   ADD ONE YEAR TO START DATE
          CALL FUNCTION 'HR_99S_DATE_ADD_SUB_DURATION'
            EXPORTING
              IM_DATE     = LW_SDATE
              IM_OPERATOR = '+'
              IM_DURATION = V_DURMM_YY
            IMPORTING
              EX_DATE     = LW_ODATE.
*   Substract one date from today
          CALL FUNCTION 'HR_99S_DATE_ADD_SUB_DURATION'
            EXPORTING
              IM_DATE     = LW_ODATE
              IM_OPERATOR = '-'
              IM_DURATION = V_DURMM_DD
            IMPORTING
              EX_DATE     = LW_ODATE.

          IF LW_ODATE <> LW_EDATE.
            PERFORM DF_FIELD_SET_ERR_FORMAT
                USING LW_FIELD
                      LS_DF_FIELD
                      GC_TFORMAT_D3
                CHANGING LS_RETURN
                         ET_FIELD_EC.

            E_RETURN = LS_RETURN.
          ENDIF.
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

        E_RETURN = LS_RETURN.

*   Get error code
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
