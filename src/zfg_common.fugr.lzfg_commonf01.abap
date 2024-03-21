*&---------------------------------------------------------------------*
*&  Include           LZFG_COMMONF01
*&---------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER IMPLEMENTATION.
  METHOD HANDLE_USER_COMMAND.
    CASE E_UCOMM.
      WHEN 'FC_ALV_INFO'.
        PERFORM SHOW_ALV_SELECT_RECORD.
      WHEN 'FC_ALV_HIDE_ERR'.
        PERFORM ALV_SHOW_ERROR_LINES.
      WHEN ''.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                           "handle_user_command
  METHOD HANDLE_TOOLBAR.
    DATA:
      LS_TOOLBAR  TYPE STB_BUTTON.

    CLEAR LS_TOOLBAR.
*   3  Separator
    LS_TOOLBAR-BUTN_TYPE = CNTB_BTYPE_SEP.
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

*   Show info, total row
    CLEAR LS_TOOLBAR.
    LS_TOOLBAR-FUNCTION   = 'FC_ALV_INFO'.
    LS_TOOLBAR-ICON       = ICON_INFORMATION.
    LS_TOOLBAR-QUICKINFO  = 'Info'(003).
    LS_TOOLBAR-DISABLED   = SPACE.
    APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.

    IF GW_HIDE_ERRLINE IS NOT INITIAL.
*     Show "Hidden error" button
      CLEAR LS_TOOLBAR.
      LS_TOOLBAR-FUNCTION   = 'FC_ALV_HIDE_ERR'.
      LS_TOOLBAR-ICON       = ICON_LED_RED   .
      LS_TOOLBAR-QUICKINFO  = TEXT-005.
      LS_TOOLBAR-TEXT       = TEXT-005.
      LS_TOOLBAR-DISABLED   = SPACE.
      APPEND LS_TOOLBAR TO E_OBJECT->MT_TOOLBAR.
    ENDIF.
  ENDMETHOD.                    "HANDLE_TOOLBAR
* Handle Button Click
  METHOD HANDLE_BUTTON_CLICK.
    PERFORM HANDLE_BUTTON_CLICK USING   ES_COL_ID
                                        ES_ROW_NO.
  ENDMETHOD.                    "HANDLE_BUTTON_CLICK
* Handle Button Click
  METHOD HANDLE_HOTSPOT_CLICK.
    PERFORM HANDLE_LINK_CLICK
      USING E_ROW_ID
            E_COLUMN_ID
            ES_ROW_NO .
  ENDMETHOD.                    "HANDLE_HOTSPOT_CLICK
ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS GCL_CHART_HANDLE IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS GCL_CHART_HANDLE IMPLEMENTATION.
  METHOD HANDLE_FINISHED.
    CHECK AUTORUN IS NOT INITIAL.
*   Set counter
    ADD GO_CHART_TIMER->INTERVAL TO COUNTER.
    MESSAGE S014(ZMS_COL_LIB) WITH COUNTER.

*   Get data
    PERFORM (REFRESH_FORMNAME) IN PROGRAM (REFRESH_PROGRAM) IF FOUND
      CHANGING <GFT_CHART_DATA>.

*   Bind data to chart
    PERFORM CHART_BIND_DATA
      USING CHART_CONF
            <GFT_CHART_DATA>
      CHANGING GO_CHART_ENGINE.

*   Render the Graph Object.
    CALL METHOD GO_CHART_ENGINE->RENDER.

*   Continue timer
    CALL METHOD GO_CHART_TIMER->RUN.

*    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
*      EXCEPTIONS
*        OTHERS = 0.

  ENDMETHOD.                    "HANDLE_FINISHED

  METHOD HANDLE_PROPERTY_CHANGE.
    IF NAME = 'Dimension'.
      GS_BM_CHART_CONF-DIMENSION_TX = VALUE.
    ENDIF.
    IF NAME = 'ChartType'.
      GS_BM_CHART_CONF-CHARTTYPE_TX = VALUE.
    ENDIF.

    PERFORM CHART_STD_LAYOUT_CONV_IN
      CHANGING GS_BM_CHART_CONF.
    MOVE-CORRESPONDING GS_BM_CHART_CONF-GLOBAL
      TO ZST_BM_CHART_LAYO_GLOBAL.

  ENDMETHOD.                    "HANDLE_PROPERTY_CHANGE
ENDCLASS.                    "GCL_CHART_HANDLE IMPLEMENTATION

*----------------------------------------------------------------------*
*       CLASS GCL_NEST_HANDLE IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS GCL_NEST_HANDLE IMPLEMENTATION.
  METHOD CONSTRUCTOR.
    FIELD-SYMBOLS:
      <LF_ROOT_NODE> TYPE ZST_BM_DATA_VIEW,
      <LF_LINE_REC>  TYPE ANY.

*   Set nodes tree
    ME->NODES = NODES.

*   Set root node
    READ TABLE ME->NODES ASSIGNING <LF_ROOT_NODE> INDEX 1 .
    IF SY-SUBRC IS INITIAL.
      IF <LF_ROOT_NODE>-COMPTYPE = GC_COMPTYPE_STRU.
        ASSIGN ROOT_DATA->* TO <LF_LINE_REC>.
        CREATE DATA <LF_ROOT_NODE>-DATA
          TYPE TABLE OF (<LF_ROOT_NODE>-ROWTYPE).
        ASSIGN <LF_ROOT_NODE>-DATA->* TO <GFT_NEST_TAB>.
        APPEND <LF_LINE_REC> TO <GFT_NEST_TAB>.
      ELSE.
        <LF_ROOT_NODE>-DATA            = ROOT_DATA.
      ENDIF.

      CURR_NODE = <LF_ROOT_NODE>.
    ENDIF.

  ENDMETHOD.                    "CONSTRUCTOR

  METHOD HANDLE_DOUBLE_CLICK.
    DATA:
      LR_DATA     TYPE REF TO DATA,
      LT_SEL_ROWS TYPE LVC_T_ROW,
      LS_SEL_ROW  TYPE LVC_S_ROW.
    FIELD-SYMBOLS:
      <LF_SEL_NODE> TYPE ZST_BM_DATA_VIEW,
      <LF_SEL_DATA> TYPE ANY.

*   Process if select other node
    CHECK NODE_KEY <> CURR_NODE-TREEKEY.

*   Get selected node
    READ TABLE NODES ASSIGNING <LF_SEL_NODE>
      WITH KEY TREEKEY = NODE_KEY.
    CHECK SY-SUBRC IS INITIAL.

*   Select other component in same parent of current node
    IF <LF_SEL_NODE>-DEPTH = CURR_NODE-DEPTH.
*     Get parent data
      ASSIGN CURR_NODE-PRDATA->* TO <LF_SEL_DATA>.
      CHECK SY-SUBRC IS INITIAL.

*     Get select component data
      ASSIGN COMPONENT <LF_SEL_NODE>-NAME
        OF STRUCTURE <LF_SEL_DATA> TO <GFT_NEST_TAB>.
      CHECK SY-SUBRC IS INITIAL.

*     Set data to node
      GET REFERENCE OF <GFT_NEST_TAB> INTO <LF_SEL_NODE>-DATA.
      <LF_SEL_NODE>-PRDATA = CURR_NODE-PRDATA.

*     Set current node
      CURR_NODE = <LF_SEL_NODE>.

*   Select component is child of current node
    ELSEIF <LF_SEL_NODE>-DEPTH > CURR_NODE-DEPTH.
*     Check selected node is child of current node
      IF CURR_NODE-AGGRKEY <> <LF_SEL_NODE>-AGPRKEY.
        MESSAGE S016(ZMS_COL_LIB).
        RETURN.
      ENDIF.

*     Get selected line of current data
      CALL METHOD GO_ALV_STR_NEST->GET_SELECTED_ROWS
        IMPORTING
          ET_INDEX_ROWS = LT_SEL_ROWS.
*     Only choose one line
      IF LT_SEL_ROWS IS INITIAL OR LINES( LT_SEL_ROWS ) > 1.
        MESSAGE S015(ZMS_COL_LIB).
        RETURN.
      ENDIF.
      READ TABLE LT_SEL_ROWS INDEX 1 INTO LS_SEL_ROW.

*     Get selected data line
      ASSIGN CURR_NODE-DATA->* TO <GFT_NEST_TAB>.
      CREATE DATA LR_DATA LIKE LINE OF <GFT_NEST_TAB>.
      ASSIGN LR_DATA->* TO <LF_SEL_DATA>.
      READ TABLE <GFT_NEST_TAB> INDEX LS_SEL_ROW-INDEX
        ASSIGNING <LF_SEL_DATA>.

*     Set new table detail data
      ASSIGN COMPONENT <LF_SEL_NODE>-NAME OF STRUCTURE <LF_SEL_DATA>
        TO <GFT_NEST_TAB>.
      CHECK SY-SUBRC IS INITIAL.
      GET REFERENCE OF <GFT_NEST_TAB> INTO <LF_SEL_NODE>-DATA.
      GET REFERENCE OF <LF_SEL_DATA> INTO <LF_SEL_NODE>-PRDATA.

*     Set current node
      CURR_NODE = <LF_SEL_NODE>.

*   Select component is ancestor of current node
    ELSE.
      CHECK <LF_SEL_NODE>-DATA IS NOT INITIAL.

*     Set current node
      CURR_NODE             = <LF_SEL_NODE>.
      ASSIGN CURR_NODE-DATA->* TO <GFT_NEST_TAB>.
    ENDIF.

*   Refresh ALV detail
    PERFORM 9999_NEST_DETAIL_ALV_SHOW
      USING GO_NEST_HANDLE
            GC_XMARK.

  ENDMETHOD.                    "HANDLE_DOUBLE_CLICK

  METHOD HANDLE_SELECTION_CHANGED.
    DATA:
      LT_FCAT       TYPE LVC_T_FCAT,
      LS_FCAT       TYPE LVC_S_FCAT,
      LS_LAYO       TYPE LVC_S_LAYO,
      LT_DET        TYPE LVC_T_DETM,
      LS_DET        TYPE LVC_S_DETM,
      LS_DETAIL_TAB	TYPE LVC_S_DETA,
      LT_DETAIL     TYPE LVC_T_DETA,
      LW_WHERE      TYPE STRING.
    FIELD-SYMBOLS:
      <LF_NEST_STR> TYPE ZST_BM_DATA_VIEW,
      <LF_NEST_VAL> TYPE ANY.

*    READ TABLE GT_DATA_VIEW INTO LS_DATA_VIEW
*      WITH KEY TREEKEY = NODE_KEY.
*    IF LS_DATA_VIEW-COMPTYPE = GC_COMPTYPE_STRU.
*      GO_NEST_HANDLE->CURR_NODE = LS_DATA_VIEW-ROWTYPE.
*      CREATE DATA LR_DATA TYPE TABLE OF (GO_NEST_HANDLE->ROOT_TYPE).
*      ASSIGN LR_DATA->* TO <GFT_NEST_TAB>.
*      ASSIGN I_DATA->* TO <LF_NEST_DATA>.
*      APPEND <LF_NEST_DATA> TO <GFT_NEST_TAB>.
*    ELSE.
*      GO_NEST_HANDLE->CURR_NODE = LS_DATA_VIEW-ROWTYPE.
*      ASSIGN CURR_DATA->* TO <GFT_NEST_TAB>.
*    ENDIF.

  ENDMETHOD.                    "HANDLE_SELECTION_CHANGED
ENDCLASS.                    "GCL_NEST_HANDLE IMPLEMENTATION
*&---------------------------------------------------------------------*
*&      Form  ALV_GRID_TOP_HTML
*&---------------------------------------------------------------------*
*       Show top HTML of ALV
*----------------------------------------------------------------------*
*      -->LPS_DYNDOC_ID  Document ID
*----------------------------------------------------------------------*
FORM ALV_GRID_TOP_HTML
  USING LPS_DYNDOC_ID TYPE REF TO CL_DD_DOCUMENT.

  IF GT_HEADER[] IS NOT INITIAL.
*   Bind data to document view
    PERFORM 9999_SET_HTML_DOC
      USING LPS_DYNDOC_ID
            GT_HEADER
            GS_LOGO.
  ENDIF.

ENDFORM.                    "ALV_GRID_TOP_HTML

*&---------------------------------------------------------------------*
*&      Form  ALV_GRID_STATUS_SET
*&---------------------------------------------------------------------*
*       Show top HTML of ALV
*----------------------------------------------------------------------*
*      -->LPS_DYNDOC_ID  Document ID
*----------------------------------------------------------------------*
FORM ALV_GRID_PF_STATUS_SET
    USING RT_EXTAB TYPE KKBLO_T_EXTAB.

  CHECK GW_CALLBACK_PF_STATUS_SET IS NOT INITIAL
    AND GW_CALLBACK_PROGRAM IS NOT INITIAL.

  PERFORM (GW_CALLBACK_PF_STATUS_SET) IN PROGRAM (GW_CALLBACK_PROGRAM)
    USING RT_EXTAB.


ENDFORM.                    "ALV_GRID_STATUS_SET

*&---------------------------------------------------------------------*
*&      Form  ALV_GRID_USER_COMMAND
*&---------------------------------------------------------------------*
*       Show top HTML of ALV
*----------------------------------------------------------------------*
*      -->LPS_DYNDOC_ID  Document ID
*----------------------------------------------------------------------*
FORM ALV_GRID_USER_COMMAND
    USING R_UCOMM     TYPE SY-UCOMM
          RS_SELFIELD TYPE SLIS_SELFIELD.

  CHECK GW_CALLBACK_USER_COMMAND IS NOT INITIAL
    AND GW_CALLBACK_PROGRAM IS NOT INITIAL.

  PERFORM (GW_CALLBACK_USER_COMMAND) IN PROGRAM (GW_CALLBACK_PROGRAM)
    USING R_UCOMM RS_SELFIELD.
ENDFORM.                    "ALV_GRID_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  ALV_GRID_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       Show top HTML of ALV
*----------------------------------------------------------------------*
FORM ALV_GRID_TOP_OF_PAGE.

  CHECK GW_CALLBACK_TOP_OF_PAGE IS NOT INITIAL
    AND GW_CALLBACK_PROGRAM IS NOT INITIAL.

  PERFORM (GW_CALLBACK_TOP_OF_PAGE) IN PROGRAM (GW_CALLBACK_PROGRAM).

ENDFORM.                    "ALV_GRID_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  ALV_GRID_HTML_END_OF_LIST
*&---------------------------------------------------------------------*
*       Show top HTML of ALV
*----------------------------------------------------------------------*
*      -->LPS_DYNDOC_ID  Document ID
*----------------------------------------------------------------------*
FORM ALV_GRID_HTML_END_OF_LIST
  USING LPS_DYNDOC_ID TYPE REF TO CL_DD_DOCUMENT.

  CHECK GW_CALLBACK_HTML_END_OF_LIST IS NOT INITIAL
    AND GW_CALLBACK_PROGRAM IS NOT INITIAL.

  PERFORM (GW_CALLBACK_HTML_END_OF_LIST)
    IN PROGRAM (GW_CALLBACK_PROGRAM).

ENDFORM.                    "ALV_GRID_HTML_END_OF_LIST

*&---------------------------------------------------------------------*
*&      Form  CREATE_ALV_OBJECTS
*&---------------------------------------------------------------------*
*       Create objects
*----------------------------------------------------------------------*
FORM CREATE_ALV_OBJECTS
  USING LPW_EXTENSION         TYPE I
        LPW_SIDE              TYPE I
        LPW_CUS_CONTROL_NAME  TYPE SCRFNAME
        LPW_CPROG             TYPE CPROG
        LPW_DYNNR             TYPE DYNNR
        LPO_GUI_CONTAINER     TYPE REF TO CL_GUI_CONTAINER
        LPT_HEADER            TYPE ZTT_ALV_HEADER
        LPS_LOGO              TYPE ZST_BM_ALV_LOGO
        LPW_CUSTOMIZE_ALV     TYPE XMARK.
  DATA:
    LT_EVENTS      TYPE CNTL_SIMPLE_EVENTS,
    LS_EVENT       TYPE CNTL_SIMPLE_EVENT,
    LW_EXTENSION   TYPE I,
    LW_CPROG       TYPE CPROG,
    LW_DYNNR       TYPE DYNNR,
    LS_BM_ALV_GRID TYPE ZST_BM_ALV_GRID.
  FIELD-SYMBOLS:
    <LF_BM_ALV_GRID>          TYPE ZST_BM_ALV_GRID.

  LW_EXTENSION = LPW_EXTENSION.
  IF LPW_EXTENSION IS INITIAL.
    LW_EXTENSION = 100.
  ENDIF.

  IF LPW_CPROG IS NOT INITIAL.
    LW_CPROG = LPW_CPROG.
  ELSE.
    LW_CPROG = SY-CPROG.
  ENDIF.

  IF LPW_DYNNR IS NOT INITIAL.
    LW_DYNNR = LPW_DYNNR.
  ELSE.
    LW_DYNNR = SY-DYNNR.
  ENDIF.

  FREE: GO_ALV_DOCKING, GO_ALV_GRID, GO_ALV_CUS_CONTAINER, GO_ALV_GRID_MERGE.
  IF LPO_GUI_CONTAINER IS NOT INITIAL.
    IF LPT_HEADER IS INITIAL.
      GO_ALV_GUI_CONTAINER = LPO_GUI_CONTAINER.
    ELSE.
      PERFORM 9999_SPLIT_CONTAINER_HORIZON
        USING LPO_GUI_CONTAINER
        CHANGING GO_ALV_HEADER_CON
                 GO_ALV_GUI_CONTAINER.
    ENDIF.
*   Create Grid
    IF LPW_CUSTOMIZE_ALV IS INITIAL.
      CREATE OBJECT GO_ALV_GRID
        EXPORTING
          I_PARENT = GO_ALV_GUI_CONTAINER.
    ELSE.
      CREATE OBJECT GO_ALV_GRID_MERGE
        EXPORTING
          I_PARENT = GO_ALV_GUI_CONTAINER.
      GO_ALV_GRID ?= GO_ALV_GRID_MERGE.
    ENDIF.
  ELSEIF LPW_CUS_CONTROL_NAME IS INITIAL.
*   Create Docking container
    CREATE OBJECT GO_ALV_DOCKING
      EXPORTING
        REPID                       = LW_CPROG
        DYNNR                       = LW_DYNNR
        SIDE                        = LPW_SIDE
        EXTENSION                   = LW_EXTENSION
        NO_AUTODEF_PROGID_DYNNR     = 'X'
      EXCEPTIONS
        CNTL_ERROR                  = 1
        CNTL_SYSTEM_ERROR           = 2
        CREATE_ERROR                = 3
        LIFETIME_ERROR              = 4
        LIFETIME_DYNPRO_DYNPRO_LINK = 5
        OTHERS                      = 6.

*   Create Grid
    IF LPW_CUSTOMIZE_ALV IS INITIAL.
      CREATE OBJECT GO_ALV_GRID
        EXPORTING
          I_PARENT = GO_ALV_DOCKING.
    ELSE.
      CREATE OBJECT GO_ALV_GRID_MERGE
        EXPORTING
          I_PARENT = GO_ALV_DOCKING.
      GO_ALV_GRID ?= GO_ALV_GRID_MERGE.
    ENDIF.
  ELSE.
    IF LPT_HEADER IS INITIAL.
      CREATE OBJECT GO_ALV_CUS_CONTAINER
        EXPORTING
          CONTAINER_NAME              = LPW_CUS_CONTROL_NAME
          REPID                       = LW_CPROG
          DYNNR                       = LW_DYNNR
        EXCEPTIONS
          CNTL_ERROR                  = 1
          CNTL_SYSTEM_ERROR           = 2
          CREATE_ERROR                = 3
          LIFETIME_ERROR              = 4
          LIFETIME_DYNPRO_DYNPRO_LINK = 5
          OTHERS                      = 6.

