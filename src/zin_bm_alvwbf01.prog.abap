*&---------------------------------------------------------------------*
*&  Include           ZIN_BM_ALVWBF01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  0000_MAIN_PROC
*&---------------------------------------------------------------------*
*       Main process
*----------------------------------------------------------------------*
FORM 0000_MAIN_PROC .
* Get program config
  PERFORM 0010_GET_DATA.

* Process configs
  PERFORM 0020_PROCESS_DATA.

* Show workbench
  PERFORM 0030_SHOW_DATA.

ENDFORM.                    " 0000_MAIN_PROC

*&---------------------------------------------------------------------*
*&      Form  0010_GET_DATA
*&---------------------------------------------------------------------*
*       Get program configs
*----------------------------------------------------------------------*
FORM 0010_GET_DATA .
* Get program config
  SELECT SINGLE *
    FROM ZTB_PROG
    INTO GS_PROG
   WHERE REPID = P_REPORT.
  IF SY-SUBRC IS NOT INITIAL.
    GS_PROG-MANDT             = SY-MANDT.
    GS_PROG-REPID             = P_REPORT.
    GS_PROG-CFALV             = GC_XMARK.
  ENDIF.

* Get ALV layout
  SELECT *
    FROM ZTB_BM_ALV_LAYO
    INTO TABLE GT_ALV_LAYO_DB
   WHERE REPORT = P_REPORT.

  CALL FUNCTION 'ZFM_DATA_TABLE_MOVE_CORRESPOND'
    CHANGING
      C_SRC_TAB = GT_ALV_LAYO_DB
      C_DES_TAB = GT_COMP_TREE.

* Get ALV layout
  SELECT *
    FROM ZTB_BM_ALV_FCAT
    INTO TABLE GT_ALV_FCAT
   WHERE REPORT = P_REPORT.
  SORT GT_ALV_FCAT BY FNAME COL_POS.
  GT_ALV_FCAT_O = GT_ALV_FCAT.

ENDFORM.                    " 0010_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  0020_PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0020_PROCESS_DATA .

  SET PARAMETER ID 'DTB' FIELD GS_PROG-ALVSTR.

* Init tree section
  PERFORM 0022_COMP_TREE_GEN_ROOTS.

* Prepare component tree data
  PERFORM 0025_COMP_TREE_GEN_COMPS_LV3.

ENDFORM.                    " 0020_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  0030_SHOW_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0030_SHOW_DATA .
* Show config data
  CALL SCREEN 0100.
ENDFORM.                    " 0030_SHOW_DATA

*&---------------------------------------------------------------------*
*&      Form  0100_PBO
*&---------------------------------------------------------------------*
*       PBO for screen 100
*----------------------------------------------------------------------*
FORM 0100_PBO.
* Init containers
  PERFORM 0100_INIT_CONTAINERS.

* Init tree components
  PERFORM 0100_INIT_TREE_COMPS.

* Init ALV template
  PERFORM 0100_INIT_ALV_TEMPLATE.
ENDFORM.                    " 0100_PBO

*&---------------------------------------------------------------------*
*&      Form  0100_INIT_CONTAINERS
*&---------------------------------------------------------------------*
*       Init container for screen 100
*----------------------------------------------------------------------*
FORM 0100_INIT_CONTAINERS.
  CHECK GO_CON_ROOT IS NOT BOUND.

* Create Root container
  CREATE OBJECT GO_CON_ROOT
    EXPORTING
      LIFETIME  = CNTL_LIFETIME_DYNPRO
      EXTENSION = CL_GUI_DOCKING_CONTAINER=>WS_MAXIMIZEBOX
    EXCEPTIONS
      OTHERS    = 6.

* Split root container to 2 columns
  CREATE OBJECT GO_SPLIT1
    EXPORTING
      PARENT  = GO_CON_ROOT
      ROWS    = 1
      COLUMNS = 2
    EXCEPTIONS
      OTHERS  = 1.
  IF SY-SUBRC NE 0 .
    MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 .
    EXIT .
  ENDIF .

* Set row mode absolute
  GO_SPLIT1->SET_ROW_MODE(
    EXPORTING MODE = CL_GUI_SPLITTER_CONTAINER=>MODE_ABSOLUTE ).

* Set left column width
  GO_SPLIT1->SET_COLUMN_WIDTH( ID = 1 WIDTH = 30 ).

* Init config and template containers
  GO_CON_CONFIG     = GO_SPLIT1->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
  GO_CON_TEMPLATE   = GO_SPLIT1->GET_CONTAINER( ROW = 1 COLUMN = 2 ).

* Split config container to 2 row
  CREATE OBJECT GO_SPLIT2
    EXPORTING
      PARENT  = GO_CON_CONFIG
      ROWS    = 2
      COLUMNS = 1
    EXCEPTIONS
      OTHERS  = 1.
  IF SY-SUBRC NE 0 .
    MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 .
    EXIT .
  ENDIF .

* Init Component and component config values containers
  GO_CON_COMPONENT  = GO_SPLIT2->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
  GO_CON_COMCONFIG  = GO_SPLIT2->GET_CONTAINER( ROW = 2 COLUMN = 1 ).

ENDFORM.                    " 0100_INIT_CONTAINERS

*&---------------------------------------------------------------------*
*&      Form  0100_INIT_TREE_COMPS
*&---------------------------------------------------------------------*
*       Init tree components
*----------------------------------------------------------------------*
FORM 0100_INIT_TREE_COMPS .
  DATA:
    LS_VARIANT                TYPE DISVARIANT,
    LS_TREE_HEADER            TYPE TREEV_HHDR,
    LW_HEIGHT                 TYPE I VALUE 30.

  IF LINES( GT_COMP_TREE ) * 5 > LW_HEIGHT.
    LW_HEIGHT = LINES( GT_COMP_TREE ) * 5.
  ENDIF.

* Set top row Height
  CALL METHOD GO_SPLIT2->SET_ROW_HEIGHT
    EXPORTING
      ID     = 1
      HEIGHT = LW_HEIGHT.
  CALL METHOD CL_GUI_CFW=>FLUSH.

  IF GO_COMPTREE IS NOT BOUND.
*   Prepare variant
    LS_VARIANT-REPORT = SY-REPID.
    LS_VARIANT-HANDLE = 'COMP'.

*   Prepare heading of tree
    LS_TREE_HEADER-T_IMAGE = GC_NODE_IMG-PROGRAM.
    LS_TREE_HEADER-HEADING = TEXT-THD.
    LS_TREE_HEADER-TOOLTIP = LS_TREE_HEADER-HEADING.

*   First display of tree
    CALL FUNCTION 'ZFM_BM_ALV_TREE_FIRST_DISPLAY'
      EXPORTING
        I_LASTCOL          = '5'
        IS_VARIANT         = LS_VARIANT
        I_CUS_CONTAINER    = GO_CON_COMPONENT
        I_ITEM_SELECTION   = SPACE
        I_HIERARCHY_HEADER = LS_TREE_HEADER
      IMPORTING
        E_TREE_CONTROL     = GO_COMPTREE
      CHANGING
        T_TREE_TAB         = GT_COMP_TREE.

*   Register events for component tree
    PERFORM 9999_COMP_TREE_REG_EVENTS.
  ELSE.
*   Refresh tree
    CALL FUNCTION 'ZFM_BM_ALV_TREE_REFRESH'
      CHANGING
        C_TREE_CONTROL = GO_COMPTREE
        T_TREE_TAB     = GT_COMP_TREE.
  ENDIF.

ENDFORM.                    " 0100_INIT_TREE_COMPS

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_CONFIG_SHOW
*&---------------------------------------------------------------------*
*       Show config of component
*----------------------------------------------------------------------*
FORM 9999_COMP_CONFIG_SHOW
  USING LPS_COMPONENT         TYPE ZST_BM_ALV_LAYO.
  DATA:
    LS_CAPTION                TYPE SBPTCAPTN.

* Set bar to initial
  PERFORM 9999_COMP_CONFIG_BAR_INIT
    USING LPS_COMPONENT.

* Generate component config
  CASE LPS_COMPONENT-NODELV.
    WHEN GC_NODE_LEVEL-CONTEXT.
*     Generate config for context
      PERFORM 9999_COMP_CONFIG_GEN_CONTEXT
        CHANGING LS_CAPTION.
    WHEN GC_NODE_LEVEL-COMPONENT.
      CASE LPS_COMPONENT-NODECODE.
        WHEN GC_NODE_CODE-COMP_HEAD.
*         Generate config for header component
          PERFORM 9999_COMP_CONFIG_GEN_HEAD
            USING LPS_COMPONENT.

        WHEN GC_NODE_CODE-COMP_DETL.
