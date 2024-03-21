FUNCTION ZFM_SUBMIT_DATA_TO_SELOPT2.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_LOW) OPTIONAL
*"     REFERENCE(I_HIGH) OPTIONAL
*"     REFERENCE(IR_SELOPT) TYPE  TABLE OPTIONAL
*"     REFERENCE(I_DATATYPE) TYPE  CHAR10 OPTIONAL
*"     REFERENCE(I_DOMAIN) LIKE  DD01L-DOMNAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(ER_SELOPT) TYPE  RSDSSELOPT_T
*"--------------------------------------------------------------------
DATA:
      LS_SELOPT LIKE LINE OF ER_SELOPT,
      LW_BEGDA  TYPE DATUM,
      LW_ENDDA  TYPE DATUM.
  DATA:
      LT_DD07VA  TYPE TABLE OF DD07V,
      LT_DD07VN  TYPE TABLE OF DD07V,
      LS_DD07VA  TYPE          DD07V.

  IF IR_SELOPT[] IS INITIAL.
    CHECK I_LOW <> '*'.
    CLEAR: LS_SELOPT.
    LS_SELOPT-SIGN    = 'I'.
    CASE I_DATATYPE.
      WHEN 'MONTH'.
        CHECK I_LOW IS NOT INITIAL.
        CONCATENATE I_LOW '01' INTO LW_BEGDA.
        CALL FUNCTION 'ZFM_GET_FIRST_END_DATE_PERIOD'
          EXPORTING
            I_DATE         = LW_BEGDA
            I_FOR_MONTH    = 'X'
          IMPORTING
            E_BEGDA        = LW_BEGDA
            E_ENDDA        = LW_ENDDA
          EXCEPTIONS
            NO_TYPE_TO_GET = 1
            OTHERS         = 2.
        IF SY-SUBRC = 0.
          LS_SELOPT-OPTION  = 'BT'.
          LS_SELOPT-LOW     = LW_BEGDA.
          LS_SELOPT-HIGH    = LW_ENDDA.
          CONDENSE: LS_SELOPT-LOW, LS_SELOPT-HIGH.
          APPEND LS_SELOPT TO ER_SELOPT.
        ENDIF.
      WHEN 'DATE'.
        CHECK I_LOW IS NOT INITIAL.
        LS_SELOPT-OPTION    = 'BT'.
        LS_SELOPT-HIGH      = I_LOW.
        CONCATENATE I_LOW(6) '01' INTO LS_SELOPT-LOW.
        CONDENSE: LS_SELOPT-LOW, LS_SELOPT-HIGH.
        APPEND LS_SELOPT TO ER_SELOPT.
      WHEN 'ALWNIT'. "Allow init
        LS_SELOPT-LOW       = I_LOW.
        IF LS_SELOPT-LOW CA '*' OR LS_SELOPT-LOW CA '%'.
          LS_SELOPT-OPTION  = 'CP'.
        ELSEIF I_HIGH IS INITIAL.
          LS_SELOPT-OPTION  = 'EQ'.
        ELSE.
          LS_SELOPT-OPTION  = 'BT'.
          LS_SELOPT-HIGH    = I_HIGH.
        ENDIF.
        REPLACE '%' IN LS_SELOPT-LOW WITH '*'.
        CONDENSE LS_SELOPT-LOW.
        APPEND LS_SELOPT TO ER_SELOPT.
*      WHEN 'FLDOMAIN'. " lay tat ca loai fix value domain.
*        IF LS_SELOPT-LOW IS INITIAL AND I_DOMAIN IS NOT INITIAL.
*          CALL FUNCTION 'DD_DOMA_GET'
*            EXPORTING
*                DOMAIN_NAME         = I_DOMAIN
*                GET_STATE           = 'M  '
*                LANGU               = SY-LANGU
*                PRID                = 0
*                WITHTEXT            = 'X'
*             TABLES
*               DD07V_TAB_A         = LT_DD07VA
*               DD07V_TAB_N         = LT_DD07VN
*            EXCEPTIONS
*              ILLEGAL_VALUE       = 1
*              OP_FAILURE          = 2
*              OTHERS              = 3.
*          IF SY-SUBRC = 0.
*            REFRESH ER_SELOPT.
*            LS_SELOPT-OPTION = 'EQ'.
*            LS_SELOPT-SIGN = 'I'.
*            LOOP AT LT_DD07VA INTO LS_DD07VA.
*              LS_SELOPT-LOW = LS_DD07VA-DOMVALUE_L.
*              APPEND LS_SELOPT TO ER_SELOPT.
*            ENDLOOP.
*          ENDIF.
*        ENDIF.
      WHEN 'TABLE'.

      WHEN OTHERS.
        CHECK I_LOW IS NOT INITIAL.
        IF I_LOW = 'N'.
          LS_SELOPT-LOW =  SPACE.
        ELSE.
          LS_SELOPT-LOW = I_LOW.
        ENDIF.

        IF LS_SELOPT-LOW CA '*' OR LS_SELOPT-LOW CA '%'.
          LS_SELOPT-OPTION  = 'CP'.
        ELSEIF I_HIGH IS INITIAL.
          LS_SELOPT-OPTION  = 'EQ'.
        ELSE.
          LS_SELOPT-OPTION  = 'BT'.
          LS_SELOPT-HIGH    = I_HIGH.
        ENDIF.
        REPLACE '%' IN LS_SELOPT-LOW WITH '*'.
        CONDENSE LS_SELOPT-LOW.
        APPEND LS_SELOPT TO ER_SELOPT.
    ENDCASE.
  ELSEIF IR_SELOPT[] IS NOT INITIAL.
    ER_SELOPT = IR_SELOPT[].
  ENDIF.





ENDFUNCTION.