*     Create Grid
      IF LPW_CUSTOMIZE_ALV IS INITIAL.
        CREATE OBJECT GO_ALV_GRID
          EXPORTING
            I_PARENT = GO_ALV_CUS_CONTAINER.
      ELSE.
        CREATE OBJECT GO_ALV_GRID_MERGE
          EXPORTING
            I_PARENT = GO_ALV_CUS_CONTAINER.
        GO_ALV_GRID ?= GO_ALV_GRID_MERGE.
      ENDIF.
    ELSE.
      CREATE OBJECT GO_ALV_CUS_WITH_HEAD
        EXPORTING
          CONTAINER_NAME              = LPW_CUS_CONTROL_NAME
          REPID                       = LW_CPROG
          DYNNR                       = LW_DYNNR
        EXCEPTIONS
          CNTL_ERROR                  = 1
          CNTL_SYSTEM_ERROR           = 2
          CREATE_ERROR                = 3
          LIFETIME_ERROR              = 4
          LIFETIME_DYNPRO_DYNPRO_LINK = 5
          OTHERS                      = 6.
      PERFORM 9999_SPLIT_CONTAINER_HORIZON
        USING GO_ALV_CUS_WITH_HEAD
        CHANGING GO_ALV_HEADER_CON
                 GO_ALV_GUI_CONTAINER.

*     Create Grid
      IF LPW_CUSTOMIZE_ALV IS INITIAL.
        CREATE OBJECT GO_ALV_GRID
          EXPORTING
            I_PARENT = GO_ALV_GUI_CONTAINER.
      ELSE.
        CREATE OBJECT GO_ALV_GRID_MERGE
          EXPORTING
            I_PARENT = GO_ALV_GUI_CONTAINER.
        GO_ALV_GRID ?= GO_ALV_GRID_MERGE.
      ENDIF.
    ENDIF.

  ENDIF.

  IF LPT_HEADER IS NOT INITIAL.
    PERFORM 9999_SHOW_HEADER_ALV
      USING LPT_HEADER
            LPS_LOGO.
  ENDIF.

* Log
  READ TABLE GT_BM_ALV_GRID ASSIGNING <LF_BM_ALV_GRID>
    WITH KEY REPID = LW_CPROG
             DYNNR = LW_DYNNR.
  IF SY-SUBRC IS INITIAL.
    <LF_BM_ALV_GRID>-ALV_GRID   = GO_ALV_GRID.
  ELSE.
    LS_BM_ALV_GRID-ALV_GRID     = GO_ALV_GRID.
    LS_BM_ALV_GRID-REPID        = LW_CPROG.
    LS_BM_ALV_GRID-DYNNR        = LW_DYNNR.
    APPEND LS_BM_ALV_GRID TO GT_BM_ALV_GRID.
  ENDIF.

ENDFORM.                    " CREATE_ALV_OBJECTS

*&---------------------------------------------------------------------
*&      Form  BUILD_TREE_ALV_OBJECTS
*&---------------------------------------------------------------------
*       Build tree objects
*----------------------------------------------------------------------
*      --> I_SHOW               Show/Hide
*      --> I_SIDE               Top, bottom,left, Right
*      --> I_EXTENSION          Size of tree
*      --> I_CUS_CONTROL_NAME   Custom container
*----------------------------------------------------------------------
FORM BUILD_TREE_ALV_OBJECTS
  USING   I_SHOW              TYPE XMARK
          I_SIDE              TYPE I
          I_EXTENSION         TYPE I
          I_CUS_CONTROL_NAME  TYPE SCRFNAME
          I_REPID             TYPE SY-REPID
          I_GUI_CONTAINER     TYPE REF TO CL_GUI_CONTAINER
          LPW_NODE_SEL_MODE   TYPE I
          LPW_ITEM_SELECTION  TYPE XMARK.

  IF I_SHOW IS INITIAL.
*   Hide functions tree
    PERFORM FREE_TREE_ALV_OBJECTS.
  ELSEIF I_CUS_CONTROL_NAME IS NOT INITIAL.
*   Build ALV tree objects using Custom container
    PERFORM BUILD_ALV_TREE_OBJECTS_CUS_CON
      USING I_CUS_CONTROL_NAME
            I_REPID
            LPW_NODE_SEL_MODE
            LPW_ITEM_SELECTION.
  ELSEIF I_GUI_CONTAINER IS NOT INITIAL.
*   Build ALV tree objects using Custom container
    PERFORM BUILD_ALV_TREE_AVAICONTAINER
      USING I_GUI_CONTAINER
            LPW_NODE_SEL_MODE
            LPW_ITEM_SELECTION.
  ELSEIF GO_ALV_TREE_DOCK_CON IS INITIAL.
*   Build ALV tree objects using Docking container
    PERFORM BUILD_ALV_TREE_OBJECTS_DOCK
    USING I_SIDE
          I_EXTENSION
          I_REPID
          LPW_NODE_SEL_MODE
          LPW_ITEM_SELECTION.
  ENDIF.

ENDFORM.                    " BUILD_TREE_ALV_OBJECTS

*&---------------------------------------------------------------------
*&      Form  FREE_TREE_ALV_OBJECTS
*&---------------------------------------------------------------------
*       Free objects
*----------------------------------------------------------------------
FORM FREE_TREE_ALV_OBJECTS.
  CHECK GO_ALV_TREE_DOCK_CON IS NOT INITIAL.

* Free objects
  IF GO_ALV_TREE IS NOT INITIAL.
    CALL METHOD GO_ALV_TREE->FREE.
  ENDIF.
  IF GO_ALV_TREE_DOCK_CON IS NOT INITIAL.
    CALL METHOD GO_ALV_TREE_DOCK_CON->FREE.
  ENDIF.
  CLEAR GO_ALV_TREE.
  CLEAR GO_ALV_TREE_DOCK_CON.
ENDFORM.                    " FREE_TREE_ALV_OBJECTS

*&---------------------------------------------------------------------
*&      Form  BUILD_ALV_TREE_OBJECTS_DOCK
*&---------------------------------------------------------------------
*       Build ALV tree objects using Docking container
*----------------------------------------------------------------------
FORM BUILD_ALV_TREE_OBJECTS_DOCK
  USING I_SIDE                TYPE I
        I_EXTENSION           TYPE I
        I_REPID               TYPE SY-REPID
        LPW_NODE_SEL_MODE     TYPE I
        LPW_ITEM_SELECTION    TYPE XMARK.
  DATA:
    LT_EVENTS    TYPE CNTL_SIMPLE_EVENTS,
    LS_EVENT     TYPE CNTL_SIMPLE_EVENT,
    LW_EXTENSION TYPE I.

  LW_EXTENSION = I_EXTENSION.
  IF LW_EXTENSION IS INITIAL.
    LW_EXTENSION = 100.
  ENDIF.

* Create Docking container
  CREATE OBJECT GO_ALV_TREE_DOCK_CON
    EXPORTING
      REPID                       = I_REPID
      DYNNR                       = SY-DYNNR
      SIDE                        = I_SIDE
      EXTENSION                   = LW_EXTENSION
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5
      OTHERS                      = 6.

* Create tree
  CREATE OBJECT GO_ALV_TREE
    EXPORTING
      PARENT              = GO_ALV_TREE_DOCK_CON
      NODE_SELECTION_MODE = LPW_NODE_SEL_MODE
      ITEM_SELECTION      = LPW_ITEM_SELECTION
      NO_HTML_HEADER      = 'X'
    EXCEPTIONS
      OTHERS              = 1.

* Add events
  LS_EVENT-EVENTID = CL_GUI_SIMPLE_TREE=>EVENTID_NODE_DOUBLE_CLICK.
  LS_EVENT-APPL_EVENT = 'X'. " process PAI if event occurs
  APPEND LS_EVENT TO LT_EVENTS.

  CALL METHOD GO_ALV_TREE->SET_REGISTERED_EVENTS
    EXPORTING
      EVENTS                    = LT_EVENTS
    EXCEPTIONS
      CNTL_ERROR                = 1
      CNTL_SYSTEM_ERROR         = 2
      ILLEGAL_EVENT_COMBINATION = 3.

ENDFORM.                    " BUILD_ALV_TREE_OBJECTS_DOCK

*&---------------------------------------------------------------------
*&      Form  PUSH_TREE_ALV_DATA
*&---------------------------------------------------------------------
*       Push tree data
*----------------------------------------------------------------------
*       --> T_TREE_DATA Tree data
*       --> I_TREE_STR  Tree structure
*----------------------------------------------------------------------
FORM PUSH_TREE_ALV_DATA
  USING T_TREE_DATA TYPE  ANY TABLE
        I_TREE_STR  TYPE ZST_TREE_STR.
  DATA:
    LT_KEYS TYPE TABLE OF FIELDNAME,
    LT_DATA TYPE REF TO DATA.

* Create table
  APPEND I_TREE_STR-KEYNM TO LT_KEYS.
  CREATE DATA LT_DATA TYPE STANDARD TABLE OF
         (I_TREE_STR-TABNM) WITH KEY (LT_KEYS).
  ASSIGN LT_DATA->* TO <GFT_TREE_ALV_DATA>.
* Get data
  APPEND LINES OF T_TREE_DATA TO <GFT_TREE_ALV_DATA>.
ENDFORM.                    "PUSH_TREE_ALV_DATA

*&---------------------------------------------------------------------
*&      Form  DISPLAY_TREE_ALV
*&---------------------------------------------------------------------
*       Display ALV tree
*----------------------------------------------------------------------
*       --> I_TREE_STR        Tree structure
*       --> T_FIELDCAT        Field category
*----------------------------------------------------------------------
FORM DISPLAY_TREE_ALV
  USING I_TREE_STR            TYPE ZST_TREE_STR
        I_HIERARCHY_HEADER    TYPE TREEV_HHDR
        IS_VARIANT            TYPE DISVARIANT
        I_SAVE                TYPE CHAR01
        I_DEFAULT             TYPE CHAR01
        IS_EXCEPTION_FIELD    TYPE LVC_S_L004
        IT_SPECIAL_GROUPS     TYPE LVC_T_SGRP
        I_LOGO                TYPE SDYDO_VALUE
        I_BACKGROUND_ID       TYPE SDYDO_KEY
        IT_TOOLBAR_EXCLUDING  TYPE UI_FUNCTIONS
        IT_EXCEPT_QINFO       TYPE LVC_T_QINF
        I_SORT_TABLE          TYPE XMARK
  CHANGING
        T_FIELDCAT            TYPE LVC_T_FCAT
        IT_FILTER             TYPE LVC_T_FILT.
  DATA:
    LS_DATA    TYPE REF TO DATA,
    LW_TABNAME TYPE TABNM.

  FIELD-SYMBOLS:
    <LFT_TREE_DATA> TYPE ANY,
    <LF_FCAT>       TYPE LVC_S_FCAT.

  CREATE DATA LS_DATA LIKE <GFT_TREE_ALV_DATA>.
  ASSIGN LS_DATA->* TO <LFT_TREE_DATA>.

  LOOP AT T_FIELDCAT ASSIGNING <LF_FCAT>.
    <LF_FCAT>-NO_ZERO         = GC_XMARK.
  ENDLOOP.

* First Display
  CALL METHOD GO_ALV_TREE->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
*     I_STRUCTURE_NAME     = I_TREE_STR-TABNM
      IS_HIERARCHY_HEADER  = I_HIERARCHY_HEADER
      IS_VARIANT           = IS_VARIANT
      I_SAVE               = I_SAVE
      I_DEFAULT            = I_DEFAULT
      IS_EXCEPTION_FIELD   = IS_EXCEPTION_FIELD
      IT_SPECIAL_GROUPS    = IT_SPECIAL_GROUPS
      I_LOGO               = I_LOGO
      I_BACKGROUND_ID      = I_BACKGROUND_ID
      IT_TOOLBAR_EXCLUDING = IT_TOOLBAR_EXCLUDING
      IT_EXCEPT_QINFO      = IT_EXCEPT_QINFO
    CHANGING
      IT_OUTTAB            = <LFT_TREE_DATA>
      IT_FIELDCATALOG      = T_FIELDCAT
      IT_FILTER            = IT_FILTER.

* Create node
  PERFORM ALV_TREE_NODES_PUSH_ALL     USING I_TREE_STR I_SORT_TABLE.
ENDFORM.                    "DISPLAY_TREE_ALV

*&---------------------------------------------------------------------
*&      Form  ALV_TREE_NODES_PUSH_ALL
*&---------------------------------------------------------------------
*       Free objects
*----------------------------------------------------------------------
FORM ALV_TREE_NODES_PUSH_ALL
  USING I_TREE_STR    TYPE ZST_TREE_STR
        I_SORT_TABLE   TYPE XMARK.
  DATA:
    LT_ROOTS TYPE LVC_T_NKEY,
    LS_ROOT  TYPE LVC_NKEY,
    LS_DATA  TYPE REF TO DATA.

  FIELD-SYMBOLS:
    <LF_TREE_DATA>    TYPE ANY.

* Sort table to correct order of parent key
  IF I_SORT_TABLE = 'X'.
    IF I_TREE_STR-NODELV IS INITIAL.
      SORT <GFT_TREE_ALV_DATA>
        BY (I_TREE_STR-KEYPR) (I_TREE_STR-KEYNM).
    ELSE.
      SORT <GFT_TREE_ALV_DATA>
        BY (I_TREE_STR-NODELV) (I_TREE_STR-KEYPR) (I_TREE_STR-KEYNM).
    ENDIF.
  ENDIF.

  LOOP AT <GFT_TREE_ALV_DATA> ASSIGNING <LF_TREE_DATA>.
*   Push single node to tree
    PERFORM ALV_TREE_NODES_PUSH_SINGLE
      USING     I_TREE_STR
                <GFT_TREE_ALV_DATA>
      CHANGING  <LF_TREE_DATA>
                GO_ALV_TREE
                LT_ROOTS.
  ENDLOOP.

* Expand tree not to runtime error
  SORT LT_ROOTS DESCENDING.
  LOOP AT LT_ROOTS INTO LS_ROOT.
    CALL METHOD GO_ALV_TREE->EXPAND_NODE
      EXPORTING
        I_NODE_KEY          = LS_ROOT
        I_EXPAND_SUBTREE    = GC_XMARK
      EXCEPTIONS
        FAILED              = 1
        ILLEGAL_LEVEL_COUNT = 2
        CNTL_SYSTEM_ERROR   = 3
        NODE_NOT_FOUND      = 4
        CANNOT_EXPAND_LEAF  = 5
        OTHERS              = 6.

  ENDLOOP.

  CALL METHOD GO_ALV_TREE->EXPAND_NODES
    EXPORTING
      IT_NODE_KEY = LT_ROOTS
    EXCEPTIONS
      OTHERS      = 6.

  PERFORM SET_ALV_TREE_EVENT.
ENDFORM.                    " ALV_TREE_NODES_PUSH_ALL

*&---------------------------------------------------------------------*
*&      Form  BUILD_TREE
*&---------------------------------------------------------------------*
*       Build tree
*----------------------------------------------------------------------*
*      --> I_SHOW  Show/Hide
*----------------------------------------------------------------------*
FORM BUILD_TREE
  USING   I_SHOW      TYPE XMARK
          I_SIDE      TYPE I
          I_EXTENSION TYPE I.

  IF I_SHOW IS INITIAL.
*   Hide functions tree
    PERFORM FREE_TREE_OBJECTS.
  ELSEIF GO_DOCK_CONTAINER IS INITIAL.
*   Create Objects
    PERFORM CREATE_TREE_OBJECTS USING I_SIDE I_EXTENSION.
*   Add nodes
    CALL METHOD GO_TREE->ADD_NODES
      EXPORTING
        TABLE_STRUCTURE_NAME           = 'ZST_TREESNODE'
        NODE_TABLE                     = GT_NODES
      EXCEPTIONS
        ERROR_IN_NODE_TABLE            = 1
        FAILED                         = 2
        DP_ERROR                       = 3
        TABLE_STRUCTURE_NAME_NOT_FOUND = 4
        OTHERS                         = 5.
*   Expand nodes
    CALL METHOD GO_TREE->EXPAND_ROOT_NODES
      EXPORTING
        EXPAND_SUBTREE = 'X'.
  ENDIF.

ENDFORM.                    " BUILD_TREE

*&---------------------------------------------------------------------*
*&      Form  FREE_OBJECTS
*&---------------------------------------------------------------------*
*       Free objects
*----------------------------------------------------------------------*
FORM FREE_TREE_OBJECTS .
  CHECK GO_DOCK_CONTAINER IS NOT INITIAL.

* Free objects
  IF GO_TREE IS NOT INITIAL.
    CALL METHOD GO_TREE->FREE.
  ENDIF.
  IF GO_DOCK_CONTAINER IS NOT INITIAL.
    CALL METHOD GO_DOCK_CONTAINER->FREE.
  ENDIF.
  CLEAR GO_TREE.
  CLEAR GO_DOCK_CONTAINER.
ENDFORM.                    " FREE_OBJECTS

*&---------------------------------------------------------------------*
*&      Form  CREATE_TREE_OBJECTS
*&---------------------------------------------------------------------*
*       Create objects
*----------------------------------------------------------------------*
FORM CREATE_TREE_OBJECTS
  USING I_SIDE      TYPE I
        I_EXTENSION TYPE I.
  DATA:
    LT_EVENTS    TYPE CNTL_SIMPLE_EVENTS,
    LS_EVENT     TYPE CNTL_SIMPLE_EVENT,
    LW_EXTENSION TYPE I.

  LW_EXTENSION = I_EXTENSION.
  IF LW_EXTENSION IS INITIAL.
    LW_EXTENSION = 100.
  ENDIF.
  IF GO_CONTAINER IS INITIAL.
*   Create Docking container
    CREATE OBJECT GO_DOCK_CONTAINER
      EXPORTING
        REPID                       = SY-CPROG
        DYNNR                       = SY-DYNNR
        SIDE                        = I_SIDE
        EXTENSION                   = LW_EXTENSION
      EXCEPTIONS
        CNTL_ERROR                  = 1
        CNTL_SYSTEM_ERROR           = 2
        CREATE_ERROR                = 3
        LIFETIME_ERROR              = 4
        LIFETIME_DYNPRO_DYNPRO_LINK = 5
        OTHERS                      = 6.

*   Create tree
    CREATE OBJECT GO_TREE
      EXPORTING
        PARENT              = GO_DOCK_CONTAINER
        NODE_SELECTION_MODE = CL_GUI_SIMPLE_TREE=>NODE_SEL_MODE_SINGLE
      EXCEPTIONS
        OTHERS              = 1.
  ELSE.
*   Create tree
    CREATE OBJECT GO_TREE
      EXPORTING
        PARENT              = GO_CONTAINER
        NODE_SELECTION_MODE = CL_GUI_SIMPLE_TREE=>NODE_SEL_MODE_SINGLE
      EXCEPTIONS
        OTHERS              = 1.
  ENDIF.

* Set handle
*  SET HANDLER GO_APPLICATION->HANDLE_NODE_DOUBLE_CLICK FOR GO_TREE.

* Add events
  LS_EVENT-EVENTID = CL_GUI_SIMPLE_TREE=>EVENTID_NODE_DOUBLE_CLICK.
  LS_EVENT-APPL_EVENT = 'X'. " process PAI if event occurs
  APPEND LS_EVENT TO LT_EVENTS.

  CALL METHOD GO_TREE->SET_REGISTERED_EVENTS
    EXPORTING
      EVENTS                    = LT_EVENTS
    EXCEPTIONS
      CNTL_ERROR                = 1
      CNTL_SYSTEM_ERROR         = 2
      ILLEGAL_EVENT_COMBINATION = 3.

ENDFORM.                    " CREATE_TREE_OBJECTS

*&---------------------------------------------------------------------*
*&      Form  PUSH_TREE_DATA
*&---------------------------------------------------------------------*
*       Push tree data
*----------------------------------------------------------------------*
*       -->
*----------------------------------------------------------------------*
FORM PUSH_TREE_DATA
  USING T_TREE_DATA TYPE  ANY TABLE
        I_TREE_STR  TYPE ZST_TREE_STR.
  DATA:
    LT_KEYS TYPE TABLE OF FIELDNAME,
    LT_DATA TYPE REF TO DATA.

