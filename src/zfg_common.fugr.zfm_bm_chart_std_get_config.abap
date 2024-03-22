FUNCTION ZFM_BM_CHART_STD_GET_CONFIG.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_CPROG) TYPE  CPROG DEFAULT SY-CPROG
*"  CHANGING
*"     REFERENCE(C_CHART_CONF) TYPE  ZST_BM_CHART_CONF
*"--------------------------------------------------------------------
DATA:
    LS_BM_CHA_LAYO      TYPE ZTB_BM_CHA_LAYO,
    LS_BM_CHA_SERI      TYPE ZTB_BM_CHA_SERI,
    LT_BM_CHA_SERI      TYPE TABLE OF ZTB_BM_CHA_SERI,
    LS_BM_CHA_CUST      TYPE ZTB_BM_CHA_CUST.

* Get config from DB
  IF C_CHART_CONF-TABNAME IS INITIAL.
    SELECT SINGLE *
      FROM ZTB_BM_CHA_LAYO
      INTO LS_BM_CHA_LAYO
     WHERE REPORT   = I_CPROG.

    SELECT *
      FROM ZTB_BM_CHA_SERI
      INTO TABLE LT_BM_CHA_SERI
     WHERE REPORT   = I_CPROG.

    SELECT SINGLE *
      FROM ZTB_BM_CHA_CUST
      INTO LS_BM_CHA_CUST
     WHERE REPORT   = I_CPROG
       AND UNAME    = SPACE.
  ELSE.
    SELECT SINGLE *
      FROM ZTB_BM_CHA_LAYO
      INTO LS_BM_CHA_LAYO
     WHERE REPORT   = I_CPROG
       AND TABNAME  = C_CHART_CONF-TABNAME.

    SELECT *
      FROM ZTB_BM_CHA_SERI
      INTO TABLE LT_BM_CHA_SERI
     WHERE REPORT   = I_CPROG
       AND TABNAME = C_CHART_CONF-TABNAME.

    SELECT SINGLE *
      FROM ZTB_BM_CHA_CUST
      INTO LS_BM_CHA_CUST
     WHERE REPORT   = I_CPROG
       AND TABNAME  = C_CHART_CONF-TABNAME
       AND UNAME    = SPACE.
  ENDIF.

* Convert DB to nest structure
  C_CHART_CONF-REPID = LS_BM_CHA_LAYO-REPORT.
  MOVE-CORRESPONDING LS_BM_CHA_LAYO TO C_CHART_CONF.
  MOVE-CORRESPONDING LS_BM_CHA_LAYO TO C_CHART_CONF-GLOBAL.
  MOVE-CORRESPONDING LS_BM_CHA_LAYO TO C_CHART_CONF-CAT_LAYO.
  CALL FUNCTION 'ZFM_DATA_TABLE_MOVE_CORRESPOND'
    CHANGING
      C_SRC_TAB = LT_BM_CHA_SERI
      C_DES_TAB = C_CHART_CONF-SERI_LAYO.

* Conversation output
  PERFORM CHART_STD_LAYOUT_CONV_OUT
   CHANGING C_CHART_CONF.

* Set customize object key, DocID
  IF LS_BM_CHA_CUST IS INITIAL.
    CONCATENATE GS_BM_CHART_CONF-REPID
                GS_BM_CHART_CONF-TABNAME
           INTO GS_BM_CHART_CONF-CUST_OBJKEY SEPARATED BY '_'.
  ELSE.
    GS_BM_CHART_CONF-CUST_OBJKEY = LS_BM_CHA_CUST-OBJKEY.
    GS_BM_CHART_CONF-CUST_DOC_ID = LS_BM_CHA_CUST-DOC_ID.
  ENDIF.





ENDFUNCTION.