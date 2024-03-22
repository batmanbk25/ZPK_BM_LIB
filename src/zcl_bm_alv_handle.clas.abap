class ZCL_BM_ALV_HANDLE definition
  public
  final
  create public .

public section.

  data GC_ALV_MSG_HANDL type SLIS_HANDL value 'MSGL' ##NO_TEXT.
  data GC_ALV_MSG_PROG type FIELDNAME value 'ALV_MSG_PROG' ##NO_TEXT.
  data GC_MESSAGE_COLUMN type FIELDNAME value 'MESSAGE' ##NO_TEXT.
  constants GC_MTYPE_COLUMN type FIELDNAME value 'MTYPE' ##NO_TEXT.
  constants GC_SEL_COLUMN type FIELDNAME value 'SELECTED' ##NO_TEXT.
  data GO_ALV_GRID type ref to CL_GUI_ALV_GRID .
  data GT_ALV_DATA type ref to DATA .
  data GW_CALLBACK_BUTTON_CLICK type SLIS_FORMNAME .
  data GW_CALLBACK_HOSPOT_CLICK type SLIS_FORMNAME .
  data GW_CALLBACK_PROGRAM type SY-REPID .
  data GW_HIDE_ERRLINE type XMARK value '' ##NO_TEXT.
  data GT_ERRFIELD_TITLE type LVC_T_FCAT .

  methods HANDLE_TOOLBAR
    for event TOOLBAR of CL_GUI_ALV_GRID
    importing
      !E_OBJECT
      !E_INTERACTIVE .
  methods HANDLE_USER_COMMAND
    for event USER_COMMAND of CL_GUI_ALV_GRID
    importing
      !E_UCOMM .
  methods HANDLE_BUTTON_CLICK
    for event BUTTON_CLICK of CL_GUI_ALV_GRID
    importing
      !ES_COL_ID
      !ES_ROW_NO .
  methods HANDLE_HOTSPOT_CLICK
    for event HOTSPOT_CLICK of CL_GUI_ALV_GRID
    importing
      !E_ROW_ID
      !E_COLUMN_ID
      !ES_ROW_NO .
  methods ALV_SET_HIDE_FILTER .
  methods ALV_SHOW_ERROR_LINES .
  methods SHOW_ALV_SELECT_RECORD .
  methods SHOW_ALV_TOTAL_RECORD .
protected section.
private section.
ENDCLASS.



CLASS ZCL_BM_ALV_HANDLE IMPLEMENTATION.


METHOD ALV_SET_HIDE_FILTER.
  DATA:
    LS_LAYOUT       TYPE LVC_S_LAYO,
    LT_FILTER       TYPE LVC_T_FILT,
    LS_FILTER       TYPE LVC_S_FILT,
    LS_ALV_INCL     TYPE ZST_ALV_INF_INCL,
    LW_NOTNULL      TYPE XMARK..
  FIELD-SYMBOLS:
    <GT_ALV_DATA>   TYPE TABLE,
    <LF_ALV_DATA>   TYPE ANY.

  ASSIGN GT_ALV_DATA->* TO <GT_ALV_DATA>.
  LOOP AT <GT_ALV_DATA> ASSIGNING <LF_ALV_DATA>.
    MOVE-CORRESPONDING <LF_ALV_DATA> TO LS_ALV_INCL.
    IF LS_ALV_INCL-MTYPE <> GC_MTYPE_E.
      LW_NOTNULL = GC_XMARK.
      EXIT.
    ENDIF.
  ENDLOOP.

  CHECK LW_NOTNULL = GC_XMARK.
  CALL METHOD GO_ALV_GRID->GET_FILTER_CRITERIA
    IMPORTING
      ET_FILTER = LT_FILTER.

  LS_FILTER-FIELDNAME  = 'MTYPE'.
  LS_FILTER-SIGN       = 'I'.
  LS_FILTER-OPTION     = 'NE'.
  LS_FILTER-LOW        = GC_MTYPE_E.
  APPEND LS_FILTER TO LT_FILTER.

  CALL METHOD GO_ALV_GRID->SET_FILTER_CRITERIA
    EXPORTING
      IT_FILTER = LT_FILTER.

  CALL METHOD GO_ALV_GRID->GET_FRONTEND_LAYOUT
    IMPORTING
      ES_LAYOUT = LS_LAYOUT.

  LS_LAYOUT-CWIDTH_OPT    = GC_XMARK.
  CALL METHOD GO_ALV_GRID->SET_FRONTEND_LAYOUT
    EXPORTING
      IS_LAYOUT = LS_LAYOUT.

  CALL METHOD GO_ALV_GRID->REFRESH_TABLE_DISPLAY.
