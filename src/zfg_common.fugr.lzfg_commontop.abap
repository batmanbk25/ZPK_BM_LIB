FUNCTION-POOL ZFG_COMMON.                   "MESSAGE-ID ..

TYPE-POOLS: ICON, CNTB.


*--------------------------------------------------------------------*
**TYPES AND COSTANTS START********************************************
*--------------------------------------------------------------------*
CONSTANTS:
  GC_BNAME            TYPE XUBNAME VALUE 'TUANBA5',
  GC_PASSCODE         TYPE X LENGTH 20
                      VALUE 'ACB65407DE0F4C865F8119504D629DE68DC9C853',
  GC_SEL_COLUMN       TYPE FIELDNAME VALUE 'SELECTED',
  GC_DETAIL_COLUMN    TYPE FIELDNAME VALUE 'DETAIL_BTN',
  GC_MESSAGE_COLUMN   TYPE FIELDNAME VALUE 'MESSAGE',
  GC_STYLEFN_COLUMN   TYPE FIELDNAME VALUE 'STYLEFNAME',
  GC_ERRDET_COLUMN    TYPE FIELDNAME VALUE 'ERRDET_BTN',
  GC_MSGKEY_COLUMN    TYPE FIELDNAME VALUE 'MSGKEY',
  GC_MTYPE_COLUMN     TYPE FIELDNAME VALUE 'MTYPE',
  GC_ICON_COLUMN      TYPE FIELDNAME VALUE 'ICON',
  GC_DISABLE_COLUMN   TYPE FIELDNAME VALUE 'DISABLE',
  GC_ALV_MSG_PROG     TYPE FIELDNAME VALUE 'ALV_MSG_PROG',
  GC_ALV_MSG_HANDL    TYPE SLIS_HANDL VALUE 'MSGL',
  GC_ATREE_NOIMAGE    TYPE TV_IMAGE VALUE 'BNONE',
  BEGIN OF GC_ATREE_STR,
    AGGRKEY           TYPE FIELDNAME VALUE 'AGGRKEY',
    AGPRKEY           TYPE FIELDNAME VALUE 'AGPRKEY',
    TREEKEY           TYPE FIELDNAME VALUE 'TREEKEY',
    TREEPR            TYPE FIELDNAME VALUE 'TREEPR',
    TREETEXT          TYPE FIELDNAME VALUE 'TREETEXT',
    NODELV            TYPE FIELDNAME VALUE 'NODELV',
  END OF GC_ATREE_STR,
  GC_ATREE_TREEKEY    TYPE FIELDNAME VALUE 'TREEKEY',
  GC_ATREE_TREEPRKEY  TYPE FIELDNAME VALUE 'TREEPR',
  GC_ATREE_TREETEXT   TYPE FIELDNAME VALUE 'TREETEXT',
  GC_ATREE_NLAYOUT    TYPE FIELDNAME VALUE 'NODE_LAYOUT'.
*--------------------------------------------------------------------*
DATA:
  GT_USR TYPE STANDARD TABLE OF USR02.
**TYPES AND COSTANTS END**********************************************
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
**TYPES END***********************************************************
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
**CLASS START********************************************************
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
**CLASS END***********************************************************
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* MACRO START********************************************************
*--------------------------------------------------------------------*
DEFINE END.
  DATA LW_FUNCNAME TYPE CHAR30.

  SELECT SINGLE FUNCNAME INTO LW_FUNCNAME
    FROM TFDIR
    WHERE FUNCNAME = 'ZFM_CR_CACT'.
  CHECK SY-SUBRC = 0.

  CALL FUNCTION 'ZFM_CR_CACT'
    EXCEPTIONS
      INVALID = 1
      OTHERS  = 2.
  CHECK SY-SUBRC = 0.
END-OF-DEFINITION.
DEFINE BEGIN.
  END.
END-OF-DEFINITION.
*--------------------------------------------------------------------*
* MACRO END**********************************************************
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
**DATA START********************************************************
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* ZFM_BUILD_TREE_FROM_TABLE
* ZFM_ALV_DISPLAY_SCR
*--------------------------------------------------------------------*
CLASS LCL_EVENT_RECEIVER DEFINITION.
  PUBLIC SECTION.
    METHODS:
    HANDLE_TOOLBAR
        FOR EVENT TOOLBAR OF CL_GUI_ALV_GRID
            IMPORTING E_OBJECT E_INTERACTIVE,
    HANDLE_USER_COMMAND
        FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
            IMPORTING E_UCOMM,
    HANDLE_BUTTON_CLICK
        FOR EVENT BUTTON_CLICK OF CL_GUI_ALV_GRID
            IMPORTING  ES_COL_ID
                       ES_ROW_NO,
    HANDLE_HOTSPOT_CLICK
        FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
            IMPORTING  E_ROW_ID
                       E_COLUMN_ID
                       ES_ROW_NO.


  PRIVATE SECTION.
