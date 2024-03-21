FUNCTION ZFM_SUBMIT_DATA_TO_SELOPT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_LOW) OPTIONAL
*"     REFERENCE(I_HIGH) OPTIONAL
*"     REFERENCE(IR_SELOPT) TYPE  TABLE OPTIONAL
*"     REFERENCE(I_DATATYPE) TYPE  CHAR10 OPTIONAL
*"  EXPORTING
*"     REFERENCE(ER_SELOPT) TYPE  RSDSSELOPT_T
*"--------------------------------------------------------------------
DATA:
      LS_SELOPT LIKE LINE OF ER_SELOPT,
      LW_BEGDA  TYPE DATUM,
      LW_ENDDA  TYPE DATUM,
      LW_LOW    TYPE CHAR256.

  IF IR_SELOPT[] IS INITIAL.
    LW_LOW = I_LOW.
    CONDENSE LW_LOW.
    CHECK LW_LOW <> '*'.
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
      WHEN OTHERS.
        CHECK I_LOW IS NOT INITIAL.
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
    ENDCASE.
  ELSEIF IR_SELOPT[] IS NOT INITIAL.
    ER_SELOPT = IR_SELOPT[].
  ENDIF.





ENDFUNCTION.
