FUNCTION ZFM_FILE_DOWNLOAD_TEMPLATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_FILENAME) TYPE  ESEFTAPPL
*"     REFERENCE(I_DEFAULT_FILENAME) TYPE  STRING OPTIONAL
*"     REFERENCE(I_FOLDER_PATH) TYPE  STRING OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_LOCALFILE) TYPE  LOCALFILE
*"  EXCEPTIONS
*"      FILE_CLIENT_ERR
*"      USER_CANCEL
*"      SAVE_CLIENT_FILE_ERR
*"--------------------------------------------------------------------
DATA:
      LW_LOGICALFILE  TYPE ESEFTAPPL,
      LW_FILENAME     TYPE STRING,
      LW_FILEPATH     TYPE STRING,
      LW_FULLPATH     TYPE STRING,
      LW_USERACTION   TYPE I,
      LW_INIT_FOLDER  TYPE STRING,
      LW_FILE_FILTER  TYPE STRING
                      VALUE 'Excel Files (*.XLS)|*.XLS|(*.XLSX)|*.XLSX',
      LW_SEPARATOR    TYPE C.

  CLEAR E_LOCALFILE.

  LW_LOGICALFILE = I_FILENAME.
*  TRANSLATE LW_LOGICALFILE TO LOWER CASE.
  IF I_FOLDER_PATH IS NOT INITIAL
  AND I_DEFAULT_FILENAME IS NOT INITIAL.
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>GET_FILE_SEPARATOR
      CHANGING
        FILE_SEPARATOR       = LW_SEPARATOR
      EXCEPTIONS
        NOT_SUPPORTED_BY_GUI = 1
        ERROR_NO_GUI         = 2
        CNTL_ERROR           = 3
        OTHERS               = 4.
    CONCATENATE I_FOLDER_PATH
                I_DEFAULT_FILENAME
           INTO LW_FULLPATH SEPARATED BY LW_SEPARATOR.
  ELSE.
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
      EXPORTING
        WINDOW_TITLE         = 'Save file'
        DEFAULT_FILE_NAME    = I_DEFAULT_FILENAME
        DEFAULT_EXTENSION    = 'XLS'
        FILE_FILTER          = LW_FILE_FILTER
        INITIAL_DIRECTORY    = LW_INIT_FOLDER
      CHANGING
        FILENAME             = LW_FILENAME
        PATH                 = LW_FILEPATH
        FULLPATH             = LW_FULLPATH
        USER_ACTION          = LW_USERACTION
      EXCEPTIONS
        CNTL_ERROR           = 1
        ERROR_NO_GUI         = 2
        NOT_SUPPORTED_BY_GUI = 3
        OTHERS               = 4.
    IF SY-SUBRC <> 0.
      RAISE FILE_CLIENT_ERR.
    ELSEIF LW_USERACTION = CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL.
      RAISE USER_CANCEL.
    ENDIF.
  ENDIF.
  DATA:
      LW_TIME1        TYPE TIMS,
      LW_TIME2        TYPE TIMS,
      LW_TIME3        TYPE TIMS.
  LW_TIME1 = SY-UZEIT.

* Copy template from server to client
  CALL FUNCTION 'ZC13Z_FILE_DOWNLOAD_BINARY'
    EXPORTING
      I_FILE_FRONT_END    = LW_FULLPATH
      I_FILE_APPL         = LW_LOGICALFILE
      I_FILE_OVERWRITE    = 'X'
    EXCEPTIONS
      FE_FILE_OPEN_ERROR  = 1
      FE_FILE_EXISTS      = 2
      FE_FILE_WRITE_ERROR = 3
      AP_NO_AUTHORITY     = 4
      AP_FILE_OPEN_ERROR  = 5
      AP_FILE_EMPTY       = 6
      OTHERS              = 7.
  IF SY-SUBRC <> 0.
    RAISE SAVE_CLIENT_FILE_ERR.
  ENDIF.

  E_LOCALFILE = LW_FULLPATH.

  LW_TIME2 = SY-UZEIT.
  LW_TIME3 = LW_TIME2 - LW_TIME1.
*  MESSAGE I009(ZFI_MS) WITH LW_TIME3 'Dowmload template'.





ENDFUNCTION.