*&---------------------------------------------------------------------*
*&  Include           ZIN_BM_IMONEYF01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  0000_INIT_PROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0000_INIT_PROC .

  SELECT *
    FROM ZTB_BM_IM_MARA
    INTO TABLE GT_MARA.

  SELECT *
    FROM ZTB_BM_IM_CAT
    INTO TABLE GT_CAT.

  CALL FUNCTION 'ZFM_SCR_INIT'
*   EXPORTING
*     I_CPROG             = SY-CPROG
*     I_DYNNR             = SY-DYNNR
            .


ENDFORM.                    " 0000_INIT_PROC

*&---------------------------------------------------------------------*
*&      Form  0000_MAIN_PROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0000_MAIN_PROC .
  CALL SCREEN 100.
ENDFORM.                    " 0000_MAIN_PROC

*&---------------------------------------------------------------------*
*&      Form  0100_PROCESS_FC_MAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0100_PROCESS_FC_MAT .

  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      ACTION                       = 'U'
      VIEW_NAME                    = 'ZTB_BM_IM_MARA'
    EXCEPTIONS
      CLIENT_REFERENCE             = 1
      FOREIGN_LOCK                 = 2
      INVALID_ACTION               = 3
      NO_CLIENTINDEPENDENT_AUTH    = 4
      NO_DATABASE_FUNCTION         = 5
      NO_EDITOR_FUNCTION           = 6
      NO_SHOW_AUTH                 = 7
      NO_TVDIR_ENTRY               = 8
      NO_UPD_AUTH                  = 9
      ONLY_SHOW_ALLOWED            = 10
      SYSTEM_FAILURE               = 11
      UNKNOWN_FIELD_IN_DBA_SELLIST = 12
      VIEW_NOT_FOUND               = 13
      MAINTENANCE_PROHIBITED       = 14
      OTHERS                       = 15.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.                    " 0100_PROCESS_FC_MAT

*&---------------------------------------------------------------------*
*&      Form  0100_PROCESS_FC_CAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0100_PROCESS_FC_CAT .

  CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
    EXPORTING
      ACTION                       = 'U'
      VIEW_NAME                    = 'ZTB_BM_IM_CAT'
    EXCEPTIONS
      CLIENT_REFERENCE             = 1
      FOREIGN_LOCK                 = 2
      INVALID_ACTION               = 3
      NO_CLIENTINDEPENDENT_AUTH    = 4
      NO_DATABASE_FUNCTION         = 5
      NO_EDITOR_FUNCTION           = 6
      NO_SHOW_AUTH                 = 7
      NO_TVDIR_ENTRY               = 8
      NO_UPD_AUTH                  = 9
      ONLY_SHOW_ALLOWED            = 10
      SYSTEM_FAILURE               = 11
      UNKNOWN_FIELD_IN_DBA_SELLIST = 12
      VIEW_NOT_FOUND               = 13
      MAINTENANCE_PROHIBITED       = 14
      OTHERS                       = 15.

ENDFORM.                    " 0100_PROCESS_FC_CAT

*&---------------------------------------------------------------------*
*&      Form  0100_PROCESS_FC_TRAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0100_PROCESS_FC_TRAN .
  CALL FUNCTION 'ZFM_SCR_INIT'
    EXPORTING
      I_DYNNR = '0200'.

  CLEAR: ZTB_BM_IM_TRANH, GT_TRAN_DET.
  CALL SCREEN 200.
ENDFORM.                    " 0100_PROCESS_FC_TRAN