* Create table
  APPEND I_TREE_STR-KEYNM TO LT_KEYS.
  CREATE DATA LT_DATA TYPE STANDARD TABLE OF
         (I_TREE_STR-TABNM) WITH KEY (LT_KEYS).
  ASSIGN LT_DATA->* TO <GFT_TREE_DATA>.
* Get data
  APPEND LINES OF T_TREE_DATA TO <GFT_TREE_DATA>.
ENDFORM.                    "PUSH_TREE_DATA

*&---------------------------------------------------------------------*
*&      Form  MAP_DATA_TO_NODE
*&---------------------------------------------------------------------*
*       Free objects
*----------------------------------------------------------------------*
FORM MAP_DATA_TO_NODE
  USING I_TREE_STR    TYPE ZST_TREE_STR.
  DATA:
    LS_NODE        LIKE LINE OF GT_NODES,
    LT_KEYS        TYPE TABLE OF FIELDNAME,
    LS_DATA        TYPE REF TO DATA,
    LW_KEY         TYPE NUMC10,
    LS_NODE_LAYOUT TYPE LVC_S_LAYN.

  FIELD-SYMBOLS:
    <LF_TREE_DATA>    TYPE ANY,
    <LF_TREE_PARENTS> TYPE ANY,
    <LF_TREE_CHILD>   TYPE ANY,
    <LF_TREEKEY>      TYPE ANY,
    <LF_TEXT>         TYPE ANY,
    <LF_TREEPRKEY>    TYPE ANY,
    <LF_CURID>        TYPE ANY,
    <LF_CHILDID>      TYPE ANY,
    <LF_PARID>        TYPE ANY.

  CREATE DATA LS_DATA LIKE LINE OF <GFT_TREE_DATA>.
  ASSIGN LS_DATA->* TO <LF_TREE_DATA>.

  IF I_TREE_STR-NODELV IS INITIAL.
    SORT <GFT_TREE_DATA>
      BY (I_TREE_STR-KEYPR) (I_TREE_STR-KEYNM).
  ELSE.
    SORT <GFT_TREE_DATA>
      BY (I_TREE_STR-NODELV) (I_TREE_STR-KEYPR) (I_TREE_STR-KEYNM).
  ENDIF.

  CLEAR: LW_KEY, GT_NODES.

  LOOP AT <GFT_TREE_DATA> ASSIGNING <LF_TREE_DATA>.
    ASSIGN COMPONENT I_TREE_STR-KEYNM OF STRUCTURE <LF_TREE_DATA>
      TO <LF_CURID>.
*   Update key on tree to tree data
    ASSIGN COMPONENT GC_ATREE_TREEKEY OF STRUCTURE <LF_TREE_DATA>
      TO <LF_TREEKEY>.
    LW_KEY = LW_KEY + 1.
    <LF_TREEKEY>         = LW_KEY.
    CONDENSE <LF_TREEKEY>.
    LS_NODE-NODE_KEY  = <LF_TREEKEY>.
*   Update parents ID for successor
    LOOP AT <GFT_TREE_DATA> ASSIGNING <LF_TREE_CHILD>.
*     Get parents ID of tree data
      ASSIGN COMPONENT I_TREE_STR-KEYPR OF STRUCTURE <LF_TREE_CHILD>
        TO <LF_PARID>.
      CHECK <LF_PARID> = <LF_CURID>.

*     Update parents tree key
      ASSIGN COMPONENT GC_ATREE_TREEPRKEY OF STRUCTURE <LF_TREE_CHILD>
        TO <LF_TREEPRKEY>.
      <LF_TREEPRKEY> = <LF_TREEKEY>.
    ENDLOOP.
*   Get parents ID of tree data
    ASSIGN COMPONENT I_TREE_STR-KEYPR OF STRUCTURE <LF_TREE_DATA>
      TO <LF_PARID>.
*   Update parents if node is not root
    IF <LF_PARID> <> <LF_CURID>.
      READ TABLE <GFT_TREE_DATA> ASSIGNING <LF_TREE_PARENTS>
        WITH KEY (I_TREE_STR-KEYNM) = <LF_PARID>.
      IF SY-SUBRC IS INITIAL.
*       Get parents tree key
        ASSIGN COMPONENT GC_ATREE_TREEKEY OF STRUCTURE <LF_TREE_PARENTS>
          TO <LF_TREEPRKEY>.
        LS_NODE-RELATKEY  = <LF_TREEPRKEY>.
      ENDIF.
    ENDIF.
    LS_NODE-RELATSHIP = CL_GUI_SIMPLE_TREE=>RELAT_LAST_CHILD.
    PERFORM SET_ALV_TREE_NODE_LAYOUT
      USING   I_TREE_STR
              <LF_TREE_DATA>
     CHANGING LS_NODE_LAYOUT
              LS_NODE-TEXT.
    MOVE-CORRESPONDING LS_NODE_LAYOUT TO LS_NODE.

    APPEND LS_NODE TO GT_NODES.
  ENDLOOP.

  SORT GT_NODES BY RELATKEY NODE_KEY.
ENDFORM.                    " MAP_DATA_TO_NODE

*&---------------------------------------------------------------------*
*&      Form  CREATE_FIELDCATALOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_STRUCTURE_NAME  Structure name
*      -->LPT_FIELDCATALOG_IN Field catalog input
*      -->LPW_LASTCOL         Last column to display
*      -->LPW_BYPASSING_BUFFER Buffer to get catalog
*      <--LPT_FIELDCAT_OUT    Field catalog input
*----------------------------------------------------------------------*
FORM CREATE_FIELDCATALOG
  USING    LPW_STRUCTURE_NAME   TYPE TABNAME
           LPT_FIELDCATALOG_IN  TYPE LVC_T_FCAT
           LPW_LASTCOL          TYPE I
           LPW_BYPASSING_BUFFER TYPE XMARK
           LPW_SHOW_ERRBTN      TYPE XMARK
  CHANGING LPT_FIELDCAT_OUT     TYPE LVC_T_FCAT.
  DATA:
     LW_LASTCOL   TYPE I.
  FIELD-SYMBOLS:
     <LF_FIELDCAT> TYPE LVC_S_FCAT.

* Get fieldcat
  IF LPW_STRUCTURE_NAME IS NOT INITIAL
  AND LPT_FIELDCATALOG_IN[] IS INITIAL.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        I_STRUCTURE_NAME       = LPW_STRUCTURE_NAME
        I_INTERNAL_TABNAME     = LPW_STRUCTURE_NAME
        I_BYPASSING_BUFFER     = LPW_BYPASSING_BUFFER
      CHANGING
        CT_FIELDCAT            = LPT_FIELDCAT_OUT
      EXCEPTIONS
        INCONSISTENT_INTERFACE = 1
        PROGRAM_ERROR          = 2
        OTHERS                 = 3.
  ELSE.
    LPT_FIELDCAT_OUT[] = LPT_FIELDCATALOG_IN[].
  ENDIF.

  IF LPW_LASTCOL > 0.
    LW_LASTCOL = LPW_LASTCOL.
  ELSE.
    LW_LASTCOL = LINES( LPT_FIELDCAT_OUT ).
  ENDIF.

* Modify column to display
  LOOP AT LPT_FIELDCAT_OUT ASSIGNING <LF_FIELDCAT>
    WHERE COL_POS > LW_LASTCOL.
    <LF_FIELDCAT>-NO_OUT     = 'X'.
*      <LF_FIELDCAT>-F4AVAILABL = 'X'.
  ENDLOOP.

* Set column selected
  READ TABLE LPT_FIELDCAT_OUT ASSIGNING <LF_FIELDCAT>
    WITH KEY FIELDNAME = GC_SEL_COLUMN.
  IF SY-SUBRC IS INITIAL.
    <LF_FIELDCAT>-CHECKBOX    = GC_XMARK.
    <LF_FIELDCAT>-EDIT        = GC_XMARK.
  ENDIF.

* Set column detail
  READ TABLE LPT_FIELDCAT_OUT ASSIGNING <LF_FIELDCAT>
    WITH KEY FIELDNAME = GC_DETAIL_COLUMN.
  IF SY-SUBRC IS INITIAL.
    <LF_FIELDCAT>-STYLE       = CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
  ENDIF.

* Set column detail
  IF LPW_SHOW_ERRBTN IS NOT INITIAL.
    READ TABLE LPT_FIELDCAT_OUT ASSIGNING <LF_FIELDCAT>
*      WITH KEY FIELDNAME = GC_ERRDET_COLUMN.
      WITH KEY FIELDNAME = GC_MESSAGE_COLUMN.
    IF SY-SUBRC IS INITIAL.
      <LF_FIELDCAT>-STYLE       = CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
      <LF_FIELDCAT>-STYLE       = CL_GUI_ALV_GRID=>MC_STYLE_HOTSPOT.
    ENDIF.
  ENDIF.

ENDFORM.                    " CREATE_FIELDCATALOG

*&---------------------------------------------------------------------*
*&      Form  BUILD_ALV_TREE_OBJECTS_CUS_CON
*&---------------------------------------------------------------------*
*       Build ALV tree using custom container
*----------------------------------------------------------------------*
*      -->LPW_CUS_CONTROL_NAME  Container name
*----------------------------------------------------------------------*
FORM BUILD_ALV_TREE_OBJECTS_CUS_CON
  USING LPW_CUS_CONTROL_NAME  TYPE SCRFNAME
        LPW_REPID             TYPE SYREPID
        LPW_NODE_SEL_MODE     TYPE I
        LPW_ITEM_SELECTION    TYPE XMARK.
  DATA:
    LT_EVENTS    TYPE CNTL_SIMPLE_EVENTS,
    LS_EVENT     TYPE CNTL_SIMPLE_EVENT,
    LW_EXTENSION TYPE I.

  CREATE OBJECT GO_ALV_TREE_CUS_CON
    EXPORTING
      CONTAINER_NAME              = LPW_CUS_CONTROL_NAME
      REPID                       = LPW_REPID
      DYNNR                       = SY-DYNNR
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5
      OTHERS                      = 6.

* Create tree
  CREATE OBJECT GO_ALV_TREE
    EXPORTING
      PARENT              = GO_ALV_TREE_CUS_CON
      NODE_SELECTION_MODE = LPW_NODE_SEL_MODE
      ITEM_SELECTION      = LPW_ITEM_SELECTION
      NO_HTML_HEADER      = 'X'
    EXCEPTIONS
      OTHERS              = 1.

ENDFORM.                    " BUILD_ALV_TREE_OBJECTS_CUS_CON

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_TREE_EVENT
*&---------------------------------------------------------------------*
*       Set ALV tree event
*----------------------------------------------------------------------*
FORM SET_ALV_TREE_EVENT.
  DATA:
    LT_EVENTS TYPE CNTL_SIMPLE_EVENTS,
    LS_EVENT  TYPE CNTL_SIMPLE_EVENT.

* Add events
  LS_EVENT-EVENTID = CL_GUI_SIMPLE_TREE=>EVENTID_NODE_DOUBLE_CLICK.
  LS_EVENT-APPL_EVENT = 'X'. " process PAI if event occurs
  APPEND LS_EVENT TO LT_EVENTS.

  LS_EVENT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_NODE_CONTEXT_MENU_REQ.
  APPEND LS_EVENT TO LT_EVENTS.
  LS_EVENT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_ITEM_CONTEXT_MENU_REQ.
  APPEND LS_EVENT TO LT_EVENTS.
  LS_EVENT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_HEADER_CONTEXT_MEN_REQ.
  APPEND LS_EVENT TO LT_EVENTS.
  LS_EVENT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_EXPAND_NO_CHILDREN.
  APPEND LS_EVENT TO LT_EVENTS.
  LS_EVENT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_HEADER_CLICK.
  APPEND LS_EVENT TO LT_EVENTS.
  LS_EVENT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_ITEM_KEYPRESS.
  APPEND LS_EVENT TO LT_EVENTS.
  LS_EVENT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_ITEM_DOUBLE_CLICK.
  APPEND LS_EVENT TO LT_EVENTS.
  LS_EVENT-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_BUTTON_CLICK.
  APPEND LS_EVENT TO LT_EVENTS.

  CALL METHOD GO_ALV_TREE->SET_REGISTERED_EVENTS
    EXPORTING
      EVENTS                    = LT_EVENTS
    EXCEPTIONS
      CNTL_ERROR                = 1
      CNTL_SYSTEM_ERROR         = 2
      ILLEGAL_EVENT_COMBINATION = 3.

  CALL METHOD GO_ALV_TREE->COLUMN_OPTIMIZE.
*  CALL METHOD GO_ALV_TREE->COLLAPSE_ALL_NODES.
  CALL METHOD GO_ALV_TREE->FRONTEND_UPDATE.
  CALL METHOD CL_GUI_CFW=>FLUSH. "Comment

ENDFORM.                    " SET_ALV_TREE_EVENT

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_TREE_NODE_LAYOUT
*&---------------------------------------------------------------------*
*       Set node layout
*----------------------------------------------------------------------*
*      -->LPS_NODE_DATA   Node data
*      <--LPS_NODE_LAYOUT Node layout
*      <--LPW_NODE_TEXT   Node text
*----------------------------------------------------------------------*
FORM SET_ALV_TREE_NODE_LAYOUT
  USING   LPS_TREE_STR      TYPE ZST_TREE_STR
          LPS_NODE_DATA     TYPE ANY
 CHANGING LPS_NODE_LAYOUT   TYPE LVC_S_LAYN
          LPW_NODE_TEXT     TYPE ANY."LVC_VALUE.
  DATA:
    LT_ITEM_LAYOUT TYPE LVC_T_LAYI,
    LS_ITEM_LAYOUT TYPE LVC_S_LAYI.
* Set default
  LPS_NODE_LAYOUT-ISFOLDER   = GC_XMARK.

  CALL FUNCTION 'ZFM_DATA_GET_COMPONENT'
    EXPORTING
      I_COMPONENT_NAME  = GC_ATREE_NLAYOUT
      I_STRUCTURE       = LPS_NODE_DATA
    IMPORTING
      E_COMPONENT_VALUE = LPS_NODE_LAYOUT.

* Get Node text
  IF LPS_TREE_STR-FTEXT IS INITIAL.
    CALL FUNCTION 'ZFM_DATA_GET_COMPONENT'
      EXPORTING
        I_COMPONENT_NAME  = GC_ATREE_TREETEXT
        I_STRUCTURE       = LPS_NODE_DATA
      IMPORTING
        E_COMPONENT_VALUE = LPW_NODE_TEXT.
  ELSE.
    CALL FUNCTION 'ZFM_DATA_GET_COMPONENT'
      EXPORTING
        I_COMPONENT_NAME  = LPS_TREE_STR-FTEXT
        I_STRUCTURE       = LPS_NODE_DATA
      IMPORTING
        E_COMPONENT_VALUE = LPW_NODE_TEXT.
  ENDIF.

ENDFORM.                    " SET_ALV_TREE_NODE_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  SET_ALV_TREE_ITEM_LAYOUT
*&---------------------------------------------------------------------*
*       Set item layout for ALV
*----------------------------------------------------------------------*
*      -->LPS_NODE_DATA   Node data
*      <--LPT_ITEM_LAYOUT Item layout
*----------------------------------------------------------------------*
FORM SET_ALV_TREE_ITEM_LAYOUT
  USING    LPS_NODE_DATA   TYPE ANY
  CHANGING LPT_ITEM_LAYOUT TYPE LVC_T_LAYI.

  DATA:
    LS_ITEM_LAYOUT    TYPE LVC_S_LAYI.
  FIELD-SYMBOLS:
    <LF_VALUE>        TYPE ANY.

  CLEAR: LPT_ITEM_LAYOUT.
  ASSIGN COMPONENT GC_DETAIL_COLUMN OF STRUCTURE LPS_NODE_DATA
    TO <LF_VALUE>.
  IF SY-SUBRC IS INITIAL AND <LF_VALUE> IS NOT INITIAL.
    LS_ITEM_LAYOUT-FIELDNAME  = GC_DETAIL_COLUMN.
*    LS_ITEM_LAYOUT-T_IMAGE    = TEXT-01.
    LS_ITEM_LAYOUT-CLASS      = CL_ITEM_TREE_CONTROL=>ITEM_CLASS_BUTTON.
    LS_ITEM_LAYOUT-STYLE      = CL_GUI_COLUMN_TREE=>STYLE_DEFAULT.
    APPEND LS_ITEM_LAYOUT TO LPT_ITEM_LAYOUT.
  ENDIF.

*  LS_ITEM_LAYOUT-T_IMAGE    = 'BNONE'.
*  LS_ITEM_LAYOUT-EDITABLE   = 'X'.
*  LS_ITEM_LAYOUT-CLASS      = CL_ITEM_TREE_CONTROL=>ITEM_CLASS_BUTTON.
*  LS_ITEM_LAYOUT-FIELDNAME  = GO_ALV_TREE->C_HIERARCHY_COLUMN_NAME.
*  LS_ITEM_LAYOUT-STYLE      = CL_GUI_COLUMN_TREE=>STYLE_DEFAULT.
*  APPEND LS_ITEM_LAYOUT TO LT_ITEM_LAYOUT.

ENDFORM.                    " SET_ALV_TREE_ITEM_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  SET_DISABLE_ALV_ROW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IS_LAYOUT  text
*      <--P_IT_OUTTAB  text
*----------------------------------------------------------------------*
FORM SET_DISABLE_ALV_ROW
  USING    LPS_LAYOUT TYPE LVC_S_LAYO
  CHANGING LPT_OUTTAB TYPE ANY TABLE.

  DATA:
    LR_DATA  TYPE REF TO DATA,
    LS_STYLE TYPE LVC_S_STYL.
  FIELD-SYMBOLS:
    <LF_LINE_REC> TYPE ANY,
    <LF_ERRDET>   TYPE ANY,
    <LF_DISABLE>  TYPE XMARK,
    <LFT_STYLE>   TYPE LVC_T_STYL,
    <LF_STYLE>    TYPE LVC_S_STYL.

* Check structure has field style
  CHECK LPS_LAYOUT-STYLEFNAME IS NOT INITIAL.

* Create line of display table
  CREATE DATA LR_DATA LIKE LINE OF LPT_OUTTAB.
  ASSIGN LR_DATA->* TO <LF_LINE_REC>.

  LOOP AT LPT_OUTTAB ASSIGNING <LF_LINE_REC>.
*   Set disable
    ASSIGN COMPONENT GC_DISABLE_COLUMN OF STRUCTURE <LF_LINE_REC>
      TO <LF_DISABLE>.
    IF SY-SUBRC IS INITIAL
    AND <LF_DISABLE> = GC_XMARK.
      ASSIGN COMPONENT LPS_LAYOUT-STYLEFNAME OF STRUCTURE <LF_LINE_REC>
        TO <LFT_STYLE>.
      IF SY-SUBRC IS INITIAL.
        READ TABLE <LFT_STYLE> ASSIGNING <LF_STYLE>
          WITH KEY FIELDNAME = GC_SEL_COLUMN.
        IF SY-SUBRC IS INITIAL.
          <LF_STYLE>-STYLE    = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
        ELSE.
          LS_STYLE-FIELDNAME  = GC_SEL_COLUMN.
          LS_STYLE-STYLE      = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED.
          INSERT LS_STYLE INTO TABLE <LFT_STYLE>.
        ENDIF.
      ENDIF.
    ENDIF.

**   Set DS loi
*    ASSIGN COMPONENT GC_ERRDET_COLUMN OF STRUCTURE <LF_LINE_REC>
*      TO <LF_ERRDET>.
*    IF SY-SUBRC IS INITIAL.
*      <LF_ERRDET> = TEXT-CDE.
*    ENDIF.
  ENDLOOP.
ENDFORM.                    " SET_DISABLE_ALV_ROW