*         Generate config for Detail component
          PERFORM 9999_COMP_CONFIG_GEN_DETL
            USING LPS_COMPONENT.

        WHEN OTHERS.
      ENDCASE.
    WHEN OTHERS.
  ENDCASE.

* Show Bar list of component configs
  PERFORM 9999_COMP_CONFIG_DISPLAY.

ENDFORM.                    " 9999_COMP_CONFIG_SHOW

*&---------------------------------------------------------------------*
*&      Form  0100_INIT_ALV_TEMPLATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM 0100_INIT_ALV_TEMPLATE.
  DATA:
    LS_LAYOUT                 TYPE LVC_S_LAYO,
    LS_VARIANT                TYPE DISVARIANT,
    LT_HEADER                 TYPE ZTT_ALV_HEADER,
    LW_HEIGHT                 TYPE I,
    LS_LOGO                   TYPE ZST_BM_ALV_LOGO,
    LW_ALV_STR                TYPE TABNAME,
    LT_FIELDCAT               TYPE LVC_T_FCAT.

  IF <GFT_ALV_DATA> IS NOT ASSIGNED.
*   Init demo context data
    PERFORM 9999_ALV_TEMPL_INIT_OUTTAB.
  ENDIF.

  CHECK <GFT_ALV_DATA> IS ASSIGNED.

* Gen ALV header, get structure name
  PERFORM 9999_ALV_TEMPL_GET_INFO
    CHANGING LW_ALV_STR
             LT_HEADER
             LW_HEIGHT
             LT_FIELDCAT
             LS_LOGO.
  LS_LAYOUT-CWIDTH_OPT        = GC_XMARK.

  IF GO_ALV_GRID IS NOT BOUND.
*   First display
    CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR'
      EXPORTING
        I_STRUCTURE_NAME  = LW_ALV_STR
        IS_LAYOUT         = LS_LAYOUT
        I_GUI_CONTAINER   = GO_CON_TEMPLATE
        IT_HEADER         = LT_HEADER
        I_LOGO            = LS_LOGO
        I_SHOW_TOTAL_INFO = SPACE
      IMPORTING
        E_ALV_GRID        = GO_ALV_GRID
        E_ALV_HEADER_DOC  = GO_ALV_HEADER_DOC
      CHANGING
        IT_OUTTAB         = <GFT_ALV_DATA>
        IT_FIELDCATALOG   = LT_FIELDCAT.
  ELSE.
    IF GO_ALV_HEADER_DOC IS INITIAL
    AND LT_HEADER IS NOT INITIAL.
      CALL METHOD GO_ALV_GRID->FREE.

      CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR'
        EXPORTING
          I_STRUCTURE_NAME  = LW_ALV_STR
          IS_LAYOUT         = LS_LAYOUT
          I_GUI_CONTAINER   = GO_CON_TEMPLATE
          IT_HEADER         = LT_HEADER
          I_LOGO            = LS_LOGO
          I_SHOW_TOTAL_INFO = SPACE
        IMPORTING
          E_ALV_GRID        = GO_ALV_GRID
          E_ALV_HEADER_DOC  = GO_ALV_HEADER_DOC
        CHANGING
          IT_OUTTAB         = <GFT_ALV_DATA>
          IT_FIELDCATALOG   = LT_FIELDCAT.

    ELSE.
*     Refresh
      CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR_REFRESH'
        EXPORTING
          I_ALV_GRID       = GO_ALV_GRID
          I_ALV_HEADER_DOC = GO_ALV_HEADER_DOC
          IT_HEADER        = LT_HEADER
          I_LOGO           = LS_LOGO
          I_HEIGHT         = LW_HEIGHT
          IS_LAYOUT        = LS_LAYOUT
          IT_FIELDCAT      = LT_FIELDCAT.
    ENDIF.

  ENDIF.

ENDFORM.                    " 0100_INIT_ALV_TEMPLATE

*&---------------------------------------------------------------------*
*&       Class (Implementation)  LCL_WB_HANDLER
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS LCL_WB_HANDLER IMPLEMENTATION.

  METHOD HNDL_NODE_CONTEXT_MENU_REQ.
    DATA:
      LW_TEXT                 TYPE GUI_TEXT,
      LS_ALV_LAYOUT           TYPE ZST_BM_ALV_LAYO.

*   Get component info
    READ TABLE GT_COMP_TREE INTO LS_ALV_LAYOUT
      WITH KEY TREEKEY = NODE_KEY.
    CHECK SY-SUBRC IS INITIAL.

    CASE LS_ALV_LAYOUT-NODELV.
*     Section
      WHEN GC_NODE_LEVEL-SECTION.
        IF LS_ALV_LAYOUT-AGGRKEY = GC_TREE_KEY-SECT_DETL.
          READ TABLE GT_COMP_TREE TRANSPORTING NO FIELDS
            WITH KEY IS_ITEM = GC_XMARK.
          CHECK SY-SUBRC IS NOT INITIAL.
        ENDIF.
        LW_TEXT = TEXT-C02 .  "Create component
        MENU->ADD_FUNCTION( FCODE     = C_FCODE-COMP_ADD_CHILD
                            ICON      = ICON_CREATE
                            TEXT      = LW_TEXT ).
      WHEN GC_NODE_LEVEL-COMPONENT.
*       Process by node code
        CASE LS_ALV_LAYOUT-NODECODE.
*         Header
          WHEN GC_NODE_CODE-COMP_HEAD.
            LW_TEXT = TEXT-C01 .  "Delete component
            MENU->ADD_FUNCTION( FCODE     = C_FCODE-COMP_DELETE
                                ICON      = ICON_DELETE
                                TEXT      = LW_TEXT ).

            LW_TEXT = TEXT-C03 .  "Clone component
            MENU->ADD_FUNCTION( FCODE     = C_FCODE-COMP_CLONE
                                ICON      = ICON_COPY_OBJECT
                                TEXT      = LW_TEXT ).
*         Detail
          WHEN GC_NODE_CODE-COMP_DETL.
            LW_TEXT = TEXT-C01 .  "Delete component
            MENU->ADD_FUNCTION( FCODE     = C_FCODE-COMP_DELETE
                                ICON      = ICON_DELETE
                                TEXT      = LW_TEXT ).
          WHEN OTHERS.
        ENDCASE.
      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD .                    "HNDL_NODE_CONTEXT_MENU_REQ

  METHOD HNDL_SELECTION_CHANGED .
    DATA:
      LS_COMPONENT          TYPE ZST_BM_ALV_LAYO,
      LS_CAPTION            TYPE SBPTCAPTN,
      LW_ID                 TYPE I.

*   Get currrent component
    READ TABLE GT_COMP_TREE INTO LS_COMPONENT
      WITH KEY TREEKEY = NODE_KEY.
    CHECK SY-SUBRC IS INITIAL.

*   Show config of current component
    PERFORM 9999_COMP_CONFIG_SHOW
      USING LS_COMPONENT.

  ENDMETHOD .                    "HNDL_SELECTION_CHANGED

  METHOD HNDL_NODE_CONTEXT_MENU_SEL .
    PERFORM 9999_COMP_TREE_HANDLE_FCODE
      USING NODE_KEY FCODE.

  ENDMETHOD .                    "HNDL_NODE_CONTEXT_MENU_SEL

  METHOD HNDL_TOOLBAR_FCODE .

  ENDMETHOD .                    "HNDL_TOOLBAR_FCODE

  METHOD HNDL_TAB_CLICKED.
    DATA:
      LS_CAPTION_CURR         TYPE SBPTCAPTN,
      LS_CAPTION_DUMMY        TYPE SBPTCAPTN.
    FIELD-SYMBOLS:
      <LF_COMPONENT>          TYPE ZST_BM_ALV_LAYO.

*   Get current tab clicked
    READ TABLE GT_CAPTIONS INTO LS_CAPTION_CURR
      WITH KEY NAME = NAME.
    CHECK SY-SUBRC IS INITIAL.

*   Get component of tab
    READ TABLE GT_CAPTIONS INTO LS_CAPTION_DUMMY
      WITH KEY NAME = GC_CAPTION-DUMMY.
    READ TABLE GT_COMP_TREE ASSIGNING <LF_COMPONENT>
      WITH KEY TREEKEY = LS_CAPTION_DUMMY-CAPTION.
    CHECK <LF_COMPONENT> IS ASSIGNED.

    CASE NAME.
      WHEN GC_CAPTION-CONTEXT.