*&---------------------------------------------------------------------*
*&      Form  0200_PROCESS_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0200_PROCESS_SAVE.
  DATA:
    LW_LINEID         TYPE ZTB_BM_IM_TRAND-LINEID.
  FIELD-SYMBOLS
    <LF_TRAN_DET>     TYPE ZTB_BM_IM_TRAND.

  PERFORM 0200_CHECK_DATA.

  PERFORM 9999_ADDNEW_MARA.

  TRY.
      CALL METHOD
        CL_SYSTEM_UUID=>IF_SYSTEM_UUID_STATIC~CREATE_UUID_C32
        RECEIVING
          UUID = ZTB_BM_IM_TRANH-TRANID.
    CATCH CX_UUID_ERROR .
  ENDTRY.

  LOOP AT GT_TRAN_DET ASSIGNING <LF_TRAN_DET>.
    LW_LINEID             = LW_LINEID + 10.
    <LF_TRAN_DET>-TRANID  = ZTB_BM_IM_TRANH-TRANID.
    <LF_TRAN_DET>-LINEID  = LW_LINEID.
    <LF_TRAN_DET>-DATUM   = ZTB_BM_IM_TRANH-DATUM.
    <LF_TRAN_DET>-UZEIT   = ZTB_BM_IM_TRANH-UZEIT.

  ENDLOOP.

  INSERT ZTB_BM_IM_TRANH FROM ZTB_BM_IM_TRANH.
  IF SY-SUBRC IS NOT INITIAL.
    MESSAGE S011(ZMS_COL_LIB) WITH 'ZTB_BM_IM_TRANH'
      DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  INSERT ZTB_BM_IM_TRAND FROM TABLE GT_TRAN_DET.
  IF SY-SUBRC IS NOT INITIAL.
    MESSAGE S011(ZMS_COL_LIB) WITH 'ZTB_BM_IM_TRAND'
      DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  MESSAGE S009(ZMS_COL_LIB).

  CLEAR: ZTB_BM_IM_TRANH, GT_TRAN_DET.
  LEAVE TO SCREEN 0.
ENDFORM.                    " 0200_PROCESS_SAVE

*&---------------------------------------------------------------------*
*&      Form  0200_CHECK_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0200_CHECK_DATA .
  DATA:
    LS_TRAN_DET       TYPE ZTB_BM_IM_TRAND,
    LS_MARA           TYPE ZTB_BM_IM_MARA.
  FIELD-SYMBOLS:
    <LF_TRAN_DET>     TYPE ZTB_BM_IM_TRAND.

  CLEAR: ZTB_BM_IM_TRANH-DMBTR, GT_MARA_ADDNEW.
  IF ZTB_BM_IM_TRANH-WAERS IS INITIAL.
    ZTB_BM_IM_TRANH-WAERS = GC_CURR_VND.
  ENDIF.

  LOOP AT GT_TRAN_DET ASSIGNING <LF_TRAN_DET>.
*    PERFORM 9999_CALCULATE_AMOUNT
*      CHANGING <LF_TRAN_DET>.

    ZTB_BM_IM_TRANH-DMBTR = ZTB_BM_IM_TRANH-DMBTR
                          + <LF_TRAN_DET>-DMBTR.
    IF <LF_TRAN_DET>-MATNR IS INITIAL.
      LS_MARA-MATNR       = <LF_TRAN_DET>-MATNR.
      LS_MARA-MATNM       = <LF_TRAN_DET>-MATNM.
      LS_MARA-STPRS       = <LF_TRAN_DET>-STPRS.
      LS_MARA-CATID       = <LF_TRAN_DET>-CATID.
      APPEND LS_MARA TO GT_MARA_ADDNEW.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'ZFM_SCR_PAI'.

ENDFORM.                    " 0200_CHECK_DATA

*&---------------------------------------------------------------------*
*&      Form  9999_FILL_MARA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LPS_BM_IM_TRAND  text
*----------------------------------------------------------------------*
FORM 9999_FILL_MARA
  CHANGING LPS_BM_IM_TRAND    TYPE ZTB_BM_IM_TRAND.
  DATA:
    LS_MARA           TYPE ZTB_BM_IM_MARA,
    LT_MARA           TYPE TABLE OF ZTB_BM_IM_MARA,
    LW_MAT_SQL        TYPE TEXT20.

  CHECK LPS_BM_IM_TRAND-MATNM IS NOT INITIAL.

  IF LPS_BM_IM_TRAND-MATNR IS INITIAL
  AND LPS_BM_IM_TRAND-MATNM IS NOT INITIAL.
    PERFORM 9999_FIND_MARA_BY_NAME
      CHANGING LPS_BM_IM_TRAND-MATNR
               LPS_BM_IM_TRAND-MATNM.
  ENDIF.

  IF LPS_BM_IM_TRAND-MATNR IS NOT INITIAL.
    SELECT SINGLE *
      FROM ZTB_BM_IM_MARA
      INTO LS_MARA
     WHERE MATNR = LPS_BM_IM_TRAND-MATNR.
    IF SY-SUBRC IS INITIAL.
      LPS_BM_IM_TRAND-MATNM   = LS_MARA-MATNM.
      LPS_BM_IM_TRAND-CATID   = LS_MARA-CATID.
      IF LPS_BM_IM_TRAND-STPRS IS INITIAL.
        LPS_BM_IM_TRAND-STPRS   = LS_MARA-STPRS.
      ENDIF.
      IF LPS_BM_IM_TRAND-QUAN IS INITIAL.
        LPS_BM_IM_TRAND-QUAN  = 1.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " 9999_FILL_MARA