*&---------------------------------------------------------------------*
*&      Form  SHOW_ALV_TOTAL_RECORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPT_OUTTAB  Output table
*----------------------------------------------------------------------*
FORM SHOW_ALV_TOTAL_RECORD
  USING    LPT_OUTTAB TYPE TABLE.
  DATA:
    LW_SELECT_REC    TYPE CHAR10,
    LW_TOTAL_REC     TYPE CHAR10,
    LW_TOTAL_HIDE    TYPE CHAR10,
    LW_TOTAL_FILETER TYPE CHAR10,
    LT_FILTER        TYPE LVC_T_FIDX.
  FIELD-SYMBOLS:
    <LF_DATA_REC> TYPE ANY,
    <LF_SELECT>   TYPE XMARK.

*  DESCRIBE TABLE LPT_OUTTAB LINES LW_TOTAL_REC.
*  SHIFT LW_TOTAL_REC LEFT DELETING LEADING '0'.
*
*  MESSAGE S004(ZMS_COL_LIB) WITH LW_TOTAL_REC.
**********************************************************************
  CLEAR: LW_SELECT_REC.
  CHECK <GT_ALV_DATA> IS ASSIGNED.
  LOOP AT <GT_ALV_DATA> ASSIGNING <LF_DATA_REC>.
    ASSIGN COMPONENT GC_SEL_COLUMN OF STRUCTURE <LF_DATA_REC>
      TO <LF_SELECT>.
    IF SY-SUBRC IS INITIAL AND <LF_SELECT> = GC_XMARK.
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

  CONDENSE: LW_SELECT_REC, LW_TOTAL_FILETER, LW_TOTAL_REC, LW_TOTAL_HIDE.

  IF LW_SELECT_REC = '0' AND LT_FILTER IS INITIAL.
    MESSAGE S004(ZMS_COL_LIB) WITH LW_TOTAL_REC.
  ELSE.
    MESSAGE S005(ZMS_COL_LIB)
      WITH LW_SELECT_REC LW_TOTAL_FILETER LW_TOTAL_REC.
  ENDIF.

ENDFORM.                    " SHOW_ALV_TOTAL_RECORD

*&---------------------------------------------------------------------*
*&      Form  SHOW_ALV_TOTAL_RECORD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPT_OUTTAB  Output table
*----------------------------------------------------------------------*
FORM SHOW_ALV_SELECT_RECORD.
  DATA:
    LW_SELECT_REC    TYPE CHAR10,
    LW_TOTAL_REC     TYPE CHAR10,
    LW_TOTAL_HIDE    TYPE CHAR10,
    LW_TOTAL_FILETER TYPE CHAR10,
    LT_FILTER        TYPE LVC_T_FIDX.
  FIELD-SYMBOLS:
    <LF_DATA_REC> TYPE ANY,
    <LF_SELECT>   TYPE XMARK.

  CALL METHOD GO_ALV_GRID->CHECK_CHANGED_DATA.
  CLEAR: LW_SELECT_REC.
  CHECK <GT_ALV_DATA> IS ASSIGNED.
  LOOP AT <GT_ALV_DATA> ASSIGNING <LF_DATA_REC>.
    ASSIGN COMPONENT GC_SEL_COLUMN OF STRUCTURE <LF_DATA_REC>
      TO <LF_SELECT>.
    IF SY-SUBRC IS INITIAL AND <LF_SELECT> = GC_XMARK.
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

ENDFORM.                    " SHOW_ALV_TOTAL_RECORD

*&---------------------------------------------------------------------*
*&      Form  ALV_SET_VARIANT_LAYOUT
*&---------------------------------------------------------------------*
*       Default layout and variant
*----------------------------------------------------------------------*
*      -->LPS_LAYOUT    Layout
*      -->LPS_VARIANT   Variant
*----------------------------------------------------------------------*
FORM ALV_SET_VARIANT_LAYOUT
  CHANGING LPS_LAYOUT   TYPE LVC_S_LAYO
           LPS_VARIANT  TYPE DISVARIANT
           LPS_SAVE     TYPE CHAR01.

  IF LPS_LAYOUT IS INITIAL.
    LPS_LAYOUT-CWIDTH_OPT = 'X'.
    IF LPS_LAYOUT-SEL_MODE IS INITIAL.
      LPS_LAYOUT-SEL_MODE = 'D'.
    ENDIF.
  ENDIF.

  IF LPS_VARIANT IS INITIAL.
    LPS_VARIANT-REPORT = SY-CPROG.
  ENDIF.

  IF SY-UNAME NS '.'. "= 'TUANBA' OR SY-UNAME = 'HOAVD7' .
    LPS_SAVE = 'A'.
  ENDIF.
ENDFORM.                    " ALV_SET_VARIANT_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  HANDLE_BUTTON_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_COLUMN_ID  text
*      -->LPS_ROW_NO  text
*----------------------------------------------------------------------*
FORM HANDLE_BUTTON_CLICK
  USING   LPS_COLUMN_ID   TYPE LVC_S_COL
          LPS_ROW_NO      TYPE LVC_S_ROID.

*  IF LPS_COLUMN_ID-FIELDNAME <> GC_ERRDET_COLUMN
  IF LPS_COLUMN_ID-FIELDNAME <> GC_MESSAGE_COLUMN.
    IF GW_CALLBACK_PROGRAM IS NOT INITIAL
    AND GW_CALLBACK_BUTTON_CLICK IS NOT INITIAL.
      PERFORM (GW_CALLBACK_BUTTON_CLICK)
        IN PROGRAM (GW_CALLBACK_PROGRAM) IF FOUND
        USING LPS_COLUMN_ID
              LPS_ROW_NO.
    ENDIF.
    RETURN.
  ENDIF.

ENDFORM.                    " HANDLE_BUTTON_CLICK

*&---------------------------------------------------------------------*
*&      Form  HANDLE_LINK_CLICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_ROW_ID  text
*      -->LPS_COLUMN_ID  text
*      -->LPS_ROW_NO  text
*----------------------------------------------------------------------*
FORM HANDLE_LINK_CLICK
  USING LPS_ROW_ID    TYPE LVC_S_ROW
        LPS_COLUMN_ID	TYPE LVC_S_COL
        LPS_ROW_NO    TYPE LVC_S_ROID .

  DATA:
    LS_MESSAGE_CURRENT TYPE ZST_ALV_INF_INCL,
    LS_VARIANT         TYPE DISVARIANT.
  FIELD-SYMBOLS:
    <LF_SELECTED> TYPE ANY,
    <LF_MSGKEY>   TYPE ANY.

  IF LPS_COLUMN_ID-FIELDNAME <> GC_MESSAGE_COLUMN.
    IF GW_CALLBACK_PROGRAM IS NOT INITIAL
    AND GW_CALLBACK_HOSPOT_CLICK IS NOT INITIAL.
      PERFORM (GW_CALLBACK_HOSPOT_CLICK)
        IN PROGRAM (GW_CALLBACK_PROGRAM) IF FOUND
        USING LPS_COLUMN_ID
              LPS_ROW_NO.
    ENDIF.
    RETURN.
  ENDIF.

* Read Row chose
  READ TABLE <GT_ALV_DATA> ASSIGNING <LF_SELECTED>
      INDEX LPS_ROW_NO-ROW_ID.
  CHECK SY-SUBRC IS INITIAL.
  MOVE-CORRESPONDING <LF_SELECTED> TO LS_MESSAGE_CURRENT.
  CHECK LS_MESSAGE_CURRENT-MSGDETAIL IS NOT INITIAL.

  LS_VARIANT-REPORT   = GC_ALV_MSG_PROG.
  LS_VARIANT-HANDLE   = GC_ALV_MSG_HANDL.
  CALL FUNCTION 'ZFM_ALV_DISPLAY'
    EXPORTING
      I_GRID_TITLE     = TEXT-004
      I_STRUCTURE_NAME = 'ZST_ALV_MSG_DETAIL'
      IS_VARIANT       = LS_VARIANT
    TABLES
      T_OUTTAB         = LS_MESSAGE_CURRENT-MSGDETAIL.


ENDFORM.                    " HANDLE_LINK_CLICK

*&---------------------------------------------------------------------*
*&      Form  ALV_SET_HIDE_FILTER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ALV_SET_HIDE_FILTER.
  DATA:
    LS_LAYOUT   TYPE LVC_S_LAYO,
    LT_FILTER   TYPE LVC_T_FILT,
    LS_FILTER   TYPE LVC_S_FILT,
    LS_ALV_INCL TYPE ZST_ALV_INF_INCL,
    LW_NOTNULL  TYPE XMARK..
  FIELD-SYMBOLS:
    <LF_ALV_DATA>   TYPE ANY.

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

ENDFORM.                    " ALV_SET_HIDE_FILTER

*&---------------------------------------------------------------------*
*&      Form  ALV_SHOW_ERROR_LINES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ALV_SHOW_ERROR_LINES .
  DATA:
    LS_LAYOUT TYPE LVC_S_LAYO,
    LT_FILTER TYPE LVC_T_FILT.

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

    LS_LAYOUT-CWIDTH_OPT    = GC_XMARK.
    CALL METHOD GO_ALV_GRID->SET_FRONTEND_LAYOUT
      EXPORTING
        IS_LAYOUT = LS_LAYOUT.

    CALL METHOD GO_ALV_GRID->REFRESH_TABLE_DISPLAY.
  ELSE.
    PERFORM ALV_SET_HIDE_FILTER.
  ENDIF.


ENDFORM.                    " ALV_SHOW_ERROR_LINES

*&---------------------------------------------------------------------*
*&      Form  CREATE_CHART_OBJECTS
*&---------------------------------------------------------------------*
*       Create objects
*----------------------------------------------------------------------*
FORM CREATE_CHART_OBJECTS
  USING LPW_ON_CALL           TYPE XMARK
        LPW_EXTENSION         TYPE I
        LPW_SIDE              TYPE I
        LPW_CUS_CONTROL_NAME  TYPE SCRFNAME
        LPW_CPROG             TYPE CPROG
        LPW_DYNNR             TYPE DYNNR.
  DATA:
    LW_EXTENSION TYPE I,
    LW_CPROG     TYPE CPROG,
    LW_DYNNR     TYPE DYNNR.

  IF LPW_ON_CALL IS INITIAL.
    LW_CPROG = SY-REPID.
    LW_DYNNR = '0100'.
  ELSE.
    IF LPW_CPROG IS NOT INITIAL.
      LW_CPROG = LPW_CPROG.
    ELSE.
      LW_CPROG = SY-CPROG.
    ENDIF.

    IF LPW_DYNNR IS NOT INITIAL.
      LW_DYNNR = LPW_DYNNR.
    ELSE.
      LW_DYNNR = SY-DYNNR.
    ENDIF.
  ENDIF.

  LW_EXTENSION = LPW_EXTENSION.
  IF LPW_EXTENSION IS INITIAL.
    LW_EXTENSION = 500.
  ENDIF.

  FREE: GO_CHART_DOCKING, GO_CHART_CONTAINER, GO_CHART_ENGINE.
  IF LPW_CUS_CONTROL_NAME IS INITIAL.
*   Create Docking container
    CREATE OBJECT GO_CHART_DOCKING
      EXPORTING
        REPID                       = LW_CPROG
        DYNNR                       = LW_DYNNR
        SIDE                        = LPW_SIDE
        EXTENSION                   = LW_EXTENSION
        NO_AUTODEF_PROGID_DYNNR     = 'X'
      EXCEPTIONS
        CNTL_ERROR                  = 1
        CNTL_SYSTEM_ERROR           = 2
        CREATE_ERROR                = 3
        LIFETIME_ERROR              = 4
        LIFETIME_DYNPRO_DYNPRO_LINK = 5
        OTHERS                      = 6.

*   Create Grid
    CREATE OBJECT GO_CHART_ENGINE
      EXPORTING
        PARENT = GO_CHART_DOCKING.
  ELSE.
    CREATE OBJECT GO_CHART_CONTAINER
      EXPORTING
        CONTAINER_NAME              = LPW_CUS_CONTROL_NAME
        REPID                       = LW_CPROG
        DYNNR                       = LW_DYNNR
      EXCEPTIONS
        CNTL_ERROR                  = 1
        CNTL_SYSTEM_ERROR           = 2
        CREATE_ERROR                = 3
        LIFETIME_ERROR              = 4
        LIFETIME_DYNPRO_DYNPRO_LINK = 5
        OTHERS                      = 6.

*   Create Grid
    CREATE OBJECT GO_CHART_ENGINE
      EXPORTING
        PARENT = GO_CHART_CONTAINER.

  ENDIF.

  CREATE OBJECT GO_CHART_HANDLE.
  SET HANDLER GO_CHART_HANDLE->HANDLE_PROPERTY_CHANGE
    FOR GO_CHART_ENGINE.

ENDFORM.                    " CREATE_CHART_OBJECTS

*---------------------------------------------------------------------*
*      Form  CHART_DATA_CREATE_XML
*---------------------------------------------------------------------*
*      -->LPO_IXML_DOC  text
*      -->LPS_CHART_CONF  text
*      -->LPT_TABDATA  text
*----------------------------------------------------------------------*
FORM CHART_DATA_CREATE_XML
  USING LPS_CHART_CONF        TYPE ZST_BM_CHART_CONF
        LPT_TABDATA           TYPE STANDARD TABLE
  CHANGING LW_XSTR            TYPE XSTRING.

  DATA:
    LO_IXML            TYPE REF TO IF_IXML,
    LO_IXML_SF         TYPE REF TO IF_IXML_STREAM_FACTORY,
    LO_IXML_DOC        TYPE REF TO IF_IXML_DOCUMENT,
    LO_SIMPLECHARTDATA TYPE REF TO IF_IXML_ELEMENT,
    LO_CATEGORIES      TYPE REF TO IF_IXML_ELEMENT,
    LO_SERIES          TYPE REF TO IF_IXML_ELEMENT,
    LO_ELEMENT         TYPE REF TO IF_IXML_ELEMENT,
    LO_ENCODING        TYPE REF TO IF_IXML_ENCODING,
    LS_SERI_LAYO       TYPE ZST_BM_CHA_LAYO_SERI,
    LW_VALUE           TYPE STRING,
    LO_OSTREAM         TYPE REF TO IF_IXML_OSTREAM.
  FIELD-SYMBOLS:
    <LF_VALUE>  TYPE ANY,
    <LF_RECORD> TYPE ANY.

* Create global objects
  IF LO_IXML IS INITIAL.
    LO_IXML = CL_IXML=>CREATE( ).
    LO_IXML_SF = LO_IXML->CREATE_STREAM_FACTORY( ).
  ENDIF.

  LO_IXML_DOC = LO_IXML->CREATE_DOCUMENT( ).
* Set encoding to UTF-8
  LO_ENCODING = LO_IXML->CREATE_ENCODING(
                BYTE_ORDER = IF_IXML_ENCODING=>CO_LITTLE_ENDIAN
                CHARACTER_SET = 'utf-8' ).
  LO_IXML_DOC->SET_ENCODING( LO_ENCODING ).
* Populate Chart Data
  LO_SIMPLECHARTDATA = LO_IXML_DOC->CREATE_SIMPLE_ELEMENT(
               NAME = 'SimpleChartData' PARENT = LO_IXML_DOC ).
* Populate X-Axis Values i.e. Categories and Series
  LO_CATEGORIES = LO_IXML_DOC->CREATE_SIMPLE_ELEMENT(
            NAME = 'Categories' PARENT = LO_SIMPLECHARTDATA ).

  LW_VALUE = LPS_CHART_CONF-GLOBAL-TITLE.
  LO_CATEGORIES->SET_ATTRIBUTE( NAME = 'label'
                            VALUE = LW_VALUE ).

* Here you can populate the category labels. First you need
* to create all the labels and only then you can populate
* values for these labels.
  LOOP AT LPT_TABDATA ASSIGNING <LF_RECORD>.
    LO_ELEMENT = LO_IXML_DOC->CREATE_SIMPLE_ELEMENT(
                NAME = 'C' PARENT = LO_CATEGORIES ).
    ASSIGN COMPONENT LPS_CHART_CONF-CAT_LAYO-CAT_FIELD
      OF STRUCTURE <LF_RECORD> TO <LF_VALUE>.
    IF SY-SUBRC IS INITIAL.
      LW_VALUE = <LF_VALUE>.
*     Populate the category value which you want to display here.
*     This will appear in the X-axis.
      LO_ELEMENT->IF_IXML_NODE~SET_VALUE( LW_VALUE ).
      CLEAR LW_VALUE.
    ENDIF.
  ENDLOOP.

  LOOP AT LPS_CHART_CONF-SERI_LAYO INTO LS_SERI_LAYO.
*   Create an element for Series and then populate it's values.
    LO_SERIES = LO_IXML_DOC->CREATE_SIMPLE_ELEMENT(
              NAME = 'Series' PARENT = LO_SIMPLECHARTDATA ).

    IF LS_SERI_LAYO-SERI_TITLE IS INITIAL.
      LS_SERI_LAYO-SERI_TITLE = LS_SERI_LAYO-SERI_FIELD.
    ENDIF.
    LW_VALUE = LS_SERI_LAYO-SERI_TITLE.

*   You can set your own label for X-Axis here e.g. Airline
    LO_SERIES->SET_ATTRIBUTE( NAME = 'label'
                              VALUE = LW_VALUE ).
    LW_VALUE = LS_SERI_LAYO-SERI_FIELD.
    LO_SERIES->SET_ATTRIBUTE( NAME = 'customizing'
                             VALUE = LW_VALUE ).
    LOOP AT LPT_TABDATA ASSIGNING <LF_RECORD>.
      LO_ELEMENT = LO_IXML_DOC->CREATE_SIMPLE_ELEMENT(
                  NAME = 'S' PARENT = LO_SERIES ).
*     Populate the Value for each category you want to display from
*     your internal table.
      ASSIGN COMPONENT LS_SERI_LAYO-SERI_FIELD OF STRUCTURE <LF_RECORD>
        TO <LF_VALUE>.
      IF SY-SUBRC IS INITIAL.
        LW_VALUE = <LF_VALUE>.
*       Populate the category value which you want to display here.
*       This will appear in the X-axis.
        LO_ELEMENT->IF_IXML_NODE~SET_VALUE( LW_VALUE ).
        CLEAR LW_VALUE.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

* Init stream x-string
  LO_OSTREAM = LO_IXML_SF->CREATE_OSTREAM_XSTRING( LW_XSTR ).

*   Render Chart Data
  CALL METHOD LO_IXML_DOC->RENDER
    EXPORTING
      OSTREAM = LO_OSTREAM.

  IF 1 = 2.
    CALL FUNCTION 'ECATT_CONV_XSTRING_TO_STRING'
      EXPORTING
        IM_XSTRING = LW_XSTR
      IMPORTING
        EX_STRING  = LW_VALUE.
  ENDIF.

ENDFORM.                    " CHART_DATA_CREATE_XML

*&---------------------------------------------------------------------*
*&      Form  CREATE_XML_CHART_CUSTOMIZING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_XSTR  Customizing xstring
*----------------------------------------------------------------------*
FORM CREATE_XML_CHART_CUSTOMIZING
  CHANGING LPW_XSTR     TYPE XSTRING.
  DATA:
    LO_IXML            TYPE REF TO IF_IXML,
    LO_IXML_SF         TYPE REF TO IF_IXML_STREAM_FACTORY,
    LO_IXML_CUSTOM_DOC TYPE REF TO IF_IXML_DOCUMENT,
    LO_OSTREAM         TYPE REF TO IF_IXML_OSTREAM,
    LO_ROOT            TYPE REF TO IF_IXML_ELEMENT,
    LO_GLOBALSETTINGS  TYPE REF TO IF_IXML_ELEMENT,
    LO_DEFAULT         TYPE REF TO IF_IXML_ELEMENT,
    LO_ELEMENTS        TYPE REF TO IF_IXML_ELEMENT,
    LO_CHARTELEMENTS   TYPE REF TO IF_IXML_ELEMENT,
    LO_TITLE           TYPE REF TO IF_IXML_ELEMENT,
    LO_ELEMENT         TYPE REF TO IF_IXML_ELEMENT,
    LO_ENCODING        TYPE REF TO IF_IXML_ENCODING,
    LW_VALUE           TYPE STRING.