*       Popup to get new value
        PERFORM 9999_COMP_CONFIG_CHG_CONTEXT
          CHANGING LS_CAPTION_CURR
                   <LF_COMPONENT>.

      WHEN GC_CAPTION-COMPONENT. " Do nothing
      WHEN GC_CAPTION-HEAD_POSID
        OR GC_CAPTION-HEAD_TYP
        OR GC_CAPTION-HEAD_HKEY
        OR GC_CAPTION-HEAD_PREFIX
        OR GC_CAPTION-HEAD_SUFFIX
        OR GC_CAPTION-DETL_COLS
        OR GC_CAPTION-DETL_STYLEFNAME.
*       Popup to get new value
        PERFORM 9999_COMP_CONFIG_CHG_COMP_LV3
          CHANGING LS_CAPTION_CURR
                  <LF_COMPONENT>.

*       Refresh ALV template
        PERFORM 0100_INIT_ALV_TEMPLATE.

      WHEN GC_CAPTION-DETL_FCAT.
*       Change setting columns
        PERFORM 9999_COMP_CONFIG_COLS_LAYOUT.
      WHEN OTHERS.
    ENDCASE.

    CALL METHOD GO_CON_BAR->SET_ACTIVE
      EXPORTING
        NAME                = GC_CAPTION-DUMMY
      EXCEPTIONS
        CELL_DOES_NOT_EXIST = 1
        OTHERS              = 2.

  ENDMETHOD.                    "HNDL_TAB_CLICKED

ENDCLASS.               "LCL_WB_HANDLER

*&---------------------------------------------------------------------*
*&      Form  0022_COMP_TREE_GEN_ROOTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0022_COMP_TREE_GEN_ROOTS.
  DATA:
    LS_ALV_LAYO               TYPE ZST_BM_ALV_LAYO.

* Add node for program
  PERFORM 9999_COMP_TREE_GEN_CONTEXT
    CHANGING LS_ALV_LAYO.
  APPEND LS_ALV_LAYO TO GT_COMP_TREE.

* Init node level and node code
  LS_ALV_LAYO-NODELV          = GC_NODE_LEVEL-SECTION.
  LS_ALV_LAYO-AGPRKEY         = GC_TREE_KEY-CONTEXT.

* Init header section
  LS_ALV_LAYO-TREETEXT        = TEXT-T01.
  LS_ALV_LAYO-NODECODE        = GC_NODE_CODE-COMP_HEAD.
  LS_ALV_LAYO-AGGRKEY         = GC_TREE_KEY-SECT_HEAD.
  LS_ALV_LAYO-NODE_LAYOUT-ISFOLDER  = GC_XMARK.
  LS_ALV_LAYO-NODE_LAYOUT-N_IMAGE   =
  LS_ALV_LAYO-NODE_LAYOUT-EXP_IMAGE = GC_NODE_IMG-SECT_HEAD.
  APPEND LS_ALV_LAYO TO GT_COMP_TREE.

* Init Detail section
  LS_ALV_LAYO-TREETEXT        = TEXT-T02.
  LS_ALV_LAYO-NODECODE        = GC_NODE_CODE-COMP_DETL.
  LS_ALV_LAYO-AGGRKEY         = GC_TREE_KEY-SECT_DETL.
  LS_ALV_LAYO-NODE_LAYOUT-ISFOLDER  = GC_XMARK.
  LS_ALV_LAYO-NODE_LAYOUT-N_IMAGE   =
  LS_ALV_LAYO-NODE_LAYOUT-EXP_IMAGE = GC_NODE_IMG-SECT_DETL.
  APPEND LS_ALV_LAYO TO GT_COMP_TREE.

ENDFORM.                    " 0022_COMP_TREE_GEN_ROOTS

*&---------------------------------------------------------------------*
*&      Form  0025_COMP_TREE_GEN_COMPS_LV3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0025_COMP_TREE_GEN_COMPS_LV3.
  FIELD-SYMBOLS:
    <LF_ALV_LAYO>             TYPE ZST_BM_ALV_LAYO.

  LOOP AT GT_COMP_TREE ASSIGNING <LF_ALV_LAYO>
    WHERE FNAME IS NOT INITIAL.
*   Generate tree data of each component
    PERFORM 9999_COMP_TREE_GEN_COMP_LV3
      CHANGING <LF_ALV_LAYO>.

  ENDLOOP.

ENDFORM.                    " 0025_COMP_TREE_GEN_COMPS_LV3

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_CONFIG_ADD_BAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_ATT_NAME  text
*      -->LPS_RECORD  text
*      <--LPT_CAPTIONS  text
*----------------------------------------------------------------------*
FORM 9999_COMP_CONFIG_ADD_BAR
  USING   LPW_ATT_NAME        TYPE FIELDNAME
          LPS_RECORD          TYPE ANY
 CHANGING LPT_CAPTIONS        TYPE SBPTCAPTNS.
  DATA:
    LS_CAPTION                TYPE SBPTCAPTN.

* Gen bar info
  PERFORM 9999_COMP_CONFIG_GEN_BAR_INFO
    USING LPW_ATT_NAME
          LPS_RECORD
    CHANGING LS_CAPTION.

  APPEND LS_CAPTION TO LPT_CAPTIONS .

ENDFORM.                    " 9999_COMP_CONFIG_ADD_BAR

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_CONFIG_GEN_BAR_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_ATT_NAME  text
*      -->LPS_RECORD  text
*      <--LPS_CAPTION  text
*----------------------------------------------------------------------*
FORM 9999_COMP_CONFIG_GEN_BAR_INFO
  USING   LPW_ATT_NAME        TYPE FIELDNAME
          LPS_RECORD          TYPE ZST_BM_ALV_LAYO
 CHANGING LPS_CAPTION         TYPE SBPTCAPTN.
  DATA:
    LW_ATT_VALUE              TYPE TEXT40,
    LS_FCAT                   TYPE LVC_S_FCAT.
  FIELD-SYMBOLS:
    <LF_ATT_VALUE>            TYPE ANY.

  LPS_CAPTION-ICON            = ICON_CHANGE_TEXT .
  LPS_CAPTION-NO_CLOSE        = GC_XMARK.
  LPS_CAPTION-INVISIBLE       = ABAP_OFF.
  LPS_CAPTION-NAME            = LPW_ATT_NAME.

  ASSIGN COMPONENT LPW_ATT_NAME OF STRUCTURE LPS_RECORD
    TO <LF_ATT_VALUE>.
  IF SY-SUBRC IS INITIAL.
    LW_ATT_VALUE              = <LF_ATT_VALUE>.
    CONDENSE LW_ATT_VALUE.

    READ TABLE GT_COMP_CONFIG INTO LS_FCAT
      WITH KEY FIELDNAME = LPW_ATT_NAME.
    IF SY-SUBRC IS INITIAL.
      CONCATENATE LS_FCAT-SCRTEXT_L
                  LW_ATT_VALUE
             INTO LPS_CAPTION-CAPTION
        SEPARATED BY ':'.
    ELSE.
      CONCATENATE LPS_CAPTION-NAME(15)
                  LW_ATT_VALUE
             INTO LPS_CAPTION-CAPTION
        SEPARATED BY ':' RESPECTING BLANKS.
    ENDIF.
  ELSE.
    LPS_CAPTION-CAPTION       = LPW_ATT_NAME.
  ENDIF.

ENDFORM.                    " 9999_COMP_CONFIG_GEN_BAR_INFO

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_CONFIG_CHG_COMP_LV3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_ATT_NAME        Attribute name
*      <--LPS_ALV_LAYOUT      ALV layout
*----------------------------------------------------------------------*
FORM 9999_COMP_CONFIG_CHG_COMP_LV3
  CHANGING  LPS_CAPTION       TYPE SBPTCAPTN
            LPS_ALV_LAYOUT    TYPE ZST_BM_ALV_LAYO.
  DATA:
    LW_RET_CODE               TYPE C.

* Popup to change data
  CALL FUNCTION 'ZFM_POPUP_SET_DATA_RECORD'
    EXPORTING
      I_SUB_TABNAME  = GC_TABLE-ALV_LAYOUT
      I_SUB_FNAME    = LPS_CAPTION-NAME
      I_SUB_REQUIRED = SPACE
    IMPORTING
      RETURNCODE     = LW_RET_CODE
    CHANGING
      C_RECORD       = LPS_ALV_LAYOUT.
  CHECK LW_RET_CODE IS INITIAL.

* Gen tree data to update screen
  PERFORM 9999_COMP_TREE_GEN_COMP_LV3
    CHANGING LPS_ALV_LAYOUT.

* Gen new value to bar info
  PERFORM 9999_COMP_CONFIG_GEN_BAR_INFO
    USING LPS_CAPTION-NAME
          LPS_ALV_LAYOUT
    CHANGING LPS_CAPTION.

* Update component frontend: tree node, bar
  PERFORM 9999_COMP_UPDATE_FRONT_END
    USING LPS_ALV_LAYOUT
          LPS_CAPTION.