*&---------------------------------------------------------------------*
*&      Form  9999_FIND_MARA_BY_NAME
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LPW_MATNR  text
*      <--LPW_MATNM  text
*----------------------------------------------------------------------*
FORM 9999_FIND_MARA_BY_NAME
  CHANGING LPW_MATNR  TYPE ZTB_BM_IM_MARA-MATNR
           LPW_MATNM  TYPE ZTB_BM_IM_MARA-MATNM.
  DATA:
    LS_MARA           TYPE ZTB_BM_IM_MARA,
    LT_MARA           TYPE TABLE OF ZTB_BM_IM_MARA,
    LW_MAT_SQL        TYPE TEXT20.

  LW_MAT_SQL = LPW_MATNM.
  TRANSLATE LW_MAT_SQL TO UPPER CASE.

  SELECT SINGLE *
    FROM ZTB_BM_IM_MARA
    INTO LS_MARA
   WHERE MATNR = LW_MAT_SQL
      OR MATNM = LW_MAT_SQL.
  IF SY-SUBRC IS INITIAL.
    LPW_MATNR = LS_MARA-MATNR.
    LPW_MATNM = LS_MARA-MATNM.
    RETURN.
  ENDIF.

  LW_MAT_SQL = '%' && LPW_MATNM && '%'.

  SELECT *
    FROM ZTB_BM_IM_MARA
    INTO TABLE LT_MARA
   WHERE MATNR LIKE LW_MAT_SQL.
  IF SY-SUBRC IS INITIAL.
    IF LINES( LT_MARA ) = 1.
      READ TABLE LT_MARA INDEX 1 INTO LS_MARA.
      LPW_MATNR = LS_MARA-MATNR.
      LPW_MATNM = LS_MARA-MATNM.
      RETURN.
    ENDIF.
  ELSE.
    SELECT *
      FROM ZTB_BM_IM_MARA
      INTO TABLE LT_MARA
     WHERE MATNM LIKE LW_MAT_SQL.
    IF SY-SUBRC IS INITIAL.
      IF LINES( LT_MARA ) = 1.
        READ TABLE LT_MARA INDEX 1 INTO LS_MARA.
        LPW_MATNR = LS_MARA-MATNR.
        LPW_MATNM = LS_MARA-MATNM.
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " 9999_FIND_MARA_BY_NAME

*&---------------------------------------------------------------------*
*&      Form  9999_CALCULATE_AMOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_<LF_TRAN_DET>  text
*----------------------------------------------------------------------*
FORM 9999_CALCULATE_AMOUNT
  CHANGING LPS_TRAN_DET     TYPE ZTB_BM_IM_TRAND.
  DATA:
    LS_TRAN_DET       TYPE ZTB_BM_IM_TRAND.
  FIELD-SYMBOLS:
    <LF_TRAN_DET>     TYPE ZTB_BM_IM_TRAND.

  IF LPS_TRAN_DET-STPRS IS INITIAL.
    IF LPS_TRAN_DET-QUAN IS INITIAL.
      IF LPS_TRAN_DET-DMBTR IS NOT INITIAL.
        LPS_TRAN_DET-STPRS    = <LF_TRAN_DET>-DMBTR.
        LPS_TRAN_DET-QUAN     = 1.
      ENDIF.
    ELSE.
      IF LPS_TRAN_DET-DMBTR IS NOT INITIAL.
        LPS_TRAN_DET-STPRS    = LPS_TRAN_DET-DMBTR
                              / LPS_TRAN_DET-QUAN.
      ENDIF.
    ENDIF.
  ELSE.
    LPS_TRAN_DET-DMBTR        = LPS_TRAN_DET-QUAN
                              * LPS_TRAN_DET-STPRS.
  ENDIF.

ENDFORM.                    " 9999_CALCULATE_AMOUNT