* Create global objects
  IF LO_IXML IS INITIAL.
    LO_IXML = CL_IXML=>CREATE( ).
    LO_IXML_SF = LO_IXML->CREATE_STREAM_FACTORY( ).
  ENDIF.

* Init
  LO_IXML_CUSTOM_DOC = LO_IXML->CREATE_DOCUMENT( ).

  PERFORM CHART_LAYOUT_GENERATE
    CHANGING GS_BM_CHART_CONF.

* Encoding UTF-8
  LO_ENCODING = LO_IXML->CREATE_ENCODING(
    BYTE_ORDER = IF_IXML_ENCODING=>CO_LITTLE_ENDIAN
    CHARACTER_SET = 'utf-8' ).
  LO_IXML_CUSTOM_DOC->SET_ENCODING( LO_ENCODING ).

* Header
  LO_ROOT = LO_IXML_CUSTOM_DOC->CREATE_SIMPLE_ELEMENT(
            NAME = 'SAPChartCustomizing' PARENT = LO_IXML_CUSTOM_DOC ).
  LO_ROOT->SET_ATTRIBUTE( NAME = 'version' VALUE = '1.1' ).
  LO_GLOBALSETTINGS = LO_IXML_CUSTOM_DOC->CREATE_SIMPLE_ELEMENT(
            NAME = 'GlobalSettings' PARENT = LO_ROOT ).

* File type -PNG
  LO_ELEMENT = LO_IXML_CUSTOM_DOC->CREATE_SIMPLE_ELEMENT(
              NAME = 'FileType' PARENT = LO_GLOBALSETTINGS ).
  LO_ELEMENT->IF_IXML_NODE~SET_VALUE( 'PNG' ).
  LO_ELEMENT->IF_IXML_NODE~SET_VALUE( 'BMP' ).

* Set dimension
  LO_ELEMENT = LO_IXML_CUSTOM_DOC->CREATE_SIMPLE_ELEMENT(
            NAME = 'Dimension' PARENT = LO_GLOBALSETTINGS ).
* PseudoTwo/Two, PseudoThree, Three
  LO_ELEMENT->IF_IXML_NODE~SET_VALUE( GS_BM_CHART_CONF-DIMENSION_TX ).

* Set chart type
  LO_ELEMENT = LO_IXML_CUSTOM_DOC->CREATE_SIMPLE_ELEMENT(
              NAME = 'ChartType' PARENT = LO_GLOBALSETTINGS ).
* Lines, StackedLines, Profiles, StackedProfiles, Bars, StackedBars,
* Columns, StackedColumns, Area, StackedArea, ProfileArea,
* StackedProfileArea, Pie,Doughnut, SplitPie, Polar,  Radar,
* StackedRadar, Speedometer, DeltaChart.
  LO_ELEMENT->IF_IXML_NODE~SET_VALUE( GS_BM_CHART_CONF-CHARTTYPE_TX ).

* Set font
  LO_ELEMENT = LO_IXML_CUSTOM_DOC->CREATE_SIMPLE_ELEMENT(
            NAME = 'FontFamily' PARENT = LO_DEFAULT ).
  LO_ELEMENT->IF_IXML_NODE~SET_VALUE( 'Arial' ).

* Set title
  LO_ELEMENTS = LO_IXML_CUSTOM_DOC->CREATE_SIMPLE_ELEMENT(
            NAME = 'Elements' PARENT = LO_ROOT ).
  LO_CHARTELEMENTS = LO_IXML_CUSTOM_DOC->CREATE_SIMPLE_ELEMENT(
            NAME = 'ChartElements' PARENT = LO_ELEMENTS ).
  LO_TITLE = LO_IXML_CUSTOM_DOC->CREATE_SIMPLE_ELEMENT(
            NAME = 'Title' PARENT = LO_CHARTELEMENTS ).
* Give the desired caption for the chart here
  LO_ELEMENT = LO_IXML_CUSTOM_DOC->CREATE_SIMPLE_ELEMENT(
                NAME = 'Caption' PARENT = LO_TITLE ).
  LW_VALUE = GS_BM_CHART_CONF-GLOBAL-TITLE.
  LO_ELEMENT->IF_IXML_NODE~SET_VALUE( LW_VALUE ).

* Init x-string
  LO_OSTREAM = LO_IXML_SF->CREATE_OSTREAM_XSTRING( LPW_XSTR ).

* Render Customizing Data
  CALL METHOD LO_IXML_CUSTOM_DOC->RENDER
    EXPORTING
      OSTREAM = LO_OSTREAM.

ENDFORM.                    " CREATE_XML_CHART_CUSTOMIZING

*&---------------------------------------------------------------------*
*&      Form  0100_PROCESS_FC_DESIGN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0100_PROCESS_FC_DESIGN .
  DATA:
    LO_WIN_CHART        TYPE REF TO CL_GUI_CHART_ENGINE_WIN.

  CATCH SYSTEM-EXCEPTIONS MOVE_CAST_ERROR = 1.
    LO_WIN_CHART ?= GO_CHART_ENGINE->GET_CONTROL( ).
  ENDCATCH.
  IF SY-SUBRC IS INITIAL.
    IF GS_BM_CHART_CONF-GLOBAL-DESIGN_MODE IS INITIAL.
      GS_BM_CHART_CONF-GLOBAL-DESIGN_MODE   = 'X'.
      ZST_BM_CHART_LAYO_GLOBAL-DESIGN_MODE  = 'X'.
    ELSE.
      GS_BM_CHART_CONF-GLOBAL-DESIGN_MODE   = ' '.
      ZST_BM_CHART_LAYO_GLOBAL-DESIGN_MODE  = ' '.
    ENDIF.

    LO_WIN_CHART->SET_DESIGN_MODE(
      FLAG = GS_BM_CHART_CONF-GLOBAL-DESIGN_MODE
      EVENT = 'X' ).
*    LO_WIN_CHART->RESTRICT_CHART_TYPES(
*      CHARTTYPES = 'Columns|Lines' ).
*    LO_WIN_CHART->RESTRICT_PROPERTY_EVENTS(
*      EVENTS = 'ChartType' ).
  ENDIF.
ENDFORM.                    " 0100_PROCESS_FC_DESIGN

*&---------------------------------------------------------------------*
*&      Form  CHART_BIND_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_CHART_CONF  text
*      -->LPT_TABDATA  text
*      <--LPO_CHART_ENGINE  text
*----------------------------------------------------------------------*
FORM CHART_BIND_DATA
  USING LPS_CHART_CONF        TYPE ZST_BM_CHART_CONF
        LPT_TABDATA           TYPE STANDARD TABLE
  CHANGING LPO_CHART_ENGINE   TYPE REF TO CL_GUI_CHART_ENGINE.
  DATA:
    LW_XSTR            TYPE XSTRING.

  IF 1 = 2.
*   Create XML data using data in internal table.
    PERFORM CHART_DATA_CREATE_XML
      USING LPS_CHART_CONF
            LPT_TABDATA
      CHANGING LW_XSTR.
  ELSE.
    PERFORM CHART_STD_DATA_CREATE_XML
      USING LPS_CHART_CONF
            LPT_TABDATA
      CHANGING LW_XSTR.
  ENDIF.

* Bind xml data to chart
  LPO_CHART_ENGINE->SET_DATA( XDATA = LW_XSTR ).

ENDFORM.                    " CHART_BIND_DATA

*&---------------------------------------------------------------------*
*&      Form  CHART_STD_BIND_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_CHART_CONF  text
*      -->LPT_TABDATA  text
*      <--LPO_CHART_ENGINE  text
*----------------------------------------------------------------------*
FORM CHART_STD_BIND_DATA
  USING LPS_CHART_CONF        TYPE ZST_BM_CHART_CONF
        LPT_TABDATA           TYPE STANDARD TABLE
  CHANGING LPO_CHART_ENGINE   TYPE REF TO CL_GUI_CHART_ENGINE.
  DATA:
    LW_XSTR            TYPE XSTRING.

* Create XML xstring to bind
  PERFORM CHART_STD_DATA_CREATE_XML
    USING LPS_CHART_CONF
          LPT_TABDATA
    CHANGING LW_XSTR.
  GW_CHART_XDATA = LW_XSTR.

* Bind xml data to chart
  LPO_CHART_ENGINE->SET_DATA( XDATA = LW_XSTR ).

ENDFORM.                    " CHART_STD_BIND_DATA

*&---------------------------------------------------------------------*
*&      Form  CHART_CHANGE_CUSTOMIZE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_CHART_CONF  text
*      <--LPO_CHART_ENGINE  text
*----------------------------------------------------------------------*
FORM CHART_CHANGE_CUSTOMIZE
  USING LPS_CHART_CONF        TYPE ZST_BM_CHART_CONF
  CHANGING LPO_CHART_ENGINE   TYPE REF TO CL_GUI_CHART_ENGINE.
  DATA:
    LW_STR  TYPE STRING,
    LW_XSTR TYPE XSTRING.

  GS_BM_CHART_CONF = LPS_CHART_CONF.

* Create the customizing data for the chart
  PERFORM CREATE_XML_CHART_CUSTOMIZING
    USING LW_XSTR.

  CALL FUNCTION 'ECATT_CONV_XSTRING_TO_STRING'
    EXPORTING
      IM_XSTRING = LW_XSTR
    IMPORTING
      EX_STRING  = LW_STR.

*   Set net config to chart
  LPO_CHART_ENGINE->SET_CUSTOMIZING( XDATA = LW_XSTR ).

  MOVE-CORRESPONDING GS_BM_CHART_CONF-GLOBAL
    TO ZST_BM_CHART_LAYO_GLOBAL.

ENDFORM.                    " CHART_CHANGE_CUSTOMIZE

*&---------------------------------------------------------------------*
*&      Form  CHART_STD_CUST_LOAD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_CHART_CONF  text
*      <--LPO_CHART_ENGINE  text
*----------------------------------------------------------------------*
FORM CHART_STD_CUST_LOAD
  CHANGING LPO_CHART_ENGINE   TYPE REF TO CL_GUI_CHART_ENGINE.

* Load customize from document in BDS
  IF GS_BM_CHART_CONF-CUST_DOC_ID IS NOT INITIAL.
    PERFORM CHART_STD_CUST_LOAD_DOC
      CHANGING LPO_CHART_ENGINE.
* Load customize from config
  ELSE.
    PERFORM CHART_STD_CUST_LOAD_CONFIG
      CHANGING LPO_CHART_ENGINE.
  ENDIF.

ENDFORM.                    " CHART_STD_CUST_LOAD

*&---------------------------------------------------------------------*
*&      Form  CHART_LAYOUT_GENERATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LPS_BM_CHART_CONF  text
*----------------------------------------------------------------------*
FORM CHART_LAYOUT_GENERATE
  CHANGING LPS_BM_CHART_CONF  TYPE ZST_BM_CHART_CONF.

  CALL FUNCTION 'CONVERSION_EXIT_ZZALL_OUTPUT'
    EXPORTING
      INPUT     = LPS_BM_CHART_CONF-GLOBAL-CHARTTYPE
      I_DOMNAME = 'ZDO_CHARTTYPE'
    IMPORTING
      OUTPUT    = LPS_BM_CHART_CONF-CHARTTYPE_TX.

  CALL FUNCTION 'CONVERSION_EXIT_ZZALL_OUTPUT'
    EXPORTING
      INPUT     = LPS_BM_CHART_CONF-GLOBAL-DIMENSION
      I_DOMNAME = 'ZDO_BM_CHA_DIMENS'
    IMPORTING
      OUTPUT    = LPS_BM_CHART_CONF-DIMENSION_TX.

** Convert chart type
*  CASE LPS_BM_CHART_CONF-GLOBAL-CHARTTYPE.
*    WHEN GC_CHATY_NO_LINES.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_LINES.
*    WHEN GC_CHATY_NO_STACKEDLINES.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_STACKEDLINES.
*    WHEN GC_CHATY_NO_PROFILES.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_PROFILES.
*    WHEN GC_CHATY_NO_STACKEDPROFILES.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_STACKEDPROFILES.
*    WHEN GC_CHATY_NO_BARS.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_BARS.
*    WHEN GC_CHATY_NO_STACKEDBARS.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_STACKEDBARS.
*    WHEN GC_CHATY_NO_COLUMNS.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_COLUMNS.
*    WHEN GC_CHATY_NO_STACKEDCOLUMNS.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_STACKEDCOLUMNS.
*    WHEN GC_CHATY_NO_AREA.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_AREA.
*    WHEN GC_CHATY_NO_STACKEDAREA.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_STACKEDAREA.
*    WHEN GC_CHATY_NO_PROFILEAREA.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_PROFILEAREA.
*    WHEN GC_CHATY_NO_STKPRFAREA.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_STKPRFAREA.
*    WHEN GC_CHATY_NO_PIE.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_PIE.
*    WHEN GC_CHATY_NO_DOUGHNUT.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_DOUGHNUT.
*    WHEN GC_CHATY_NO_SPLITPIE.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_SPLITPIE.
*    WHEN GC_CHATY_NO_POLAR.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_POLAR.
*    WHEN GC_CHATY_NO_RADAR.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_RADAR.
*    WHEN GC_CHATY_NO_STACKEDRADAR.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_STACKEDRADAR.
*    WHEN GC_CHATY_NO_SPEEDOMETER.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_SPEEDOMETER.
*    WHEN GC_CHATY_NO_DELTACHART.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_DELTACHART.
*    WHEN OTHERS.
*      LPS_BM_CHART_CONF-CHARTTYPE_TX = GC_CHATY_TX_COLUMNS.
*  ENDCASE.

** Convert dimension
*  CASE LPS_BM_CHART_CONF-GLOBAL-DIMENSION.
*    WHEN GC_DIMEN_CODE_2D. "Two/PseudoTwo
*      LPS_BM_CHART_CONF-DIMENSION_TX = GC_DIMEN_TX_2D.
*    WHEN GC_DIMEN_CODE_25D. "PseudoThree
*      LPS_BM_CHART_CONF-DIMENSION_TX = GC_DIMEN_TX_25D.
*    WHEN GC_DIMEN_CODE_3D. "Three
*      LPS_BM_CHART_CONF-DIMENSION_TX = GC_DIMEN_TX_3D.
*    WHEN OTHERS.
*      LPS_BM_CHART_CONF-DIMENSION_TX = GC_DIMEN_TX_2D.
*  ENDCASE.

ENDFORM.                    " CHART_LAYOUT_GENERATE

*&---------------------------------------------------------------------*
*&      Form  CHART_STD_LAYOUT_CONV_OUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LPS_BM_CHART_CONF  text
*----------------------------------------------------------------------*
FORM CHART_STD_LAYOUT_CONV_OUT
  CHANGING LPS_BM_CHART_CONF  TYPE ZST_BM_CHART_CONF.

  CALL FUNCTION 'CONVERSION_EXIT_ZZALL_OUTPUT'
    EXPORTING
      INPUT     = LPS_BM_CHART_CONF-GLOBAL-CHARTTYPE
      I_DOMNAME = 'ZDO_CHARTTYPE'
    IMPORTING
      OUTPUT    = LPS_BM_CHART_CONF-CHARTTYPE_TX.

  CALL FUNCTION 'CONVERSION_EXIT_ZZALL_OUTPUT'
    EXPORTING
      INPUT     = LPS_BM_CHART_CONF-GLOBAL-DIMENSION
      I_DOMNAME = 'ZDO_BM_CHA_DIMENS'
    IMPORTING
      OUTPUT    = LPS_BM_CHART_CONF-DIMENSION_TX.

ENDFORM.                    " CHART_STD_LAYOUT_CONV_OUT

*&---------------------------------------------------------------------*
*&      Form  CHART_STD_LAYOUT_CONV_IN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LPS_BM_CHART_CONF  text
*----------------------------------------------------------------------*
FORM CHART_STD_LAYOUT_CONV_IN
  CHANGING LPS_BM_CHART_CONF  TYPE ZST_BM_CHART_CONF.

  CALL FUNCTION 'CONVERSION_EXIT_ZZALL_INPUT'
    EXPORTING
      INPUT     = LPS_BM_CHART_CONF-CHARTTYPE_TX
      I_DOMNAME = 'ZDO_CHARTTYPE'
    IMPORTING
      OUTPUT    = LPS_BM_CHART_CONF-GLOBAL-CHARTTYPE.

  CALL FUNCTION 'CONVERSION_EXIT_ZZALL_INPUT'
    EXPORTING
      INPUT     = LPS_BM_CHART_CONF-DIMENSION_TX
      I_DOMNAME = 'ZDO_BM_CHA_DIMENS'
    IMPORTING
      OUTPUT    = LPS_BM_CHART_CONF-GLOBAL-DIMENSION.

ENDFORM.                    " CHART_STD_LAYOUT_CONV_IN

*&---------------------------------------------------------------------*
*&      Form  CHART_STD_DATA_CREATE_XML
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_CHART_CONF  text
*      -->LPT_TABDATA  text
*      <--LPT_CHART_STD  text
*----------------------------------------------------------------------*
FORM CHART_STD_DATA_CREATE_XML
  USING    LPS_CHART_CONF     TYPE ZST_BM_CHART_CONF
           LPT_TABDATA        TYPE TABLE
  CHANGING LPW_XSTR           TYPE XSTRING.

  DATA:
    LW_STR       TYPE STRING,
    LS_SERI_LAYO TYPE ZST_BM_CHA_LAYO_SERI,
    LS_POINT     TYPE ZST_BM_CHART_POINT,
    LS_CATEGORY  TYPE ZST_BM_CHART_CAT,
    LS_SERIES    TYPE ZST_BM_CHART_SERI,
    LW_VALUE     TYPE STRING,
    LW_CHAR30    TYPE CHAR30,
    LW_SERVAL    TYPE ZST_BM_CHART_VALS.
  FIELD-SYMBOLS:
    <LF_VALUE>  TYPE ANY,
    <LF_RECORD> TYPE ANY.

  CLEAR: GS_CHART_STD.

* Loop records to convert
  LOOP AT LPT_TABDATA ASSIGNING <LF_RECORD>.
    CLEAR: LS_POINT.

*   Prepare Category layout
    MOVE-CORRESPONDING LPS_CHART_CONF-CAT_LAYO TO LS_CATEGORY.
    ASSIGN COMPONENT LS_CATEGORY-CAT_FIELD
      OF STRUCTURE <LF_RECORD> TO <LF_VALUE>.
    IF SY-SUBRC IS INITIAL.
      LW_VALUE = <LF_VALUE>.
*     Get X value
      LS_POINT-CATE_VAL   = LW_VALUE.
      LW_SERVAL-VALUE     = LW_VALUE.
      APPEND LW_SERVAL TO LS_CATEGORY-VALUES.
      CLEAR LW_VALUE.
    ENDIF.

*   Prepare Seri layout
    LOOP AT LPS_CHART_CONF-SERI_LAYO INTO LS_SERI_LAYO.
      ASSIGN COMPONENT LS_SERI_LAYO-SERI_FIELD OF STRUCTURE <LF_RECORD>
        TO <LF_VALUE>.
      IF SY-SUBRC IS INITIAL.
        LW_SERVAL-VALUE = <LF_VALUE>.
        APPEND LW_SERVAL TO LS_POINT-SERI_VALS .
        CLEAR LW_SERVAL.
      ENDIF.
    ENDLOOP.
    APPEND LS_POINT TO GS_CHART_STD-POINTS.
    GS_CHART_STD-CATEGORIES = LS_CATEGORY.
  ENDLOOP.

