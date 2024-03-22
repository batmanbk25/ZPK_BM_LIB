*----------------------------------------------------------------------*
***INCLUDE LZFG_BM_POPUPF01.
*----------------------------------------------------------------------*

CLASS  LCL_HANDLE_EVENT IMPLEMENTATION.
  METHOD HANDLE_ALV_COND_F4.
    PERFORM 0100_ALV_COND_F4
      USING E_FIELDNAME
            ES_ROW_NO
            ER_EVENT_DATA.
  ENDMETHOD.
ENDCLASS.

FORM 0100_ALV_COND_F4
  USING E_FIELDNAME   TYPE LVC_FNAME
        ES_ROW_NO     TYPE LVC_S_ROID
        ER_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA.

  DATA:
    LS_SHLP        TYPE SHLP_DESCR,
    LW_SCRFIELD    TYPE DYNFNAM,
    LW_SHLPPARAM   TYPE SHLPFIELD,
    LT_RETURN_VALS TYPE TABLE OF DDSHRETVAL.
  FIELD-SYMBOLS:
    <LF_VALUE>     TYPE ANY.

  CHECK E_FIELDNAME = 'LOW' OR E_FIELDNAME = 'HIGH'.

  READ TABLE GT_CONDITION ASSIGNING FIELD-SYMBOL(<LF_CONDITION>)
    INDEX ES_ROW_NO-ROW_ID.
  CHECK SY-SUBRC IS INITIAL.

  READ TABLE GS_SCR_COND_KEY-DETAIL ASSIGNING FIELD-SYMBOL(<LF_COND>)
    WITH KEY RFIELD = <LF_CONDITION>-FIELDNAME.
  CHECK SY-SUBRC IS INITIAL.

  CALL FUNCTION 'F4IF_DETERMINE_SEARCHHELP'
    EXPORTING
      TABNAME           = <LF_COND>-RTABLE
      FIELDNAME         = <LF_COND>-RFIELD
    IMPORTING
      SHLP              = LS_SHLP
    EXCEPTIONS
      FIELD_NOT_FOUND   = 1
      NO_HELP_FOR_FIELD = 2
      INCONSISTENT_HELP = 3
      OTHERS            = 4.
  CHECK SY-SUBRC IS INITIAL AND LS_SHLP-SHLPNAME IS NOT INITIAL.

  READ TABLE LS_SHLP-INTERFACE INTO DATA(LS_INTERFACE)
    WITH KEY VALFIELD = <LF_COND>-RFIELD.
  IF SY-SUBRC IS INITIAL.
    LW_SHLPPARAM = LS_INTERFACE-SHLPFIELD.
  ELSE.
    READ TABLE LS_SHLP-INTERFACE INTO LS_INTERFACE
      WITH KEY F4FIELD = 'X'.
    IF SY-SUBRC IS INITIAL.
      LW_SHLPPARAM = LS_INTERFACE-SHLPFIELD.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      TABNAME           = 'ZST0_BM_SELOPT'
      FIELDNAME         = E_FIELDNAME
      SEARCHHELP        = LS_SHLP-SHLPNAME
      SHLPPARAM         = LW_SHLPPARAM
    TABLES
      RETURN_TAB        = LT_RETURN_VALS
    EXCEPTIONS
      FIELD_NOT_FOUND   = 1
      NO_HELP_FOR_FIELD = 2
      INCONSISTENT_HELP = 3
      NO_VALUES_FOUND   = 4
      OTHERS            = 5.
  READ TABLE LT_RETURN_VALS INTO DATA(LS_RETVAL)
    WITH KEY FIELDNAME = <LF_COND>-RFIELD.
  IF SY-SUBRC IS INITIAL.
    ASSIGN COMPONENT E_FIELDNAME OF STRUCTURE <LF_CONDITION>
      TO <LF_VALUE>.
    <LF_VALUE> = LS_RETVAL-FIELDVAL.
  ENDIF.

  <LF_COND>-RLOW   = <LF_CONDITION>-LOW.
  <LF_COND>-RHIGH  = <LF_CONDITION>-HIGH.

* Conversation Input
  PERFORM 9999_CONDITION_CONV_INPUT
    CHANGING <LF_COND>.

  CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR_REFRESH'
    EXPORTING
      I_ALV_GRID = GO_ALV_COND.

* Avoid possible standard search help
  ER_EVENT_DATA->M_EVENT_HANDLED = 'X'.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  9999_GEN_OPTION_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LPT_OPTIONS  text