*&---------------------------------------------------------------------*
*&      Form  9999_ADDNEW_MARA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 9999_ADDNEW_MARA .
  DATA:
    LW_ANSWER         TYPE C,
    LS_MARA           TYPE ZTB_BM_IM_MARA,
    LT_MARA           TYPE TABLE OF ZTB_BM_IM_MARA,
    LW_MAXNO          TYPE CHAR10,
    BEGIN OF LS_CAT_NO,
      CATID           TYPE ZTB_BM_IM_CAT-CATID,
      MATNR_BE        TYPE NUMC2,
      MATNO           TYPE INT4,
    END OF LS_CAT_NO,
    LT_CAT_NO         LIKE TABLE OF LS_CAT_NO.
  FIELD-SYMBOLS:
    <LF_MARA>         TYPE ZTB_BM_IM_MARA,
    <LF_CAT_NO>       LIKE LS_CAT_NO.

  IF GT_MARA_ADDNEW IS NOT INITIAL.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR              = TEXT-T01
        TEXT_QUESTION         = TEXT-Q01
        DISPLAY_CANCEL_BUTTON = ' '
      IMPORTING
        ANSWER                = LW_ANSWER
      EXCEPTIONS
        TEXT_NOT_FOUND        = 1
        OTHERS                = 2.
    IF SY-SUBRC <> 0 OR LW_ANSWER <> 1.
      RETURN.
    ENDIF.
  ENDIF.

  LOOP AT GT_MARA_ADDNEW ASSIGNING <LF_MARA>.
    LS_CAT_NO-CATID   = <LF_MARA>-CATID.
    LS_CAT_NO-MATNO   = 1.
    COLLECT LS_CAT_NO INTO LT_CAT_NO.
  ENDLOOP.
  SORT LT_CAT_NO BY CATID.
  DELETE ADJACENT DUPLICATES FROM LT_CAT_NO COMPARING CATID.

  SELECT *
    FROM ZTB_BM_IM_MARA
    INTO TABLE LT_MARA
     FOR ALL ENTRIES IN LT_CAT_NO
   WHERE CATID = LT_CAT_NO-CATID.

  SORT LT_MARA BY CATID MATNR DESCENDING.
  LOOP AT LT_MARA INTO LS_MARA.
    IF LS_MARA-MATNR(4) = LS_MARA-CATID.
      LW_MAXNO = LS_MARA-MATNR+4.
      IF LW_MAXNO CO '1234567890 ' AND LW_MAXNO+2 CO ' '.
        READ TABLE LT_CAT_NO ASSIGNING <LF_CAT_NO>
          WITH KEY CATID = LS_MARA-CATID.
        IF SY-SUBRC IS INITIAL AND <LF_CAT_NO>-MATNR_BE < LW_MAXNO.
          <LF_CAT_NO>-MATNR_BE = LW_MAXNO.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT GT_MARA_ADDNEW ASSIGNING <LF_MARA>.
    READ TABLE LT_CAT_NO ASSIGNING <LF_CAT_NO>
      WITH KEY CATID = <LF_MARA>-CATID.
    IF SY-SUBRC IS INITIAL.
      <LF_CAT_NO>-MATNR_BE  = <LF_CAT_NO>-MATNR_BE + 1.
      <LF_MARA>-MATNR       = <LF_CAT_NO>-CATID && <LF_CAT_NO>-MATNR_BE.
      <LF_MARA>-CATID       = <LF_CAT_NO>-CATID.
    ENDIF.
    <LF_MARA>-WAERS     = 'VND'.
  ENDLOOP.

  CHECK GT_MARA_ADDNEW IS NOT INITIAL.

  CALL SCREEN 0300 STARTING AT 5 5.

ENDFORM.                    " 9999_ADDNEW_MARA

*&---------------------------------------------------------------------*
*&      Form  0300_PROCESS_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0300_PROCESS_SAVE.
  DATA:
    LW_ERROR            TYPE XMARK.
  FIELD-SYMBOLS:
    <LF_MARA>           TYPE ZTB_BM_IM_MARA,
    <LF_TRAN_DET>       TYPE ZTB_BM_IM_TRAND.

  CALL METHOD GO_ALV_MARA->CHECK_CHANGED_DATA.

  LOOP AT GT_MARA_ADDNEW ASSIGNING <LF_MARA>.
    IF <LF_MARA>-MATNR IS INITIAL.
      MESSAGE S001(ZMS_COL_LIB) DISPLAY LIKE 'E' WITH 'MATNR' SY-TABIX.
      LEAVE TO SCREEN SY-DYNNR.
    ENDIF.
  ENDLOOP.

  INSERT ZTB_BM_IM_MARA FROM TABLE GT_MARA_ADDNEW.
  MESSAGE I009(ZMS_COL_LIB).

  LOOP AT GT_TRAN_DET ASSIGNING <LF_TRAN_DET>.
    PERFORM 9999_FILL_MARA CHANGING <LF_TRAN_DET>.
  ENDLOOP.

  LEAVE TO SCREEN 0.