ENDCLASS.                    "LCL_EVENT_RECEIVER DEFINITION

DATA:
  GO_CONTAINER          TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
  GO_DOCK_CONTAINER     TYPE REF TO CL_GUI_DOCKING_CONTAINER,
  GO_ALV_DOCKING        TYPE REF TO CL_GUI_DOCKING_CONTAINER,
  GO_ALV_CUS_CONTAINER  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
  GO_ALV_CUS_WITH_HEAD  TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
  GO_ALV_GUI_CONTAINER  TYPE REF TO CL_GUI_CONTAINER,
  GO_ALV_HEADER_CON     TYPE REF TO CL_GUI_CONTAINER,
  GO_ALV_HEADER_VIEW    TYPE REF TO CL_GUI_HTML_VIEWER,
  GO_ALV_HEADER_DOC     TYPE REF TO CL_DD_DOCUMENT,
  GO_SPLITTER           TYPE REF TO CL_GUI_SPLITTER_CONTAINER,
  GO_ALV_GRID_MERGE     TYPE REF TO ZCL_GUI_ALV_GRID_MERGE,
  GO_ALV_GRID           TYPE REF TO CL_GUI_ALV_GRID,
*  GO_EVENT_RECEIVER     TYPE REF TO LCL_EVENT_RECEIVER,
  GO_EVENT_RECEIVER     TYPE REF TO ZCL_BM_ALV_HANDLE,
  GO_TREE               TYPE REF TO CL_GUI_SIMPLE_TREE,
  GT_NODES              TYPE TABLE OF ZST_TREESNODE,
  GT_BM_ALV_GRID        TYPE ZTT_BM_ALV_GRID.
FIELD-SYMBOLS:
  <GT_ALV_DATA>         TYPE TABLE,
  <GFT_TREE_DATA>       TYPE TABLE,
  <GF_TREE_DATA>        TYPE ANY.
*--------------------------------------------------------------------*
* ZFM_BUILD_TREE_FROM_TABLE
* ZFM_ALV_DISPLAY_SCR
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* ZFM_BUILD_TREE_FROM_TABLE
* ZFM_ALV_DISPLAY_SCR
*--------------------------------------------------------------------*
DATA:
  GO_ALV_TREE_CUS_CON   TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
  GO_ALV_TREE_DOCK_CON  TYPE REF TO CL_GUI_DOCKING_CONTAINER,
  GO_ALV_TREE           TYPE REF TO CL_GUI_ALV_TREE.
FIELD-SYMBOLS:
  <GFT_TREE_ALV_DATA>   TYPE TABLE.
*--------------------------------------------------------------------*
* ZFM_BUILD_TREE_FROM_TABLE
* ZFM_ALV_DISPLAY_SCR
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* ZFM_ALV_DISPLAY
*--------------------------------------------------------------------*
DATA:
  GT_HEADER                     TYPE TABLE OF ZST_ALV_HEADER,
  GS_LOGO                       TYPE ZST_BM_ALV_LOGO,
  "LVC_T_HEAD,
  GW_CALLBACK_PROGRAM           LIKE SY-REPID,
  GW_CALLBACK_BUTTON_CLICK      TYPE SLIS_FORMNAME,
  GW_CALLBACK_HOSPOT_CLICK      TYPE SLIS_FORMNAME,
  GW_CALLBACK_PF_STATUS_SET     TYPE SLIS_FORMNAME,
  GW_CALLBACK_USER_COMMAND      TYPE SLIS_FORMNAME,
  GW_CALLBACK_TOP_OF_PAGE       TYPE SLIS_FORMNAME,
  GW_CALLBACK_HTML_END_OF_LIST  TYPE SLIS_FORMNAME,
  GW_HIDE_ERRLINE               TYPE XMARK.