*----------------------------------------------------------------------*
FORM 9999_GEN_OPTION_LIST
  TABLES LPT_OPTIONS STRUCTURE SE16N_SEL_OPTION.

  PERFORM 9999_INIT_SEL_OPT.

  PERFORM 9999_ADD_OPTION:
    TABLES LPT_OPTIONS USING 'I' 'BT',
    TABLES LPT_OPTIONS USING 'I' 'CP',
    TABLES LPT_OPTIONS USING 'I' 'NP',
    TABLES LPT_OPTIONS USING 'I' 'EQ',
    TABLES LPT_OPTIONS USING 'I' 'NB',
    TABLES LPT_OPTIONS USING 'I' 'NE',
    TABLES LPT_OPTIONS USING 'I' 'GT',
    TABLES LPT_OPTIONS USING 'I' 'LT',
    TABLES LPT_OPTIONS USING 'I' 'GE',
    TABLES LPT_OPTIONS USING 'I' 'LE',
    TABLES LPT_OPTIONS USING 'E' 'BT',
    TABLES LPT_OPTIONS USING 'E' 'CP',
    TABLES LPT_OPTIONS USING 'E' 'NP',
    TABLES LPT_OPTIONS USING 'E' 'EQ',
    TABLES LPT_OPTIONS USING 'E' 'NB',
    TABLES LPT_OPTIONS USING 'E' 'NE',
    TABLES LPT_OPTIONS USING 'E' 'GT',
    TABLES LPT_OPTIONS USING 'E' 'LT',
    TABLES LPT_OPTIONS USING 'E' 'GE',
    TABLES LPT_OPTIONS USING 'E' 'LE'.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  9999_INIT_SEL_OPT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 9999_INIT_SEL_OPT.

  REFRESH GT_SEL_INIT.
  DEFINE MAKRO_INIT.
    CLEAR GT_SEL_INIT.
    GT_SEL_INIT-OPTION = &1.
    GT_SEL_INIT-LOW    = &2.
    GT_SEL_INIT-HIGH   = &3.
    APPEND GT_SEL_INIT.
  END-OF-DEFINITION.

  MAKRO_INIT 'EQ' 'X' SPACE.
  MAKRO_INIT 'NE' 'X' SPACE.
  MAKRO_INIT 'BT' 'X' 'X'.
  MAKRO_INIT 'NB' 'X' 'X'.
  MAKRO_INIT 'GT' 'X' SPACE.
  MAKRO_INIT 'LT' 'X' SPACE.
  MAKRO_INIT 'GE' 'X' SPACE.
  MAKRO_INIT 'LE' 'X' SPACE.

ENDFORM.                    " 9999_INIT_SEL_OPT

*&---------------------------------------------------------------------*
*&      Form  9999_ADD_OPTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPT_OPTIONS  text
*      -->LPW_SIGN   text
*      -->LPW_OPTION   text
*----------------------------------------------------------------------*
FORM 9999_ADD_OPTION
  TABLES LPT_OPTIONS  STRUCTURE SE16N_SEL_OPTION
   USING LPW_SIGN     TYPE SE16N_SIGN
         LPW_OPTION   TYPE SE16N_OPTION.

  DATA:
    LS_OPTION    TYPE SE16N_SEL_OPTION,
    LW_TEXT      TYPE ICONT-QUICKINFO,
    LW_ICON_NAME TYPE ICON-NAME.

* Set sign, option
  LS_OPTION-SIGN    = LPW_SIGN.
  LS_OPTION-OPTION  = LPW_OPTION.

* Get icon name
  CALL FUNCTION 'SELSCREEN_ICONS_SUPPLY'
    EXPORTING
      SIGN           = LPW_SIGN
      OPTION         = LPW_OPTION
    IMPORTING
      ICON_RESULT    = LS_OPTION-ICON
    EXCEPTIONS
      ILLEGAL_SIGN   = 1
      ILLEGAL_OPTION = 2
      OTHERS         = 3.

  LW_ICON_NAME = LS_OPTION-ICON.
  SPLIT LS_OPTION-ICON AT '@' INTO LW_ICON_NAME LS_OPTION-TEXT LW_ICON_NAME.
  LS_OPTION-TEXT = LS_OPTION-TEXT+4.

** Get icon text
*  CALL FUNCTION 'ICON_CHECK'
*    EXPORTING
*      ICON_NAME      = LW_ICON_NAME
*      LANGUAGE       = SY-LANGU
*    IMPORTING
*      ICON_TEXT      = LW_TEXT
*    EXCEPTIONS
*      ICON_NOT_FOUND = 1
*      OTHERS         = 2.
*  IF SY-SUBRC IS INITIAL.
*    LS_OPTION-TEXT = LW_TEXT.
*  ENDIF.

  APPEND LS_OPTION TO LPT_OPTIONS.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form 0000_INIT_PROC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM 0000_INIT_PROC.
  DATA:
    LT_COND_NAME TYPE TABLE OF ZTB_BM_COND_NAME
                  WITH UNIQUE SORTED KEY KEY COMPONENTS CONDNM,
    LT_COND_DIM  TYPE TABLE OF ZST0_BM_COND_DIM
                  WITH UNIQUE SORTED KEY KEY
                  COMPONENTS CONDNM  TABNAME FIELDNAME,
    LT_COND      TYPE TABLE OF ZTB_BM_COND
                  WITH UNIQUE SORTED KEY KEY
                  COMPONENTS CONDNM CONDKEY CONDID RTABLE RFIELD RANGID,
    LS_COND_KEY  TYPE ZST0_BM_COND_KEY,
    LS_CONDNM    TYPE ZST0_BM_CONDNM.