ENDFORM.                    " 0300_PROCESS_SAVE

*&---------------------------------------------------------------------*
*&      Form  0300_PBO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0300_PBO .
  DATA:
    LS_VARIANT        TYPE DISVARIANT,
    LS_LAYOUT         TYPE LVC_S_LAYO.

  LS_LAYOUT-EDIT        = 'X'.
  LS_LAYOUT-CWIDTH_OPT  = 'X'.
  LS_VARIANT-REPORT     = SY-REPID.
  LS_VARIANT-HANDLE     = '0300'.

  IF GO_ALV_MARA IS INITIAL.
    CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR'
      EXPORTING
        I_DYNNR            = '0300'
        I_CUS_CONTROL_NAME = 'CUS_ALV_MARA'
        I_STRUCTURE_NAME   = 'ZTB_BM_IM_MARA'
        IS_VARIANT         = LS_VARIANT
        IS_LAYOUT          = LS_LAYOUT
        I_SHOW_TOTAL_INFO  = ' '
      IMPORTING
        E_ALV_GRID         = GO_ALV_MARA
      CHANGING
        IT_OUTTAB          = GT_MARA_ADDNEW.
  ELSE.
    CALL METHOD GO_ALV_MARA->REFRESH_TABLE_DISPLAY.
  ENDIF.
ENDFORM.                    " 0300_PBO

*&---------------------------------------------------------------------*
*&      Form  0100_PROCESS_FC_GRAPH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0100_PROCESS_FC_GRAPH .
* Get graph data
  PERFORM 9999_GET_GRAPH_TRANS.

  IF 1 = 2.
*   Show graph
    PERFORM DISPLAY_GRAPH.
  ELSE.
*   Create chart object
    CREATE OBJECT GO_BM_CHART
      EXPORTING
*        I_CHA_PROG     = SY-REPID
*        I_REPID        = SY-REPID
        I_DYNNR        = '0400'
*        I_CUS_CON_NAME = 'CUS_GRAPH'
        IT_TABDATA     = GT_PERAM.
    CALL SCREEN 0400.
  ENDIF.

ENDFORM.                    " 0100_PROCESS_FC_GRAPH

*&---------------------------------------------------------------------*
*&      Form  0100_PROCESS_FC_GRAPH_REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0100_PROCESS_FC_GRAPH_REFRESH .
* Get graph data
  PERFORM 9999_GET_GRAPH_TRANS.

* Show graph auto refresh
  PERFORM DISPLAY_GRAPH_REFRESH.

ENDFORM.                    " 0100_PROCESS_FC_GRAPH_REFRESH

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_GRAPH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_GRAPH.
  DATA:
    LS_SERIES         TYPE ZST_BM_CHA_LAYO_SERI,
    LS_CHART_CONF     TYPE ZST_BM_CHART_CONF.

  LS_CHART_CONF-CAT_LAYO-CAT_FIELD  = 'MONAT'.
  LS_CHART_CONF-GLOBAL-TITLE        = 'Tháng'.
  LS_CHART_CONF-GLOBAL-CHARTTYPE    = 7.
  LS_CHART_CONF-GLOBAL-DIMENSION    = '2.5D'.

  LS_SERIES-SERI_FIELD              = 'DMBTR'.
  LS_SERIES-SERI_TITLE              = TEXT-001.
  LS_SERIES-SERI_COLOR              = '#3EE5A7'.
  APPEND LS_SERIES TO LS_CHART_CONF-SERI_LAYO.
  LS_SERIES-SERI_FIELD              = 'DMBTR2'.
  LS_SERIES-SERI_TITLE              = TEXT-002.
  LS_SERIES-SERI_COLOR              = '@40'.
  APPEND LS_SERIES TO LS_CHART_CONF-SERI_LAYO.

  IF 1 = 1.
    CALL FUNCTION 'ZFM_BM_CHART_STD_DISPLAY2'
      EXPORTING
        IT_TABDATA = GT_PERAM.
  ELSE.
    CALL FUNCTION 'ZFM_BM_CHART_DISPLAY'
      EXPORTING
        I_CUS_CONTROL_NAME = 'CUS_GRAPH'
        I_CHART_CONF       = LS_CHART_CONF
        IT_TABDATA         = GT_PERAM.
  ENDIF.