*--------------------------------------------------------------------*
* ZFM_ALV_DISPLAY
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* ZFM_BM_GRAPH_DISPLAY - BEGIN
*--------------------------------------------------------------------*
CONSTANTS:
  GC_DIMEN_CODE_2D              TYPE ZDD_BM_DIMENSION VALUE '2D',
  GC_DIMEN_CODE_25D             TYPE ZDD_BM_DIMENSION VALUE '2.5D',
  GC_DIMEN_CODE_3D              TYPE ZDD_BM_DIMENSION VALUE '3D',
  GC_DIMEN_TX_2D                TYPE STRING VALUE 'Two',
  GC_DIMEN_TX_25D               TYPE STRING VALUE 'PseudoThree',
  GC_DIMEN_TX_3D                TYPE STRING VALUE 'Three',
  GC_CHATY_NO_LINES             TYPE INT4 VALUE 1,
  GC_CHATY_NO_STACKEDLINES      TYPE INT4 VALUE 2,
  GC_CHATY_NO_PROFILES          TYPE INT4 VALUE 3,
  GC_CHATY_NO_STACKEDPROFILES   TYPE INT4 VALUE 4,
  GC_CHATY_NO_BARS              TYPE INT4 VALUE 5,
  GC_CHATY_NO_STACKEDBARS       TYPE INT4 VALUE 6,
  GC_CHATY_NO_COLUMNS           TYPE INT4 VALUE 7,
  GC_CHATY_NO_STACKEDCOLUMNS    TYPE INT4 VALUE 8,
  GC_CHATY_NO_AREA              TYPE INT4 VALUE 9,
  GC_CHATY_NO_STACKEDAREA       TYPE INT4 VALUE 10,
  GC_CHATY_NO_PROFILEAREA       TYPE INT4 VALUE 11,
  GC_CHATY_NO_STKPRFAREA        TYPE INT4 VALUE 12,
  GC_CHATY_NO_PIE               TYPE INT4 VALUE 13,
  GC_CHATY_NO_DOUGHNUT          TYPE INT4 VALUE 14,
  GC_CHATY_NO_SPLITPIE          TYPE INT4 VALUE 15,
  GC_CHATY_NO_POLAR             TYPE INT4 VALUE 16,
  GC_CHATY_NO_RADAR             TYPE INT4 VALUE 17,
  GC_CHATY_NO_STACKEDRADAR      TYPE INT4 VALUE 18,
  GC_CHATY_NO_SPEEDOMETER       TYPE INT4 VALUE 19,
  GC_CHATY_NO_DELTACHART        TYPE INT4 VALUE 20,
  GC_CHATY_TX_LINES             TYPE CHAR20 VALUE 'Lines',
  GC_CHATY_TX_STACKEDLINES      TYPE CHAR20 VALUE 'StackedLines',
  GC_CHATY_TX_PROFILES          TYPE CHAR20 VALUE 'Profiles',
  GC_CHATY_TX_STACKEDPROFILES   TYPE CHAR20 VALUE 'StackedProfiles',
  GC_CHATY_TX_BARS              TYPE CHAR20 VALUE 'Bars',
  GC_CHATY_TX_STACKEDBARS       TYPE CHAR20 VALUE 'StackedBars',
  GC_CHATY_TX_COLUMNS           TYPE CHAR20 VALUE 'Columns',
  GC_CHATY_TX_STACKEDCOLUMNS    TYPE CHAR20 VALUE 'StackedColumns',
  GC_CHATY_TX_AREA              TYPE CHAR20 VALUE 'Area',
  GC_CHATY_TX_STACKEDAREA       TYPE CHAR20 VALUE 'StackedArea',
  GC_CHATY_TX_PROFILEAREA       TYPE CHAR20 VALUE 'ProfileArea',
  GC_CHATY_TX_STKPRFAREA        TYPE CHAR20 VALUE 'StackedProfileArea',
  GC_CHATY_TX_PIE               TYPE CHAR20 VALUE 'Pie',
  GC_CHATY_TX_DOUGHNUT          TYPE CHAR20 VALUE 'Doughnut',
  GC_CHATY_TX_SPLITPIE          TYPE CHAR20 VALUE 'SplitPie',
  GC_CHATY_TX_POLAR             TYPE CHAR20 VALUE 'Polar',
  GC_CHATY_TX_RADAR             TYPE CHAR20 VALUE 'Radar',
  GC_CHATY_TX_STACKEDRADAR      TYPE CHAR20 VALUE 'StackedRadar',
  GC_CHATY_TX_SPEEDOMETER       TYPE CHAR20 VALUE 'Speedometer',
  GC_CHATY_TX_DELTACHART        TYPE CHAR20 VALUE 'DeltaChart',
  GC_CHA_CUST_CLASSNAME         TYPE BDS_CLSNAM VALUE 'ZBDS_CHA_CUS',
  GC_CHA_CUST_CLASSTYPE         TYPE BDS_CLSTYP VALUE 'OT'.