* Get condition names
  SELECT *
    FROM ZTB_BM_COND_NAME
    INTO TABLE LT_COND_NAME.

* Get range table
  SELECT DISTINCT TABNAME
    FROM ZTB_BM_COND_DIM
    INTO TABLE GT_RTABLE
   WHERE TABNAME NE SPACE.
  SORT GT_RTABLE BY TABLE.

* Get condition dimension
  SELECT D~CONDNM
         D~TABNAME
         D~FIELDNAME
         D~DESCR
         D~KFFLAG
         D~CHFLAG
         D~CHECKTABLE
         D~CHECKFIELD
         D~DESCF
         D~LANGF
         T~SCRTEXT_L
         T~ROLLNAME
         C~CONVEXIT
    FROM ZTB_BM_COND_DIM AS D INNER JOIN DD03VT AS T
      ON D~TABNAME = T~TABNAME AND D~FIELDNAME = T~FIELDNAME
     AND T~DDLANGUAGE = SY-LANGU
   INNER JOIN DD04L AS C ON T~ROLLNAME = C~ROLLNAME
    INTO CORRESPONDING FIELDS OF TABLE LT_COND_DIM.

* Get condition details
  SELECT *
    FROM ZTB_BM_COND
    INTO TABLE LT_COND.

* Pack data
  LOOP AT LT_COND_NAME INTO DATA(LS_COND_NAME).
    CLEAR: LS_CONDNM.
*   Condition names
    MOVE-CORRESPONDING LS_COND_NAME TO LS_CONDNM.

*   Condition dimensions
    LOOP AT LT_COND_DIM INTO DATA(LS_COND_DIM)
      WHERE CONDNM = LS_COND_NAME-CONDNM.
      APPEND LS_COND_DIM TO LS_CONDNM-DIMENSIONS.
    ENDLOOP.

*   Condition keys
    LOOP AT LT_COND INTO DATA(LS_COND)
      WHERE CONDNM = LS_COND_NAME-CONDNM.
*     New Condition keys
      AT NEW CONDKEY.
        CLEAR: LS_COND_KEY.
        LS_COND_KEY-CONDKEY = LS_COND-CONDKEY.
      ENDAT.

*     Condition details
      APPEND LS_COND TO LS_COND_KEY-DETAIL.
      AT END OF CONDKEY.
        APPEND LS_COND_KEY TO LS_CONDNM-KEYS.
      ENDAT.
    ENDLOOP.

    APPEND LS_CONDNM TO GT_CONDNM.
  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'ZGS_100'.
  SET TITLEBAR 'ZGT_100'.

  PERFORM 0100_PBO.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Form 0100_PBO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM 0100_PBO .
  DATA:
    LS_LAYOUT    TYPE LVC_S_LAYO,
    LS_LAYO_CHAR TYPE LVC_S_LAYO,
    LT_FCAT_COND TYPE LVC_T_FCAT,
    LT_FCAT_CHAR TYPE LVC_T_FCAT,
    LS_VAR_COND  TYPE DISVARIANT,
    LS_VAR_CHAR  TYPE DISVARIANT.

  CALL FUNCTION 'ZFM_SCR_PBO'
    EXPORTING
      I_CPROG            = SY-REPID
      I_DYNNR            = SY-DYNNR
      I_SET_LIST_VALUES  = 'X'
      I_SET_LIST_DEFAULT = SPACE.

  LS_LAYOUT-NO_TOOLBAR    = 'X'.
  LS_LAYOUT-CWIDTH_OPT    = 'X'.
  LS_LAYOUT-GRID_TITLE    = TEXT-001.
  LS_LAYO_CHAR            = LS_LAYOUT.
  LS_LAYO_CHAR-GRID_TITLE = TEXT-002.
  LS_VAR_COND-REPORT      = LS_VAR_CHAR-REPORT = SY-REPID.
  LS_VAR_COND-HANDLE      = 'COND'.
  LS_VAR_CHAR-HANDLE      = 'CHAR'.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = 'ZST0_BM_SELOPT'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_COND
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.
  LOOP AT LT_FCAT_COND ASSIGNING FIELD-SYMBOL(<LF_FCAT>).
    CASE <LF_FCAT>-FIELDNAME.
      WHEN 'LOW' OR 'HIGH'.
        <LF_FCAT>-EDIT = 'X'.
        <LF_FCAT>-F4AVAILABL = 'X'.
      WHEN 'FIELDNAME' OR 'CONDID' OR 'TEXT' OR 'TO_TEXT'.
        <LF_FCAT>-NO_OUT = SPACE.
      WHEN 'OPTI_PUSH' OR 'VALU_PUSH'.
        <LF_FCAT>-STYLE       = CL_GUI_ALV_GRID=>MC_STYLE_BUTTON.
      WHEN OTHERS.
        <LF_FCAT>-NO_OUT = 'X'.
    ENDCASE.
  ENDLOOP.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = 'ZST0_BM_COND_DIM'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_CHAR
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.
  LOOP AT LT_FCAT_CHAR ASSIGNING <LF_FCAT>.
    CASE <LF_FCAT>-FIELDNAME.
      WHEN 'FIELDNAME' OR 'SCRTEXT_L'.
        <LF_FCAT>-NO_OUT = SPACE.
      WHEN OTHERS.
        <LF_FCAT>-NO_OUT = 'X'.
    ENDCASE.
  ENDLOOP.

  IF GO_ALV_COND IS INITIAL.
    CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR'
      EXPORTING
        I_CPROG                 = SY-REPID
        I_DYNNR                 = SY-DYNNR
        I_CUS_CONTROL_NAME      = 'CUS_CONDITIONS'
        IS_LAYOUT               = LS_LAYOUT
        IS_VARIANT              = LS_VAR_COND
        I_CALLBACK_PROGRAM      = SY-REPID
        I_CALLBACK_BUTTON_CLICK = '0100_ALV_COND_PUSH'
      IMPORTING
        E_ALV_GRID              = GO_ALV_COND
      CHANGING
        IT_OUTTAB               = GT_CONDITION
        IT_FIELDCATALOG         = LT_FCAT_COND.

    DATA: LT_F4 TYPE LVC_T_F4 WITH HEADER LINE.
    CLEAR LT_F4.
    LT_F4-FIELDNAME = 'LOW'.
    LT_F4-REGISTER  = 'X'.
    INSERT TABLE LT_F4.
    LT_F4-FIELDNAME = 'HIGH'.
    LT_F4-REGISTER  = 'X'.
    INSERT TABLE LT_F4.
    CALL METHOD GO_ALV_COND->REGISTER_F4_FOR_FIELDS
      EXPORTING
        IT_F4 = LT_F4[].

    CALL METHOD GO_ALV_COND->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

    CALL METHOD GO_ALV_COND->REGISTER_EDIT_EVENT
      EXPORTING
        I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

    SET HANDLER LCL_HANDLE_EVENT=>HANDLE_ALV_COND_F4 FOR GO_ALV_COND.

    CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR'
      EXPORTING
        I_CPROG            = SY-REPID
        I_DYNNR            = SY-DYNNR
        I_CUS_CONTROL_NAME = 'CUS_FIELDCAT'
        IS_LAYOUT          = LS_LAYO_CHAR
        IS_VARIANT         = LS_VAR_CHAR
      IMPORTING
        E_ALV_GRID         = GO_ALV_CHAR
      CHANGING
        IT_OUTTAB          = GT_ALV_DIMENS
        IT_FIELDCATALOG    = LT_FCAT_CHAR.
  ELSE.
    CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR_REFRESH'
      EXPORTING
        I_ALV_GRID = GO_ALV_COND.

    CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR_REFRESH'
      EXPORTING
        I_ALV_GRID = GO_ALV_CHAR.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  0100_VALUE_COND_PUSH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ES_COL_ID  text
