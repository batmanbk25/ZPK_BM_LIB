FUNCTION ZFM_FILE_EXCEL_EXPORT_SHEETS.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_LOGICALFILE) TYPE  ESEFTAPPL OPTIONAL
*"     REFERENCE(I_DEFAULT_FILENAME) TYPE  STRING OPTIONAL
*"     REFERENCE(I_NO_ASK) TYPE  XMARK OPTIONAL
*"     VALUE(T_SHEET_DATA) TYPE  ZTT_SHEET_DATA
*"     REFERENCE(I_FOLDER_PATH) TYPE  STRING OPTIONAL
*"     REFERENCE(I_OPEN_FILE) TYPE  XMARK DEFAULT 'X'
*"     REFERENCE(I_LARGE_FILE) TYPE  XMARK OPTIONAL
*"     REFERENCE(I_READ_ONLY) TYPE  XMARK OPTIONAL
*"  EXCEPTIONS
*"      SAVE_TEMPLATE_ERR
*"      OPEN_FILE_ERR
*"      EXPORT_ERR
*"--------------------------------------------------------------------
DATA:
      LW_LOCALFILE    TYPE LOCALFILE,
      LS_SQUARE_DATA  TYPE ZST_EXCEL_EXP,
      LT_SHEETS       TYPE SOI_SHEETS_TABLE,
      LS_SHEET        TYPE SOI_SHEETS,
      LO_SPREASHEET   TYPE REF TO I_OI_SPREADSHEET,
      LS_DIMENS       TYPE SOI_DIMENSION_ITEM,
      LW_TIME1        TYPE TIMS,
      LW_TIME2        TYPE TIMS,
      LW_TIME3        TYPE TIMS,
      LS_DELROW       TYPE ZST_BOLD_ROW,
      LW_DELETED_ROWS TYPE I,
      LS_SHEET_DATA   TYPE ZST_SHEET_DATA,
      LT_SHEET_COPY   TYPE TABLE OF ZST_SHEET_KEY,
      LS_SHEET_COPY   TYPE ZST_SHEET_KEY,
      LT_SQUARE_DATA  TYPE ZST_SHEET_DATA-T_SQUARE_DATA,
      LT_DEL_ROWS     TYPE ZST_SHEET_DATA-T_DEL_ROWS,
      LS_PAGESETUP    TYPE ZST_SHEET_DATA-I_PAGESETUP.

* Save template to client
  CALL FUNCTION 'ZFM_FILE_DOWNLOAD_TEMPLATE'
    EXPORTING
      I_FILENAME           = I_LOGICALFILE
      I_DEFAULT_FILENAME   = I_DEFAULT_FILENAME
      I_FOLDER_PATH        = I_FOLDER_PATH
    IMPORTING
      E_LOCALFILE          = LW_LOCALFILE
    EXCEPTIONS
      FILE_CLIENT_ERR      = 1
      USER_CANCEL          = 2
      SAVE_CLIENT_FILE_ERR = 3
      OTHERS               = 4.

  IF SY-SUBRC IS NOT INITIAL.
    RAISE SAVE_TEMPLATE_ERR.
  ENDIF.

  LW_TIME1 = SY-UZEIT.
* Open file
  CALL FUNCTION 'ZFM_OLE_EXCEL_OPEN'
    EXPORTING
      I_FILENAME    = LW_LOCALFILE
    EXCEPTIONS
      EXCEL_APP_ERR = 1
      FILE_OPEN_ERR = 2
      OTHERS        = 3.

  LW_TIME2 = SY-UZEIT.
  LW_TIME3 = LW_TIME2 - LW_TIME1.
*MESSAGE I009(ZFI_MS) WITH LW_TIME3 'Open file'.
  LW_TIME1 = SY-UZEIT.

* Copy sheet if have original sheet, sort decending to copy
* correct sheet index
  SORT T_SHEET_DATA BY ORG_SHEETIX SHEETNO.
  LOOP AT T_SHEET_DATA INTO LS_SHEET_DATA
    WHERE ORG_SHEETIX IS NOT INITIAL.
*   Init list of sheet need to copy
    AT NEW ORG_SHEETIX.
      CLEAR LT_SHEET_COPY[].
    ENDAT.

*   Prepare Sheet need to copy
    CLEAR: LS_SHEET_COPY.
    MOVE-CORRESPONDING LS_SHEET_DATA TO LS_SHEET_COPY.
    APPEND LS_SHEET_COPY TO LT_SHEET_COPY.

*   Copy sheet with same original sheet
    AT END OF ORG_SHEETIX.