ENDFORM.                    " 9999_COMP_CONFIG_CHG_COMP_LV3

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_CONFIG_CHG_CONTEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_ATT_NAME        Attribute name
*      <--LPS_ALV_LAYOUT      ALV layout
*----------------------------------------------------------------------*
FORM 9999_COMP_CONFIG_CHG_CONTEXT
  CHANGING LPS_CAPTION_CNTX   TYPE SBPTCAPTN
           LPS_COMP_CONTEXT   TYPE ZST_BM_ALV_LAYO.
  DATA:
    LW_RET_CODE               TYPE C.

  CALL FUNCTION 'ZFM_POPUP_SET_DATA_RECORD'
    EXPORTING
      I_SUB_TABNAME = GC_TABLE-PROG
      I_SUB_FNAME   = GC_CAPTION-CONTEXT
    IMPORTING
      RETURNCODE    = LW_RET_CODE
    CHANGING
      C_RECORD      = GS_PROG.
  CHECK LW_RET_CODE IS INITIAL.

* Generate tree node context
  PERFORM 9999_LABEL_CONTEXT_GEN
    CHANGING LPS_COMP_CONTEXT-TREETEXT.

* Gen context bar info
  LPS_CAPTION_CNTX-CAPTION     = LPS_COMP_CONTEXT-TREETEXT.

* Update component frontend: tree node, bar
  PERFORM 9999_COMP_UPDATE_FRONT_END
    USING LPS_COMP_CONTEXT
          LPS_CAPTION_CNTX.

ENDFORM.                    " 9999_COMP_CONFIG_CHG_CONTEXT

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_TREE_HANDLE_FCODE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_NODE_KEY  text
*      -->LPW_FCODE  text
*----------------------------------------------------------------------*
FORM 9999_COMP_TREE_HANDLE_FCODE
  USING    LPW_NODE_KEY       TYPE LVC_NKEY
           LPW_FCODE          TYPE SY-UCOMM.
  DATA:
    LS_ALV_LAYOUT             TYPE ZST_BM_ALV_LAYO.

* Get current node
  READ TABLE GT_COMP_TREE INTO LS_ALV_LAYOUT
    WITH KEY TREEKEY = LPW_NODE_KEY.
  CHECK SY-SUBRC IS INITIAL.

  CASE LS_ALV_LAYOUT-NODELV.
    WHEN GC_NODE_LEVEL-SECTION.
      IF LPW_FCODE = C_FCODE-COMP_ADD_CHILD.
        PERFORM 9999_COMP_TREE_ADD_NEW
          USING LS_ALV_LAYOUT.
      ENDIF.
    WHEN GC_NODE_LEVEL-COMPONENT.
      CASE LS_ALV_LAYOUT-NODECODE.
        WHEN GC_NODE_CODE-COMP_HEAD.
          CASE LPW_FCODE.
            WHEN C_FCODE-COMP_CLONE.
              PERFORM 9999_COMP_TREE_ADD_NEW
                USING LS_ALV_LAYOUT.
            WHEN C_FCODE-COMP_DELETE.
              PERFORM 9999_COMP_TREE_DELETE
                USING LS_ALV_LAYOUT.
            WHEN OTHERS.
          ENDCASE.
        WHEN GC_NODE_CODE-COMP_DETL.
          CASE LPW_FCODE.
            WHEN C_FCODE-COMP_DELETE.
              PERFORM 9999_COMP_TREE_DELETE
                USING LS_ALV_LAYOUT.
            WHEN OTHERS.
          ENDCASE.
        WHEN OTHERS.
      ENDCASE.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " 9999_COMP_TREE_HANDLE_FCODE

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_TREE_ADD_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_SECTION  text
*----------------------------------------------------------------------*
FORM 9999_COMP_TREE_ADD_NEW
  USING LPS_CUR_COMP        TYPE ZST_BM_ALV_LAYO.
  DATA:
    LS_COMPONENT            TYPE ZST_BM_ALV_LAYO.

  CASE LPS_CUR_COMP-NODELV.
*   Create new Component for section
    WHEN GC_NODE_LEVEL-SECTION.
      LS_COMPONENT-NODECODE = LPS_CUR_COMP-NODECODE.
*   Clone new Component from a component
    WHEN GC_NODE_LEVEL-COMPONENT.
      LS_COMPONENT          = LPS_CUR_COMP.
    WHEN OTHERS.
  ENDCASE.

* Popup and get config values of new component
  PERFORM 9999_COMP_TREE_POPUP_CONFIG
    CHANGING LS_COMPONENT.

* Redraw 0100
  PERFORM 0100_PBO.

ENDFORM.                    " 9999_COMP_TREE_ADD_NEW

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_TREE_DELETE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_CUR_COMP  text
*----------------------------------------------------------------------*
FORM 9999_COMP_TREE_DELETE
  USING LPS_CUR_COMP        TYPE ZST_BM_ALV_LAYO.
  DATA:
    LS_ALV_LAYOUT_NEW       TYPE ZST_BM_ALV_LAYO.

* Delete component
  DELETE GT_COMP_TREE
    WHERE FNAME = LPS_CUR_COMP-FNAME
      AND POSID = LPS_CUR_COMP-POSID.

* Delete component columns
  DELETE GT_ALV_FCAT
    WHERE FNAME = LPS_CUR_COMP-FNAME.

* Remove node in comp tree
  CALL METHOD GO_COMPTREE->DELETE_SUBTREE
    EXPORTING
      I_NODE_KEY            = LPS_CUR_COMP-TREEKEY
    EXCEPTIONS
      NODE_KEY_NOT_IN_MODEL = 1
      OTHERS                = 2.

* Redraw 0100
  PERFORM 0100_PBO.

* Clear Bar list
  PERFORM 9999_COMP_CONFIG_BAR_INIT
    USING LPS_CUR_COMP.

ENDFORM.                    " 9999_COMP_TREE_DELETE

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_TREE_GEN_COMP_LV3
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LPS_ALV_LAYO  text
*----------------------------------------------------------------------*
FORM 9999_COMP_TREE_GEN_COMP_LV3
  CHANGING LPS_COMPONENT       TYPE ZST_BM_ALV_LAYO.

* Build tree key
  LPS_COMPONENT-AGGRKEY       = GC_TREE_KEY-COMP_PREF
                              && LPS_COMPONENT-POSID
                              && LPS_COMPONENT-FNAME.
  CONDENSE: LPS_COMPONENT-AGGRKEY, LPS_COMPONENT-AGPRKEY.

* Set node text, node level, leaf type
  LPS_COMPONENT-TREETEXT      = LPS_COMPONENT-FNAME.
  LPS_COMPONENT-NODELV        = GC_NODE_LEVEL-COMPONENT.
  LPS_COMPONENT-NODE_LAYOUT-ISFOLDER   = SPACE.

* Set parents key node code, image
  IF LPS_COMPONENT-IS_ITEM IS INITIAL.
    LPS_COMPONENT-AGPRKEY     = GC_TREE_KEY-SECT_HEAD.
    LPS_COMPONENT-NODECODE    = GC_NODE_CODE-COMP_HEAD.
    LPS_COMPONENT-NODE_LAYOUT-N_IMAGE   =
    LPS_COMPONENT-NODE_LAYOUT-EXP_IMAGE = GC_NODE_IMG-COMP_HEAD.
  ELSE.
    LPS_COMPONENT-AGPRKEY     = GC_TREE_KEY-SECT_DETL.
    LPS_COMPONENT-NODECODE    = GC_NODE_CODE-COMP_DETL.
    LPS_COMPONENT-NODE_LAYOUT-N_IMAGE   =
    LPS_COMPONENT-NODE_LAYOUT-EXP_IMAGE = GC_NODE_IMG-COMP_DETL.
  ENDIF.

ENDFORM.                    " 9999_COMP_TREE_GEN_COMP_LV3

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_TREE_REG_EVENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM 9999_COMP_TREE_REG_EVENTS .
  DATA:
    LS_EVENTS                 TYPE CNTL_SIMPLE_EVENT ,
    LT_EVENTS                 TYPE CNTL_SIMPLE_EVENTS.

* Get all current events of tree
  GO_COMPTREE->GET_REGISTERED_EVENTS( IMPORTING EVENTS = LT_EVENTS ).

* Prepare new events
*  LS_EVENTS-APPL_EVENT = GC_XMARK.
  LS_EVENTS-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_NODE_CONTEXT_MENU_REQ.
  APPEND LS_EVENTS TO LT_EVENTS .

  LS_EVENTS-EVENTID = CL_GUI_COLUMN_TREE=>EVENTID_SELECTION_CHANGED.
  APPEND LS_EVENTS TO LT_EVENTS .

  SORT LT_EVENTS BY EVENTID APPL_EVENT.
  DELETE ADJACENT DUPLICATES FROM LT_EVENTS COMPARING EVENTID.