*      -->ES_ROW_NO  text
*----------------------------------------------------------------------*
FORM 0100_ALV_COND_PUSH
  USING   ES_COL_ID TYPE  LVC_S_COL
          ES_ROW_NO TYPE  LVC_S_ROID.

  CASE ES_COL_ID-FIELDNAME.
    WHEN 'OPTI_PUSH'.
      PERFORM 0100_OPTI_COND_PUSH
        USING ES_COL_ID
              ES_ROW_NO.
    WHEN 'VALU_PUSH'.
      PERFORM 0100_VALUE_COND_PUSH
        USING ES_COL_ID
              ES_ROW_NO.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  0100_OPTI_COND_PUSH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ES_COL_ID  text
*      -->ES_ROW_NO  text
*----------------------------------------------------------------------*
FORM 0100_OPTI_COND_PUSH
  USING   ES_COL_ID TYPE  LVC_S_COL
          ES_ROW_NO TYPE  LVC_S_ROID.
  CHECK ES_COL_ID-FIELDNAME = 'OPTI_PUSH'.

* Get cell position
  READ TABLE GT_CONDITION ASSIGNING FIELD-SYMBOL(<LF_SELOPT>)
    INDEX ES_ROW_NO-ROW_ID.
  CHECK SY-SUBRC IS INITIAL.

* Get DB condition
  READ TABLE GS_SCR_COND_KEY-DETAIL ASSIGNING FIELD-SYMBOL(<LF_COND>)
    WITH KEY RFIELD = <LF_SELOPT>-FIELDNAME
             RANGID = 1.
  CHECK SY-SUBRC IS INITIAL.

* Popup range
  CALL FUNCTION 'ZFM_BM_POPUP_RANGE_OPTION'
    CHANGING
      C_SIGN   = <LF_COND>-RSIGN
      C_OPTION = <LF_COND>-ROPTI
      C_HIGH   = <LF_COND>-RHIGH.

* Convert conditions to screen
  PERFORM 9999_CONV_CONDITION_DB2ALV
    USING GS_SCR_COND_KEY-DETAIL
    CHANGING GT_CONDITION.

* Refresh ALV
  CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR_REFRESH'
    EXPORTING
      I_ALV_GRID = GO_ALV_COND.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  0100_VALUE_COND_PUSH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->ES_COL_ID  text