ENDFORM.                    " DISPLAY_GRAPH

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_GRAPH_REFRESH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DISPLAY_GRAPH_REFRESH.
  DATA:
    LS_SERIES         TYPE ZST_BM_CHA_LAYO_SERI,
    LS_CHART_CONF     TYPE ZST_BM_CHART_CONF.

  LS_CHART_CONF-CAT_LAYO-CAT_FIELD  = 'MONAT'.
  LS_CHART_CONF-GLOBAL-TITLE        = 'Tháng'.
  LS_CHART_CONF-GLOBAL-CHARTTYPE    = 7.
  LS_CHART_CONF-GLOBAL-DIMENSION    = '2.5D'.

  LS_SERIES-SERI_FIELD              = 'DMBTR'.
  LS_SERIES-SERI_TITLE              = TEXT-001.
  APPEND LS_SERIES TO LS_CHART_CONF-SERI_LAYO.
  LS_SERIES-SERI_FIELD              = 'DMBTR2'.
  LS_SERIES-SERI_TITLE              = TEXT-002.
  APPEND LS_SERIES TO LS_CHART_CONF-SERI_LAYO.

  CALL FUNCTION 'ZFM_BM_CHART_DISPLAY_TIMER'
    EXPORTING
      IT_TABDATA     = GT_PERAM
      I_INTERVAL     = 1
      I_SUBR_REFDATA = '9999_GET_TRANS'.

ENDFORM.                    " DISPLAY_GRAPH_REFRESH

*----------------------------------------------------------------------*
*       CLASS LCL_RECEIVER IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCL_RECEIVER IMPLEMENTATION.
  METHOD HANDLE_FINISHED.

*  ADD GW_INTERVAL TO GW_COUNTER.
*  MESSAGE S002 WITH COUNTER.
    CALL METHOD GO_TIMER->RUN.
  ENDMETHOD.                    "HANDLE_FINISHED
ENDCLASS.                    "LCL_RECEIVER IMPLEMENTATION

*&---------------------------------------------------------------------*
*&      Form  9999_GET_TRANS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LPT_PERAM  text
*----------------------------------------------------------------------*
FORM 9999_GET_TRANS
  CHANGING LPT_PERAM          TYPE ZTT_BM_IM_PERAM.
  DATA:
    LW_DMBTR                  TYPE WRBTR_BI,
    LW_ROW_ADD                TYPE I.
  FIELD-SYMBOLS:
    <LF_PERAM>                TYPE ZST_BM_IM_PERAM.

*  CLEAR: LPT_PERAM.

  IF LPT_PERAM IS INITIAL.
    APPEND LINES OF GT_PERAM TO LPT_PERAM.
  ENDIF.

  LW_ROW_ADD = LINES( GT_PERAM ).
  CALL FUNCTION 'RANDOM_I4'
    EXPORTING
      RND_MIN   = 1
      RND_MAX   = LW_ROW_ADD
    IMPORTING
      RND_VALUE = LW_ROW_ADD.

  READ TABLE GT_PERAM ASSIGNING <LF_PERAM> INDEX LW_ROW_ADD.
  APPEND <LF_PERAM> TO LPT_PERAM.
  DELETE LPT_PERAM INDEX 1.

*  LOOP AT LPT_PERAM ASSIGNING <LF_PERAM>.
*    CALL FUNCTION 'RANDOM_AMOUNT'
*      EXPORTING
*        RND_MIN    = '-1000000'
*        RND_MAX    = '1000000'
*        VALCURR    = 'VND'
*      IMPORTING
*        RND_AMOUNT = LW_DMBTR.
*    REPLACE ALL OCCURRENCES OF '.' IN LW_DMBTR WITH SPACE.
*    CONDENSE LW_DMBTR.
*
*    <LF_PERAM>-DMBTR = <LF_PERAM>-DMBTR + LW_DMBTR.
*    CALL FUNCTION 'RANDOM_AMOUNT'
*      EXPORTING
*        RND_MIN    = '-1000000'
*        RND_MAX    = '1000000'
*        VALCURR    = 'VND'
*      IMPORTING
*        RND_AMOUNT = LW_DMBTR.
*    REPLACE ALL OCCURRENCES OF '.' IN LW_DMBTR WITH SPACE.
*    CONDENSE LW_DMBTR.
*
*    <LF_PERAM>-DMBTR2 = <LF_PERAM>-DMBTR2 + LW_DMBTR.
*  ENDLOOP.

