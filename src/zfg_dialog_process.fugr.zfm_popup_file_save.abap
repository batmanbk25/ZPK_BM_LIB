FUNCTION ZFM_POPUP_FILE_SAVE.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_FILENAME)
*"     VALUE(IT_FILEDATA) TYPE  W3MIMETABTYPE
*"     REFERENCE(I_FILESIZE) TYPE  I OPTIONAL
*"----------------------------------------------------------------------
  DATA:
    LW_FILENAME               TYPE STRING,
    LW_FILEPATH               TYPE STRING,
    LW_FILESIZE               TYPE I,
    LW_PATH                   TYPE STRING,
    LW_USER_ACTION            TYPE I.
  FIELD-SYMBOLS:
    <LF_LINE>                 TYPE ANY.

* Initial
  LW_FILENAME = I_FILENAME.
  IF I_FILESIZE IS INITIAL.
    READ TABLE IT_FILEDATA INDEX 1 ASSIGNING <LF_LINE>.
    IF SY-SUBRC IS INITIAL.
      DESCRIBE FIELD <LF_LINE> LENGTH LW_FILESIZE IN BYTE MODE.
      LW_FILESIZE = LW_FILESIZE * LINES( IT_FILEDATA ).
    ENDIF.
  ELSE.
    LW_FILESIZE = I_FILESIZE.
  ENDIF.

* Popup save file
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
    EXPORTING
      DEFAULT_FILE_NAME = LW_FILENAME
    CHANGING
      FILENAME          = LW_FILENAME
      PATH              = LW_PATH
      FULLPATH          = LW_FILEPATH
      USER_ACTION       = LW_USER_ACTION
    EXCEPTIONS
      OTHERS            = 1.
  IF SY-SUBRC <> 0.
    MESSAGE A017(ZMS_COL_LIB).
  ENDIF.
* Process when user choose 1 file
  CHECK LW_USER_ACTION = CL_GUI_FRONTEND_SERVICES=>ACTION_OK.

* Write file
  IF NOT LW_FILEPATH IS INITIAL.
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
      EXPORTING
        FILETYPE         = 'BIN'
        FILENAME         = LW_FILEPATH
        BIN_FILESIZE     = LW_FILESIZE
      CHANGING
        DATA_TAB         = IT_FILEDATA
      EXCEPTIONS
        FILE_WRITE_ERROR = 1
        OTHERS           = 22.
  ENDIF.

ENDFUNCTION.
