FUNCTION ZFM_FILE_EXCEL_EXPORT2.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_LOGICALFILE) TYPE  ESEFTAPPL
*"     REFERENCE(T_SQUARE_DATA) TYPE  ZTT_EXCEL_EXP
*"     REFERENCE(T_EXCEL_LAYOUT) TYPE  ZTT_EXCEL_LAYOUT OPTIONAL
*"     REFERENCE(I_DATA)
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
    LW_TIME3        TYPE TIMS.
  FIELD-SYMBOLS:
    <LF_DATA>       TYPE any.

* Save template to client
  CALL FUNCTION 'ZFM_FILE_DOWNLOAD_TEMPLATE'
    EXPORTING
      I_FILENAME           = I_LOGICALFILE
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
* Add row if need
  READ TABLE T_SQUARE_DATA TRANSPORTING NO FIELDS
    WITH KEY INSRW = 'X'.
  IF SY-SUBRC IS INITIAL.
*   Open file
    CALL FUNCTION 'ZFM_OLE_EXCEL_OPEN'
      EXPORTING
        I_FILENAME    = LW_LOCALFILE
      EXCEPTIONS
        EXCEL_APP_ERR = 1
        FILE_OPEN_ERR = 2
        OTHERS        = 3.

*   Add row
    LOOP AT T_SQUARE_DATA INTO LS_SQUARE_DATA.
      IF LS_SQUARE_DATA-INSRW = 'X'.
        CALL FUNCTION 'ZFM_FILE_EXCEL_DATA_GETDIMENS'
          IMPORTING
            E_DIMENSION  = LS_DIMENS
          TABLES
            T_EXCEL_DATA = LS_SQUARE_DATA-EXDAT.

        LS_DIMENS-ROW  = LS_DIMENS-ROW + 1.
        LS_DIMENS-ROWS = LS_DIMENS-ROWS - 2.
        CALL FUNCTION 'ZFM_OLE_EXCEL_ROWS_INSERT'
          EXPORTING
            I_TOP  = LS_DIMENS-ROW
            I_ROWS = LS_DIMENS-ROWS.
      ENDIF.
*      CALL FUNCTION 'ZFM_OLE_EXCEL_CELLS_EXPORT'
*        TABLES
*          T_EXCEL_DATA = LS_SQUARE_DATA-EXDAT.

*     Set bold row
      IF LS_SQUARE_DATA-BLDRW[] IS NOT INITIAL.
        CALL FUNCTION 'ZFM_OLE_EXCEL_ROWS_SETBOLD'
          EXPORTING
            I_LEFT      = LS_DIMENS-COLUMN
            I_COLS      = LS_DIMENS-COLUMNS
          TABLES
            T_BOLD_ROWS = LS_SQUARE_DATA-BLDRW.
      ENDIF.
    ENDLOOP.

    CALL FUNCTION 'ZFM_OLE_EXCEL_CELLS_EXPORT'
      EXPORTING
        I_DATA               = I_DATA
        T_EXCEL_LAYOUT       = T_EXCEL_LAYOUT.

*   Save file
    IF SY-SUBRC IS INITIAL.
      CALL FUNCTION 'ZFM_OLE_EXCEL_SAVE'
        EXPORTING
          I_FILENAME = LW_LOCALFILE.
    ENDIF.

*   Free all object
    CALL FUNCTION 'ZFM_OLE_EXCEL_FREE'.

    CALL FUNCTION 'WS_EXECUTE'
      EXPORTING
        INFORM             = ' '
        PROGRAM            = LW_LOCALFILE
      EXCEPTIONS
        FRONTEND_ERROR     = 1
        NO_BATCH           = 2
        PROG_NOT_FOUND     = 3
        ILLEGAL_OPTION     = 4
        GUI_REFUSE_EXECUTE = 5
        OTHERS             = 6.
  ENDIF.

  LW_TIME2 = SY-UZEIT.
  LW_TIME3 = LW_TIME2 - LW_TIME1.
*  MESSAGE I009(ZFI_MS) WITH LW_TIME3.





ENDFUNCTION.