*      -->ES_ROW_NO  text
*----------------------------------------------------------------------*
FORM 0100_VALUE_COND_PUSH
  USING   ES_COL_ID TYPE  LVC_S_COL
          ES_ROW_NO TYPE  LVC_S_ROID.
  DATA:
    LS_SELOPT     TYPE ZST0_BM_SELOPT,
    LT_COND       TYPE TABLE OF ZTB_BM_COND,
    LS_RSTABFIELD TYPE RSTABFIELD,
    LS_RANGE      TYPE RSDSSELOPT,
    LR_RANGE      TYPE RSDSSELOPT_T.

  CHECK ES_COL_ID-FIELDNAME = 'VALU_PUSH'.

* Get cell position
  READ TABLE GT_CONDITION INTO LS_SELOPT INDEX ES_ROW_NO-ROW_ID.

* Update first row DB condition
  LOOP AT GS_SCR_COND_KEY-DETAIL ASSIGNING FIELD-SYMBOL(<LF_SRC_COND>)
    WHERE RFIELD  = LS_SELOPT-FIELDNAME
      AND CONDID  = LS_SELOPT-CONDID.
    <LF_SRC_COND>-RSIGN  = LS_SELOPT-SIGN.
    <LF_SRC_COND>-ROPTI  = LS_SELOPT-OPTION.
    <LF_SRC_COND>-RLOW   = LS_SELOPT-LOW.
    <LF_SRC_COND>-RHIGH  = LS_SELOPT-HIGH.
    EXIT.
  ENDLOOP.

  LT_COND = GS_SCR_COND_KEY-DETAIL.
  DELETE LT_COND
    WHERE RFIELD <> LS_SELOPT-FIELDNAME
       OR CONDID  <> LS_SELOPT-CONDID.

  READ TABLE GT_ALL_DIMENS INTO DATA(LS_CHAR)
    WITH KEY TABNAME = ZTB_BM_COND_NAME-RTABLE
             FIELDNAME = LS_SELOPT-FIELDNAME BINARY SEARCH.
  IF LS_CHAR-CHECKTABLE IS NOT INITIAL.
    LS_RSTABFIELD-TABLENAME = LS_CHAR-CHECKTABLE.
    LS_RSTABFIELD-FIELDNAME = LS_CHAR-CHECKFIELD.
  ELSE.
    LS_RSTABFIELD-TABLENAME = ZTB_BM_COND_NAME-RTABLE.
    LS_RSTABFIELD-FIELDNAME = LS_SELOPT-FIELDNAME.
  ENDIF.

  DELETE LT_COND INDEX 1.
  MOVE-CORRESPONDING LS_SELOPT TO LS_RANGE.
  IF LS_RANGE IS NOT INITIAL.
    APPEND LS_RANGE TO LR_RANGE.
  ENDIF.
  LOOP AT LT_COND INTO DATA(LS_COND).
    LS_RANGE-SIGN    = LS_COND-RSIGN.
    LS_RANGE-OPTION  = LS_COND-ROPTI.
    LS_RANGE-LOW     = LS_COND-RLOW.
    LS_RANGE-HIGH    = LS_COND-RHIGH.
    APPEND LS_RANGE TO LR_RANGE.
  ENDLOOP.

  CALL FUNCTION 'COMPLEX_SELECTIONS_DIALOG'
    EXPORTING
      TITLE             = 'Selection'
      TEXT              = 'Option'
      TAB_AND_FIELD     = LS_RSTABFIELD
    TABLES
      RANGE             = LR_RANGE
    EXCEPTIONS
      NO_RANGE_TAB      = 1
      CANCELLED         = 2
      INTERNAL_ERROR    = 3
      INVALID_FIELDNAME = 4
      OTHERS            = 5.

  CHECK LR_RANGE[] IS NOT INITIAL.
  DELETE GS_SCR_COND_KEY-DETAIL
    WHERE RFIELD  = LS_SELOPT-FIELDNAME
      AND CONDID  = LS_SELOPT-CONDID.
  LOOP AT LR_RANGE INTO LS_RANGE.
    CLEAR: LS_COND.
    LS_COND-RTABLE  = ZTB_BM_COND_NAME-RTABLE.
    LS_COND-CONDID  = LS_SELOPT-CONDID.
    LS_COND-RFIELD  = LS_SELOPT-FIELDNAME.
    LS_COND-RANGID  = SY-TABIX.
    LS_COND-RSIGN   = LS_RANGE-SIGN.
    LS_COND-ROPTI   = LS_RANGE-OPTION.
    LS_COND-RLOW    = LS_RANGE-LOW.
    LS_COND-RHIGH   = LS_RANGE-HIGH.
    APPEND LS_COND TO GS_SCR_COND_KEY-DETAIL.
  ENDLOOP.

* Convert conditions to screen
  PERFORM 9999_CONV_CONDITION_DB2ALV
    USING GS_SCR_COND_KEY-DETAIL
    CHANGING GT_CONDITION.

