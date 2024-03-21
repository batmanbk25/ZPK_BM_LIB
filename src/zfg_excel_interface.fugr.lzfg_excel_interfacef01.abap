*----------------------------------------------------------------------*
*&  Include           LZFG_EXCEL_INTERFACEF01
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  CREATE_CONTAINER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CREATE_CONTAINER
  USING LPW_CONTAINER TYPE SCRFNAME.

  DATA:
    LW_APPLICATION TYPE SCRFNAME.

  CONCATENATE 'EXCEL' LPW_CONTAINER INTO LW_APPLICATION
    SEPARATED BY SPACE.

* Create the instance control.
  CALL METHOD C_OI_CONTAINER_CONTROL_CREATOR=>GET_CONTAINER_CONTROL
    IMPORTING
      CONTROL = GO_CONTROL
      ERROR   = GO_ERROR.
  IF GO_ERROR->HAS_FAILED = 'X'.
    CALL METHOD GO_ERROR->RAISE_MESSAGE
      EXPORTING
        TYPE = 'E'.
  ENDIF.
* If you want to use Desktop Office Integration in-place, you also
*  need to create a container
  CREATE OBJECT GO_CONTAINER
    EXPORTING
      CONTAINER_NAME              = LPW_CONTAINER
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5
      OTHERS                      = 6.
  IF SY-SUBRC <> 0.
    MESSAGE E001(00) WITH 'Error while creating container'.
  ENDIF.
* Call the method init_control.
* You have now created the central object for Desktop Office
*  integration and the connection to the relevant gui control.
  CALL METHOD GO_CONTROL->INIT_CONTROL
    EXPORTING
      R3_APPLICATION_NAME = LW_APPLICATION  "'EXCEL GO_CONTAINER'
      INPLACE_ENABLED     = GC_XMARK
      PARENT              = GO_CONTAINER
    IMPORTING
      ERROR               = GO_ERROR.
  IF GO_ERROR->HAS_FAILED = GC_XMARK.
    CALL METHOD GO_ERROR->RAISE_MESSAGE
      EXPORTING
        TYPE = 'E'.
  ENDIF.

* Create an instance document for each document that you want to open:
  CALL METHOD GO_CONTROL->GET_DOCUMENT_PROXY
    EXPORTING
      DOCUMENT_TYPE  = SOI_DOCTYPE_EXCEL_SHEET
    IMPORTING
      DOCUMENT_PROXY = GO_DOCUMENT
      ERROR          = GO_ERROR.
  IF GO_ERROR->HAS_FAILED = GC_XMARK.
    CALL METHOD GO_ERROR->RAISE_MESSAGE
      EXPORTING
        TYPE = 'E'.
  ENDIF.
ENDFORM.                    "CREATE_CONTAINER

*&---------------------------------------------------------------------*
*&      Form  CLOSE_DOCUMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM CLOSE_DOCUMENT.
  DATA:
    LW_RETCODE TYPE SOI_RET_STRING,
    LW_DOC_SIZE TYPE C.

  CHECK NOT GO_DOCUMENT IS INITIAL.
* Closes a Document in the Office Application
  CALL METHOD GO_DOCUMENT->CLOSE_DOCUMENT
    EXPORTING
*     NO_FLUSH = ' '
      DO_SAVE  = 'X'
    IMPORTING
      ERROR    = GO_ERROR
      RETCODE  = LW_RETCODE.
  IF GO_ERROR->HAS_FAILED = 'X'.
    CALL METHOD GO_ERROR->RAISE_MESSAGE
      EXPORTING
        TYPE = 'I'.
  ENDIF.
* Releases the Memory Used by the Document
  CALL METHOD GO_DOCUMENT->RELEASE_DOCUMENT
    IMPORTING
      ERROR   = GO_ERROR
      RETCODE = LW_RETCODE.
  IF GO_ERROR->HAS_FAILED = 'X'.
    CALL METHOD GO_ERROR->RAISE_MESSAGE
      EXPORTING
        TYPE = 'I'.
  ENDIF.

  FREE GO_DOCUMENT.
  CALL METHOD GO_CONTROL->RELEASE_ALL_DOCUMENTS.
  CALL METHOD GO_CONTROL->DESTROY_CONTROL.
  FREE GO_CONTROL.
  FREE GO_SPREADSHEET.

  CALL METHOD GO_CONTAINER->FREE.

  FREE GO_CONTAINER.
ENDFORM.                    "CLOSE_DOCUMENT

*&---------------------------------------------------------------------*
*&      Form  STANDARD_VALUE_EXCEL_TO_SAP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_VALUE  text
*----------------------------------------------------------------------*
FORM STANDARD_VALUE_EXCEL_TO_SAP
  USING    LPS_FIELDCAT TYPE SLIS_FIELDCAT_ALV
           LPW_DATA
           LPW_VALUE_ORG  TYPE CHAR256
  CHANGING LPW_VALUE.

  FIELD-SYMBOLS:
    <LF_VALUE>      TYPE ANY,
    <LF_CURKY>      TYPE ANY.
  LPW_VALUE   = LPW_VALUE_ORG.