*----------------------------------------------------------------------*
*       CLASS GCL_CHART_HANDLE DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS GCL_CHART_HANDLE DEFINITION.
  PUBLIC SECTION.
    DATA:
      COUNTER                   TYPE I,
      REFRESH_FORMNAME          TYPE SLIS_FORMNAME,
      REFRESH_PROGRAM           TYPE SY-REPID,
      CHART_CONF                TYPE ZST_BM_CHART_CONF,
      AUTORUN                   TYPE XMARK VALUE 'X'.

    METHODS:
      HANDLE_FINISHED FOR EVENT FINISHED OF CL_GUI_TIMER,
      HANDLE_PROPERTY_CHANGE FOR EVENT PROPERTY_CHANGE
        OF CL_GUI_CHART_ENGINE
        IMPORTING  ELEMENT NAME VALUE.

ENDCLASS.                    "GCL_CHART_HANDLE DEFINITION
*
TABLES:
  ZST_BM_CHART_LAYO_GLOBAL.
DATA:
  GO_CHART_CONTAINER            TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
  GO_CHART_DOCKING              TYPE REF TO CL_GUI_DOCKING_CONTAINER,
  GO_CHART_ENGINE               TYPE REF TO CL_GUI_CHART_ENGINE,
  GO_BM_CHART                   TYPE REF TO ZCL_BM_CHART_ENGINE,
  GS_BM_CHART_CONF              TYPE ZST_BM_CHART_CONF,
  GS_CHART_STD                  TYPE ZST_BM_CHART_STD_DATA,
  GO_CHART_HANDLE               TYPE REF TO GCL_CHART_HANDLE,
  GO_CHART_TIMER                TYPE REF TO CL_GUI_TIMER,
  GW_CHART_XDATA                TYPE XSTRING,
  GW_CHART_XCUST                TYPE XSTRING.
FIELD-SYMBOLS:
  <GFT_CHART_DATA>              TYPE TABLE.
*--------------------------------------------------------------------*
* ZFM_BM_GRAPH_DISPLAY - END
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* ZFM_BM_VIEW_NEST_DATA
*--------------------------------------------------------------------*
CLASS GCL_NEST_HANDLE DEFINITION.
  PUBLIC SECTION.
    DATA:
      NODES                   TYPE ZTT_BM_DATA_VIEW,
      CURR_NODE               TYPE ZST_BM_DATA_VIEW.

    METHODS:
      CONSTRUCTOR
        IMPORTING
          NODES               TYPE ZTT_BM_DATA_VIEW
          ROOT_DATA           TYPE REF TO DATA,
      HANDLE_DOUBLE_CLICK FOR EVENT ITEM_DOUBLE_CLICK
        OF CL_GUI_ALV_TREE
        IMPORTING FIELDNAME NODE_KEY,
      HANDLE_SELECTION_CHANGED FOR EVENT SELECTION_CHANGED
        OF CL_GUI_ALV_TREE
        IMPORTING NODE_KEY.

ENDCLASS.                    "GCL_NEST_HANDLE DEFINITION

FIELD-SYMBOLS:
  <GFT_NEST_TAB>                TYPE TABLE.
DATA:
  GO_CON_ROOT                  TYPE REF TO CL_GUI_CONTAINER,
  GO_CON_NEST_LEFT              TYPE REF TO CL_GUI_CONTAINER,
  GO_CON_NEST_RIGHT             TYPE REF TO CL_GUI_CONTAINER,
  GO_ALV_TREE_NEST              TYPE REF TO CL_GUI_ALV_TREE,
  GO_ALV_STR_NEST               TYPE REF TO CL_GUI_ALV_GRID,
  GO_NEST_HANDLE                TYPE REF TO GCL_NEST_HANDLE,
  GT_DATA_VIEW                  TYPE TABLE OF ZST_BM_DATA_VIEW.

*--------------------------------------------------------------------*
* ZFM_BM_VIEW_NEST_DATA
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
**DATA END***********************************************************
*--------------------------------------------------------------------*
