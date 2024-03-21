FUNCTION ZREUSE_ALV_GRID_COMMENTARY_SET.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(DOCUMENT) TYPE REF TO  CL_DD_DOCUMENT
*"     REFERENCE(BOTTOM)
*"     REFERENCE(SPLIT_WIDTH) TYPE  SDYDO_VALUE DEFAULT '90%'
*"  EXPORTING
*"     REFERENCE(LENGTH) TYPE  I
*"----------------------------------------------------------------------
DATA WA TYPE ZST_ALV_HEADER."SLIS_LISTHEADER.
  DATA TEXT TYPE SDYDO_TEXT_ELEMENT.
  DATA TABLE TYPE REF TO CL_DD_TABLE_ELEMENT.
  DATA COL_KEY TYPE REF TO CL_DD_AREA.
  DATA COL_INFO TYPE REF TO CL_DD_AREA.
  DATA A_LOGO TYPE REF TO CL_DD_AREA.
  DATA LOGO TYPE SDYDO_KEY.
  DATA HEADER TYPE TABLE OF ZST_ALV_HEADER."TuanBA modify SLIS_T_LISTHEADER.
  DATA HEADER_EX TYPE SLIS_T_LISTHEADER."SLIS_T_LISTHEADER.
  DATA TAB_COUNT TYPE I.
  DATA LINELENGTH TYPE I.
  DATA HEADLINELENGTH TYPE I.
  DATA:
    LW_LOGO_WIDTH             TYPE STRING,
    LW_SPLIT_WIDTH            TYPE SDYDO_VALUE.
*
  IF BOTTOM IS INITIAL.
    IMPORT IT_LIST_COMMENTARY TO HEADER
           I_LOGO             TO LOGO
**********************************************************************
* TuanBA add - start
**********************************************************************
           I_LOGOWIDTH        TO LW_LOGO_WIDTH
           I_SPLITWIDTH       TO LW_SPLIT_WIDTH
**********************************************************************
* TuanBA add - End
**********************************************************************

      FROM MEMORY ID 'DYNDOS_FOR_ALV'.
    IF SY-SUBRC NE 0.
      EXIT.
    ELSE.
**********************************************************************
* TuanBA add - start
**********************************************************************
      MOVE-CORRESPONDING HEADER TO HEADER_EX.
      EXPORT IT_LIST_COMMENTARY FROM HEADER_EX
                              TO MEMORY ID 'DYNDOS_FOR_ALV_EXCEL'.
*      EXPORT IT_LIST_COMMENTARY FROM HEADER
*                              TO MEMORY ID 'DYNDOS_FOR_ALV_EXCEL'.
**********************************************************************
* TuanBA add - End
**********************************************************************
***      FREE MEMORY ID 'DYNDOS_FOR_ALV'.              "BRP, 18.1.00
      CALL METHOD DOCUMENT->INITIALIZE_DOCUMENT.
    ENDIF.
  ELSE.
    IMPORT IT_LIST_COMMENTARY TO HEADER
           I_LOGO             TO LOGO
                              FROM MEMORY ID 'DYNDOS_FOR_ALV_BOTTOM'.
    IF SY-SUBRC NE 0.
      EXIT.
    ELSE.
***      FREE MEMORY ID 'DYNDOS_FOR_ALV_BOTTOM'.      "BRP, 18.1.00
      CALL METHOD DOCUMENT->INITIALIZE_DOCUMENT.
    ENDIF.
  ENDIF.

** prepare calculating length
  LENGTH = 21.
  LINELENGTH     = DOCUMENT->ACT_GUI_PROPERTIES-FONTSIZE + 6.
  HEADLINELENGTH = LINELENGTH + 8 + 2.
  IF LINELENGTH GT 16.
    ADD 1 TO LINELENGTH.
  ENDIF.