* Register events
  GO_COMPTREE->SET_REGISTERED_EVENTS( EVENTS = LT_EVENTS ) .

* Create object to handle event of tree
  CREATE OBJECT GO_WB_HANDLER.
  SET HANDLER:
    GO_WB_HANDLER->HNDL_SELECTION_CHANGED FOR GO_COMPTREE,
    GO_WB_HANDLER->HNDL_NODE_CONTEXT_MENU_REQ FOR GO_COMPTREE,
    GO_WB_HANDLER->HNDL_NODE_CONTEXT_MENU_SEL FOR GO_COMPTREE.

ENDFORM.                    " 9999_COMP_TREE_REG_EVENTS

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_CONFIG_BAR_INIT
*&---------------------------------------------------------------------*
*       Set bar to initial: Only have Dummy bar
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM 9999_COMP_CONFIG_BAR_INIT
  USING LPS_COMPONENT         TYPE ZST_BM_ALV_LAYO.
  DATA:
    LS_CAPTION                TYPE SBPTCAPTN.
  FIELD-SYMBOLS:
    <LF_CAPTION>              TYPE SBPTCAPTN.

  IF GO_CON_BAR IS BOUND.
    CALL METHOD GO_CON_BAR->SET_ACTIVE
      EXPORTING
        NAME                = GC_CAPTION-DUMMY
      EXCEPTIONS
        CELL_DOES_NOT_EXIST = 1
        OTHERS              = 2.
    LOOP AT GT_CAPTIONS INTO LS_CAPTION
      WHERE NAME <> GC_CAPTION-DUMMY.
      CALL METHOD GO_CON_BAR->REMOVE_CELL
        EXPORTING
          NAME                = LS_CAPTION-NAME
        EXCEPTIONS
          CELL_DOES_NOT_EXIST = 1
          OTHERS              = 2.
    ENDLOOP.
    DELETE GT_CAPTIONS WHERE NAME <> GC_CAPTION-DUMMY.
    READ TABLE GT_CAPTIONS ASSIGNING <LF_CAPTION>
      WITH KEY NAME = GC_CAPTION-DUMMY.
    IF SY-SUBRC IS INITIAL.
      <LF_CAPTION>-CAPTION   = LPS_COMPONENT-TREEKEY.
    ENDIF.
  ELSE.
*   New cell
    LS_CAPTION-CAPTION   = LPS_COMPONENT-TREEKEY.
    LS_CAPTION-NAME      = GC_CAPTION-DUMMY.
    LS_CAPTION-ICON      = ICON_TOOLS .
    LS_CAPTION-NO_CLOSE  = LS_CAPTION-INVISIBLE = GC_XMARK.
    APPEND LS_CAPTION TO GT_CAPTIONS.
  ENDIF.
ENDFORM.                    " 9999_COMP_CONFIG_BAR_INIT

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_CONFIG_GEN_CONTEXT
*&---------------------------------------------------------------------*
*       Generate config for context
*----------------------------------------------------------------------*
FORM 9999_COMP_CONFIG_GEN_CONTEXT
  CHANGING LPS_CAPTION        TYPE SBPTCAPTN.

* New cell
  PERFORM 9999_LABEL_CONTEXT_GEN
    CHANGING LPS_CAPTION-CAPTION.
*  CONCATENATE TEXT-T00 "GC_CAPTION-CONTEXT(15)
*              GS_PROG-ALVSTR
*         INTO LPS_CAPTION-CAPTION
*         SEPARATED BY ':'.
  LPS_CAPTION-ICON            = ICON_TOOLS .
  LPS_CAPTION-NO_CLOSE        = ABAP_ON.
  LPS_CAPTION-INVISIBLE       = ABAP_OFF.
  LPS_CAPTION-NAME            = GC_CAPTION-CONTEXT.
  APPEND LPS_CAPTION TO GT_CAPTIONS.

ENDFORM.                    " 9999_COMP_CONFIG_GEN_CONTEXT

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_CONFIG_GEN_HEAD
*&---------------------------------------------------------------------*
*       Generate config for context
*----------------------------------------------------------------------*
*   -->  LPS_ALV_LAYOUT        ALV layout
*----------------------------------------------------------------------*
FORM 9999_COMP_CONFIG_GEN_HEAD
  USING LPS_ALV_LAYOUT        TYPE ZST_BM_ALV_LAYO.
  DATA:
    LS_CAPTION                TYPE SBPTCAPTN.

* New cell
  LS_CAPTION-CAPTION   = LPS_ALV_LAYOUT-FNAME.
  LS_CAPTION-ICON      = ICON_TOOLS .
  LS_CAPTION-NO_CLOSE  = ABAP_ON.
  LS_CAPTION-INVISIBLE = ABAP_OFF.
  LS_CAPTION-NAME      = GC_CAPTION-COMPONENT.
  APPEND LS_CAPTION TO GT_CAPTIONS.

* Add bar attribute
  PERFORM 9999_COMP_CONFIG_ADD_BAR:
    USING GC_CAPTION-HEAD_POSID
          LPS_ALV_LAYOUT
    CHANGING GT_CAPTIONS,
    USING GC_CAPTION-HEAD_TYP
          LPS_ALV_LAYOUT
    CHANGING GT_CAPTIONS,
    USING GC_CAPTION-HEAD_HKEY
          LPS_ALV_LAYOUT
    CHANGING GT_CAPTIONS,
    USING GC_CAPTION-HEAD_PREFIX
          LPS_ALV_LAYOUT
    CHANGING GT_CAPTIONS,
    USING GC_CAPTION-HEAD_SUFFIX
          LPS_ALV_LAYOUT
    CHANGING GT_CAPTIONS.

ENDFORM.                    " 9999_COMP_CONFIG_GEN_HEAD

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_CONFIG_GEN_DETL
*&---------------------------------------------------------------------*
*       Generate config for context
*----------------------------------------------------------------------*
*   -->  LPS_ALV_LAYOUT        ALV layout
*----------------------------------------------------------------------*
FORM 9999_COMP_CONFIG_GEN_DETL
  USING LPS_ALV_LAYOUT        TYPE ZST_BM_ALV_LAYO.
  DATA:
    LS_CAPTION                TYPE SBPTCAPTN.

* New cell
  LS_CAPTION-CAPTION      = LPS_ALV_LAYOUT-FNAME.
  LS_CAPTION-ICON         = ICON_TOOLS .
  LS_CAPTION-NO_CLOSE     = ABAP_ON.
  LS_CAPTION-INVISIBLE    = ABAP_OFF.
  LS_CAPTION-NAME         = GC_CAPTION-COMPONENT.
  APPEND LS_CAPTION TO GT_CAPTIONS.

* Add bar attribute
  PERFORM 9999_COMP_CONFIG_ADD_BAR:
    USING GC_CAPTION-DETL_COLS
          LPS_ALV_LAYOUT
    CHANGING GT_CAPTIONS,
    USING GC_CAPTION-DETL_STYLEFNAME
          LPS_ALV_LAYOUT
    CHANGING GT_CAPTIONS.

* Gen field catelog bar
  LS_CAPTION-ICON             = ICON_CHOOSE_COLUMNS .
  LS_CAPTION-NO_CLOSE         = GC_XMARK.
  LS_CAPTION-INVISIBLE        = ABAP_OFF.
  LS_CAPTION-NAME             = GC_CAPTION-DETL_FCAT.
  LS_CAPTION-CAPTION          = TEXT-T03.
  APPEND LS_CAPTION TO GT_CAPTIONS .

ENDFORM.                    " 9999_COMP_CONFIG_GEN_DETL

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_CONFIG_DISPLAY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM 9999_COMP_CONFIG_DISPLAY .
  DATA:
    LS_CAPTION                TYPE SBPTCAPTN,
    LW_ID                     TYPE I.

  IF GT_CAPTIONS IS NOT INITIAL.
    IF GO_CON_BAR IS NOT BOUND.
      CREATE OBJECT GO_CON_BAR
        EXPORTING
          PARENT        = GO_CON_COMCONFIG
          CAPTIONS      = GT_CAPTIONS
          ACTIVE_ID     = 1
          STYLE         = CL_GUI_CONTAINER_BAR_2=>C_STYLE_FIX
