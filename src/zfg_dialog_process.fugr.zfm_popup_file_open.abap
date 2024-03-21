FUNCTION ZFM_POPUP_FILE_OPEN.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_EXTENSION) OPTIONAL
*"     REFERENCE(I_FILE_FILTER) OPTIONAL
*"     REFERENCE(I_FILETYPE) DEFAULT 'BIN'
*"     REFERENCE(I_CODEPAGE) TYPE  ABAP_ENCOD OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_FILEDATA) TYPE  STRING
*"     REFERENCE(E_FILEDATA_X) TYPE  XSTRING
*"     REFERENCE(ET_BIN_TAB) TYPE  W3MIMETABTYPE
*"----------------------------------------------------------------------
  DATA:
    LW_TITLE                  TYPE STRING,
    LW_EXTENSION              TYPE STRING,
    LW_FILE_FILTER            TYPE STRING,
    LW_FILETYPE               TYPE CHAR10,
    LW_RC                     TYPE I,
    LW_USER_ACTION            TYPE I,
    LW_FILENAME               TYPE STRING,
    LT_FILE_TAB               TYPE FILETABLE,
    LS_FILE_TAB               TYPE FILE_TABLE,
    LT_FILERAW                TYPE W3MIMETABTYPE,
    LW_LENGTH                 TYPE I.

* Prepare Title, Extenision, File filter
  LW_TITLE = TEXT-012.
  IF I_EXTENSION IS NOT INITIAL.
    LW_EXTENSION = I_EXTENSION.
    IF I_FILE_FILTER IS INITIAL.
      LW_FILE_FILTER = 'EXT files (*.EXT)|*.EXT'.
      REPLACE ALL OCCURRENCES OF 'EXT' IN LW_FILE_FILTER
        WITH LW_EXTENSION.
    ENDIF.
  ENDIF.

* Popup to choose file
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE            = LW_TITLE
      DEFAULT_EXTENSION       = LW_EXTENSION
      FILE_FILTER             = LW_FILE_FILTER
    CHANGING
      FILE_TABLE              = LT_FILE_TAB
      RC                      = LW_RC
      USER_ACTION             = LW_USER_ACTION
    EXCEPTIONS
      FILE_OPEN_DIALOG_FAILED = 1
      CNTL_ERROR              = 2
      ERROR_NO_GUI            = 3
      NOT_SUPPORTED_BY_GUI    = 4
      OTHERS                  = 5.
  IF SY-SUBRC <> 0 OR LW_RC = -1.
    MESSAGE A017(ZMS_COL_LIB).
  ENDIF.

* Process when user choose 1 file
  CHECK LW_USER_ACTION = CL_GUI_FRONTEND_SERVICES=>ACTION_OK.
  READ TABLE LT_FILE_TAB INTO LS_FILE_TAB INDEX 1.
  CHECK SY-SUBRC IS INITIAL.

* Prepare parameters to upload file
  LW_FILENAME = LS_FILE_TAB-FILENAME.
  IF I_FILETYPE IS INITIAL.
    LW_FILETYPE = 'BIN'.
  ELSE.
    LW_FILETYPE = I_FILETYPE.
  ENDIF.

* Upload file to internal table
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD
    EXPORTING
      FILENAME                = LW_FILENAME
      FILETYPE                = LW_FILETYPE
      CODEPAGE                = I_CODEPAGE
    IMPORTING
      FILELENGTH              = LW_LENGTH
    CHANGING
      DATA_TAB                = LT_FILERAW
    EXCEPTIONS
      FILE_OPEN_ERROR         = 1
      FILE_READ_ERROR         = 2
      NO_BATCH                = 3
      GUI_REFUSE_FILETRANSFER = 4
      INVALID_TYPE            = 5
      NO_AUTHORITY            = 6
      UNKNOWN_ERROR           = 7
      BAD_DATA_FORMAT         = 8
      HEADER_NOT_ALLOWED      = 9
      SEPARATOR_NOT_ALLOWED   = 10
      HEADER_TOO_LONG         = 11
      UNKNOWN_DP_ERROR        = 12
      ACCESS_DENIED           = 13
      DP_OUT_OF_MEMORY        = 14
      DISK_FULL               = 15
      DP_TIMEOUT              = 16
      NOT_SUPPORTED_BY_GUI    = 17
      ERROR_NO_GUI            = 18
      OTHERS                  = 19.
  CHECK SY-SUBRC IS INITIAL.

* Convert to string data
  IF E_FILEDATA IS REQUESTED.
    CALL FUNCTION 'SCMS_BINARY_TO_STRING'
      EXPORTING
        INPUT_LENGTH = LW_LENGTH
      IMPORTING
        TEXT_BUFFER  = E_FILEDATA
      TABLES
        BINARY_TAB   = LT_FILERAW
      EXCEPTIONS
        FAILED       = 1
        OTHERS       = 2.
  ENDIF.

* Convert to xstring data
  IF E_FILEDATA_X IS REQUESTED.
    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
      EXPORTING
        INPUT_LENGTH = LW_LENGTH
      IMPORTING
        BUFFER       = E_FILEDATA_X
      TABLES
        BINARY_TAB   = LT_FILERAW
      EXCEPTIONS
        FAILED       = 1
        OTHERS       = 2.
  ENDIF.

* Export raw data
  IF ET_BIN_TAB IS REQUESTED.
    ET_BIN_TAB = LT_FILERAW.
  ENDIF.

ENDFUNCTION.