ENDMETHOD.


METHOD ALV_SHOW_ERROR_LINES.
  DATA:
    LS_LAYOUT   TYPE LVC_S_LAYO,
    LT_FILTER   TYPE LVC_T_FILT.

  CALL METHOD GO_ALV_GRID->GET_FILTER_CRITERIA
    IMPORTING
      ET_FILTER = LT_FILTER.

  DELETE LT_FILTER WHERE FIELDNAME = GC_MTYPE_COLUMN.
  IF SY-SUBRC IS INITIAL.

    CALL METHOD GO_ALV_GRID->SET_FILTER_CRITERIA
      EXPORTING
        IT_FILTER = LT_FILTER.

    CALL METHOD GO_ALV_GRID->GET_FRONTEND_LAYOUT
      IMPORTING
        ES_LAYOUT = LS_LAYOUT.

    LS_LAYOUT-CWIDTH_OPT    = ABAP_TRUE.
    CALL METHOD GO_ALV_GRID->SET_FRONTEND_LAYOUT
      EXPORTING
        IS_LAYOUT = LS_LAYOUT.

    CALL METHOD GO_ALV_GRID->REFRESH_TABLE_DISPLAY.
  ELSE.
    CALL METHOD ALV_SET_HIDE_FILTER.
  ENDIF.

ENDMETHOD.


METHOD HANDLE_BUTTON_CLICK.
  IF GW_CALLBACK_PROGRAM IS NOT INITIAL
  AND GW_CALLBACK_BUTTON_CLICK IS NOT INITIAL.
    PERFORM (GW_CALLBACK_BUTTON_CLICK)
      IN PROGRAM (GW_CALLBACK_PROGRAM) IF FOUND
      USING ES_COL_ID
            ES_ROW_NO.
  ENDIF.
  RETURN.

*  IF ES_COL_ID-FIELDNAME <> GC_MESSAGE_COLUMN.
*  ENDIF.

ENDMETHOD.


METHOD HANDLE_HOTSPOT_CLICK.
  DATA:
    LS_MESSAGE_CURRENT TYPE ZST_ALV_INF_INCL,
    LS_VARIANT         TYPE DISVARIANT,
    LW_TITLE           TYPE LVC_TITLE.
  FIELD-SYMBOLS:
    <GT_ALV_DATA> TYPE TABLE,
    <LF_SELECTED> TYPE ANY,
    <LF_MSGKEY>   TYPE ANY.

  IF E_COLUMN_ID-FIELDNAME <> GC_MESSAGE_COLUMN.
    IF GW_CALLBACK_PROGRAM IS NOT INITIAL
    AND GW_CALLBACK_HOSPOT_CLICK IS NOT INITIAL.
      PERFORM (GW_CALLBACK_HOSPOT_CLICK)
        IN PROGRAM (GW_CALLBACK_PROGRAM) IF FOUND
        USING E_COLUMN_ID
              ES_ROW_NO.
    ENDIF.
    RETURN.
  ENDIF.