*         STYLE         = CL_GUI_CONTAINER_BAR_2=>C_STYLE_OUTLOOK
          CLOSE_BUTTONS = SPACE
        EXCEPTIONS
          OTHERS        = 7.
      SET HANDLER GO_WB_HANDLER->HNDL_TAB_CLICKED FOR GO_CON_BAR .
    ELSE.
      LOOP AT GT_CAPTIONS INTO LS_CAPTION
        WHERE NAME <> GC_CAPTION-DUMMY.
        CLEAR: LW_ID.
        CALL METHOD GO_CON_BAR->ADD_CELL
          EXPORTING
            CAPTION                      = LS_CAPTION
          CHANGING
            ID                           = LW_ID
          EXCEPTIONS
            CELL_ALREADY_USED            = 1
            MAX_NUMBER_OF_CELLS_EXCEEDED = 2
            INVALID_CELL_ID              = 3
            OTHERS                       = 4.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " 9999_COMP_CONFIG_DISPLAY

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_TREE_POPUP_CONFIG
*&---------------------------------------------------------------------*
*       Popup new component
*----------------------------------------------------------------------*
*      <--LPS_COMPONENT  Component
*----------------------------------------------------------------------*
FORM 9999_COMP_TREE_POPUP_CONFIG
  CHANGING LPS_COMPONENT    TYPE ZST_BM_ALV_LAYO.
  DATA:
    LS_FIELD                TYPE SVAL,
    LT_FIELD                TYPE TABLE OF SVAL,
    LW_RET_CODE             TYPE C.

* Clear tree info
  CLEAR:  LPS_COMPONENT-AGGRKEY,
          LPS_COMPONENT-TREEKEY,
          LPS_COMPONENT-TREEPR,
          LPS_COMPONENT-TREETEXT.
  LPS_COMPONENT-REPORT        = GS_PROG-REPID.

* Prepare Popup value for field
  LS_FIELD-TABNAME            = GC_TABLE-PROG.
  LS_FIELD-FIELDNAME          = GC_CAPTION-CONTEXT.
  LS_FIELD-VALUE              = GS_PROG-ALVSTR.
  LS_FIELD-FIELD_ATTR         = '02'.
  APPEND LS_FIELD TO LT_FIELD.

  LS_FIELD-FIELD_ATTR         = SPACE.
  LS_FIELD-TABNAME            = GC_TABLE-ALV_LAYOUT.

  LS_FIELD-FIELDNAME          = GC_CAPTION-FIELDNAME.
  LS_FIELD-VALUE              = LPS_COMPONENT-FNAME.
  APPEND LS_FIELD TO LT_FIELD.

  CASE LPS_COMPONENT-NODECODE.
    WHEN GC_NODE_CODE-COMP_HEAD.
      LPS_COMPONENT-IS_ITEM   = SPACE.
*     Prepare header Attributes
      LS_FIELD-FIELDNAME      = GC_CAPTION-HEAD_POSID.
      LS_FIELD-VALUE          = LPS_COMPONENT-POSID.
      APPEND LS_FIELD TO LT_FIELD.
      LS_FIELD-FIELDNAME      = GC_CAPTION-HEAD_TYP.
      LS_FIELD-VALUE          = LPS_COMPONENT-TYP.
      APPEND LS_FIELD TO LT_FIELD.
      LS_FIELD-FIELDNAME      = GC_CAPTION-HEAD_HKEY.
      LS_FIELD-VALUE          = LPS_COMPONENT-HKEY.
      APPEND LS_FIELD TO LT_FIELD.
      LS_FIELD-FIELDNAME      = GC_CAPTION-HEAD_PREFIX.
      LS_FIELD-VALUE          = LPS_COMPONENT-PREFIX.
      APPEND LS_FIELD TO LT_FIELD.
      LS_FIELD-FIELDNAME      = GC_CAPTION-HEAD_SUFFIX.
      LS_FIELD-VALUE          = LPS_COMPONENT-SUFFIX.
      APPEND LS_FIELD TO LT_FIELD.
    WHEN GC_NODE_CODE-COMP_DETL.
      LPS_COMPONENT-IS_ITEM   = GC_XMARK.

*     Prepare item Attributes
      LS_FIELD-FIELDNAME      = GC_CAPTION-DETL_COLS.
      LS_FIELD-VALUE          = LPS_COMPONENT-COLS.
      APPEND LS_FIELD TO LT_FIELD.
      LS_FIELD-FIELDNAME      = GC_CAPTION-DETL_STYLEFNAME.
      LS_FIELD-VALUE          = LPS_COMPONENT-STYLEFNAME.
      APPEND LS_FIELD TO LT_FIELD.
    WHEN OTHERS.
  ENDCASE.

* Popup to set values
  CALL FUNCTION 'ZFM_POPUP_SET_DATA_RECORD'
    EXPORTING
      IT_FIELDS     = LT_FIELD
      I_POPUP_TITLE = TEXT-CT1
      I_DB_CHECK    = GC_XMARK
    IMPORTING
      RETURNCODE    = LW_RET_CODE
    CHANGING
      C_RECORD      = LPS_COMPONENT.
  CHECK LW_RET_CODE IS INITIAL.

* Generate tree data
  PERFORM 9999_COMP_TREE_GEN_COMP_LV3
    CHANGING LPS_COMPONENT.

* Add node to internal table
  APPEND LPS_COMPONENT TO GT_COMP_TREE.

ENDFORM.                    " 9999_COMP_TREE_POPUP_CONFIG

*&---------------------------------------------------------------------*
*&      Form  0100_PROCESS_SAVE
*&---------------------------------------------------------------------*
*       Save data
*----------------------------------------------------------------------*
FORM 0100_PROCESS_SAVE.
  DATA:
    LT_ALV_LAYO_DB            TYPE TABLE OF ZTB_BM_ALV_LAYO,
    LS_ALV_LAYO_DB            TYPE ZTB_BM_ALV_LAYO,
    LT_PROG                   TYPE TABLE OF ZTB_PROG.

  APPEND GS_PROG TO LT_PROG.

* Move data in screen to DB format
  CALL FUNCTION 'ZFM_DATA_TABLE_MOVE_CORRESPOND'
    CHANGING
      C_SRC_TAB = GT_COMP_TREE
      C_DES_TAB = LT_ALV_LAYO_DB.

* Update client
  DELETE LT_ALV_LAYO_DB WHERE REPORT IS INITIAL.
  LS_ALV_LAYO_DB-MANDT = SY-MANDT.
  MODIFY LT_ALV_LAYO_DB FROM LS_ALV_LAYO_DB TRANSPORTING MANDT
    WHERE MANDT IS INITIAL.

* Update current data to database
  CALL FUNCTION 'ZFM_DATA_UPDATE_TABLE'
    EXPORTING
      I_STRUCTURE     = GC_TABLE-PROG
      T_TABLE_CHANGED = LT_PROG
      I_ASSIGN_RQ     = GC_XMARK
      I_GET_ORG_DATA  = GC_XMARK
    EXCEPTIONS
      OTHERS          = 10.
  IF SY-SUBRC IS NOT INITIAL.
    MESSAGE S011(ZMS_COL_LIB) WITH GC_TABLE-PROG.
    LEAVE TO SCREEN SY-DYNNR.
  ENDIF.

  IF LT_ALV_LAYO_DB IS NOT INITIAL
  OR GT_ALV_LAYO_DB IS NOT INITIAL.
*   Update current data to database
    CALL FUNCTION 'ZFM_DATA_UPDATE_TABLE'
      EXPORTING
        I_STRUCTURE      = GC_TABLE-ALV_LAYOUT
        T_TABLE_CHANGED  = LT_ALV_LAYO_DB
        T_TABLE_ORIGINAL = GT_ALV_LAYO_DB
        I_ASSIGN_RQ      = GC_XMARK
      EXCEPTIONS
        OTHERS           = 10.
    IF SY-SUBRC IS NOT INITIAL.
      MESSAGE S011(ZMS_COL_LIB) WITH GC_TABLE-ALV_LAYOUT.
      LEAVE TO SCREEN SY-DYNNR.
    ENDIF.
  ENDIF.

  IF GT_ALV_FCAT IS NOT INITIAL
  OR GT_ALV_FCAT_O IS NOT INITIAL.
*   Update current data to database
    CALL FUNCTION 'ZFM_DATA_UPDATE_TABLE'
      EXPORTING
        I_STRUCTURE      = GC_TABLE-ALV_FCAT
        T_TABLE_CHANGED  = GT_ALV_FCAT
        T_TABLE_ORIGINAL = GT_ALV_FCAT_O
        I_ASSIGN_RQ      = GC_XMARK
      EXCEPTIONS
        OTHERS           = 10.
    IF SY-SUBRC IS NOT INITIAL.
      MESSAGE S011(ZMS_COL_LIB) WITH GC_TABLE-ALV_FCAT.
      LEAVE TO SCREEN SY-DYNNR.
    ENDIF.
  ENDIF.

  GT_ALV_LAYO_DB  = LT_ALV_LAYO_DB.
  GT_ALV_FCAT_O   = GT_ALV_FCAT.
  MESSAGE S009(ZMS_COL_LIB).

