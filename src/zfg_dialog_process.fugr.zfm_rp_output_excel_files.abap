FUNCTION ZFM_RP_OUTPUT_EXCEL_FILES.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_REPORT) TYPE  PROGRAMM DEFAULT SY-CPROG
*"     REFERENCE(T_EXCEL_FILE_OUT) TYPE  ZTT_EXCEL_FILE_OUT
*"     REFERENCE(I_LOGICALFILE) TYPE  ESEFTAPPL
*"     REFERENCE(I_LARGE_FILE) TYPE  XMARK OPTIONAL
*"  EXCEPTIONS
*"      NO_CONFIG
*"      NO_FIELD_SHEETNAME
*"--------------------------------------------------------------------
DATA:
    LS_EXCEL_FILE_OUT TYPE ZST_EXCEL_FILE_OUT,
    LW_FOLDER_PATH    TYPE  STRING.
  FIELD-SYMBOLS:
    <LFT_FILEDATA>    TYPE TABLE.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_BROWSE
*    EXPORTING
*      WINDOW_TITLE         =
*      INITIAL_FOLDER       =
    CHANGING
      SELECTED_FOLDER      = LW_FOLDER_PATH
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      NOT_SUPPORTED_BY_GUI = 3
      OTHERS               = 4.
  IF SY-SUBRC <> 0.
    MESSAGE E003.
    RETURN.
  ENDIF.
  IF LW_FOLDER_PATH IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT T_EXCEL_FILE_OUT INTO LS_EXCEL_FILE_OUT.
    ASSIGN LS_EXCEL_FILE_OUT-FILEDATA->* TO <LFT_FILEDATA>.
    CALL FUNCTION 'ZFM_RP_OUTPUT_EXCEL_SHEETS'
      EXPORTING
        I_REPORT                 = I_REPORT
        T_DATA                   = <LFT_FILEDATA>
        I_LOGICALFILE            = I_LOGICALFILE
        I_DEFAULT_FILENAME       = LS_EXCEL_FILE_OUT-FILENAME
        I_NO_ASK                 = GC_XMARK
        I_FOLDER_PATH            = LW_FOLDER_PATH
        I_OPEN_FILE              = SPACE
        I_LARGE_FILE             = I_LARGE_FILE
      EXCEPTIONS
        NO_CONFIG                = 1
        NO_FIELD_SHEETNAME       = 2
        OTHERS                   = 3.

    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE GC_MTYPE_S NUMBER SY-MSGNO
        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4 DISPLAY LIKE SY-MSGTY.
      RETURN.
    ENDIF.
    MESSAGE S010.
  ENDLOOP.

** Get list of sheets
*  SELECT *
*    INTO TABLE LT_SHEETS
*    FROM ZTB_EXCEL_SHEETS
*   WHERE REPID = I_REPORT.
*  IF LT_SHEETS[] IS INITIAL.
*    RAISE NO_CONFIG.
*  ENDIF.
*
** Get Sheet layout
*  SELECT *
*    INTO TABLE LT_SHEET_LAYOUT
*    FROM ZTB_SHEET_LAYOUT
*   WHERE REPORT  = I_REPORT.
*  IF LT_SHEET_LAYOUT[] IS INITIAL.
*    RAISE NO_CONFIG.
*  ENDIF.





ENDFUNCTION.