* Process with leading 0 and =
  IF LPW_VALUE CP '==*'
  OR LPW_VALUE CP '0*'.
    CONCATENATE '''' LPW_VALUE INTO LPW_VALUE.
  ENDIF.

  IF LPS_FIELDCAT-DATATYPE = 'CURR'.
    ASSIGN COMPONENT LPS_FIELDCAT-CFIELDNAME OF STRUCTURE LPW_DATA
      TO <LF_CURKY>.
    IF <LF_CURKY> IS INITIAL.
      CLEAR LPW_VALUE.
    ELSE.
      WRITE LPW_VALUE_ORG TO LPW_VALUE
        CURRENCY <LF_CURKY> NO-SIGN.
      CONDENSE LPW_VALUE.
      IF LPW_VALUE_ORG < 0.
        CONCATENATE '-' LPW_VALUE INTO LPW_VALUE.
*      ELSEIF <LF_VALUE> = 0.
*        LS_EXCEL_DATA-VALUE = '-'.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    "STANDARD_VALUE_EXCEL_TO_SAP

*&---------------------------------------------------------------------*
*&      Form  GET_EXCEL_FILE_DATA
*&---------------------------------------------------------------------*
*       Get data from import file
*----------------------------------------------------------------------*
*      -->T_SHEET_ROWST          Row start each sheet
*      -->LT_EXCEL_MAPPING_ALL   Mapping of sheet to table
*      -->LPT_FILE_DATA          File data
*----------------------------------------------------------------------*
FORM GET_EXCEL_FILE_DATA
  USING     LPT_SHEET_ROWST         TYPE ZTT_SHEET_ROWST
            LPT_EXCEL_MAPPING_ALL   TYPE ZTT_EXCEL_MAPPING
            LPW_READING_LINE        TYPE INT4
  CHANGING  LPT_FILE_DATA           TYPE GTY_T_SHEETDATA.

  DATA:
    LT_EXCEL_MAPPING        TYPE ZTT_EXCEL_MAPPING,
    LO_ERROR                TYPE REF TO I_OI_ERROR,
    LS_SHEETROWST           TYPE ZST_SHEET_ROWST,
    LT_SHEETS               TYPE SOI_SHEETS_TABLE,
    LS_SHEET                TYPE SOI_SHEETS,
    LW_ERROR                TYPE XMARK,
    LS_FILE_DATA            TYPE GTY_SHEETDATA.

  CLEAR: LPT_FILE_DATA[].

  LOOP AT GT_SHEETS INTO LS_SHEET.
*   Active sheet
    CALL METHOD GO_SPREADSHEET->SELECT_SHEET
      EXPORTING
        NAME  = LS_SHEET-SHEET_NAME
      IMPORTING
        ERROR = LO_ERROR.
    IF LO_ERROR->HAS_FAILED = 'X'.
      RAISE READ_DATA_ERROR.
    ENDIF.

*   Get data of sheet
    READ TABLE LPT_SHEET_ROWST INTO LS_SHEETROWST
      WITH KEY SHEETNAME = LS_SHEET-SHEET_NAME.
    CHECK SY-SUBRC IS INITIAL.

*   Get mapping
    LT_EXCEL_MAPPING = LPT_EXCEL_MAPPING_ALL.
    DELETE LT_EXCEL_MAPPING WHERE SHEETNAME <> LS_SHEET-SHEET_NAME.

*   Get sheet data
    CLEAR LS_FILE_DATA.
    LS_FILE_DATA-SHTNM = LS_SHEET-SHEET_NAME.

    PERFORM GET_SHEET_DATA
      USING     LS_SHEETROWST
                LT_EXCEL_MAPPING
                LPW_READING_LINE
      CHANGING  LS_FILE_DATA-SHEETDATA
                LW_ERROR.
    IF LW_ERROR IS NOT INITIAL.
      RAISE READ_DATA_ERROR.
    ELSE.
      APPEND LS_FILE_DATA TO LPT_FILE_DATA.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "GET_EXCEL_FILE_DATA

*&---------------------------------------------------------------------*
*&      Form  GET_SHEET_DATA
*&---------------------------------------------------------------------*
*       Get sheet data
*----------------------------------------------------------------------*
FORM GET_SHEET_DATA
  USING     LPS_SHEETROWST    TYPE ZST_SHEET_ROWST
            LPT_EXCEL_MAPPING TYPE  ZTT_EXCEL_MAPPING
            LPW_READING_LINE        TYPE INT4
  CHANGING
            LPT_FILE_DATA     TYPE ZTT_EXCEL_NUMBR
            LPW_ERROR         TYPE XMARK.
  DATA:
    LS_EXCEL_MAPPING        TYPE ZST_EXCEL_MAPPING,
    LS_DIMENS               TYPE SOI_DIMENSION_ITEM,
    LT_DIMENS               TYPE TABLE OF SOI_DIMENSION_ITEM,
    LT_RANGES               TYPE SOI_RANGE_LIST,
    LT_CELLS_DATA           TYPE SOI_GENERIC_TABLE,
    LS_CELL_DATA            TYPE SOI_GENERIC_ITEM,
    LT_DATA_TMP             TYPE ZTT_EXCEL_NUMBR,
    LT_CELL_NUM             TYPE ZTT_EXCEL_NUMBR,
    LS_CELL_NUM             TYPE ZST_EXCEL_NUMBR,
    LW_ROWSTART             TYPE I,
    LW_COLSTART             TYPE I,
    LW_COLS                 TYPE I,
    LW_RETCODE              TYPE SOI_RET_STRING.

  CONSTANTS:
    LC_READING_ROW  TYPE I VALUE 100.   "Read 100 row each time

* Init
  CLEAR: LT_RANGES.
* Get start row
  LW_ROWSTART = LPS_SHEETROWST-ROWST.
  IF LW_ROWSTART = 0.
    LW_ROWSTART = 1.
  ENDIF.

* Get start column
  SORT LPT_EXCEL_MAPPING BY COLUMN ASCENDING.
  READ TABLE LPT_EXCEL_MAPPING INTO LS_EXCEL_MAPPING INDEX 1.
  LW_COLSTART         = LS_EXCEL_MAPPING-COLUMN.
  IF LW_COLSTART = 0.
    LW_COLSTART = 1.
  ENDIF.

* Get number of columns
  SORT LPT_EXCEL_MAPPING BY COLUMN DESCENDING.
  READ TABLE LPT_EXCEL_MAPPING INTO LS_EXCEL_MAPPING INDEX 1.
  LW_COLS             = LS_EXCEL_MAPPING-COLUMN - LW_COLSTART + 1.

  IF LW_COLS = 0.
    RETURN.
  ENDIF.

  WHILE 1 = 1.
    CLEAR: LT_DIMENS[].
    LS_DIMENS-ROW     = LW_ROWSTART.
    LS_DIMENS-COLUMN  = LW_COLSTART.
    IF LPW_READING_LINE IS NOT INITIAL.
      LS_DIMENS-ROWS    = LPW_READING_LINE.   "ROWS .
    ELSE.
      LS_DIMENS-ROWS    = LC_READING_ROW.   "ROWS .
    ENDIF.
    LS_DIMENS-COLUMNS = LW_COLS.          "COLUMNS .
    APPEND LS_DIMENS TO LT_DIMENS.

    CALL METHOD GO_SPREADSHEET->SET_SELECTION
      EXPORTING
        TOP     = LW_ROWSTART
        LEFT    = LW_COLSTART
        ROWS    = LS_DIMENS-ROWS
        COLUMNS = LW_COLS
      IMPORTING
        RETCODE = LW_RETCODE.

    CALL METHOD GO_SPREADSHEET->INSERT_RANGE
      EXPORTING
        ROWS    = LS_DIMENS-ROWS
        COLUMNS = LS_DIMENS-COLUMNS
        NAME    = 'SAP_range1'
      IMPORTING
        RETCODE = LW_RETCODE.

    CALL METHOD GO_SPREADSHEET->GET_RANGES_NAMES
      IMPORTING
        RANGES  = LT_RANGES
        RETCODE = LW_RETCODE.

    DELETE LT_RANGES WHERE NAME <> 'SAP_range1'.

*   Get range data
    CALL METHOD GO_SPREADSHEET->GET_RANGES_DATA
*      EXPORTING
*        ALL       = 'X'
*        RANGESDEF = LT_DIMENS
      IMPORTING
        CONTENTS  = LT_CELLS_DATA[]
        ERROR     = GO_ERROR
      CHANGING
        RANGES    = LT_RANGES.
    IF GO_ERROR->HAS_FAILED = 'X'.
      LPW_ERROR = 'X'.
      RETURN.
    ENDIF.

    CLEAR: LT_CELL_NUM.
*   Standard row, column index of data
    LOOP AT LT_CELLS_DATA[] INTO LS_CELL_DATA.
      LS_CELL_NUM-ROW     = LS_CELL_DATA-ROW + LW_ROWSTART - 1.
      LS_CELL_NUM-COLUMN  = LS_CELL_DATA-COLUMN + LW_COLSTART - 1.
      LS_CELL_NUM-VALUE   = LS_CELL_DATA-VALUE.
      APPEND LS_CELL_NUM TO LT_CELL_NUM.
    ENDLOOP.

*   Get temporary data
    LT_DATA_TMP[] = LT_CELL_NUM[].

*   Check data are empty
    DELETE LT_DATA_TMP[] WHERE VALUE IS INITIAL.
    IF LT_DATA_TMP[] IS INITIAL.
      EXIT. "Quit Loop
    ENDIF.

*   Append data to table
    APPEND LINES OF LT_CELL_NUM[] TO LPT_FILE_DATA[].

*   Set start row to read
    LW_ROWSTART = LW_ROWSTART + LS_DIMENS-ROWS.
  ENDWHILE.
ENDFORM.                    "GET_SHEET_DATA

*&---------------------------------------------------------------------*
*&      Form  STANDARD_VALUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_VALUE  text
*----------------------------------------------------------------------*
FORM STANDARD_VALUE
  USING    LPS_FIELDCAT TYPE SLIS_FIELDCAT_ALV
           LPW_DATA
           LPW_VALUE_ORG
           LPW_KEEP_VALUE TYPE XMARK
  CHANGING LPW_VALUE TYPE CHAR256.

  DATA:
    BEGIN OF LS_DATE,
      YEAR    TYPE GJAHR,
      MONTH   TYPE MONTH,
      DAY(2)  TYPE N,
    END OF LS_DATE.

  FIELD-SYMBOLS:
    <LF_VALUE>      TYPE ANY,
    <LF_CURKY>      TYPE ANY,
    <LF_QUAN>       TYPE ANY.

  LPW_VALUE   = LPW_VALUE_ORG.
* Process with leading 0 and =
  IF LPW_VALUE CP '==*'
  OR LPW_VALUE CP '0*'.
    CONCATENATE '''' LPW_VALUE INTO LPW_VALUE.
  ENDIF.

  CASE LPS_FIELDCAT-DATATYPE.
    WHEN 'CURR'.
      ASSIGN COMPONENT LPS_FIELDCAT-CFIELDNAME OF STRUCTURE LPW_DATA
        TO <LF_CURKY>.
      IF <LF_CURKY> IS INITIAL.
        CLEAR LPW_VALUE.
      ELSE.
        WRITE LPW_VALUE_ORG TO LPW_VALUE
          CURRENCY <LF_CURKY> NO-SIGN.
        CONDENSE LPW_VALUE.

        CASE GS_DEFAULTS-DCPFM.
          WHEN SPACE.
            REPLACE ALL OCCURRENCES OF '.' IN LPW_VALUE WITH ''.
            IF <LF_CURKY> EQ 'VND'.
              "ThanhNq2 fix decimal point for currency not equal VND
              REPLACE ',' IN LPW_VALUE WITH '.'.
            ENDIF."ThanhNq2 fix decimal point for currency not equal VND
          WHEN 'X'.
            REPLACE ALL OCCURRENCES OF ',' IN LPW_VALUE WITH ''.
          WHEN 'Y'.
            CONDENSE LPW_VALUE.
            REPLACE ',' IN LPW_VALUE WITH '.'.
        ENDCASE.

        IF LPW_VALUE_ORG < 0.
          CONCATENATE '-' LPW_VALUE INTO LPW_VALUE.
        ENDIF.
      ENDIF.
    WHEN 'QUAN'.
      ASSIGN COMPONENT LPS_FIELDCAT-QFIELDNAME OF STRUCTURE LPW_DATA
        TO <LF_QUAN>.
      IF <LF_QUAN> IS INITIAL.
        LPW_VALUE = 0.
      ELSE.
        WRITE LPW_VALUE_ORG TO LPW_VALUE
          UNIT <LF_QUAN>.
        CONDENSE LPW_VALUE.
      ENDIF.
    WHEN 'DATS'.
      IF LPW_VALUE_ORG IS INITIAL.
        CLEAR: LPW_VALUE.
      ELSE.
        WRITE LPW_VALUE_ORG TO LPW_VALUE.
        LS_DATE = LPW_VALUE_ORG.
        CONCATENATE LS_DATE-YEAR LS_DATE-MONTH LS_DATE-DAY
          INTO LPW_VALUE SEPARATED BY '/'.
      ENDIF.
    WHEN 'NUMC'.
      IF LPW_VALUE_ORG IS INITIAL.
        LPW_VALUE = 0.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.
  IF LPW_KEEP_VALUE IS NOT INITIAL.
    LPW_VALUE = LPW_VALUE_ORG.
  ENDIF.