* Refresh ALV
  CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR_REFRESH'
    EXPORTING
      I_ALV_GRID = GO_ALV_COND.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form 9999_CONV_CONDITION_DB2ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM 9999_CONV_CONDITION_DB2ALV
  USING    LPT_COND_DB TYPE ZTT_BM_COND
  CHANGING LPT_COND_ALV TYPE ZTT0_BM_SELOPT.

  DATA:
    LT_COND      TYPE TABLE OF ZTB_BM_COND,
    LS_SELOPT    TYPE ZST0_BM_SELOPT,
    LW_FIELDNAME TYPE CHAR61,
    LW_SCRTEXT_L TYPE SCRTEXT_L.

  CLEAR: LPT_COND_ALV.

  LT_COND = LPT_COND_DB.
  SORT LT_COND BY CONDID RFIELD.

  GT_ALV_DIMENS = GT_ALL_DIMENS.
  DELETE GT_ALV_DIMENS WHERE TABNAME <> ZTB_BM_COND_NAME-RTABLE.
  LOOP AT LPT_COND_DB INTO DATA(LS_COND).
    AT NEW RFIELD.
      CLEAR: LS_SELOPT.
      LS_SELOPT-FIELDNAME = LS_COND-RFIELD.
      LS_SELOPT-CONDID    = LS_COND-CONDID.
      READ TABLE GT_ALV_DIMENS INTO DATA(LS_DIMENSION)
        WITH KEY CONDNM     = LS_COND-CONDNM
                 TABNAME    = LS_COND-RTABLE
                 FIELDNAME  = LS_COND-RFIELD BINARY SEARCH.
      IF SY-SUBRC IS INITIAL.
        LS_SELOPT-TEXT    = LS_DIMENSION-SCRTEXT_L .
      ENDIF.
      LS_SELOPT-TO_TEXT = 'To'.
      DELETE GT_ALV_DIMENS WHERE FIELDNAME = LS_COND-RFIELD.
    ENDAT.

    IF LS_SELOPT-SIGN IS INITIAL.
      LS_SELOPT-SIGN    = LS_COND-RSIGN.
      LS_SELOPT-OPTION  = LS_COND-ROPTI.
      LS_SELOPT-LOW     = LS_COND-RLOW.
      LS_SELOPT-HIGH    = LS_COND-RHIGH.
      CALL FUNCTION 'SELSCREEN_ICONS_SUPPLY'
        EXPORTING
          SIGN           = LS_SELOPT-SIGN
          OPTION         = LS_SELOPT-OPTION
        IMPORTING
          ICON_RESULT    = LS_SELOPT-OPTI_PUSH
        EXCEPTIONS
          ILLEGAL_SIGN   = 1
          ILLEGAL_OPTION = 2
          OTHERS         = 3.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          NAME                  = 'ICON_ENTER_MORE'
        IMPORTING
          RESULT                = LS_SELOPT-VALU_PUSH
        EXCEPTIONS
          ICON_NOT_FOUND        = 1
          OUTPUTFIELD_TOO_SHORT = 2
          OTHERS                = 3.
    ELSE.
      CALL FUNCTION 'ICON_CREATE'
        EXPORTING
          NAME                  = 'ICON_DISPLAY_MORE'
        IMPORTING
          RESULT                = LS_SELOPT-VALU_PUSH
        EXCEPTIONS
          ICON_NOT_FOUND        = 1
          OUTPUTFIELD_TOO_SHORT = 2
          OTHERS                = 3.
    ENDIF.

    AT END OF RFIELD.
      APPEND LS_SELOPT TO LPT_COND_ALV.
    ENDAT.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CALL FUNCTION 'ZFM_SCR_SIMPLE_FC_PROCESS'.
  IF GO_ALV_COND IS BOUND.
    CALL METHOD GO_ALV_COND->CHECK_CHANGED_DATA.
  ENDIF.

  CASE SY-UCOMM.
    WHEN 'OK'.
      CALL FUNCTION 'ZFM_SCR_PAI'
        EXPORTING
          I_CPROG = SY-REPID
          I_DYNNR = SY-DYNNR.
      PERFORM 0100_OK.
    WHEN 'MOVE_ALL_RIGHT'.
      PERFORM 0100_FC_MOVE_ALL_RIGHT.
    WHEN 'MOVE_RIGHT'.
      PERFORM 0100_FC_MOVE_RIGHT.
    WHEN 'MOVE_LEFT'.
      PERFORM 0100_FC_MOVE_LEFT.
    WHEN 'MOVE_ALL_LEFT'.
      PERFORM 0100_FC_MOVE_ALL_LEFT.
*    WHEN 'FC_SRCTAB'.
*      PERFORM 0100_FC_SRCTAB.
    WHEN 'ADDCOND'.
      PERFORM 0100_ADDCOND.
    WHEN OTHERS.
      CALL FUNCTION 'ZFM_SCR_PAI'
        EXPORTING
          I_CPROG = SY-REPID
          I_DYNNR = SY-DYNNR.
  ENDCASE.
  CLEAR: SY-UCOMM.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  0100_CANCEL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE 0100_CANCEL INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Form 0100_FC_MOVE_ALL_RIGHT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM 0100_FC_MOVE_ALL_RIGHT .