*     Copy sheet if need
      CALL FUNCTION 'ZFM_OLE_EXCEL_SHEETS_COPY'
        EXPORTING
          I_ORG_SHEETIX   = LS_SHEET_DATA-ORG_SHEETIX
          T_SHEET_COPY    = LT_SHEET_COPY.
    ENDAT.
  ENDLOOP.

  LOOP AT T_SHEET_DATA INTO LS_SHEET_DATA.
    LT_SQUARE_DATA  = LS_SHEET_DATA-T_SQUARE_DATA.
    LT_DEL_ROWS     = LS_SHEET_DATA-T_DEL_ROWS.
    LS_PAGESETUP    = LS_SHEET_DATA-I_PAGESETUP.

*   Add row if need
    READ TABLE LT_SQUARE_DATA TRANSPORTING NO FIELDS
      WITH KEY INSRW = 'X'.
    IF SY-SUBRC IS INITIAL.
*     Active sheet
      CALL FUNCTION 'ZFM_OLE_EXCEL_SHEET_ACTIVE'
        EXPORTING
          I_SHEET_IX = LS_SHEET_DATA-SHEETNO
*          I_SHEET_NAME = LS_SHEET_DATA-SHEET_NAME.
          .
*     Del rows
      LW_DELETED_ROWS = 0.
      LOOP AT LT_DEL_ROWS INTO LS_DELROW.
        LS_DELROW-ROW = LS_DELROW-ROW - LW_DELETED_ROWS.
        CALL FUNCTION 'ZFM_OLE_EXCEL_ROWS_DELETE'
          EXPORTING
            I_TOP  = LS_DELROW-ROW
            I_ROWS = 1.
        LW_DELETED_ROWS = LW_DELETED_ROWS + 1.
      ENDLOOP.

*     Add row
      LOOP AT LT_SQUARE_DATA INTO LS_SQUARE_DATA.
        IF LS_SQUARE_DATA-INSRW = 'X'
        OR LS_SQUARE_DATA-INSCL = 'X'.
          IF I_LARGE_FILE IS INITIAL.
            CALL FUNCTION 'ZFM_FILE_EXCEL_DATA_GETDIMENS'
              IMPORTING
                E_DIMENSION  = LS_DIMENS
              TABLES
                T_EXCEL_DATA = LS_SQUARE_DATA-EXDAT.

          ELSE.
            CALL FUNCTION 'ZFM_FILE_EXCEL_DATA_GETDIM_NUM'
              IMPORTING
                E_DIMENSION  = LS_DIMENS
              TABLES
                T_EXCEL_DATA = LS_SQUARE_DATA-EXDATN.

          ENDIF.
          IF LS_SQUARE_DATA-INITROWS IS INITIAL.
            LS_DIMENS-ROWS      = LS_DIMENS-ROWS - 2.
*           Set row to last init row, to insert
            LS_DIMENS-ROW       = LS_DIMENS-ROW + 1.
          ELSE.
            LS_DIMENS-ROWS      = LS_DIMENS-ROWS
                                - LS_SQUARE_DATA-INITROWS.
*           Set row to last init row, to insert
            LS_DIMENS-ROW       = LS_DIMENS-ROW
                                + LS_SQUARE_DATA-INITROWS - 1.
          ENDIF.
*         Don't insert header row
          IF LS_SQUARE_DATA-EXHDR = 'X'.
            LS_DIMENS-ROW     = LS_DIMENS-ROW + 1.
            LS_DIMENS-ROWS    = LS_DIMENS-ROWS - 1.
          ENDIF.
*         Don't insert header column
          IF LS_SQUARE_DATA-EXHCL = 'X'.
            LS_DIMENS-COLUMN  = LS_DIMENS-COLUMN + 1.
            LS_DIMENS-COLUMNS = LS_DIMENS-COLUMNS - 1.
          ENDIF.
          IF LS_SQUARE_DATA-INSRW = 'X'.
            CALL FUNCTION 'ZFM_OLE_EXCEL_ROWS_INSERT'
              EXPORTING
                I_TOP  = LS_DIMENS-ROW
                I_ROWS = LS_DIMENS-ROWS.
          ENDIF.
          IF LS_SQUARE_DATA-INSCL = 'X'.
            LS_DIMENS-COLUMN    = LS_DIMENS-COLUMN + 1.
            LS_DIMENS-COLUMNS   = LS_DIMENS-COLUMNS - 2.
            CALL FUNCTION 'ZFM_OLE_EXCEL_COLS_INSERT'
              EXPORTING
                I_LEFT = LS_DIMENS-COLUMN
                I_COLS = LS_DIMENS-COLUMNS.
            LS_DIMENS-COLUMN    = LS_DIMENS-COLUMN - 1.
            LS_DIMENS-COLUMNS   = LS_DIMENS-COLUMNS + 2.
          ENDIF.
        ENDIF.