ENDFORM.                    " 0100_PROCESS_SAVE

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_CONFIG_COLS_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM 9999_COMP_CONFIG_COLS_LAYOUT .
  DATA:
    LS_DBL_ALV_LAYO         TYPE LVC_S_DALY,
    LW_CANCEL               TYPE XMARK,
    LS_FIELD_OBJS           TYPE LVC_S_OBJS,
    LT_FCAT_OUT             TYPE LVC_T_FCAT,
    LT_FIELD_OUT            TYPE LVC_T_OBJS,
    LT_FIELD_AVAI           TYPE LVC_T_OBJS,
    LS_FCAT                 TYPE LVC_S_FCAT,
    LT_FCAT                 TYPE LVC_T_FCAT.
  FIELD-SYMBOLS:
    <LF_DETAIL_LINE>        TYPE ANY.

* Get all available fields
  PERFORM 9999_ALV_TEMPL_GET_AVAI_FIELDS
    CHANGING LT_FCAT.

* Get current output fields
  PERFORM 9999_COMP_CONFIG_GET_OUT_FLDS
    CHANGING LT_FCAT_OUT
             LT_FCAT.

* Prepare avai fields to ALV
  LOOP AT LT_FCAT INTO LS_FCAT.
    LS_FIELD_OBJS-ID = LS_FCAT-COL_POS.
    CONCATENATE LS_FCAT-FIELDNAME ' (' LS_FCAT-SCRTEXT_L ')'
           INTO LS_FIELD_OBJS-TEXT.
    APPEND LS_FIELD_OBJS TO LT_FIELD_AVAI.
  ENDLOOP.

* Prepare avai fields to ALV
  LOOP AT LT_FCAT_OUT INTO LS_FCAT.
    LS_FIELD_OBJS-ID = SY-TABIX.
    CONCATENATE LS_FCAT-FIELDNAME ' (' LS_FCAT-SCRTEXT_L ')'
           INTO LS_FIELD_OBJS-TEXT.
    APPEND LS_FIELD_OBJS TO LT_FIELD_OUT.
  ENDLOOP.

* Show double field cat
  LS_DBL_ALV_LAYO-NO_ICONS = 'X'.
  CALL FUNCTION 'REUSE_DOUBLE_ALV'
    EXPORTING
      I_TITLE_LEFT         = TEXT-003
      I_TITLE_RIGHT        = TEXT-004
      I_POPUP_TITLE        = TEXT-005
      IS_LAYOUT_DOUBLE_ALV = LS_DBL_ALV_LAYO
    IMPORTING
      E_CANCELLED          = LW_CANCEL
    TABLES
      T_LEFTX              = LT_FIELD_OUT
      T_RIGHTX             = LT_FIELD_AVAI.

  CHECK LW_CANCEL IS INITIAL.

* Get current output fields
  PERFORM 9999_COMP_CONFIG_SET_OUT_FCAT
    USING LT_FIELD_OUT.

* Refresh ALV template
  PERFORM 0100_INIT_ALV_TEMPLATE.

ENDFORM.                    " 9999_COMP_CONFIG_COLS_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  9999_ALV_TEMPL_INIT_OUTTAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 9999_ALV_TEMPL_INIT_OUTTAB .
  DATA:
    LR_DATA                   TYPE REF TO DATA,
    LS_ALV_LAYOUT             TYPE ZST_BM_ALV_LAYO.

  FIELD-SYMBOLS:
    <LF_DETAIL_LINE>          TYPE ANY,
    <LFT_DETAIL_TAB>          TYPE TABLE.

  IF GS_PROG-ALVSTR IS NOT INITIAL.
    CREATE DATA LR_DATA TYPE (GS_PROG-ALVSTR).
    ASSIGN LR_DATA->* TO <GF_CONTEXT>.

    READ TABLE GT_COMP_TREE INTO LS_ALV_LAYOUT
      WITH KEY IS_ITEM = GC_XMARK.
    IF SY-SUBRC IS INITIAL.
      ASSIGN COMPONENT LS_ALV_LAYOUT-FNAME OF STRUCTURE <GF_CONTEXT>
        TO <GFT_ALV_DATA>.
      IF SY-SUBRC IS INITIAL.
        DO 20 TIMES.
          APPEND INITIAL LINE TO <GFT_ALV_DATA>.
        ENDDO.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " 9999_ALV_TEMPL_INIT_OUTTAB

*&---------------------------------------------------------------------*
*&      Form  9999_ALV_TEMPL_GET_INFO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LPW_ALV_STR  text
*      <--LPT_HEADER  text
*      <--LPW_HEIGHT  text
*      <--LPT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM 9999_ALV_TEMPL_GET_INFO
  CHANGING  LPW_ALV_STR       TYPE TABNAME
            LPT_HEADER        TYPE ZTT_ALV_HEADER
            LPW_HEIGHT        TYPE I
            LPT_FIELDCAT      TYPE LVC_T_FCAT
            LPS_LOGO          TYPE ZST_BM_ALV_LOGO.
  DATA:
    LR_DATA                   TYPE REF TO DATA,
    LT_ALV_LAYOUT             TYPE ZTT_ALV_LAYOUT,
    LT_ALL_FIELDCAT           TYPE LVC_T_FCAT,
    LT_FIELD_OUT              TYPE LVC_T_FCAT,
    LS_FIELD_OUT              TYPE LVC_S_FCAT.
  FIELD-SYMBOLS:
    <LF_STRUCTURE>            TYPE ANY.

  CHECK <GFT_ALV_DATA> IS ASSIGNED.

* Get structure of ALV
  CREATE DATA LR_DATA LIKE LINE OF <GFT_ALV_DATA>.
  ASSIGN LR_DATA->* TO <LF_STRUCTURE>.
  DESCRIBE FIELD <LF_STRUCTURE> HELP-ID LPW_ALV_STR.

* Move ALV layout
  CALL FUNCTION 'ZFM_DATA_TABLE_MOVE_CORRESPOND'
    CHANGING
      C_SRC_TAB = GT_COMP_TREE
      C_DES_TAB = LT_ALV_LAYOUT.

* Get header data of ALV
  CALL FUNCTION 'ZFM_RP_ALV_GET_HEADER_HTML'
    EXPORTING
      I_REPORT     = GS_PROG-REPID
      I_TABNAME    = LPW_ALV_STR
      I_RP_DATA    = <LF_STRUCTURE>
      I_TEMPLATE   = GC_XMARK
      T_ALV_LAYOUT = LT_ALV_LAYOUT
    IMPORTING
      T_ALV_HEADER = LPT_HEADER
      E_HEIGHT     = LPW_HEIGHT
      E_LOGO       = LPS_LOGO.

* Get all available fields
  PERFORM 9999_ALV_TEMPL_GET_AVAI_FIELDS
    CHANGING LT_ALL_FIELDCAT.

* Get current output fields
  PERFORM 9999_COMP_CONFIG_GET_OUT_FLDS
    CHANGING LPT_FIELDCAT
             LT_ALL_FIELDCAT.

ENDFORM.                    " 9999_ALV_TEMPL_GET_INFO

*&---------------------------------------------------------------------*
*&      Form  9999_ALV_TEMPL_GET_AVAI_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_FCAT  text
*----------------------------------------------------------------------*
FORM 9999_ALV_TEMPL_GET_AVAI_FIELDS
  CHANGING LPT_FCAT         TYPE LVC_T_FCAT.
  DATA:
    LR_DATA                 TYPE REF TO DATA,
    LPW_ALV_STR             TYPE TABNM,
    LS_FCAT                 TYPE LVC_S_FCAT.
  FIELD-SYMBOLS:
    <LF_DETAIL_LINE>        TYPE ANY.

  CHECK <GFT_ALV_DATA> IS ASSIGNED.

  CREATE DATA LR_DATA LIKE LINE OF <GFT_ALV_DATA>.
  ASSIGN LR_DATA->* TO <LF_DETAIL_LINE>.
  DESCRIBE FIELD <LF_DETAIL_LINE> HELP-ID LPW_ALV_STR.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = LPW_ALV_STR
      I_INTERNAL_TABNAME     = LPW_ALV_STR
    CHANGING
      CT_FIELDCAT            = LPT_FCAT
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