* Clear all detail conditions
  CLEAR GS_SCR_COND_KEY-DETAIL.

* Convert conditions to screen
  PERFORM 9999_CONV_CONDITION_DB2ALV
    USING GS_SCR_COND_KEY-DETAIL
    CHANGING GT_CONDITION.

* Refresh alv
  CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR_REFRESH'
    EXPORTING
      I_ALV_GRID = GO_ALV_COND.

  CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR_REFRESH'
    EXPORTING
      I_ALV_GRID = GO_ALV_CHAR.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  0100_FC_MOVE_RIGHT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0100_FC_MOVE_RIGHT .
  DATA:
    LW_ROW    TYPE I.

* Get current cell in condition alv
  CALL METHOD GO_ALV_COND->GET_CURRENT_CELL
    IMPORTING
      E_ROW = LW_ROW.

* Get current condition in screen
  READ TABLE GT_CONDITION INTO DATA(LS_COND) INDEX LW_ROW.
  CHECK SY-SUBRC IS INITIAL.

* Remove current condition in DB
  DELETE GS_SCR_COND_KEY-DETAIL
    WHERE RFIELD = LS_COND-FIELDNAME
      AND CONDID = LS_COND-CONDID.

* Convert conditions to screen
  PERFORM 9999_CONV_CONDITION_DB2ALV
    USING GS_SCR_COND_KEY-DETAIL
    CHANGING GT_CONDITION.

* Refresh alv
  CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR_REFRESH'
    EXPORTING
      I_ALV_GRID = GO_ALV_COND.

  CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR_REFRESH'
    EXPORTING
      I_ALV_GRID = GO_ALV_CHAR.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  0100_FC_MOVE_LEFT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0100_FC_MOVE_LEFT.
  DATA:
    LW_ROW  TYPE I,
    LS_COND TYPE ZTB_BM_COND.

* Get current cell in dimensions alv
  CALL METHOD GO_ALV_CHAR->GET_CURRENT_CELL
    IMPORTING
      E_ROW = LW_ROW.

* Get dimension need to add to condition
  READ TABLE GT_ALV_DIMENS INTO DATA(LS_DIMENSION) INDEX LW_ROW.
  IF SY-SUBRC IS INITIAL.
    CLEAR: LS_COND.

    LS_COND-CONDNM  = ZTB_BM_COND_NAME-CONDNM.
    LS_COND-CONDKEY = ZST0_BM_COND_KEY_FLAT-CONDKEY.
    LS_COND-RTABLE  = ZTB_BM_COND_NAME-RTABLE.
    LS_COND-RFIELD  = LS_DIMENSION-FIELDNAME.
    LS_COND-RANGID  = 1.
    APPEND LS_COND TO GS_SCR_COND_KEY-DETAIL.

*   Convert conditions to screen
    PERFORM 9999_CONV_CONDITION_DB2ALV
      USING GS_SCR_COND_KEY-DETAIL
      CHANGING GT_CONDITION.

*   Refresh alv
    CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR_REFRESH'
      EXPORTING
        I_ALV_GRID = GO_ALV_COND.

    CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR_REFRESH'
      EXPORTING
        I_ALV_GRID = GO_ALV_CHAR.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  0100_FC_MOVE_LEFT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0100_FC_MOVE_ALL_LEFT.
  DATA:
    LS_COND TYPE ZTB_BM_COND.

* Add all dimension to condition
  LOOP AT GT_ALV_DIMENS INTO DATA(LS_DIMENSION).
    CLEAR: LS_COND.
    LS_COND-RTABLE  = ZTB_BM_COND_NAME-RTABLE.
    LS_COND-RFIELD  = LS_DIMENSION-FIELDNAME.
    LS_COND-RANGID  = 1.
    APPEND LS_COND TO GS_SCR_COND_KEY-DETAIL.
  ENDLOOP.

* Convert conditions to screen
  PERFORM 9999_CONV_CONDITION_DB2ALV
      USING GS_SCR_COND_KEY-DETAIL
      CHANGING GT_CONDITION.

* Refresh alv
  CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR_REFRESH'
    EXPORTING
      I_ALV_GRID = GO_ALV_COND.

  CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR_REFRESH'
    EXPORTING
      I_ALV_GRID = GO_ALV_CHAR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form 0100_ADDCOND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM 0100_ADDCOND .

  DATA:
    LT_SELOPT     TYPE TABLE OF ZST0_BM_SELOPT,
    LS_SELOPT     TYPE ZST0_BM_SELOPT,
    LS_COND       TYPE ZTB_BM_COND,
    LW_RETURNCODE TYPE C.

* Get current condition
  CALL FUNCTION 'ZFM_ALV_ROWS_GET_SELECTED'
    EXPORTING
      I_ALV_GRID  = GO_ALV_COND
      IT_ALV_DATA = GT_CONDITION
    IMPORTING
      ET_SEL_DATA = LT_SELOPT.

  IF LT_SELOPT IS INITIAL.
    MESSAGE S018(ZMS_COL_LIB) DISPLAY LIKE GC_MTYPE_W.
    RETURN.
  ENDIF.