ENDFORM.                    " 9999_GET_TRANS

*&---------------------------------------------------------------------*
*&      Form  9999_GET_GRAPH_TRANS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM 9999_GET_GRAPH_TRANS .
  DATA:
    LS_PERAM                TYPE ZST_BM_IM_PERAM,
    LS_TRAN_DET             TYPE ZTB_BM_IM_TRAND,
    LT_TRAN_DET             TYPE TABLE OF ZTB_BM_IM_TRAND,
    LS_GRAPH_X              TYPE GPRTXT,
    LS_GRAPH_Y              TYPE GPRVAL,
    LW_COL                  TYPE I,
    LW_COL_STR              TYPE CHAR6,
    LW_VAL_STR              TYPE CHAR20,
    LS_CHART_CONF           TYPE ZST_BM_CHART_CONF,
    LW_DMBTR                TYPE DMBTR.
  FIELD-SYMBOLS:
    <LF_VAL>                TYPE GFWYVAL,
    <LF_PERAM>              TYPE ZST_BM_IM_PERAM.

  CLEAR: GT_PERAM, GT_GRAPH_X, GT_GRAPH_Y.
  SELECT *
    FROM ZTB_BM_IM_TRAND
    INTO TABLE LT_TRAN_DET.
  SORT LT_TRAN_DET BY DATUM.

  LOOP AT LT_TRAN_DET INTO LS_TRAN_DET.
    LS_PERAM-GJAHR    = LS_TRAN_DET-DATUM(4).
    LS_PERAM-MONAT    = LS_TRAN_DET-DATUM+4(2).
    LS_PERAM-DMBTR    = LS_TRAN_DET-DMBTR.
    LS_PERAM-WAERS    = GC_CURR_VND.
    COLLECT LS_PERAM INTO GT_PERAM.
  ENDLOOP.

  LOOP AT GT_PERAM ASSIGNING <LF_PERAM>.
    LW_DMBTR          = <LF_PERAM>-DMBTR * SY-TABIX.
    <LF_PERAM>-DMBTR2 = LW_DMBTR.
*    WRITE LW_DMBTR CURRENCY GC_CURR_VND TO <LF_PERAM>-DMBTR2.
    LW_DMBTR          = <LF_PERAM>-DMBTR * ( SY-TABIX + 1 ).
    <LF_PERAM>-DMBTR3 = LW_DMBTR.
*    WRITE LW_DMBTR CURRENCY GC_CURR_VND TO <LF_PERAM>-DMBTR3.
*    CONDENSE: <LF_PERAM>-DMBTR2, <LF_PERAM>-DMBTR3.
  ENDLOOP.

  SORT GT_PERAM BY GJAHR MONAT.
  LS_GRAPH_Y-ROWTXT = 'Amount'.
  LOOP AT GT_PERAM INTO LS_PERAM.
    LS_GRAPH_X-COLTXT = LS_PERAM-MONAT && '/' && LS_PERAM-GJAHR.
    APPEND LS_GRAPH_X TO GT_GRAPH_X.
    LW_COL  = LW_COL + 1.
    LW_COL_STR = LW_COL.
    CONDENSE LW_COL_STR.
    LW_COL_STR = 'VAL'&& LW_COL_STR.
    ASSIGN COMPONENT LW_COL_STR OF STRUCTURE LS_GRAPH_Y TO <LF_VAL>.
    IF SY-SUBRC IS INITIAL.
      WRITE LS_PERAM-DMBTR TO LW_VAL_STR CURRENCY 'VND' NO-GROUPING.
      CONDENSE LW_VAL_STR.
      <LF_VAL> = LW_VAL_STR.
    ENDIF.
  ENDLOOP.
  APPEND LS_GRAPH_Y TO GT_GRAPH_Y.

ENDFORM.                    " 9999_GET_GRAPH_TRANS