ENDFORM.                    " 9999_ALV_TEMPL_GET_AVAI_FIELDS

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_CONFIG_GET_OUT_FLDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPT_FIELDCAT  text
*      <--LPT_FIELD_OUT  text
*----------------------------------------------------------------------*
FORM 9999_COMP_CONFIG_GET_OUT_FLDS
  CHANGING LPT_FIELD_OUT      TYPE LVC_T_FCAT
           LPT_FIELDCAT       TYPE LVC_T_FCAT.
  DATA:
    LS_CAPTION_COMP           TYPE SBPTCAPTN,
    LT_FIELDNAME              TYPE TABLE OF FIELDNAME,
    LW_FIELDNAME              TYPE FIELDNAME,
    LS_FIELDCAT               TYPE LVC_S_FCAT,
    LT_ALV_FCAT               TYPE TABLE OF ZTB_BM_ALV_FCAT,
    LS_ALV_FCAT               TYPE ZTB_BM_ALV_FCAT,
    LW_ID                     TYPE I.
  FIELD-SYMBOLS:
    <LF_ALV_LAYOUT>           TYPE ZST_BM_ALV_LAYO.

* Get current component info
  READ TABLE GT_CAPTIONS INTO LS_CAPTION_COMP
    WITH KEY NAME = GC_CAPTION-COMPONENT.
  IF SY-SUBRC IS INITIAL.
    READ TABLE GT_COMP_TREE ASSIGNING <LF_ALV_LAYOUT>
      WITH KEY FNAME = LS_CAPTION_COMP-CAPTION.
    CHECK SY-SUBRC IS INITIAL.
  ELSE.
    READ TABLE GT_COMP_TREE ASSIGNING <LF_ALV_LAYOUT>
      WITH KEY IS_ITEM = GC_XMARK.
    CHECK SY-SUBRC IS INITIAL.
  ENDIF.

* Remove columns have position larger than max columns
  IF <LF_ALV_LAYOUT>-COLS IS NOT INITIAL.
    DELETE LPT_FIELDCAT WHERE COL_POS > <LF_ALV_LAYOUT>-COLS.
  ENDIF.

* Remove columns was not be long to current detail
  LT_ALV_FCAT = GT_ALV_FCAT.
  DELETE LT_ALV_FCAT WHERE FNAME <> <LF_ALV_LAYOUT>-FNAME.

* Prepare output field list
  LOOP AT LT_ALV_FCAT INTO LS_ALV_FCAT.
*   Get Field text to output field list
    READ TABLE LPT_FIELDCAT INTO LS_FIELDCAT
      WITH KEY FIELDNAME = LS_ALV_FCAT-COL_NAME.
    IF SY-SUBRC IS INITIAL.
      DELETE LPT_FIELDCAT INDEX SY-TABIX.
    ELSE.
      LS_FIELDCAT-FIELDNAME   = LS_ALV_FCAT-COL_NAME.
    ENDIF.

    LS_FIELDCAT-COL_POS       = LS_ALV_FCAT-COL_POS.
    APPEND LS_FIELDCAT TO LPT_FIELD_OUT.
  ENDLOOP.

ENDFORM.                    " 9999_COMP_CONFIG_GET_OUT_FLDS

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_CONFIG_SET_OUT_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPT_FIELD_OUT  text
*----------------------------------------------------------------------*
FORM 9999_COMP_CONFIG_SET_OUT_FCAT
  USING    LPT_FIELD_OUT      TYPE LVC_T_OBJS.
  DATA:
    LS_CAPTION_COMP           TYPE SBPTCAPTN,
    LT_FIELDNAME              TYPE TABLE OF FIELDNAME,
    LW_FIELDNAME              TYPE FIELDNAME,
    LW_FIELDTEXT              TYPE FIELDNAME,
    LS_FIELDCAT               TYPE LVC_S_FCAT,
    LS_FIELD_OUT              TYPE LVC_S_OBJS,
    LS_ALV_FCAT               TYPE ZTB_BM_ALV_FCAT.
  FIELD-SYMBOLS:
    <LF_ALV_LAYOUT>           TYPE ZST_BM_ALV_LAYO.

* Get current component info
  READ TABLE GT_CAPTIONS INTO LS_CAPTION_COMP
    WITH KEY NAME = GC_CAPTION-COMPONENT.
  CHECK SY-SUBRC IS INITIAL.
  READ TABLE GT_COMP_TREE ASSIGNING <LF_ALV_LAYOUT>
    WITH KEY FNAME = LS_CAPTION_COMP-CAPTION.
  CHECK SY-SUBRC IS INITIAL.

  DELETE GT_ALV_FCAT WHERE FNAME = <LF_ALV_LAYOUT>-FNAME.

* Prepare field name to save DB
  LOOP AT LPT_FIELD_OUT INTO LS_FIELD_OUT.
    LS_ALV_FCAT-MANDT         = SY-MANDT.
    LS_ALV_FCAT-REPORT        = GS_PROG-REPID.
    LS_ALV_FCAT-FNAME         = <LF_ALV_LAYOUT>-FNAME.
    SPLIT LS_FIELD_OUT-TEXT AT SPACE
      INTO LS_ALV_FCAT-COL_NAME LW_FIELDTEXT.
    LS_ALV_FCAT-COL_POS         = SY-TABIX.
    APPEND LS_ALV_FCAT TO GT_ALV_FCAT.
  ENDLOOP.

  SORT GT_ALV_FCAT BY FNAME COL_POS.

ENDFORM.                    " 9999_COMP_CONFIG_SET_OUT_FCAT

*&---------------------------------------------------------------------*
*&      Form  0000_INIT_PROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0000_INIT_PROC .

* Get component config (Fields in table ZTB_BM_ALV_LAYO)
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = GC_TABLE-ALV_LAYOUT
      I_INTERNAL_TABNAME     = GC_TABLE-ALV_LAYOUT
    CHANGING
      CT_FIELDCAT            = GT_COMP_CONFIG
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

ENDFORM.                    " 0000_INIT_PROC

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_TREE_GEN_CONTEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LPS_ALV_LAYO  text
*----------------------------------------------------------------------*
FORM 9999_COMP_TREE_GEN_CONTEXT
  CHANGING LPS_ALV_LAYO       TYPE ZST_BM_ALV_LAYO.

  LPS_ALV_LAYO-NODELV         = GC_NODE_LEVEL-CONTEXT.
  LPS_ALV_LAYO-NODECODE       = GC_NODE_CODE-CONTEXT.
  LPS_ALV_LAYO-AGGRKEY        = GC_TREE_KEY-CONTEXT.
  LPS_ALV_LAYO-NODE_LAYOUT-ISFOLDER  = GC_XMARK.
  LPS_ALV_LAYO-NODE_LAYOUT-N_IMAGE   =
  LPS_ALV_LAYO-NODE_LAYOUT-EXP_IMAGE = GC_NODE_IMG-CONTEXT.

  PERFORM 9999_LABEL_CONTEXT_GEN
    CHANGING LPS_ALV_LAYO-TREETEXT.

ENDFORM.                    " 9999_COMP_TREE_GEN_CONTEXT

*&---------------------------------------------------------------------*
*&      Form  9999_COMP_UPDATE_FRONT_END
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_COMPONENT  text
*----------------------------------------------------------------------*
FORM 9999_COMP_UPDATE_FRONT_END
  CHANGING LPS_COMPONENT      TYPE ZST_BM_ALV_LAYO
           LPS_CAPTION        TYPE SBPTCAPTN.
  DATA:
    LW_NODETEXT               TYPE LVC_VALUE.

* Set node text
  LW_NODETEXT               = LPS_COMPONENT-TREETEXT.

* Set update front end node
  CALL METHOD GO_COMPTREE->CHANGE_NODE
    EXPORTING
      I_NODE_KEY     = LPS_COMPONENT-TREEKEY
      I_OUTTAB_LINE  = LPS_COMPONENT
      I_NODE_TEXT    = LW_NODETEXT
      I_U_NODE_TEXT  = GC_XMARK
    EXCEPTIONS
      NODE_NOT_FOUND = 1
      OTHERS         = 2.
*  CALL METHOD CL_GUI_CFW=>FLUSH.

* Execute update tree front end
  CALL METHOD GO_COMPTREE->FRONTEND_UPDATE.

* Set new value to screen
  CALL METHOD GO_CON_BAR->SET_CELL_CAPTION
    EXPORTING
      NAME                = LPS_CAPTION-NAME
      CAPTION             = LPS_CAPTION
    EXCEPTIONS
      CELL_DOES_NOT_EXIST = 1
      OTHERS              = 2.

ENDFORM.                    " 9999_COMP_UPDATE_FRONT_END

*&---------------------------------------------------------------------*
*&      Form  9999_LABEL_CONTEXT_GEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LPW_LBL_CONTEXT  text
*----------------------------------------------------------------------*
FORM 9999_LABEL_CONTEXT_GEN
  CHANGING LPW_LBL_CONTEXT.

  LPW_LBL_CONTEXT       = TEXT-T00 && '-' && GS_PROG-ALVSTR.

ENDFORM.                    " 9999_LABEL_CONTEXT_GEN
