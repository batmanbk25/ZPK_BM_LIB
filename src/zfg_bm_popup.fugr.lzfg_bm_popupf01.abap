*----------------------------------------------------------------------*
***INCLUDE LZFG_BM_POPUPF01.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  GEN_OPTION_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LPT_OPTIONS  text
*----------------------------------------------------------------------*
FORM GEN_OPTION_LIST
  TABLES LPT_OPTIONS STRUCTURE SE16N_SEL_OPTION.

  PERFORM INIT_SEL_OPT.

  PERFORM ADD_OPTION:
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
*&      Form  init_sel_opt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM INIT_SEL_OPT.

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

ENDFORM.                    " init_sel_opt

*&---------------------------------------------------------------------*
*&      Form  ADD_OPTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPT_OPTIONS  text
*      -->LPW_SIGN   text
*      -->LPW_OPTION   text
*----------------------------------------------------------------------*
FORM ADD_OPTION
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