* Prepare series
  LOOP AT LPS_CHART_CONF-SERI_LAYO INTO LS_SERI_LAYO.
    CLEAR LS_SERIES.
    MOVE-CORRESPONDING LS_SERI_LAYO TO LS_SERIES.
    LOOP AT LPT_TABDATA ASSIGNING <LF_RECORD>.
      ASSIGN COMPONENT LS_SERI_LAYO-SERI_FIELD OF STRUCTURE <LF_RECORD>
        TO <LF_VALUE>.
      IF SY-SUBRC IS INITIAL.
        LW_SERVAL-VALUE = <LF_VALUE>.
        WRITE <LF_VALUE> TO LW_CHAR30 DECIMALS 0 NO-GAP.
        CONDENSE LW_CHAR30.
        LW_SERVAL-TOOLTIP   = 'alt=''' && LW_CHAR30 && ''''.
        APPEND LW_SERVAL TO LS_SERIES-VALUES .
      ENDIF.
    ENDLOOP.
    APPEND LS_SERIES TO GS_CHART_STD-SERIES.
  ENDLOOP.

  IF 1 = 1.
    CALL TRANSFORMATION ZTR_BM_CHART_P
      SOURCE DATA = GS_CHART_STD
      RESULT XML LPW_XSTR
      OPTIONS XML_HEADER = 'no'.
  ELSE.
    CALL TRANSFORMATION ZTR_BM_CHART
      SOURCE DATA = GS_CHART_STD
      RESULT XML LPW_XSTR
      OPTIONS XML_HEADER = 'no'.
  ENDIF.

  IF 1 = 2.
*    CALL TRANSFORMATION ZTR_BM_CHART
    CALL TRANSFORMATION ZTR_BM_CHART_P
      SOURCE DATA = GS_CHART_STD
      RESULT XML LW_STR
      OPTIONS XML_HEADER = 'no'.
  ENDIF.

ENDFORM.                    " CHART_STD_DATA_CREATE_XML

*&---------------------------------------------------------------------*
*&      Form  BUILD_ALV_TREE_AVAICONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_GUI_CONTAINER  text
*----------------------------------------------------------------------*
FORM BUILD_ALV_TREE_AVAICONTAINER
  USING
    LPO_GUI_CONTAINER         TYPE REF TO CL_GUI_CONTAINER
    LPW_NODE_SEL_MODE         TYPE I
    LPW_ITEM_SELECTION        TYPE XMARK.

* Create tree
  CREATE OBJECT GO_ALV_TREE
    EXPORTING
      PARENT              = LPO_GUI_CONTAINER
      NODE_SELECTION_MODE = LPW_NODE_SEL_MODE
      ITEM_SELECTION      = LPW_ITEM_SELECTION
      NO_HTML_HEADER      = 'X'
    EXCEPTIONS
      OTHERS              = 1.

ENDFORM.                    " BUILD_ALV_TREE_AVAICONTAINER

*&---------------------------------------------------------------------*
*&      Form  9999_SHOW_HEADER_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_HEADER  text
*----------------------------------------------------------------------*
FORM 9999_SHOW_HEADER_ALV
  USING LPT_HEADER            TYPE ZTT_ALV_HEADER
        LPS_LOGO              TYPE ZST_BM_ALV_LOGO.
  DATA:
    LS_HEADER   TYPE ZST_ALV_HEADER,
    LW_HEIGH    TYPE I,
    LW_LINE     TYPE I,
    LO_TOP_HTML TYPE REF TO CL_DD_DOCUMENT,
    LO_SPLITTER TYPE REF TO CL_GUI_SPLITTER_CONTAINER.

  LOOP AT LPT_HEADER INTO LS_HEADER.
    CASE LS_HEADER-TYP.
      WHEN 'H'.
        LW_LINE = STRLEN( LS_HEADER-INFO )
                  DIV GC_ALV_LINELENG_H + 1.
        LW_HEIGH = LW_HEIGH + GC_ALV_HEIGH_H * LW_LINE.
      WHEN 'S'.
        LW_LINE = STRLEN( LS_HEADER-INFO )
                  DIV GC_ALV_LINELENG_S + 1.
        LW_HEIGH = LW_HEIGH + GC_ALV_HEIGH_S * LW_LINE.
      WHEN 'A'.
        LW_HEIGH = LW_HEIGH + GC_ALV_HEIGH_A.
        LW_LINE = STRLEN( LS_HEADER-INFO )
                  DIV GC_ALV_LINELENG_A + 1.
        LW_HEIGH = LW_HEIGH + GC_ALV_HEIGH_A * LW_LINE.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

  LO_SPLITTER ?= GO_ALV_HEADER_CON->PARENT.
  CALL METHOD LO_SPLITTER->SET_ROW_HEIGHT
    EXPORTING
      ID     = 1
      HEIGHT = LW_HEIGH.

* Create viewer
  CREATE OBJECT GO_ALV_HEADER_VIEW
    EXPORTING
      PARENT = GO_ALV_HEADER_CON.

* Create document
  CREATE OBJECT GO_ALV_HEADER_DOC
    EXPORTING
      STYLE = 'ALV_GRID'.
  GO_ALV_HEADER_DOC->HTML_CONTROL = GO_ALV_HEADER_VIEW.

* Show Header document
  PERFORM 9999_SHOW_HTML_DOC
    USING GO_ALV_HEADER_DOC
          LPT_HEADER
          LPS_LOGO.

ENDFORM.                    " 9999_SHOW_HEADER_ALV

*&---------------------------------------------------------------------*
*&      Form  9999_SPLIT_CONTAINER_HORIZON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPO_CON_PARENT  text
*      <--LPO_CON_TOP  text
*      <--LPO_CON_DOWN  text
*----------------------------------------------------------------------*
FORM 9999_SPLIT_CONTAINER_HORIZON
  USING    LPO_CON_PARENT     "TYPE REF TO CL_GUI_CONTAINER
  CHANGING LPO_CON_TOP        TYPE REF TO CL_GUI_CONTAINER
           LPO_CON_DOWN       TYPE REF TO CL_GUI_CONTAINER.
  DATA:
    LO_SPLITTER               TYPE REF TO CL_GUI_SPLITTER_CONTAINER.

  CREATE OBJECT LO_SPLITTER
    EXPORTING
      PARENT  = LPO_CON_PARENT
      ROWS    = 2
      COLUMNS = 1.

  CALL METHOD LO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = LPO_CON_TOP.

  CALL METHOD LO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = LPO_CON_DOWN.

  CALL METHOD LO_SPLITTER->SET_ROW_HEIGHT
    EXPORTING
      ID     = 1
      HEIGHT = 20.

ENDFORM.                    " 9999_SPLIT_CONTAINER_HORIZON

*&---------------------------------------------------------------------*
*&      Form  9999_SHOW_HTML_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPO_HTML_DOC  HTML document
*      -->LPT_HEADER    Header text
*----------------------------------------------------------------------*
FORM 9999_SHOW_HTML_DOC
  USING LPO_HTML_DOC          TYPE REF TO CL_DD_DOCUMENT
        LPT_HEADER            TYPE ZTT_ALV_HEADER
        LPS_LOGO              TYPE ZST_BM_ALV_LOGO.

* Bind data to document view
  PERFORM 9999_SET_HTML_DOC
    USING LPO_HTML_DOC
          LPT_HEADER
          LPS_LOGO.

* Get TOP->HTML_TABLE ready
  CALL METHOD LPO_HTML_DOC->MERGE_DOCUMENT.

* Show document
  CALL METHOD LPO_HTML_DOC->DISPLAY_DOCUMENT
    EXPORTING
      REUSE_CONTROL      = 'X'
    EXCEPTIONS
      HTML_DISPLAY_ERROR = 1.

ENDFORM.                    " 9999_SHOW_HTML_DOC

*&---------------------------------------------------------------------*
*&      Form  9999_SET_HTML_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPO_HTML_DOC  HTML document
*      -->LPT_HEADER    Header text
*      -->LPS_LOGO      Header Logo
*----------------------------------------------------------------------*
FORM 9999_SET_HTML_DOC
  USING LPO_HTML_DOC          TYPE REF TO CL_DD_DOCUMENT
        LPT_HEADER            TYPE ZTT_ALV_HEADER
        LPS_LOGO              TYPE ZST_BM_ALV_LOGO.

* Bind data to docment view
  EXPORT IT_LIST_COMMENTARY FROM LPT_HEADER
         I_LOGO             FROM LPS_LOGO-LOGO
         I_LOGOWIDTH        FROM LPS_LOGO-WIDTH
         I_SPLITWIDTH       FROM '90%'
      TO MEMORY ID 'DYNDOS_FOR_ALV'.

** Export to Memory for HTML Conversion
*  EXPORT GRID_TOP_HTML FROM  LPO_HTML_DOC->HTML_TABLE
*    TO MEMORY ID 'TOP_HTML_FOR_ALV'.

  CALL FUNCTION 'ZREUSE_ALV_GRID_COMMENTARY_SET'
    EXPORTING
      DOCUMENT = LPO_HTML_DOC
      BOTTOM   = SPACE.

  FREE MEMORY ID 'DYNDOS_FOR_ALV'.

ENDFORM.                    " 9999_SET_HTML_DOC

*&---------------------------------------------------------------------*
*&      Form  9999_GET_TREE_PARENT_KEY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_TREE_STR  text
*      -->LPT_TREE_TAB  text
*      <--LPS_TREE_DATA  text
*----------------------------------------------------------------------*
FORM 9999_GET_TREE_PARENT_KEY
  USING   LPS_TREE_STR        TYPE ZST_TREE_STR
          LPT_TREE_TAB        TYPE TABLE
 CHANGING LPS_TREE_DATA       TYPE ANY.
  FIELD-SYMBOLS:
    <LF_TREE_PARENTS> TYPE ANY,
    <LF_TREEKEY>      TYPE ANY,
    <LF_TREEPRKEY>    TYPE ANY,
    <LF_PARID>        TYPE ANY.

* Get parent ID of record
  ASSIGN COMPONENT LPS_TREE_STR-KEYPR OF STRUCTURE LPS_TREE_DATA
    TO <LF_PARID>.
* Get parent record and update parent key on tree
  READ TABLE LPT_TREE_TAB ASSIGNING <LF_TREE_PARENTS>
    WITH KEY (LPS_TREE_STR-KEYNM) = <LF_PARID>.
  IF SY-SUBRC IS INITIAL.
*   Get Tree key of parent record
    ASSIGN COMPONENT GC_ATREE_TREEKEY OF STRUCTURE <LF_TREE_PARENTS>
      TO <LF_TREEKEY>.
*   Update parent key to current record
    ASSIGN COMPONENT GC_ATREE_TREEPRKEY OF STRUCTURE LPS_TREE_DATA
      TO <LF_TREEPRKEY>.
    <LF_TREEPRKEY> = <LF_TREEKEY>.
  ELSE.
*   Assign value of parent key is null
    ASSIGN COMPONENT GC_ATREE_TREEPRKEY OF STRUCTURE LPS_TREE_DATA
      TO <LF_TREEPRKEY>.
    CLEAR: <LF_TREEPRKEY>.
  ENDIF.

ENDFORM.                    " 9999_GET_TREE_PARENT_KEY

*&---------------------------------------------------------------------*
*&      Form  ALV_TREE_NODES_PUSH_SINGLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_TREE_STR  text
*      -->LPT_TREE_TAB  text
*      <--LPS_TREE_DATA  text
*      <--LPT_ROOTS  text
*----------------------------------------------------------------------*
FORM ALV_TREE_NODES_PUSH_SINGLE
  USING   LPS_TREE_STR        TYPE ZST_TREE_STR
          LPT_TREE_TAB        TYPE TABLE
 CHANGING LPS_TREE_DATA       TYPE ANY
          LPO_TREE_CONTROL    TYPE REF TO CL_GUI_ALV_TREE
          LPT_ROOTS           TYPE LVC_T_NKEY.
  DATA:
    LW_NODE_TEXT   TYPE LVC_VALUE,
    LS_DATA        TYPE REF TO DATA,
    LT_ITEM_LAYOUT TYPE LVC_T_LAYI,
    LS_NODE_LAYOUT TYPE LVC_S_LAYN.

  FIELD-SYMBOLS:
    <LF_TREE_PARENTS> TYPE ANY,
    <LF_TREEKEY>      TYPE ANY,
    <LF_TREEPRKEY>    TYPE ANY.

* Get parent key in tree of node
  PERFORM 9999_GET_TREE_PARENT_KEY
    USING LPS_TREE_STR
          LPT_TREE_TAB
    CHANGING LPS_TREE_DATA.

* Prepare node layout
  PERFORM SET_ALV_TREE_NODE_LAYOUT
    USING    LPS_TREE_STR
             LPS_TREE_DATA
    CHANGING LS_NODE_LAYOUT
             LW_NODE_TEXT.

* Prepare items layout
  PERFORM SET_ALV_TREE_ITEM_LAYOUT
    USING LPS_TREE_DATA
    CHANGING LT_ITEM_LAYOUT.

* Add node and update new tree key to current record
  ASSIGN COMPONENT GC_ATREE_TREEKEY OF STRUCTURE LPS_TREE_DATA
    TO <LF_TREEKEY>.
  ASSIGN COMPONENT GC_ATREE_TREEPRKEY OF STRUCTURE LPS_TREE_DATA
    TO <LF_TREEPRKEY>.

* Add node and update new tree key to current record
  CALL METHOD LPO_TREE_CONTROL->ADD_NODE
    EXPORTING
      I_RELAT_NODE_KEY     = <LF_TREEPRKEY>
      I_RELATIONSHIP       = CL_GUI_COLUMN_TREE=>RELAT_LAST_CHILD
      IS_OUTTAB_LINE       = LPS_TREE_DATA
      IS_NODE_LAYOUT       = LS_NODE_LAYOUT
      IT_ITEM_LAYOUT       = LT_ITEM_LAYOUT
      I_NODE_TEXT          = LW_NODE_TEXT
    IMPORTING
      E_NEW_NODE_KEY       = <LF_TREEKEY>
    EXCEPTIONS
      RELAT_NODE_NOT_FOUND = 1
      NODE_NOT_FOUND       = 2
      OTHERS               = 3.
* Get root node
  IF SY-SUBRC IS INITIAL AND <LF_TREEPRKEY> IS INITIAL.
    APPEND <LF_TREEKEY> TO LPT_ROOTS.
  ENDIF.

ENDFORM.                    " ALV_TREE_NODES_PUSH_SINGLE

*&---------------------------------------------------------------------*
*&      Form  ALV_TREE_STANDARD_STRUCTURE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPT_TREE_TAB  text
*      <--LPS_TREE_STR  text
*----------------------------------------------------------------------*
FORM ALV_TREE_STANDARD_STRUCTURE
  USING LPT_TREE_TAB          TYPE TABLE
  CHANGING LPS_TREE_STR       TYPE ZST_TREE_STR.
  DATA:
    LR_DATA  TYPE REF TO DATA,
    LW_TABNM TYPE TABNAME.
  FIELD-SYMBOLS:
    <LF_INIT_LINE>            TYPE ANY.

* Structure of tree table
  IF LPS_TREE_STR-TABNM IS INITIAL.
    CREATE DATA LR_DATA LIKE LINE OF LPT_TREE_TAB.
    ASSIGN LR_DATA->* TO <LF_INIT_LINE>.

    DESCRIBE FIELD <LF_INIT_LINE> HELP-ID LW_TABNM.
    LPS_TREE_STR-TABNM = LW_TABNM.
  ENDIF.

* Key name in program processing
  IF LPS_TREE_STR-KEYNM IS INITIAL.
    LPS_TREE_STR-KEYNM = GC_ATREE_STR-AGGRKEY.
  ENDIF.

* Key parents name in program processing
  IF LPS_TREE_STR-KEYPR IS INITIAL.
    LPS_TREE_STR-KEYPR = GC_ATREE_STR-AGPRKEY.
  ENDIF.

* Texxt field to display on tree
  IF LPS_TREE_STR-FTEXT IS INITIAL.
    LPS_TREE_STR-FTEXT = GC_ATREE_STR-TREETEXT.
  ENDIF.

ENDFORM.                    " ALV_TREE_STANDARD_STRUCTURE

*&---------------------------------------------------------------------*
*&      Form  9999_DATA_ADD_NODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_NODENAME  text
*      -->LPW_TYPENAME  text
*----------------------------------------------------------------------*
FORM 9999_DATA_ADD_NODE
  USING LPW_NODENAME
        LPW_TYPENAME          TYPE TYPENAME
        LPS_PARENTS           TYPE ZST_BM_DATA_VIEW.
  DATA:
    LW_TYPEKIND  TYPE DDTYPEKIND,
    LS_DD40V     TYPE DD40V,
    LS_DATA_VIEW TYPE ZST_BM_DATA_VIEW,
    LS_PARENTS   TYPE ZST_BM_DATA_VIEW,
    LT_DD03P     TYPE TABLE OF DD03P,
    LS_DD03P     TYPE DD03P.

* Set node info
  LS_DATA_VIEW-NAME       = LPW_NODENAME.
  LS_DATA_VIEW-TYPE       = LPW_TYPENAME.
  LS_DATA_VIEW-DEPTH      = LPS_PARENTS-DEPTH + 1.
  LS_DATA_VIEW-AGGRKEY    = LPW_TYPENAME.
  LS_DATA_VIEW-AGPRKEY    = LPS_PARENTS-AGGRKEY.
  LS_DATA_VIEW-TREETEXT   = LPW_NODENAME && ': ' && LPW_TYPENAME.
  LS_DATA_VIEW-TREETEXT   = LPW_NODENAME.
  LS_DATA_VIEW-NODELV     = LPS_PARENTS-DEPTH.
  LS_DATA_VIEW-NODE_LAYOUT-ISFOLDER  = GC_XMARK.
  LS_DATA_VIEW-HIDENULL   = LPS_PARENTS-HIDENULL.

* Get type info
  CALL FUNCTION 'DDIF_TYPEINFO_GET'
    EXPORTING
      TYPENAME = LPW_TYPENAME
    IMPORTING
      TYPEKIND = LW_TYPEKIND.
  CASE LW_TYPEKIND.
    WHEN GC_TYPEKIND_TABL.
      IF LPW_NODENAME = 'ROOT'.
        LS_DATA_VIEW-COMPTYPE   = GC_COMPTYPE_STRU.
        LS_DATA_VIEW-ROWTYPE    = LPW_TYPENAME.
        APPEND LS_DATA_VIEW TO GT_DATA_VIEW.
        LS_PARENTS = LS_DATA_VIEW .
      ELSE.
        LS_PARENTS = LPS_PARENTS .
      ENDIF.

      CALL FUNCTION 'DDIF_TABL_GET'
        EXPORTING
          NAME          = LPW_TYPENAME
        TABLES
          DD03P_TAB     = LT_DD03P
        EXCEPTIONS
          ILLEGAL_INPUT = 1
          OTHERS        = 2.
      LOOP AT LT_DD03P INTO LS_DD03P
        WHERE FIELDNAME <> '.INCLUDE'.
        IF LPW_NODENAME <> 'ROOT'.
          CALL FUNCTION 'ZFM_DATA_CONCATENATE'
            EXPORTING
              I_TEXT1     = LPW_NODENAME
              I_TEXT2     = LS_DD03P-FIELDNAME
              I_SEPARATOR = '-'
            IMPORTING
              E_TEXT      = LS_DD03P-FIELDNAME.
        ENDIF.
        CASE LS_DD03P-COMPTYPE.
          WHEN GC_COMPTYPE_STRU.
            PERFORM 9999_DATA_ADD_NODE
              USING LS_DD03P-FIELDNAME
                    LS_DD03P-ROLLNAME
                    LS_PARENTS.

          WHEN GC_COMPTYPE_TTYP.
            CHECK LS_DD03P-DEPTH IS INITIAL.
            PERFORM 9999_DATA_ADD_NODE
              USING LS_DD03P-FIELDNAME
                    LS_DD03P-ROLLNAME
                    LS_PARENTS.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP.

    WHEN GC_TYPEKIND_TTYP.
      CALL FUNCTION 'DDIF_TTYP_GET'
        EXPORTING
          NAME          = LPW_TYPENAME
        IMPORTING
          DD40V_WA      = LS_DD40V
        EXCEPTIONS
          ILLEGAL_INPUT = 1
          OTHERS        = 2.
      IF SY-SUBRC IS INITIAL.
        LS_DATA_VIEW-COMPTYPE   = GC_COMPTYPE_TTYP.
        LS_DATA_VIEW-ROWTYPE    = LS_DD40V-ROWTYPE.
        APPEND LS_DATA_VIEW TO GT_DATA_VIEW.
        PERFORM 9999_DATA_ADD_NODE
          USING SPACE"'ROW'
                LS_DD40V-ROWTYPE
                LS_DATA_VIEW.
      ELSE.
        RAISE INVALID_TYPE.
      ENDIF.
    WHEN OTHERS.
      RAISE INVALID_TYPE.
  ENDCASE.

ENDFORM.                    " 9999_DATA_ADD_NODE

*&---------------------------------------------------------------------*
*&      Form  9999_CHART_CREATE_OBJ_TIMER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 9999_CHART_CREATE_OBJ_TIMER
  USING LPW_INTERVAL          TYPE I
        LPW_CPROG             TYPE SY-REPID
        LPW_SUBR_REFDATA      TYPE SLIS_FORMNAME
        LPS_CHART_CONF        TYPE ZST_BM_CHART_CONF
        LPT_TAB_DATA          TYPE TABLE.
  DATA:
    LR_DATA                   TYPE REF TO DATA.

  CHECK GO_CHART_TIMER IS NOT BOUND.
  CREATE OBJECT GO_CHART_TIMER.
  CREATE OBJECT GO_CHART_HANDLE.
  SET HANDLER GO_CHART_HANDLE->HANDLE_FINISHED FOR GO_CHART_TIMER.
  GO_CHART_TIMER->INTERVAL = LPW_INTERVAL.

  CREATE DATA LR_DATA LIKE LPT_TAB_DATA.
  ASSIGN LR_DATA->* TO <GFT_CHART_DATA>.

  GO_CHART_HANDLE->CHART_CONF       = LPS_CHART_CONF.
  GO_CHART_HANDLE->REFRESH_PROGRAM  = LPW_CPROG.
  GO_CHART_HANDLE->REFRESH_FORMNAME = LPW_SUBR_REFDATA.
  CALL METHOD GO_CHART_TIMER->RUN.

ENDFORM.                    " 9999_CHART_CREATE_OBJ_TIMER

*&---------------------------------------------------------------------*
*&      Form  0100_PROCESS_FC_EXPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0100_PROCESS_FC_EXPORT .
  DATA:
    LT_CUSTOMIZE TYPE W3MIMETABTYPE,
    LO_WIN_CHART TYPE REF TO CL_GUI_CHART_ENGINE_WIN,
    LW_FILENAME  TYPE STRING,
    LW_FILEPATH  TYPE STRING,
    LW_FILESIZE  TYPE I,
    LW_PATH      TYPE STRING.

  CATCH SYSTEM-EXCEPTIONS MOVE_CAST_ERROR = 1.
    LO_WIN_CHART ?= GO_CHART_ENGINE->GET_CONTROL( ).
  ENDCATCH.
  IF SY-SUBRC IS INITIAL.
    CALL METHOD LO_WIN_CHART->GET_CUSTOMIZING
      IMPORTING
        XDATA_TABLE = LT_CUSTOMIZE.

    DESCRIBE TABLE LT_CUSTOMIZE LINES LW_FILESIZE.
    MULTIPLY LW_FILESIZE BY 255.

    CALL FUNCTION 'ZFM_POPUP_FILE_SAVE'
      EXPORTING
        I_FILENAME  = 'customizing.xml'
        IT_FILEDATA = LT_CUSTOMIZE
        I_FILESIZE  = LW_FILESIZE.
    RETURN.

    LW_FILENAME = 'customizing.xml'.
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
      EXPORTING
        DEFAULT_FILE_NAME = LW_FILENAME
      CHANGING
        FILENAME          = LW_FILENAME
        PATH              = LW_PATH
        FULLPATH          = LW_FILEPATH.

    IF NOT LW_FILEPATH IS INITIAL.
      CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
        EXPORTING
          FILETYPE         = 'BIN'
          FILENAME         = LW_FILEPATH
          BIN_FILESIZE     = LW_FILESIZE
        CHANGING
          DATA_TAB         = LT_CUSTOMIZE
        EXCEPTIONS
          FILE_WRITE_ERROR = 1
          OTHERS           = 22.
    ENDIF.

  ENDIF.
ENDFORM.                    " 0100_PROCESS_FC_EXPORT

*&---------------------------------------------------------------------*
*&      Form  0100_PROCESS_FC_LOAD
*&---------------------------------------------------------------------*
*       Load customize
*----------------------------------------------------------------------*
FORM 0100_PROCESS_FC_LOAD .
  DATA:
    LT_CUSTOMIZE TYPE W3MIMETABTYPE,
    LO_WIN_CHART TYPE REF TO CL_GUI_CHART_ENGINE_WIN.

  CATCH SYSTEM-EXCEPTIONS MOVE_CAST_ERROR = 1.
    LO_WIN_CHART ?= GO_CHART_ENGINE->GET_CONTROL( ).
  ENDCATCH.
  IF SY-SUBRC IS INITIAL.
*   Popup to load customizing file
    CALL FUNCTION 'ZFM_POPUP_FILE_OPEN'
      EXPORTING
        I_EXTENSION = 'xml'
      IMPORTING
        ET_BIN_TAB  = LT_CUSTOMIZE.

*   Set customizing to graph
    CALL METHOD GO_CHART_ENGINE->SET_CUSTOMIZING
      EXPORTING
        XDATA_TABLE = LT_CUSTOMIZE.

*    CALL METHOD GO_CHART_ENGINE->RENDER.
  ENDIF.

ENDFORM.                    " 0100_PROCESS_FC_LOAD

*&---------------------------------------------------------------------*
*&      Form  9999_SHOW_STRUCTURE_TREE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 9999_SHOW_STRUCTURE_TREE.

* Show nest tree and alv
  PERFORM 200_NEST_DATA_VIEW.

* Call screen to show
  CALL SCREEN 200.

ENDFORM.                    " 9999_SHOW_STRUCTURE_TREE

*&---------------------------------------------------------------------*
*&      Form  200_NEST_DATA_VIEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 200_NEST_DATA_VIEW .
*  CALL METHOD CL_GUI_CFW=>FLUSH.

  IF GO_CON_NEST_LEFT IS INITIAL.
*   Create containers
    CALL FUNCTION 'ZFM_SCR_SPLIT'
      EXPORTING
        I_REPID     = SY-REPID
        I_DYNNR     = '0200' "SY-DYNNR
      IMPORTING
        E_CON_LEFT  = GO_CON_NEST_LEFT
        E_CON_RIGHT = GO_CON_NEST_RIGHT
        E_CON_ROOT  = GO_CON_ROOT.

*   Show tree config
    PERFORM 9999_NEST_STRUCTURE_TREE_SHOW.

*   Show detail ALV data
    PERFORM 9999_NEST_DETAIL_ALV_SHOW
      USING GO_NEST_HANDLE
            SPACE.
  ENDIF.

ENDFORM.                    " 200_NEST_DATA_VIEW

*&---------------------------------------------------------------------*
*&      Form  9999_NEST_DETAIL_ALV_SHOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_STRUCTURE_NAME  text
*      -->LPW_REFRESH  text
*----------------------------------------------------------------------*
FORM 9999_NEST_DETAIL_ALV_SHOW
  USING LPO_NEST_HANDLE       TYPE REF TO GCL_NEST_HANDLE
        LPW_REFRESH           TYPE XMARK.
  DATA:
    LS_VARIANT   TYPE DISVARIANT,
    LT_FIELDCAT  TYPE LVC_T_FCAT,
    LT_REPLFCAT  TYPE LVC_T_FCAT,
    LR_REPL_DATA TYPE REF TO DATA.

  LS_VARIANT-HANDLE           = 'A001'.

* Create fieldcat for nest structure
  PERFORM 9999_NEST_STR_CREATE_FCAT
    USING LPO_NEST_HANDLE->CURR_NODE-ROWTYPE
    CHANGING LT_FIELDCAT
             LT_REPLFCAT.

* If structure has no normal, use replace fieldcat
  IF LT_FIELDCAT IS INITIAL.
*   Create replace table data
    PERFORM 9999_NEST_STR_REPL_TAB_CREATE
      USING LT_FIELDCAT
            LT_REPLFCAT
            LPO_NEST_HANDLE->CURR_NODE-DATA
      CHANGING LR_REPL_DATA.

*   Assign ALV table to new replace table
    ASSIGN LR_REPL_DATA->* TO <GFT_NEST_TAB>.

*   Set field cat to new replace field cat
    LT_FIELDCAT = LT_REPLFCAT.
  ELSE.
*   Set ALV data
    ASSIGN LPO_NEST_HANDLE->CURR_NODE-DATA->* TO <GFT_NEST_TAB>.
  ENDIF.
  CHECK LT_FIELDCAT IS NOT INITIAL.

* Free ALV object
  IF LPW_REFRESH IS NOT INITIAL.
    CALL METHOD GO_ALV_STR_NEST->FREE.
  ENDIF.

* Show ALV detail
  CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR'
    EXPORTING
      IS_VARIANT      = LS_VARIANT
      I_GUI_CONTAINER = GO_CON_NEST_RIGHT
      I_CPROG         = SY-REPID
    IMPORTING
      E_ALV_GRID      = GO_ALV_STR_NEST
    CHANGING
      IT_OUTTAB       = <GFT_NEST_TAB>
      IT_FIELDCATALOG = LT_FIELDCAT.

ENDFORM.                    " 9999_NEST_DETAIL_ALV_SHOW

*&---------------------------------------------------------------------*
*&      Form  9999_NEST_STRUCTURE_TREE_SHOW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 9999_NEST_STRUCTURE_TREE_SHOW .
  DATA:
    LS_TREE_STR TYPE ZST_TREE_STR,
    LS_VARIANT  TYPE DISVARIANT.

  LS_TREE_STR-TABNM           = 'ZST_BM_DATA_VIEW'.
  LS_TREE_STR-KEYNM           = GC_ATREE_STR-AGGRKEY.
  LS_TREE_STR-KEYPR           = GC_ATREE_STR-AGPRKEY.
  LS_TREE_STR-NODELV          = GC_ATREE_STR-NODELV.
  LS_VARIANT-REPORT           = SY-CPROG.
  LS_VARIANT-HANDLE           = SY-DYNNR.
  CALL FUNCTION 'ZFM_BM_ALV_TREE_FIRST_DISPLAY'
    EXPORTING
      I_TREE_STR      = LS_TREE_STR
      I_CUS_CONTAINER = GO_CON_NEST_LEFT
      I_LASTCOL       = 5
      IS_VARIANT      = LS_VARIANT
    IMPORTING
      E_TREE_CONTROL  = GO_ALV_TREE_NEST
    CHANGING
      T_TREE_TAB      = GO_NEST_HANDLE->NODES.

  SET HANDLER GO_NEST_HANDLE->HANDLE_DOUBLE_CLICK
    FOR GO_ALV_TREE_NEST.
  SET HANDLER GO_NEST_HANDLE->HANDLE_SELECTION_CHANGED
    FOR GO_ALV_TREE_NEST.
  READ TABLE GO_NEST_HANDLE->NODES  INDEX 1
    INTO GO_NEST_HANDLE->CURR_NODE.

ENDFORM.                    " 9999_NEST_STRUCTURE_TREE_SHOW

*&---------------------------------------------------------------------*
*&      Form  9999_NEST_FREE_OBJECTS
*&---------------------------------------------------------------------*
*       Free objects
*----------------------------------------------------------------------*
FORM 9999_NEST_FREE_OBJECTS .
  DATA:
    LO_GUI_CONTROL            TYPE REF TO CL_GUI_CONTROL.

  IF SY-UCOMM = GC_FC_BACK OR SY-UCOMM = GC_FC_EXIT.
    IF GO_CON_NEST_LEFT IS NOT INITIAL.
      FREE GO_NEST_HANDLE.
      CALL METHOD GO_ALV_TREE_NEST->FREE.
      IF GO_ALV_STR_NEST IS BOUND.
        CALL METHOD GO_ALV_STR_NEST->FREE.
      ENDIF.
      CALL METHOD GO_CON_NEST_LEFT->FREE.
      LO_GUI_CONTROL = GO_CON_NEST_RIGHT.
      DO.
        IF LO_GUI_CONTROL->PARENT IS BOUND.
          CALL METHOD LO_GUI_CONTROL->FREE.
          LO_GUI_CONTROL = LO_GUI_CONTROL->PARENT.
        ELSE.
          EXIT.
        ENDIF.
      ENDDO.
      CALL METHOD CL_GUI_CFW=>FLUSH.
    ENDIF.
    FREE: GO_CON_NEST_LEFT, GO_CON_NEST_RIGHT,
          GO_ALV_TREE_NEST, GO_ALV_STR_NEST, GO_CON_ROOT.

  ENDIF.

ENDFORM.                    " 9999_NEST_FREE_OBJECTS

*&---------------------------------------------------------------------*
*&      Form  9999_NEST_STR_CREATE_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_TYPENAME  text
*      <--LPT_FIELDCAT  text
*      <--LPT_TTYP_FCAT  text
*----------------------------------------------------------------------*
FORM 9999_NEST_STR_CREATE_FCAT
  USING    LPW_TYPENAME       TYPE TYPENAME
  CHANGING LPT_FIELDCAT       TYPE LVC_T_FCAT
           LPT_TTYP_FCAT      TYPE LVC_T_FCAT.
  DATA:
    LT_DD03P    TYPE TABLE OF DD03P,
    LS_HDR      TYPE DD03P,
    LS_PRV      TYPE DD03P,
    LS_DD03P    TYPE DD03P,
    LS_FIELDCAT TYPE LVC_S_FCAT.
  FIELD-SYMBOLS:
    <LFT_NEST_TAB> TYPE TABLE,
    <LF_NEST_ROW>  TYPE ANY,
    <LF_VALUE>     TYPE ANY,
    <LF_NEST_REAL> TYPE ANY.

* Get all field of structure
  CALL FUNCTION 'DDIF_TABL_GET'
    EXPORTING
      NAME          = LPW_TYPENAME
    TABLES
      DD03P_TAB     = LT_DD03P
    EXCEPTIONS
      ILLEGAL_INPUT = 1
      OTHERS        = 2.

* Build field cat
  LOOP AT LT_DD03P INTO LS_DD03P.
*   Init field cat
    MOVE-CORRESPONDING LS_DD03P TO LS_FIELDCAT.
    LS_FIELDCAT-COLTEXT     = LS_DD03P-FIELDNAME.

*   Table type
    IF LS_DD03P-COMPTYPE = GC_COMPTYPE_TTYP.
*     Build nest table type field cat to show ALV
      LS_FIELDCAT-INTTYPE     = 'C'.
      LS_FIELDCAT-INTLEN      = '30'.
      LS_FIELDCAT-DOMNAME     = 'TTYPENAME'.
      LS_FIELDCAT-ROLLNAME    = 'TTYPENAME'.
      LS_FIELDCAT-OUTPUTLEN   = '30'.
      LS_FIELDCAT-DATATYPE    = 'CHAR'.

*     Log original data element
      LS_FIELDCAT-PARAMETER0  = LS_DD03P-ROLLNAME.
      APPEND LS_FIELDCAT TO LPT_TTYP_FCAT.
*   Normal field or structure
    ELSE.
*     Nest structure fieldcat
      IF LS_DD03P-DEPTH > LS_HDR-DEPTH.
*       Current field is a component of previous structure
        IF LS_DD03P-DEPTH > LS_PRV-DEPTH.
*         [HEADER_FIELD] = [HEADER_FIELD]-[PREVIOUS_FIELD]
          CALL FUNCTION 'ZFM_DATA_CONCATENATE'
            EXPORTING
              I_TEXT1     = LS_HDR-FIELDNAME
              I_TEXT2     = LS_PRV-FIELDNAME
              I_SEPARATOR = '-'
            IMPORTING
              E_TEXT      = LS_PRV-FIELDNAME.

*         Set Header is Previous field
          LS_HDR = LS_PRV.
        ENDIF.

*       FIELDNAME = [HEADER_FIELD]-[CURRENT_FIELD]
        CONCATENATE LS_HDR-FIELDNAME '-' LS_DD03P-FIELDNAME
               INTO LS_FIELDCAT-FIELDNAME.

*       Set label to nest field name
        LS_FIELDCAT-SCRTEXT_S = LS_FIELDCAT-SCRTEXT_M
                              = LS_FIELDCAT-COLTEXT
                              = LS_FIELDCAT-SCRTEXT_L
                              = LS_FIELDCAT-FIELDNAME.
      ENDIF.

*     Only flat field can add to field cat
      IF LS_DD03P-COMPTYPE IS INITIAL
      OR LS_DD03P-COMPTYPE = GC_COMPTYPE_ELEM.
        APPEND LS_FIELDCAT TO LPT_FIELDCAT.
      ENDIF.

*     Log previous field
      LS_PRV  = LS_DD03P.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " 9999_NEST_STR_CREATE_FCAT

*&---------------------------------------------------------------------*
*&      Form  9999_NEST_STR_REPL_TAB_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPT_FIELDCAT  text
*      -->LPT_NESTFCAT  text
*      -->LPR_ORIG_DATA  text
*      <--LPR_REPL_DATA  text
*----------------------------------------------------------------------*
FORM 9999_NEST_STR_REPL_TAB_CREATE
  USING    LPT_FIELDCAT       TYPE LVC_T_FCAT
           LPT_NESTFCAT       TYPE LVC_T_FCAT
           LPR_ORIG_DATA      TYPE REF TO DATA
  CHANGING LPR_REPL_DATA      TYPE REF TO DATA.
  DATA:
    LS_FIELDCAT TYPE LVC_S_FCAT,
    LR_DATA     TYPE REF TO DATA.
  FIELD-SYMBOLS:
    <LFT_REPL_TAB> TYPE TABLE,
    <LFT_ORGI_TAB> TYPE TABLE,
    <LF_REPL_ROW>  TYPE ANY,
    <LF_VALUE>     TYPE ANY,
    <LF_ORGI_ROW>  TYPE ANY.

* Create dynamic table of replace fieldcat
  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
      IT_FIELDCATALOG           = LPT_NESTFCAT
    IMPORTING
      EP_TABLE                  = LPR_REPL_DATA
    EXCEPTIONS
      GENERATE_SUBPOOL_DIR_FULL = 1
      OTHERS                    = 2.

* Get Original data and new data
  ASSIGN LPR_REPL_DATA->* TO <LFT_REPL_TAB>.
  ASSIGN LPR_ORIG_DATA->* TO <LFT_ORGI_TAB>.

* Create dynamic table data
  LOOP AT <LFT_ORGI_TAB> ASSIGNING <LF_ORGI_ROW>.
*   Create replace row
    CREATE DATA LR_DATA LIKE LINE OF <LFT_REPL_TAB>.
    ASSIGN LR_DATA->* TO <LF_REPL_ROW>.

*   Create data value for each field of row
    LOOP AT LPT_NESTFCAT INTO LS_FIELDCAT.
      ASSIGN COMPONENT LS_FIELDCAT-FIELDNAME
        OF STRUCTURE <LF_REPL_ROW> TO <LF_VALUE>.
      IF SY-SUBRC IS INITIAL.
        <LF_VALUE> = LS_FIELDCAT-PARAMETER0.
      ENDIF.
    ENDLOOP.

*   Append replace row to replace table
    APPEND <LF_REPL_ROW> TO <LFT_REPL_TAB>.
  ENDLOOP.

ENDFORM.                    " 9999_NEST_STR_REPL_TAB_CREATE

*&---------------------------------------------------------------------*
*&      Form  0100_PROCESS_FC_SAVE_CUST
*&---------------------------------------------------------------------*
*       Save customize layout
*----------------------------------------------------------------------*
FORM 0100_PROCESS_FC_SAVE_CUST .
  DATA:
    LT_XCUSTOMIZE    TYPE W3MIMETABTYPE, "W3HTMLTABTYPE
    LO_WIN_CHART     TYPE REF TO CL_GUI_CHART_ENGINE_WIN,
    LW_FILESIZE      TYPE I,
    LT_COMPONENTS    TYPE SBDST_COMPONENTS,
    LT_CONTENT       TYPE SBDST_CONTENT,
    LW_OBJECT_KEY    TYPE SBDST_OBJECT_KEY,
    LS_SIGNATURE     TYPE BAPISIGNAT,
    LT_SIGNATURE     TYPE SBDST_SIGNATURE,
    LS_CHA_CUSTOMIZE TYPE ZTB_BM_CHA_CUST.

  CATCH SYSTEM-EXCEPTIONS MOVE_CAST_ERROR = 1.
    LO_WIN_CHART ?= GO_CHART_ENGINE->GET_CONTROL( ).
  ENDCATCH.
  IF SY-SUBRC IS INITIAL.
*   Get customizing
    CALL METHOD LO_WIN_CHART->GET_CUSTOMIZING
      IMPORTING
        XDATA_TABLE = LT_XCUSTOMIZE.

*   Convert to document data
    CALL FUNCTION 'ZFM_BM_BINARY_TO_BINARY'
      EXPORTING
        IT_SOURCE_BIN      = LT_XCUSTOMIZE
      IMPORTING
        E_LENGTH           = LW_FILESIZE
        ET_DESTINATION_BIN = LT_CONTENT.

*   Init document components, signatures
    PERFORM 9999_CHART_STD_CUST_DOC_INIT
      USING LW_FILESIZE
      CHANGING LT_COMPONENTS
               LT_SIGNATURE.

*   Create new chart customizing doc
    IF GS_BM_CHART_CONF-CUST_DOC_ID IS INITIAL.
      CALL FUNCTION 'BDS_BUSINESSDOCUMENT_CREA_TAB'
        EXPORTING
          CLASSNAME     = GC_CHA_CUST_CLASSNAME
          CLASSTYPE     = GC_CHA_CUST_CLASSTYPE
          OBJECT_KEY    = GS_BM_CHART_CONF-CUST_OBJKEY
        IMPORTING
          OBJECT_KEY    = LW_OBJECT_KEY
        TABLES
          SIGNATURE     = LT_SIGNATURE
          COMPONENTS    = LT_COMPONENTS
          CONTENT       = LT_CONTENT
        EXCEPTIONS
          NOTHING_FOUND = 1
          OTHERS        = 7.

*     Log to DB
      READ TABLE LT_SIGNATURE INTO LS_SIGNATURE INDEX 1.

      LS_CHA_CUSTOMIZE-REPORT   = GS_BM_CHART_CONF-REPID.
      LS_CHA_CUSTOMIZE-TABNAME  = GS_BM_CHART_CONF-TABNAME.
      LS_CHA_CUSTOMIZE-UNAME    = SPACE.
      LS_CHA_CUSTOMIZE-OBJKEY   = GS_BM_CHART_CONF-CUST_OBJKEY.
      LS_CHA_CUSTOMIZE-DOC_ID   = LS_SIGNATURE-DOC_ID.

      INSERT ZTB_BM_CHA_CUST FROM LS_CHA_CUSTOMIZE.
      COMMIT WORK.
*   Update chart customizing doc
    ELSE.
      CALL FUNCTION 'BDS_BUSINESSDOCUMENT_UPD_TAB'
        EXPORTING
          CLASSNAME   = GC_CHA_CUST_CLASSNAME
          CLASSTYPE   = GC_CHA_CUST_CLASSTYPE
          OBJECT_KEY  = GS_BM_CHART_CONF-CUST_OBJKEY
          DOC_ID      = GS_BM_CHART_CONF-CUST_DOC_ID
          DOC_VER_NO  = 1
          DOC_VAR_ID  = 1
          BINARY_FLAG = 'X'
        TABLES
          COMPONENTS  = LT_COMPONENTS
          CONTENT     = LT_CONTENT
          SIGNATURE   = LT_SIGNATURE
        EXCEPTIONS
          OTHERS      = 7.
    ENDIF.
  ENDIF.

ENDFORM.                    " 0100_PROCESS_FC_SAVE_CUST

*&---------------------------------------------------------------------*
*&      Form  CHART_STD_CUST_LOAD_CONFIG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LPO_CHART_ENGINE  text
*----------------------------------------------------------------------*
FORM CHART_STD_CUST_LOAD_CONFIG
  CHANGING LPO_CHART_ENGINE   TYPE REF TO CL_GUI_CHART_ENGINE.
  DATA:
    LW_STR  TYPE STRING,
    LW_XSTR TYPE XSTRING.

* Generate chart type, dimension text
  PERFORM CHART_STD_LAYOUT_CONV_OUT
    CHANGING GS_BM_CHART_CONF.

* Generate XML customize
  CALL TRANSFORMATION ZTR_BM_CHART_CUSTOMIZE
    OPTIONS XML_HEADER = 'no'
    SOURCE DATA = GS_BM_CHART_CONF
    RESULT XML LW_XSTR.
* Use to check customize
  IF 1 = 2.
    CALL TRANSFORMATION ZTR_BM_CHART_CUSTOMIZE
      OPTIONS XML_HEADER = 'no'
      SOURCE DATA = GS_BM_CHART_CONF
      RESULT XML LW_STR.
  ENDIF.

* Set customize to chart
  LPO_CHART_ENGINE->SET_CUSTOMIZING( XDATA = LW_XSTR ).
  GW_CHART_XCUST = LW_XSTR.

  MOVE-CORRESPONDING GS_BM_CHART_CONF-GLOBAL
    TO ZST_BM_CHART_LAYO_GLOBAL.

ENDFORM.                    " CHART_STD_CUST_LOAD_CONFIG

*&---------------------------------------------------------------------*
*&      Form  CHART_STD_CUST_SCR_UPDATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LPO_CHART_ENGINE  text
*----------------------------------------------------------------------*
FORM CHART_STD_CUST_SCR_UPDATE
  CHANGING LPO_CHART_ENGINE   TYPE REF TO CL_GUI_CHART_ENGINE.
  DATA:
    LW_STR        TYPE STRING,
    LW_XSTR       TYPE XSTRING,
    LO_WIN_CHART  TYPE REF TO CL_GUI_CHART_ENGINE_WIN,
    LT_XCUSTOMIZE TYPE W3MIMETABTYPE,
    LW_LENGTH     TYPE I,
    LO_XML        TYPE REF TO CL_XML_DOCUMENT,
    LO_NODE       TYPE REF TO IF_IXML_NODE,
    LW_RC         TYPE I.

* Generate chart type, dimension text
  PERFORM CHART_STD_LAYOUT_CONV_OUT
    CHANGING GS_BM_CHART_CONF.

  MOVE-CORRESPONDING GS_BM_CHART_CONF-GLOBAL
    TO ZST_BM_CHART_LAYO_GLOBAL.

  CATCH SYSTEM-EXCEPTIONS MOVE_CAST_ERROR = 1.
    LO_WIN_CHART ?= GO_CHART_ENGINE->GET_CONTROL( ).
  ENDCATCH.
  CHECK SY-SUBRC IS INITIAL.

* Get customizing
  CALL METHOD LO_WIN_CHART->GET_CUSTOMIZING
    IMPORTING
      XDATA_TABLE = LT_XCUSTOMIZE.

  LW_LENGTH = LINES( LT_XCUSTOMIZE ) * 255.
  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      INPUT_LENGTH = LW_LENGTH
    IMPORTING
      BUFFER       = LW_XSTR
    TABLES
      BINARY_TAB   = LT_XCUSTOMIZE.

* Set XML customize to document to process
  CREATE OBJECT LO_XML.
  CALL METHOD LO_XML->PARSE_XSTRING
    EXPORTING
      STREAM = LW_XSTR.

* Search node Dimension update
  LO_NODE = LO_XML->FIND_NODE( NAME = 'Dimension' ).
  CALL METHOD LO_NODE->SET_VALUE
    EXPORTING
      VALUE = GS_BM_CHART_CONF-DIMENSION_TX
    RECEIVING
      RVAL  = LW_RC.

* Search node ChartType update
  LO_NODE = LO_XML->FIND_NODE( NAME = 'ChartType' ).
  CALL METHOD LO_NODE->SET_VALUE
    EXPORTING
      VALUE = GS_BM_CHART_CONF-CHARTTYPE_TX
    RECEIVING
      RVAL  = LW_RC.

* Render customize to Xstring
  CALL METHOD LO_XML->RENDER_2_XSTRING
    IMPORTING
      STREAM = LW_XSTR
      SIZE   = LW_LENGTH.

* Set customize to chart
  LPO_CHART_ENGINE->SET_CUSTOMIZING( XDATA = LW_XSTR ).

ENDFORM.                    " CHART_STD_CUST_SCR_UPDATE

*&---------------------------------------------------------------------*
*&      Form  CHART_STD_CUST_LOAD_DOC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LPO_CHART_ENGINE  text
*----------------------------------------------------------------------*
FORM CHART_STD_CUST_LOAD_DOC
  CHANGING LPO_CHART_ENGINE   TYPE REF TO CL_GUI_CHART_ENGINE.
  DATA:
    LT_COMPONENTS TYPE SBDST_COMPONENTS,
    LT_CONTENT    TYPE RSSEM_UI_YT_DOC_AS_CONTENT,
    LT_SIGNATURE  TYPE RSZW_T_BAPISIGNAT,
    LW_LENGTH     TYPE I.

* Get customizing file info on server
  CALL FUNCTION 'BDS_BUSINESSDOCUMENT_GET_INFO'
    EXPORTING
      CLASSNAME  = GC_CHA_CUST_CLASSNAME
      CLASSTYPE  = GC_CHA_CUST_CLASSTYPE
      OBJECT_KEY = GS_BM_CHART_CONF-CUST_OBJKEY
    TABLES
      SIGNATURE  = LT_SIGNATURE
      COMPONENTS = LT_COMPONENTS
    EXCEPTIONS
      OTHERS     = 7.
  IF SY-SUBRC IS INITIAL.
*   Get customizing data
    CALL FUNCTION 'BDS_BUSINESSDOCUMENT_GET_TAB'
      EXPORTING
        CLASSNAME     = GC_CHA_CUST_CLASSNAME
        CLASSTYPE     = GC_CHA_CUST_CLASSTYPE
        OBJECT_KEY    = GS_BM_CHART_CONF-CUST_OBJKEY
      TABLES
        SIGNATURE     = LT_SIGNATURE
        COMPONENTS    = LT_COMPONENTS
        ASCII_CONTENT = LT_CONTENT
      EXCEPTIONS
        OTHERS        = 7.

    IF 1 = 1.
      CALL TRANSFORMATION ID
        SOURCE XML LT_CONTENT
        RESULT XML GW_CHART_XCUST.
    ELSE.
      LW_LENGTH = LINES( LT_CONTENT ) * 1022.
*     Convert to Xstring
      CALL FUNCTION 'SCMS_FTEXT_TO_XSTRING'
        EXPORTING
          INPUT_LENGTH = LW_LENGTH
        IMPORTING
          BUFFER       = GW_CHART_XCUST
        TABLES
          FTEXT_TAB    = LT_CONTENT.
    ENDIF.

*   Set net config to chart
    LPO_CHART_ENGINE->SET_CUSTOMIZING( XDATA = GW_CHART_XCUST ).
  ENDIF.

* Update customize setting to screen
  PERFORM 9999_CHART_STD_CUST_TO_SCR
    USING GW_CHART_XCUST.

ENDFORM.                    " CHART_STD_CUST_LOAD_DOC

*&---------------------------------------------------------------------*
*&      Form  9999_CHART_STD_CUST_DOC_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LW_FILESIZE  text
*      <--LPT_COMPONENTS  text
*      <--LPT_SIGNATURE  text
*----------------------------------------------------------------------*
FORM 9999_CHART_STD_CUST_DOC_INIT
  USING LW_FILESIZE           TYPE I
  CHANGING LPT_COMPONENTS     TYPE SBDST_COMPONENTS
           LPT_SIGNATURE      TYPE SBDST_SIGNATURE.
  DATA:
    LS_COMPONENTS TYPE BAPICOMPON,
    LS_SIGNATURE  TYPE BAPISIGNAT.

* Init component
  LS_COMPONENTS-DOC_COUNT   = 1.
  LS_COMPONENTS-COMP_COUNT  = 1.
  LS_COMPONENTS-COMP_SIZE   = LW_FILESIZE.
  LS_COMPONENTS-MIMETYPE    = 'text/xml'.
  LS_COMPONENTS-COMP_ID     = 'Chart customizing.xml'.
  APPEND LS_COMPONENTS TO LPT_COMPONENTS.

* Init signature
  LS_SIGNATURE-DOC_COUNT    = '1'.
  LS_SIGNATURE-PROP_NAME    = 'BDS_DOCUMENTTYPE'.
  LS_SIGNATURE-PROP_VALUE   = 'BDS_ATTACH'.
  APPEND LS_SIGNATURE TO LPT_SIGNATURE.

  LS_SIGNATURE-PROP_NAME    = 'BDS_DOCUMENTCLASS'.
  LS_SIGNATURE-PROP_VALUE   = 'XML'.
  APPEND LS_SIGNATURE TO LPT_SIGNATURE.

  LS_SIGNATURE-PROP_NAME    = 'DESCRIPTION'.
  LS_SIGNATURE-PROP_VALUE   = 'Chart customizing'.
  APPEND LS_SIGNATURE TO LPT_SIGNATURE.

  LS_SIGNATURE-PROP_NAME    = 'LANGUAGE'.
  LS_SIGNATURE-PROP_VALUE   = 'E'.
  APPEND LS_SIGNATURE TO LPT_SIGNATURE.

ENDFORM.                    " 9999_CHART_STD_CUST_DOC_INIT

*&---------------------------------------------------------------------*
*&      Form  9999_CHART_STD_CUST_TO_SCR
*&---------------------------------------------------------------------*
*       Update customize setting to screen
*----------------------------------------------------------------------*
*      -->LPW_CUS_XSTRING  text
*----------------------------------------------------------------------*
FORM 9999_CHART_STD_CUST_TO_SCR
  USING LPW_CUS_XSTRING       TYPE XSTRING.

  DATA:
    LO_XML  TYPE REF TO CL_XML_DOCUMENT,
    LO_NODE TYPE REF TO IF_IXML_NODE.

* Set XML customize to document to process
  CREATE OBJECT LO_XML.
  CALL METHOD LO_XML->PARSE_XSTRING
    EXPORTING
      STREAM = LPW_CUS_XSTRING.

* Search node Dimension to set screen
  LO_NODE = LO_XML->FIND_NODE( NAME = 'Dimension' ).
  CALL METHOD LO_XML->GET_NODE_VALUE
    EXPORTING
      NODE  = LO_NODE
    RECEIVING
      VALUE = GS_BM_CHART_CONF-DIMENSION_TX.

* Search node ChartType to set screen
  LO_NODE = LO_XML->FIND_NODE( NAME = 'ChartType' ).
  CALL METHOD LO_XML->GET_NODE_VALUE
    EXPORTING
      NODE  = LO_NODE
    RECEIVING
      VALUE = GS_BM_CHART_CONF-CHARTTYPE_TX.

* Convert ChartType, Dimension output to input
  PERFORM CHART_STD_LAYOUT_CONV_IN
    CHANGING GS_BM_CHART_CONF.

* Update screen
  MOVE-CORRESPONDING GS_BM_CHART_CONF-GLOBAL
    TO ZST_BM_CHART_LAYO_GLOBAL.

ENDFORM.                    " 9999_CHART_STD_CUST_TO_SCR

*&---------------------------------------------------------------------*
*&      Form  0100_PROCESS_FC_PRINT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0100_PROCESS_FC_PRINT .
  DATA:
    LO_WIN_CHART   TYPE REF TO CL_GUI_CHART_ENGINE_WIN,
    LO_IGS_DATA    TYPE REF TO CL_IGS_DATA,
    LO_XML         TYPE REF TO CL_XML_DOCUMENT,
    LO_NODE        TYPE REF TO IF_IXML_NODE,
    LO_NODE_GLB    TYPE REF TO IF_IXML_NODE,
    LW_RC          TYPE I,
    LT_CUSTOMIZE   TYPE W3MIMETABTYPE,
    LT_IMAGE_MIME  TYPE W3MIMETABTYPE,
    LW_TABLE_INDEX TYPE I.
  DATA:
    LW_FILENAME TYPE STRING,
    LW_FILEPATH TYPE STRING,
    LW_FILESIZE TYPE I,
    LW_PATH     TYPE STRING.

  CATCH SYSTEM-EXCEPTIONS MOVE_CAST_ERROR = 1.
    LO_WIN_CHART ?= GO_CHART_ENGINE->GET_CONTROL( ).
  ENDCATCH.
  CHECK SY-SUBRC IS INITIAL.

  CREATE OBJECT LO_IGS_DATA.

* Set XML customize to document to process
  CREATE OBJECT LO_XML.

  CALL METHOD LO_WIN_CHART->GET_CUSTOMIZING
    IMPORTING
      XDATA_TABLE = LT_CUSTOMIZE.
  LW_FILESIZE = LINES( LT_CUSTOMIZE ) * 255.
  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      INPUT_LENGTH = LW_FILESIZE
    IMPORTING
      BUFFER       = GW_CHART_XCUST
    TABLES
      BINARY_TAB   = LT_CUSTOMIZE.

  CALL METHOD LO_XML->PARSE_XSTRING
    EXPORTING
      STREAM = GW_CHART_XCUST.

* Search node Dimension update
  LO_NODE_GLB = LO_XML->FIND_NODE( NAME = 'GlobalSettings' ).
  CALL METHOD LO_XML->CREATE_SIMPLE_ELEMENT
    EXPORTING
      NAME     = 'FileType'
      VALUE    = 'PNG'
      PARENT   = LO_NODE_GLB
    RECEIVING
      NEW_NODE = LO_NODE.

  CALL METHOD LO_XML->CREATE_SIMPLE_ELEMENT
    EXPORTING
      NAME     = 'Height'
      VALUE    = '768'
      PARENT   = LO_NODE_GLB
    RECEIVING
      NEW_NODE = LO_NODE.

  CALL METHOD LO_XML->CREATE_SIMPLE_ELEMENT
    EXPORTING
      NAME     = 'Width'
      VALUE    = '1280'
      PARENT   = LO_NODE_GLB
    RECEIVING
      NEW_NODE = LO_NODE.

* Render customize to Xstring
  CALL METHOD LO_XML->RENDER_2_XSTRING
    IMPORTING
      STREAM = GW_CHART_XCUST
      SIZE   = LW_FILESIZE.

  CALL METHOD LO_IGS_DATA->ADD_XSTRING
    EXPORTING
      INPUT  = GW_CHART_XDATA
      NAME   = 'DATA'
    RECEIVING
      RESULT = LW_RC.

  CALL METHOD LO_IGS_DATA->ADD_XSTRING
    EXPORTING
      INPUT  = GW_CHART_XCUST
      NAME   = 'CUSTOM'
    RECEIVING
      RESULT = LW_RC.

  CALL METHOD LO_IGS_DATA->SEND
    EXPORTING
      RFCDESTINATION          = 'IGS_RFC_DEST'
      FARM_TYPE               = 'XMLCHART'
    EXCEPTIONS
      RFC_COMMUNICATION_ERROR = 1
      RFC_SYSTEM_ERROR        = 2
      INTERNAL_ERROR          = 3
      OTHERS                  = 4.
  IF SY-SUBRC IS INITIAL.
    LW_TABLE_INDEX = LO_IGS_DATA->GET_INDEX_BY_NAME( 'Picture' ).
    IF LW_TABLE_INDEX GT 0.
      CALL METHOD LO_IGS_DATA->GET_TABLE
        EXPORTING
          NUMBER = LW_TABLE_INDEX
        IMPORTING
          LENGTH = LW_FILESIZE
          TABLE  = LT_IMAGE_MIME.
    ENDIF.

    LW_FILENAME = 'chart.png'.
    CALL FUNCTION 'ZFM_POPUP_FILE_SAVE'
      EXPORTING
        I_FILENAME  = LW_FILENAME
        IT_FILEDATA = LT_IMAGE_MIME
        I_FILESIZE  = LW_FILESIZE.
  ENDIF.

*  CALL METHOD LO_WIN_CHART->PRINT.

ENDFORM.                    " 0100_PROCESS_FC_PRINT