* Read Row chose
  ASSIGN GT_ALV_DATA->* TO <GT_ALV_DATA>.
  READ TABLE <GT_ALV_DATA> ASSIGNING <LF_SELECTED>
      INDEX ES_ROW_NO-ROW_ID.
  CHECK SY-SUBRC IS INITIAL.
  MOVE-CORRESPONDING <LF_SELECTED> TO LS_MESSAGE_CURRENT.
  CHECK LS_MESSAGE_CURRENT-MSGDETAIL IS NOT INITIAL.
  IF GT_ERRFIELD_TITLE IS NOT INITIAL.
    LOOP AT GT_ERRFIELD_TITLE INTO DATA(LS_FCAT).
      ASSIGN COMPONENT LS_FCAT-FIELDNAME OF STRUCTURE <LF_SELECTED>
        TO FIELD-SYMBOL(<LF_VALUE>).
      IF SY-SUBRC IS INITIAL.
        CONCATENATE LW_TITLE LS_FCAT-SCRTEXT_L <LF_VALUE> INTO LW_TITLE SEPARATED BY SPACE.
      ENDIF.

    ENDLOOP.
  ELSE.
    LW_TITLE = TEXT-004.
  ENDIF.

  LS_VARIANT-REPORT   = GC_ALV_MSG_PROG.
  LS_VARIANT-HANDLE   = GC_ALV_MSG_HANDL.
  CALL FUNCTION 'ZFM_ALV_DISPLAY'
    EXPORTING
      I_GRID_TITLE     = LW_TITLE
      I_STRUCTURE_NAME = 'ZST_ALV_MSG_DETAIL'
      IS_VARIANT       = LS_VARIANT
    TABLES
      T_OUTTAB         = LS_MESSAGE_CURRENT-MSGDETAIL.
ENDMETHOD.


METHOD HANDLE_TOOLBAR.
  DATA:
    LS_TOOLBAR  TYPE STB_BUTTON.

  CLEAR LS_TOOLBAR.

* 3  Separator
  LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_SEP.
  APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

* Show info, total row
  CLEAR LS_TOOLBAR.
  LS_TOOLBAR-FUNCTION   = 'FC_ALV_INFO'.
  LS_TOOLBAR-ICON       = ICON_INFORMATION.
  LS_TOOLBAR-QUICKINFO  = 'Info'(003).
  LS_TOOLBAR-DISABLED   = SPACE.
  APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

  IF GW_HIDE_ERRLINE IS NOT INITIAL.
*   Show "Hidden error" button
    CLEAR LS_TOOLBAR.
    LS_TOOLBAR-FUNCTION   = 'FC_ALV_HIDE_ERR'.
    LS_TOOLBAR-ICON       = ICON_LED_RED   .
    LS_TOOLBAR-QUICKINFO  = TEXT-005.
    LS_TOOLBAR-TEXT       = TEXT-005.
    LS_TOOLBAR-DISABLED   = SPACE.
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
  ENDIF.

ENDMETHOD.


METHOD HANDLE_USER_COMMAND.
  CASE E_UCOMM.
    WHEN 'FC_ALV_INFO'.
      CALL METHOD ME->SHOW_ALV_SELECT_RECORD.
    WHEN 'FC_ALV_HIDE_ERR'.
      CALL METHOD ALV_SHOW_ERROR_LINES.
    WHEN ''.
    WHEN OTHERS.
  ENDCASE.
ENDMETHOD.