ENDFORM.                    "STANDARD_VALUE

*&---------------------------------------------------------------------*
*&      Form  STANDARD_VALUE_LVC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_VALUE  text
*----------------------------------------------------------------------*
FORM STANDARD_VALUE_LVC
  USING    LPS_FIELDCAT TYPE LVC_S_FCAT
           LPW_DATA
           LPW_VALUE_ORG
           LPW_KEEP_VALUE TYPE XMARK
  CHANGING LPW_VALUE TYPE CHAR256.

  DATA:
    BEGIN OF LS_DATE,
      YEAR    TYPE GJAHR,
      MONTH   TYPE MONTH,
      DAY(2)  TYPE N,
    END OF LS_DATE.

  FIELD-SYMBOLS:
    <LF_VALUE>      TYPE ANY,
    <LF_CURKY>      TYPE ANY,
    <LF_QUAN>       TYPE ANY.

  LPW_VALUE   = LPW_VALUE_ORG.
  CHECK LPW_KEEP_VALUE IS INITIAL.
* Process with leading 0 and =
  IF LPW_VALUE CP '==*'
  OR ( LPW_VALUE CP '0*' AND LPW_VALUE CO '0' ).
    CONCATENATE '''' LPW_VALUE INTO LPW_VALUE.
  ENDIF.

  CASE LPS_FIELDCAT-DATATYPE.
    WHEN 'CURR'.
      ASSIGN COMPONENT LPS_FIELDCAT-CFIELDNAME OF STRUCTURE LPW_DATA
        TO <LF_CURKY>.
      IF <LF_CURKY> IS INITIAL.
        CLEAR LPW_VALUE.
      ELSE.
        WRITE LPW_VALUE_ORG TO LPW_VALUE
          CURRENCY <LF_CURKY> NO-SIGN.
        CONDENSE LPW_VALUE.

        CASE GS_DEFAULTS-DCPFM.
          WHEN SPACE.
            REPLACE ALL OCCURRENCES OF '.' IN LPW_VALUE WITH ''.
            IF <LF_CURKY> EQ 'VND'.
              REPLACE ',' IN LPW_VALUE WITH '.'.
            ENDIF.
          WHEN 'X'.
            REPLACE ALL OCCURRENCES OF ',' IN LPW_VALUE WITH ''.
          WHEN 'Y'.
            CONDENSE LPW_VALUE.
            REPLACE ',' IN LPW_VALUE WITH '.'.
        ENDCASE.

        IF LPW_VALUE_ORG < 0.
          CONCATENATE '-' LPW_VALUE INTO LPW_VALUE.
        ENDIF.
      ENDIF.
    WHEN 'QUAN'.
      ASSIGN COMPONENT LPS_FIELDCAT-QFIELDNAME OF STRUCTURE LPW_DATA
        TO <LF_QUAN>.
      IF <LF_QUAN> IS INITIAL.
        LPW_VALUE = 0.
      ELSE.
        WRITE LPW_VALUE_ORG TO LPW_VALUE UNIT <LF_QUAN> NO-SIGN.
        CONDENSE LPW_VALUE.
        IF LPW_VALUE_ORG < 0.
          CONCATENATE '-' LPW_VALUE INTO LPW_VALUE.
        ENDIF.
      ENDIF.
    WHEN 'DATS'.
      IF LPW_VALUE_ORG IS INITIAL.
        CLEAR: LPW_VALUE.
      ELSE.
        WRITE LPW_VALUE_ORG TO LPW_VALUE.
        LS_DATE = LPW_VALUE_ORG.
        CONCATENATE LS_DATE-YEAR LS_DATE-MONTH LS_DATE-DAY
          INTO LPW_VALUE SEPARATED BY '/'.
      ENDIF.
    WHEN 'NUMC'.
      IF LPW_VALUE_ORG IS INITIAL.
        LPW_VALUE = 0.
      ENDIF.
    WHEN 'DEC'.
      WRITE LPW_VALUE_ORG TO LPW_VALUE NO-SIGN.
      CONDENSE LPW_VALUE.
      CASE GS_DEFAULTS-DCPFM.
        WHEN SPACE.
          REPLACE ALL OCCURRENCES OF '.' IN LPW_VALUE WITH ''.
        WHEN 'X'.
          REPLACE ALL OCCURRENCES OF ',' IN LPW_VALUE WITH ''.
        WHEN 'Y'.
          CONDENSE LPW_VALUE.
          REPLACE ',' IN LPW_VALUE WITH '.'.
      ENDCASE.
      IF LPW_VALUE_ORG < 0.
        CONCATENATE '-' LPW_VALUE INTO LPW_VALUE.
      ENDIF.
      IF LPW_VALUE_ORG IS INITIAL.
        LPW_VALUE = 0.
      ENDIF.
    WHEN 'INT4' OR 'INT2'.
      CONDENSE LPW_VALUE.
    WHEN OTHERS.
      IF LPS_FIELDCAT-DATATYPE CS 'INT'.
        CONDENSE LPW_VALUE.
      ENDIF.
  ENDCASE.
ENDFORM.                    "STANDARD_VALUE_LVC

*&---------------------------------------------------------------------*
*&      Form  GET_EXCEL_FILE_DATA_ALL
*&---------------------------------------------------------------------*
*       Get data from import file
*----------------------------------------------------------------------*
*      -->T_SHEET_ROWST          Row start each sheet
*      -->LT_EXCEL_MAPPING_ALL   Mapping of sheet to table
*      -->LPT_FILE_DATA          File data
*----------------------------------------------------------------------*
FORM GET_EXCEL_FILE_DATA_ALL
  CHANGING  LPT_FILE_DATA           TYPE ZTT_EXCEL_IMP.

  DATA:
    LO_ERROR                TYPE REF TO I_OI_ERROR,
    LT_SHEETS               TYPE SOI_SHEETS_TABLE,
    LS_SHEET                TYPE SOI_SHEETS,
    LW_ERROR                TYPE XMARK,
    LS_FILE_DATA            TYPE ZST_EXCEL_IMP.

  CLEAR: LPT_FILE_DATA[].

  LOOP AT GT_SHEETS INTO LS_SHEET.
*   Active sheet
    CALL METHOD GO_SPREADSHEET->SELECT_SHEET
      EXPORTING
        NAME  = LS_SHEET-SHEET_NAME
      IMPORTING
        ERROR = LO_ERROR.
    IF LO_ERROR->HAS_FAILED = 'X'.
      RAISE READ_DATA_ERROR.
    ENDIF.

*   Get sheet data
    CLEAR LS_FILE_DATA.
    LS_FILE_DATA-SHEETNAME = LS_SHEET-SHEET_NAME.

    PERFORM GET_SHEET_DATA_ALL
      CHANGING  LS_FILE_DATA-EXDAT
                LW_ERROR.
    IF LW_ERROR IS NOT INITIAL.
      RAISE READ_DATA_ERROR.
    ELSE.
      APPEND LS_FILE_DATA TO LPT_FILE_DATA.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "GET_EXCEL_FILE_DATA_ALL

*&---------------------------------------------------------------------*
*&      Form  GET_SHEET_DATA_ALL
*&---------------------------------------------------------------------*
*       Get sheet data
*----------------------------------------------------------------------*
FORM GET_SHEET_DATA_ALL
  CHANGING  LPT_FILE_DATA     TYPE ZTT_EXCEL
            LPW_ERROR         TYPE XMARK.
  DATA:
    LS_DIMENS               TYPE SOI_DIMENSION_ITEM,
    LT_DIMENS               TYPE TABLE OF SOI_DIMENSION_ITEM,
    LT_RANGES               TYPE SOI_RANGE_LIST,
    LT_SHEET_DATA           TYPE SOI_GENERIC_TABLE,
    LT_DATA_TMP             TYPE SOI_GENERIC_TABLE,
    LS_DATA                 TYPE SOI_GENERIC_ITEM,
    LW_ROWSTART             TYPE I,
    LT_EXCEL_NR             TYPE TABLE OF ZST_EXCEL_NUMBR,
    LS_EXCEL_NR             TYPE ZST_EXCEL_NUMBR,
    LW_COLSTART             TYPE I,
    LW_COLS                 TYPE I,
    LW_FIXCOL               TYPE XMARK.

  FIELD-SYMBOLS:
   <LF_DATA>      TYPE SOI_GENERIC_ITEM,
   <LF_CELL>      TYPE ANY.

  CONSTANTS:
    LC_READING_ROW  TYPE I VALUE 100.   "Read 100 row each time

* Init
  CLEAR: LT_RANGES, LW_FIXCOL.
* Get start row, start column
  LW_ROWSTART = 1.
  LW_COLSTART = 1.

* Get number of columns
  LW_COLS    = 30.

  WHILE 1 = 1.
    CLEAR: LT_DIMENS[].
    LS_DIMENS-ROW     = LW_ROWSTART.
    LS_DIMENS-COLUMN  = LW_COLSTART.
    LS_DIMENS-ROWS    = LC_READING_ROW.   "ROWS .
    LS_DIMENS-COLUMNS = LW_COLS.          "COLUMNS .
    APPEND LS_DIMENS TO LT_DIMENS.

*   Get range data
    CALL METHOD GO_SPREADSHEET->GET_RANGES_DATA
      EXPORTING
*       ALL       = 'X'
        RANGESDEF = LT_DIMENS
      IMPORTING
        CONTENTS  = LT_SHEET_DATA[]
        ERROR     = GO_ERROR
      CHANGING
        RANGES    = LT_RANGES.
    IF GO_ERROR->HAS_FAILED = 'X'.
      LPW_ERROR = 'X'.
      RETURN.
    ENDIF.

*   Standard row index of data
    LOOP AT LT_SHEET_DATA[] ASSIGNING <LF_DATA>.
      <LF_DATA>-ROW = <LF_DATA>-ROW + LW_ROWSTART - 1.
    ENDLOOP.

*   Get temporary data
    LT_DATA_TMP[] = LT_SHEET_DATA[].

**   Check data are empty
*    DELETE LT_DATA_TMP[] WHERE VALUE IS INITIAL.
*    IF LT_DATA_TMP[] IS INITIAL.
*      EXIT. "Quit Loop
*    ELSEIF LW_FIXCOL IS INITIAL.
*      CLEAR: LT_EXCEL_NR[].
**     Change to excel data with column, row type number
*      LOOP AT LT_DATA_TMP INTO LS_DATA.
*        MOVE-CORRESPONDING LS_DATA TO LS_EXCEL_NR.
*        APPEND LS_EXCEL_NR TO LT_EXCEL_NR.
*      ENDLOOP.
*
**     Sort to get max column
*      SORT LT_EXCEL_NR BY COLUMN DESCENDING ROW.
*      READ TABLE LT_EXCEL_NR INTO LS_EXCEL_NR INDEX 1.
**     Update number of columns to read
*      LW_COLS = LS_EXCEL_NR-COLUMN - 1.
*    ENDIF.

*   Check data are empty
    DELETE LT_SHEET_DATA[] WHERE VALUE IS INITIAL.
    IF LT_SHEET_DATA[] IS INITIAL.
      EXIT. "Quit Loop
    ELSEIF LW_FIXCOL IS INITIAL.
      CLEAR: LT_EXCEL_NR[].
*     Change to excel data with column, row type number
      LOOP AT LT_SHEET_DATA INTO LS_DATA.
        MOVE-CORRESPONDING LS_DATA TO LS_EXCEL_NR.
        APPEND LS_EXCEL_NR TO LT_EXCEL_NR.
      ENDLOOP.

*     Sort to get max column
      SORT LT_EXCEL_NR BY COLUMN DESCENDING ROW.
      READ TABLE LT_EXCEL_NR INTO LS_EXCEL_NR INDEX 1.
*     Update number of columns to read
      LW_COLS = LS_EXCEL_NR-COLUMN - 1.
    ENDIF.

*   Append data to table
    APPEND LINES OF LT_SHEET_DATA[] TO LPT_FILE_DATA[].

*   Set start row to read
    LW_ROWSTART = LW_ROWSTART + LC_READING_ROW.
  ENDWHILE.

ENDFORM.                    "GET_SHEET_DATA_ALL

*&---------------------------------------------------------------------*
*&      Form  9000_COMPLETE_CELL_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_EXCEL_LAYOUT  Config excel layout
*      -->LPS_FIELDCAT      Field catalog
*      <--LPS_EXCEL_VALUE   Excel value
*----------------------------------------------------------------------*
FORM 9000_COMPLETE_CELL_DATA
  USING    LPS_EXCEL_LAYOUT   TYPE ZTB_EXCEL_LAYOUT
           LPS_FIELDCAT       TYPE LVC_S_FCAT
  CHANGING LPS_EXCEL_VALUE    TYPE CHAR256.

* Convert data
  IF LPS_EXCEL_LAYOUT-DOMAIN_CV IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ZZALL_OUTPUT'
      EXPORTING
        INPUT           = LPS_EXCEL_VALUE
        I_DOMNAME       = LPS_FIELDCAT-DOMNAME
      IMPORTING
        OUTPUT          = LPS_EXCEL_VALUE.
  ENDIF.

* Set prefix
  IF LPS_EXCEL_LAYOUT-PREFIX IS NOT INITIAL.
    CONCATENATE LPS_EXCEL_LAYOUT-PREFIX
                LPS_EXCEL_VALUE
           INTO LPS_EXCEL_VALUE SEPARATED BY SPACE.
  ENDIF.

* Set suffix
  IF LPS_EXCEL_LAYOUT-SUFFIX IS NOT INITIAL.
    CONCATENATE LPS_EXCEL_VALUE
                LPS_EXCEL_LAYOUT-SUFFIX
           INTO LPS_EXCEL_VALUE SEPARATED BY SPACE.
  ENDIF.
ENDFORM.                    " 9000_COMPLETE_CELL_DATA
*&---------------------------------------------------------------------*
*&      Form  INIT_PROC
*----------------------------------------------------------------------*
FORM INIT_PROC .
  DATA:
    LT_RETURN             TYPE BAPIRET2_T,
    LW_TH_OPCODE(1)       TYPE X,
    LT_USRS_INFO          TYPE TABLE OF UINFO WITH HEADER LINE.
  CONSTANTS:
    LC_OPCODE_LIST        LIKE LW_TH_OPCODE VALUE 2.
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      USERNAME = SY-UNAME
    IMPORTING
      DEFAULTS = GS_DEFAULTS
    TABLES
      RETURN   = LT_RETURN.



  CALL 'ThUsrInfo' ID 'OPCODE' FIELD LC_OPCODE_LIST
                   ID 'TAB'    FIELD LT_USRS_INFO-*SYS*.

  LOOP AT LT_USRS_INFO WHERE BNAME = SY-UNAME.
    GW_PCNAME = LT_USRS_INFO-TERM.
  ENDLOOP.
ENDFORM.                    " INIT_PROC


*&---------------------------------------------------------------------*
*&      Form  GET_ONE_EXCEL_ROW
*&---------------------------------------------------------------------*
*       Get one excel row
*----------------------------------------------------------------------*
*      -->T_SHEET_ROWST          Row start each sheet
*      -->LT_EXCEL_MAPPING_ALL   Mapping of sheet to table
*      -->LPT_FILE_DATA          File data
*----------------------------------------------------------------------*
FORM GET_ONE_EXCEL_ROW
  USING     LPO_SPREADSHEET         TYPE REF TO I_OI_SPREADSHEET
            LPS_SHEET               TYPE SOI_SHEETS
            LPW_ROW                 TYPE I
            LPW_COLS                TYPE I
  CHANGING  LPT_CELL_NUM            TYPE ZTT_EXCEL_NUMBR.

  DATA:
    LO_ERROR                TYPE REF TO I_OI_ERROR,
    LT_RANGES               TYPE SOI_RANGE_LIST,
    LT_CELLS_DATA           TYPE SOI_GENERIC_TABLE,
    LS_CELL_DATA            TYPE SOI_GENERIC_ITEM,
    LS_CELL_NUM             TYPE ZST_EXCEL_NUMBR,
    LW_RETCODE              TYPE SOI_RET_STRING.

  CLEAR: LPT_CELL_NUM[].

* Active sheet
  CALL METHOD LPO_SPREADSHEET->SELECT_SHEET
    EXPORTING
      NAME  = LPS_SHEET-SHEET_NAME
    IMPORTING
      ERROR = LO_ERROR.
  IF LO_ERROR->HAS_FAILED = 'X'.
    RETURN.
  ENDIF.

  CALL METHOD LPO_SPREADSHEET->SET_SELECTION
    EXPORTING
      TOP     = LPW_ROW
      LEFT    = 1
      ROWS    = 1
      COLUMNS = LPW_COLS
    IMPORTING
      RETCODE = LW_RETCODE.

  CALL METHOD LPO_SPREADSHEET->INSERT_RANGE
    EXPORTING
      ROWS    = LPW_ROW
      COLUMNS = LPW_COLS
      NAME    = GC_RANGE_NAME
    IMPORTING
      RETCODE = LW_RETCODE.

  CALL METHOD GO_SPREADSHEET->GET_RANGES_NAMES
    IMPORTING
      RANGES  = LT_RANGES
      RETCODE = LW_RETCODE.

  DELETE LT_RANGES WHERE NAME <> GC_RANGE_NAME.

* Get range data
  CALL METHOD GO_SPREADSHEET->GET_RANGES_DATA
    IMPORTING
      CONTENTS  = LT_CELLS_DATA[]
      ERROR     = GO_ERROR
    CHANGING
      RANGES    = LT_RANGES.
  IF GO_ERROR->HAS_FAILED = 'X'.
    RETURN.
  ENDIF.

* Standard row, column index of data
  LOOP AT LT_CELLS_DATA[] INTO LS_CELL_DATA.
    LS_CELL_NUM-ROW     = LS_CELL_DATA-ROW + LPW_ROW - 1.
    LS_CELL_NUM-COLUMN  = LS_CELL_DATA-COLUMN.
    LS_CELL_NUM-VALUE   = LS_CELL_DATA-VALUE.
    TRANSLATE LS_CELL_NUM-VALUE TO UPPER CASE.
    APPEND LS_CELL_NUM TO LPT_CELL_NUM.
  ENDLOOP.
ENDFORM.                    "GET_ONE_EXCEL_ROW

*&---------------------------------------------------------------------*
*&      Form  GEN_COLUMN_MAPPING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LPT_CELL_NUM  text
*      -->P_T_FIELDCAT  text
*      <--P_LT_EXCEL_MAPPING_ALL  text
*----------------------------------------------------------------------*
FORM GEN_COLUMN_MAPPING
  USING   LPS_SHEET             TYPE SOI_SHEETS
          LPT_HDR_ROW_DATA      TYPE ZTT_EXCEL_NUMBR
  CHANGING  LPT_FIELDCAT          TYPE LVC_T_FCAT
            LPT_EXCEL_MAPPING     TYPE ZTT_EXCEL_MAPPING.
  DATA:
     LS_CELL_NBR        TYPE ZST_EXCEL_NUMBR,
     LS_EXCEL_MAPPING   TYPE ZST_EXCEL_MAPPING.
  FIELD-SYMBOLS:
     <LF_FIELDCAT>      TYPE LVC_S_FCAT.

*  CLEAR: LPT_EXCEL_MAPPING.
  LOOP AT LPT_FIELDCAT ASSIGNING <LF_FIELDCAT>.
    READ TABLE LPT_HDR_ROW_DATA INTO LS_CELL_NBR
      WITH KEY VALUE = <LF_FIELDCAT>-FIELDNAME.
    IF SY-SUBRC IS INITIAL.
      CLEAR: LS_EXCEL_MAPPING.
      LS_EXCEL_MAPPING-SHEETNAME  = LPS_SHEET-SHEET_NAME.
      LS_EXCEL_MAPPING-FIELDNAME  = <LF_FIELDCAT>-FIELDNAME.
      LS_EXCEL_MAPPING-COLUMN     = LS_CELL_NBR-COLUMN.
      APPEND LS_EXCEL_MAPPING TO LPT_EXCEL_MAPPING.

      <LF_FIELDCAT>-EMPHASIZE     = 'C500'.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " GEN_COLUMN_MAPPING

*&---------------------------------------------------------------------*
*&      Form  9999_CHECK_LOCK_CLBEX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--LPW_LOCK  text
*----------------------------------------------------------------------*
FORM 9999_CHECK_LOCK_CLBEX
  CHANGING LPW_LOCK     TYPE XMARK.
  DATA:
    LW_TOTAL_WAIT       TYPE I.

  WHILE LPW_LOCK IS INITIAL
    AND LW_TOTAL_WAIT < 1000.
    CALL FUNCTION 'ENQUEUE_EZLO_EX_CLBEX'
      EXPORTING
        PCNAME                  = GW_PCNAME
        UNAME                   = SY-UNAME
      EXCEPTIONS
        FOREIGN_LOCK            = 1
        SYSTEM_FAILURE          = 2
        OTHERS                  = 3.
    IF SY-SUBRC IS INITIAL.
      LPW_LOCK = GC_XMARK.
    ELSE.
      LW_TOTAL_WAIT = LW_TOTAL_WAIT + 1.
      WAIT UP TO 1 SECONDS.
    ENDIF.
  ENDWHILE.
ENDFORM.                    " 9999_CHECK_LOCK_CLBEX

*&---------------------------------------------------------------------*
*&      Form  9999_CONVERT_EXDAT2COLDAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_EXCEL_EXP  text
*      <--P_LT_EXCEL_COLDAT  text
*----------------------------------------------------------------------*
FORM 9999_CONVERT_EXDAT2COLDAT
  USING    LPS_EXCEL_EXP    TYPE ZST_EXCEL_EXP
  CHANGING LPT_EXCEL_COLDAT TYPE GTY_T_EXCEL_COLDAT.
  DATA:
    LS_CELLDAT        TYPE ZST_EXCEL_NUMBR,
    LS_CELLDAT_OLD    TYPE ZST_EXCEL_NUMBR,
    LS_EXCEL_COLDAT   TYPE ZST_EXCEL_COLDAT.

  SORT LPS_EXCEL_EXP-EXDATN BY COLUMN ROW.
  LOOP AT LPS_EXCEL_EXP-EXDATN INTO LS_CELLDAT.
    IF LS_CELLDAT-COLUMN <> LS_CELLDAT_OLD-COLUMN.
      IF LS_CELLDAT_OLD-COLUMN IS NOT INITIAL.
        APPEND LS_EXCEL_COLDAT TO LPT_EXCEL_COLDAT.
      ENDIF.
      CLEAR: LS_EXCEL_COLDAT.
      LS_EXCEL_COLDAT-COL_POS = LS_CELLDAT-COLUMN.
    ENDIF.
    LS_CELLDAT_OLD = LS_CELLDAT.
    APPEND LS_CELLDAT-VALUE TO LS_EXCEL_COLDAT-COLDAT.
  ENDLOOP.
  IF LS_EXCEL_COLDAT-COL_POS IS NOT INITIAL.
    APPEND LS_EXCEL_COLDAT TO LPT_EXCEL_COLDAT.
  ENDIF.

ENDFORM.                    " 9999_CONVERT_EXDAT2COLDAT

*&---------------------------------------------------------------------*
*&      Form  9999_CONVERT_EXDAT2CLIPBOARD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_EXCEL_EXP  text
*      <--LPS_EXCEL_COLDAT  text
*----------------------------------------------------------------------*
FORM 9999_CONVERT_EXDAT2CLIPBOARD
  USING    LPS_EXCEL_EXP    TYPE ZST_EXCEL_EXP
  CHANGING LPT_EX_COLDAT    TYPE ZTT_EX_COLDAT.
  DATA:
    LS_CELLDAT        TYPE ZST_EXCEL_NUMBR,
    LT_CELLDAT        TYPE TABLE OF ZST_EXCEL_NUMBR-VALUE,
    LW_LINEDAT        TYPE ZST_EX_COLDAT-VALUE,
    LS_EXCEL_COLDAT   TYPE ZST_EXCEL_COLDAT.

  CLEAR: LPT_EX_COLDAT.
  SORT LPS_EXCEL_EXP-EXDATN BY ROW COLUMN.
  LOOP AT LPS_EXCEL_EXP-EXDATN INTO LS_CELLDAT.
    AT NEW ROW.
      CLEAR: LT_CELLDAT, LW_LINEDAT.
    ENDAT.

    APPEND LS_CELLDAT-VALUE TO LT_CELLDAT.

    AT END OF ROW.
      CONCATENATE LINES OF LT_CELLDAT INTO LW_LINEDAT
        SEPARATED BY CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB.
      APPEND LW_LINEDAT TO LPT_EX_COLDAT.
    ENDAT.
  ENDLOOP.

ENDFORM.                    " 9999_CONVERT_EXDAT2CLIPBOARD

*&---------------------------------------------------------------------*
*&      Form  9999_EXPORT_EACH_COLUMN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_EXCEL_COLDAT  text
*----------------------------------------------------------------------*
FORM 9999_EXPORT_EACH_COLUMN
  USING    LPS_EXCEL_EXP    TYPE ZST_EXCEL_EXP.
  DATA:
    LW_ROW            TYPE I,
    LS_CELL1          TYPE OLE2_OBJECT,
    LS_CELL2          TYPE OLE2_OBJECT,
    LS_RANGE          TYPE OLE2_OBJECT,
    LS_ACTIVESHEET    TYPE OLE2_OBJECT,
    LW_LOCK           TYPE XMARK,
    LS_EXCEL_COLDAT   TYPE ZST_EXCEL_COLDAT,
    LW_RC             TYPE I,
    LT_EXCEL_COLDAT   TYPE GTY_T_EXCEL_COLDAT.

  PERFORM 9999_CONVERT_EXDAT2COLDAT
    USING LPS_EXCEL_EXP
    CHANGING LT_EXCEL_COLDAT.

  LOOP AT LT_EXCEL_COLDAT INTO LS_EXCEL_COLDAT.
    IF LW_ROW IS INITIAL.
      DESCRIBE TABLE LS_EXCEL_COLDAT-COLDAT LINES LW_ROW.
      LW_ROW = LPS_EXCEL_EXP-ROW_POS + LW_ROW - 1.
    ENDIF.
*   Select first cell
    CALL METHOD OF GS_OLE_EXCEL 'Cells' = LS_CELL1
      EXPORTING
        #1 = LPS_EXCEL_EXP-ROW_POS
        #2 = LS_EXCEL_COLDAT-COL_POS.

*   Select last cell
    CALL METHOD OF GS_OLE_EXCEL 'Cells' = LS_CELL2
      EXPORTING
        #1 = LW_ROW
        #2 = LS_EXCEL_COLDAT-COL_POS.

    CALL METHOD OF GS_OLE_EXCEL 'Range' = LS_RANGE
      EXPORTING
      #1 = LS_CELL1
      #2 = LS_CELL2.

    CALL METHOD OF LS_RANGE 'Select'.

    PERFORM 9999_CHECK_LOCK_CLBEX CHANGING LW_LOCK.
    CHECK LW_LOCK IS NOT INITIAL.

    CALL METHOD CL_GUI_FRONTEND_SERVICES=>CLIPBOARD_EXPORT
      EXPORTING
        NO_AUTH_CHECK        = GC_XMARK
      IMPORTING
        DATA                 = LS_EXCEL_COLDAT-COLDAT
      CHANGING
        RC                   = LW_RC
      EXCEPTIONS
        CNTL_ERROR           = 1
        ERROR_NO_GUI         = 2
        NOT_SUPPORTED_BY_GUI = 3
        NO_AUTHORITY         = 4
        OTHERS               = 5.
    IF SY-SUBRC IS INITIAL.
*     Set cells value
      CALL METHOD OF GS_OLE_EXCEL 'ActiveSheet' = LS_ACTIVESHEET.
      CALL METHOD OF LS_ACTIVESHEET 'Activate'.

      CALL METHOD OF LS_ACTIVESHEET 'Paste'.
    ENDIF.

    CALL FUNCTION 'DEQUEUE_EZLO_EX_CLBEX'
      EXPORTING
        PCNAME                  = GW_PCNAME
        UNAME                   = SY-UNAME.

  ENDLOOP.

ENDFORM.                    " 9999_EXPORT_EACH_COLUMN

*&---------------------------------------------------------------------*
*&      Form  9999_EXPORT_WHOLE_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_EXCEL_EXP  text
*----------------------------------------------------------------------*
FORM 9999_EXPORT_WHOLE_TABLE
  USING    LPS_EXCEL_EXP  TYPE ZST_EXCEL_EXP.
  DATA:
    LW_ROW            TYPE I,
    LW_COL            TYPE I,
    LS_CELL1          TYPE OLE2_OBJECT,
    LS_CELL2          TYPE OLE2_OBJECT,
    LS_RANGE          TYPE OLE2_OBJECT,
    LS_ACTIVESHEET    TYPE OLE2_OBJECT,
    LW_LOCK           TYPE XMARK,
    LW_RC             TYPE I,
    LT_EX_COLDAT      TYPE ZTT_EX_COLDAT.

  PERFORM 9999_CONVERT_EXDAT2CLIPBOARD
    USING LPS_EXCEL_EXP
    CHANGING LT_EX_COLDAT.

  IF LW_ROW IS INITIAL.
    DESCRIBE TABLE LT_EX_COLDAT LINES LW_ROW.
    LW_ROW = LPS_EXCEL_EXP-ROW_POS + LW_ROW - 1.
  ENDIF.
*  LW_COL = LPS_EXCEL_EXP-COL_POS + LPS_EXCEL_EXP-NCOLS - 1.

* Select first cell
  CALL METHOD OF GS_OLE_EXCEL 'Cells' = LS_CELL1
    EXPORTING
      #1 = LPS_EXCEL_EXP-ROW_POS
      #2 = LPS_EXCEL_EXP-COL_POS.

** Select last cell
*  CALL METHOD OF GS_OLE_EXCEL 'Cells' = LS_CELL2
*    EXPORTING
*      #1 = LW_ROW
*      #2 = LW_COL.

  CALL METHOD OF GS_OLE_EXCEL 'Range' = LS_RANGE
    EXPORTING
    #1 = LS_CELL1
    #2 = LS_CELL1.

  CALL METHOD OF LS_RANGE 'Select'.

  PERFORM 9999_CHECK_LOCK_CLBEX CHANGING LW_LOCK.
  CHECK LW_LOCK IS NOT INITIAL.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>CLIPBOARD_EXPORT
    EXPORTING
      NO_AUTH_CHECK        = GC_XMARK
    IMPORTING
      DATA                 = LT_EX_COLDAT
    CHANGING
      RC                   = LW_RC
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      NOT_SUPPORTED_BY_GUI = 3
      NO_AUTHORITY         = 4
      OTHERS               = 5.
  IF SY-SUBRC IS INITIAL.
*   Set cells value
    CALL METHOD OF GS_OLE_EXCEL 'ActiveSheet' = LS_ACTIVESHEET.
    CALL METHOD OF LS_ACTIVESHEET 'Activate'.

    CALL METHOD OF LS_ACTIVESHEET 'Paste'.
  ENDIF.

  CALL FUNCTION 'DEQUEUE_EZLO_EX_CLBEX'
    EXPORTING
      PCNAME                  = GW_PCNAME
      UNAME                   = SY-UNAME.

ENDFORM.                    " 9999_EXPORT_WHOLE_TABLE