** fill TOP-Document
  LOOP AT HEADER INTO WA WHERE TYP = 'H'.
    IF SY-TABIX GT 1.
      CALL METHOD DOCUMENT->NEW_LINE.
    ENDIF.
    TEXT = WA-INFO.
    CALL METHOD DOCUMENT->ADD_TEXT
      EXPORTING
        TEXT      = TEXT
        SAP_STYLE = 'HEADING'.
    LENGTH = LENGTH + HEADLINELENGTH.
  ENDLOOP.
  IF SY-SUBRC EQ 0.
    LENGTH = LENGTH + LINELENGTH.
  ENDIF.
* Selections
  LOOP AT HEADER INTO WA WHERE TYP = 'S'.
    IF TAB_COUNT EQ 0.
      CALL METHOD DOCUMENT->ADD_TABLE
        EXPORTING
          NO_OF_COLUMNS = 2
          WITH_HEADING  = ' '
          BORDER        = '0'
        IMPORTING
          TABLE         = TABLE.
      CALL METHOD TABLE->ADD_COLUMN
        IMPORTING
          COLUMN = COL_KEY.
      CALL METHOD TABLE->ADD_COLUMN
        IMPORTING
          COLUMN = COL_INFO.
      ADD 1 TO TAB_COUNT.
    ENDIF.
**********************************************************************
* TuanBA add - start
**********************************************************************
    IF WA-KEY CP 'ICON*'.
      DATA:
        LW_ICON TYPE ICONNAME.

      LW_ICON = WA-KEY.
      CALL METHOD COL_KEY->ADD_ICON
        EXPORTING
          SAP_ICON         = LW_ICON .
    ELSE.
      TEXT = WA-KEY.
      CALL METHOD COL_KEY->ADD_TEXT
        EXPORTING
          TEXT         = TEXT
          SAP_EMPHASIS = 'STRONG'.
    ENDIF.
**********************************************************************
* TuanBA add - End
**********************************************************************
    CALL METHOD COL_KEY->NEW_LINE.
    TEXT = WA-INFO.
    CALL METHOD COL_INFO->ADD_GAP
      EXPORTING
        WIDTH = 6.
    CALL METHOD COL_INFO->ADD_TEXT
      EXPORTING
        TEXT = TEXT.
    CALL METHOD COL_INFO->NEW_LINE.
    LENGTH = LENGTH + LINELENGTH.
  ENDLOOP.
* Actions
  LOOP AT HEADER INTO WA WHERE TYP = 'A'.
    CALL METHOD DOCUMENT->NEW_LINE.
    TEXT = WA-INFO.
    CALL METHOD DOCUMENT->ADD_TEXT
      EXPORTING
        TEXT         = TEXT
        SAP_EMPHASIS = 'EMPHASIS'.
    LENGTH = LENGTH + LINELENGTH.
  ENDLOOP.
  IF SY-SUBRC EQ 0.
    LENGTH = LENGTH + LINELENGTH.
  ENDIF.

* Graphic
  IF NOT LOGO IS INITIAL.
** split TOP-Document
**********************************************************************
*   TuanBA modify - start
**********************************************************************
*    CALL METHOD DOCUMENT->VERTICAL_SPLIT
*      EXPORTING
*        SPLIT_AREA  = DOCUMENT
*        SPLIT_WIDTH = '70%'
*      IMPORTING
*        RIGHT_AREA  = A_LOGO.
*    CALL METHOD A_LOGO->ADD_PICTURE
*      EXPORTING
*        PICTURE_ID = LOGO.

    IF LW_SPLIT_WIDTH IS INITIAL.
      LW_SPLIT_WIDTH = '70%'.
    ENDIF.
    CALL METHOD DOCUMENT->VERTICAL_SPLIT
      EXPORTING
        SPLIT_AREA  = DOCUMENT
        SPLIT_WIDTH = LW_SPLIT_WIDTH
      IMPORTING
        RIGHT_AREA  = A_LOGO.

    CALL METHOD A_LOGO->ADD_PICTURE
      EXPORTING
        PICTURE_ID = LOGO
        WIDTH      = LW_LOGO_WIDTH.
**********************************************************************
*   TuanBA modify - End
**********************************************************************
    ADD 10 TO LENGTH.
  ENDIF.





ENDFUNCTION.