* Popup to input new condition ID
  CALL FUNCTION 'ZFM_POPUP_SET_DATA_RECORD'
    EXPORTING
      I_POPUP_TITLE = TEXT-001
      I_SUB_TABNAME = 'ZST0_BM_SELOPT'
      I_SUB_FNAME   = 'CONDID'
    IMPORTING
      RETURNCODE    = LW_RETURNCODE
    CHANGING
      C_RECORD      = LS_SELOPT.
  CHECK LW_RETURNCODE IS INITIAL.

* Copy all condition to new condition set
  MODIFY LT_SELOPT FROM LS_SELOPT
    TRANSPORTING CONDID WHERE CONDID <> LS_SELOPT-CONDID.
  APPEND LINES OF LT_SELOPT TO GT_CONDITION.
  LOOP AT LT_SELOPT INTO LS_SELOPT.
    CLEAR: LS_COND.
    LS_COND-RTABLE  = ZTB_BM_COND_NAME-RTABLE.
    LS_COND-RFIELD  = LS_SELOPT-FIELDNAME.
    LS_COND-CONDID  = LS_SELOPT-CONDID.
    LS_COND-RANGID  = 1.
    APPEND LS_COND TO GS_SCR_COND_KEY-DETAIL.
  ENDLOOP.

* Convert conditions to screen
  PERFORM 9999_CONV_CONDITION_DB2ALV
      USING GS_SCR_COND_KEY-DETAIL
      CHANGING GT_CONDITION.

* Refresh alv
  CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR_REFRESH'
    EXPORTING
      I_ALV_GRID = GO_ALV_COND.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form 0100_OK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM 0100_OK .
  DATA:
    LW_INDEX    TYPE I.

  LOOP AT GT_CONDITION INTO DATA(LS_SELOPT).
    LOOP AT GS_SCR_COND_KEY-DETAIL ASSIGNING FIELD-SYMBOL(<LF_SRC_COND>)
      WHERE RFIELD  = LS_SELOPT-FIELDNAME
        AND CONDID  = LS_SELOPT-CONDID.
      <LF_SRC_COND>-RSIGN  = LS_SELOPT-SIGN.
      <LF_SRC_COND>-ROPTI  = LS_SELOPT-OPTION.
      <LF_SRC_COND>-RLOW   = LS_SELOPT-LOW.
      <LF_SRC_COND>-RHIGH  = LS_SELOPT-HIGH.

*     Conversation Input
      PERFORM 9999_CONDITION_CONV_INPUT
        CHANGING <LF_SRC_COND>.
    ENDLOOP.
  ENDLOOP.


  LEAVE TO SCREEN 0.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form 9999_CONDITION_CONV_INPUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LF_SRC_COND>
*&---------------------------------------------------------------------*
FORM 9999_CONDITION_CONV_INPUT
  CHANGING LPS_COND TYPE ZTB_BM_COND.
  DATA:
    LR_DATA     TYPE REF TO DATA,
    LW_FUNCNAME TYPE CHAR30.
  FIELD-SYMBOLS:
    <LF_VALUE>  TYPE ANY.

  IF LPS_COND-RSIGN IS INITIAL.
    LPS_COND-RSIGN = 'I'.
  ENDIF.
  IF LPS_COND-ROPTI IS INITIAL.
    IF LPS_COND-RHIGH IS INITIAL.
      LPS_COND-ROPTI = 'EQ'.
    ELSE.
      LPS_COND-ROPTI = 'BT'.
    ENDIF.
  ENDIF.

  READ TABLE GT_ALL_DIMENS INTO DATA(LS_DIMENSION)
    WITH KEY TABNAME = LPS_COND-RTABLE
             FIELDNAME = LPS_COND-RFIELD BINARY SEARCH.
  IF SY-SUBRC IS INITIAL
  AND LS_DIMENSION-CONVEXIT IS NOT INITIAL.
    CREATE DATA LR_DATA TYPE (LS_DIMENSION-ROLLNAME).
    ASSIGN LR_DATA->* TO <LF_VALUE>.
    LW_FUNCNAME = 'CONVERSION_EXIT_' && LS_DIMENSION-CONVEXIT && '_INPUT'.

    <LF_VALUE> = LPS_COND-RLOW.
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT':
    CALL FUNCTION LW_FUNCNAME
      EXPORTING
        INPUT  = <LF_VALUE>
      IMPORTING
        OUTPUT = <LF_VALUE>.
    LPS_COND-RLOW = <LF_VALUE>.

    <LF_VALUE> = LPS_COND-RHIGH.
    CALL FUNCTION LW_FUNCNAME
      EXPORTING
        INPUT  = <LF_VALUE>
      IMPORTING
        OUTPUT = <LF_VALUE>.
    LPS_COND-RHIGH = <LF_VALUE>.
  ENDIF.
ENDFORM.