METHOD SHOW_ALV_SELECT_RECORD.
  DATA:
    LW_SELECT_REC     TYPE CHAR10,
    LW_TOTAL_REC      TYPE CHAR10,
    LW_TOTAL_HIDE     TYPE CHAR10,
    LW_TOTAL_FILETER  TYPE CHAR10,
    LT_FILTER         TYPE LVC_T_FIDX.
  FIELD-SYMBOLS:
    <GT_ALV_DATA>     TYPE TABLE,
    <LF_DATA_REC>     TYPE ANY,
    <LF_SELECT>       TYPE XMARK.

  CALL METHOD GO_ALV_GRID->CHECK_CHANGED_DATA.
  CLEAR: LW_SELECT_REC.
  CHECK GT_ALV_DATA IS NOT INITIAL.
  ASSIGN GT_ALV_DATA->* TO <GT_ALV_DATA>.
  LOOP AT <GT_ALV_DATA> ASSIGNING <LF_DATA_REC>.
    ASSIGN COMPONENT GC_SEL_COLUMN OF STRUCTURE <LF_DATA_REC>
      TO <LF_SELECT>.
    IF SY-SUBRC IS INITIAL AND <LF_SELECT> = ABAP_TRUE.
      LW_SELECT_REC = LW_SELECT_REC + 1.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE <GT_ALV_DATA> LINES LW_TOTAL_REC.
  SHIFT LW_TOTAL_REC LEFT DELETING LEADING '0'.
  SHIFT LW_SELECT_REC LEFT DELETING LEADING '0'.
  IF LW_SELECT_REC = SPACE.
    LW_SELECT_REC = '0'.
  ENDIF.

  CALL METHOD GO_ALV_GRID->GET_FILTERED_ENTRIES
    IMPORTING
      ET_FILTERED_ENTRIES = LT_FILTER. " Record isn't display in alv
  DESCRIBE TABLE LT_FILTER LINES LW_TOTAL_HIDE.
  LW_TOTAL_FILETER = LW_TOTAL_REC - LW_TOTAL_HIDE.

  CONDENSE: LW_SELECT_REC, LW_TOTAL_FILETER, LW_TOTAL_REC.
  MESSAGE I005(ZMS_COL_LIB)
    WITH LW_SELECT_REC LW_TOTAL_FILETER LW_TOTAL_REC.
ENDMETHOD.


METHOD SHOW_ALV_TOTAL_RECORD.
  DATA:
    LW_SELECT_REC     TYPE CHAR10,
    LW_TOTAL_REC      TYPE CHAR10,
    LW_TOTAL_HIDE     TYPE CHAR10,
    LW_TOTAL_FILETER  TYPE CHAR10,
    LT_FILTER         TYPE LVC_T_FIDX.
  FIELD-SYMBOLS:
    <GT_ALV_DATA>     TYPE TABLE,
    <LF_DATA_REC>     TYPE ANY,
    <LF_SELECT>       TYPE XMARK.

  CLEAR: LW_SELECT_REC.
  CHECK GT_ALV_DATA IS NOT INITIAL.
  ASSIGN GT_ALV_DATA->* TO <GT_ALV_DATA>.
  LOOP AT <GT_ALV_DATA> ASSIGNING <LF_DATA_REC>.
    ASSIGN COMPONENT GC_SEL_COLUMN OF STRUCTURE <LF_DATA_REC>
      TO <LF_SELECT>.
    IF SY-SUBRC IS INITIAL AND <LF_SELECT> = ABAP_TRUE.
      LW_SELECT_REC = LW_SELECT_REC + 1.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE <GT_ALV_DATA> LINES LW_TOTAL_REC.
  SHIFT LW_TOTAL_REC LEFT DELETING LEADING '0'.
  SHIFT LW_SELECT_REC LEFT DELETING LEADING '0'.
  IF LW_SELECT_REC = SPACE.
    LW_SELECT_REC = '0'.
  ENDIF.

  IF GO_ALV_GRID IS NOT INITIAL.
    CALL METHOD GO_ALV_GRID->GET_FILTERED_ENTRIES
      IMPORTING
        ET_FILTERED_ENTRIES = LT_FILTER.
    DESCRIBE TABLE LT_FILTER LINES LW_TOTAL_HIDE.
    LW_TOTAL_FILETER = LW_TOTAL_REC - LW_TOTAL_HIDE.
  ENDIF.

  CONDENSE: LW_SELECT_REC, LW_TOTAL_FILETER, LW_TOTAL_REC.
  MESSAGE S005(ZMS_COL_LIB)
    WITH LW_SELECT_REC LW_TOTAL_FILETER LW_TOTAL_REC.

ENDMETHOD.
ENDCLASS.