*       Set bold row
        IF LS_SQUARE_DATA-BLDRW[] IS NOT INITIAL.
          IF LS_SQUARE_DATA-EXHCL = 'X'.
            LS_DIMENS-COLUMN  = LS_DIMENS-COLUMN - 1.
            LS_DIMENS-COLUMNS = LS_DIMENS-COLUMNS + 1.
          ENDIF.
          CALL FUNCTION 'ZFM_OLE_EXCEL_ROWS_SETBOLD'
            EXPORTING
              I_LEFT      = LS_DIMENS-COLUMN
              I_COLS      = LS_DIMENS-COLUMNS
            TABLES
              T_BOLD_ROWS = LS_SQUARE_DATA-BLDRW.
        ENDIF.
      ENDLOOP.
      IF SY-UNAME = 'TUANBA2'.
        CALL FUNCTION 'ZFM_OLE_EXCEL_CELLS_EXPORT_MT'
          EXPORTING
            T_EXCEL_EXP       = LT_SQUARE_DATA.
      ENDIF.

      CALL FUNCTION 'ZFM_OLE_EXCEL_PAGESETUP'
        EXPORTING
          I_PAGESETUP = LS_PAGESETUP.
    ENDIF.
  ENDLOOP.

* Save file using OLE
  IF SY-SUBRC IS INITIAL.
    CALL FUNCTION 'ZFM_OLE_EXCEL_SAVE'
      EXPORTING
        I_FILENAME = LW_LOCALFILE.
  ENDIF.

* Free all object
  CALL FUNCTION 'ZFM_OLE_EXCEL_FREE'.

  IF SY-UNAME = 'TUANBA2'.
    RETURN.
  ENDIF.

* Open excel file witk DOI
  CALL FUNCTION 'ZFM_DOI_EXCEL_OPEN'
    EXPORTING
      I_FILENAME    = LW_LOCALFILE
      I_READ_ONLY   = I_READ_ONLY
    IMPORTING
      E_SPREADSHEET = LO_SPREASHEET
      T_SHEETS      = LT_SHEETS
    EXCEPTIONS
      OPEN_FILE_ERR = 1
      OTHERS        = 2.
  IF SY-SUBRC IS NOT INITIAL.
    RAISE OPEN_FILE_ERR.
  ENDIF.

  LOOP AT T_SHEET_DATA INTO LS_SHEET_DATA.
    LT_SQUARE_DATA = LS_SHEET_DATA-T_SQUARE_DATA.
    LT_DEL_ROWS    = LS_SHEET_DATA-T_DEL_ROWS.
    LS_PAGESETUP   = LS_SHEET_DATA-I_PAGESETUP.
*    READ TABLE LT_SHEETS INTO LS_SHEET
*      WITH KEY SHEET_NAME = LS_SHEET_DATA-SHEET_NAME.
    READ TABLE LT_SHEETS INTO LS_SHEET INDEX LS_SHEET_DATA-SHEETNO.
    CHECK SY-SUBRC IS INITIAL.

    LOOP AT LT_SQUARE_DATA INTO LS_SQUARE_DATA.
      IF I_LARGE_FILE IS INITIAL.
        CALL FUNCTION 'ZFM_DOI_EXCEL_DATA_EXPORT'
          EXPORTING
            I_SPREADSHEET = LO_SPREASHEET
            I_SHEETNAME   = LS_SHEET-SHEET_NAME
          TABLES
            T_EXCEL       = LS_SQUARE_DATA-EXDAT
          EXCEPTIONS
            EXPORT_ERR    = 1
            OTHERS        = 2.
      ELSE.
        CALL FUNCTION 'ZFM_DOI_EXCEL_DATA_EXPORT_NUM'
          EXPORTING
            I_SPREADSHEET = LO_SPREASHEET
            I_SHEETNAME   = LS_SHEET-SHEET_NAME
          TABLES
            T_EXCEL       = LS_SQUARE_DATA-EXDATN
          EXCEPTIONS
            EXPORT_ERR    = 1
            OTHERS        = 2.
      ENDIF.
      IF SY-SUBRC <> 0.
        RAISE EXPORT_ERR.
      ENDIF.

      IF LS_SQUARE_DATA-CELLS_FORMAT[] IS NOT INITIAL.
        CALL FUNCTION 'ZFM_DOI_EXCEL_FORMAT_CELLS'
          EXPORTING
            I_SPREADSHEET  = LO_SPREASHEET
            T_CELLS_FORMAT = LS_SQUARE_DATA-CELLS_FORMAT.

      ENDIF.
    ENDLOOP.
  ENDLOOP.

  CALL FUNCTION 'ZFM_DOI_EXCEL_CLOSE'
    EXPORTING
      I_FILENAME  = LW_LOCALFILE
      I_OPEN_FILE = I_OPEN_FILE
      I_NO_ASK    = I_NO_ASK.

  LW_TIME2 = SY-UZEIT.
  LW_TIME3 = LW_TIME2 - LW_TIME1.
*  MESSAGE I009(ZFI_MS) WITH LW_TIME3 'Work with DOI'.





ENDFUNCTION.
