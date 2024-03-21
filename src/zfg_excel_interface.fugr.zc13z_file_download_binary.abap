FUNCTION ZC13Z_FILE_DOWNLOAD_BINARY.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_FILE_FRONT_END) TYPE  STRING
*"     VALUE(I_FILE_APPL) TYPE  ESEFTAPPL
*"     VALUE(I_FILE_OVERWRITE) TYPE  ESEBOOLE DEFAULT ' '
*"  EXPORTING
*"     VALUE(E_FLG_OPEN_ERROR) TYPE  ESEBOOLE
*"     VALUE(E_OS_MESSAGE) TYPE  CHAR1
*"  EXCEPTIONS
*"      FE_FILE_OPEN_ERROR
*"      FE_FILE_EXISTS
*"      FE_FILE_WRITE_ERROR
*"      AP_NO_AUTHORITY
*"      AP_FILE_OPEN_ERROR
*"      AP_FILE_EMPTY
*"----------------------------------------------------------------------
CONSTANTS: LC_FILEFORMAT_BINARY        LIKE RLGRAP-FILETYPE
                                         VALUE 'BIN'.
* Local data ----------------------------------------------------------

  DATA: L_FILELENGTH    TYPE I.
  DATA: L_ORLN          LIKE DRAO-ORLN.
  DATA: L_DATA_TAB      LIKE RCGREPFILE OCCURS 10 WITH HEADER LINE.
  DATA: L_FILENAME      TYPE STRING.
  DATA: L_AUTH_FILENAME LIKE AUTHB-FILENAME.
  DATA: L_RETURN        TYPE C.
  DATA: L_LINES         TYPE I.

* Function body -------------------------------------------------------

* init
  E_FLG_OPEN_ERROR = ' '. "FALSE.
  CLEAR E_OS_MESSAGE.

  L_FILENAME   = I_FILE_FRONT_END.

** check the authority to read the file from the application server
*  l_auth_filename = i_file_appl.
*  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
*       EXPORTING
**           PROGRAM          =
*            activity         = sabc_act_read
*            filename         = l_auth_filename
*       EXCEPTIONS
*            no_authority     = 1
*            activity_unknown = 2
*            OTHERS           = 3.
*  IF NOT sy-subrc IS INITIAL.
*    CASE sy-subrc.
*      WHEN 1.
**       no auhtority
*        RAISE ap_no_authority.
*      WHEN OTHERS.
*        RAISE ap_file_open_error.
*    ENDCASE.
*  ENDIF.


* check if the file on the front-end exists
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIST
    EXPORTING
      FILE                 = L_FILENAME
    RECEIVING
      RESULT               = L_RETURN
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      WRONG_PARAMETER      = 3
      NOT_SUPPORTED_BY_GUI = 4
      OTHERS               = 5.

* if file exists continue only if parameter is specified
  IF SY-SUBRC = 0 AND L_RETURN = 'X'.
    IF I_FILE_OVERWRITE = ' '. "FALSE.
      RAISE FE_FILE_EXISTS.
    ENDIF.
  ELSEIF SY-SUBRC <> 0.
    RAISE FE_FILE_OPEN_ERROR.
  ENDIF.                          " not sy-subrc is initial.

** Begin Correction 24.09.2010 1505368 ********************
** validate physical filename against logical filename
*  CALL FUNCTION 'FILE_VALIDATE_NAME'
*    EXPORTING
*      LOGICAL_FILENAME  = LC_LOGICAL_FILENAME_FTAPPL_2
*    CHANGING
*      PHYSICAL_FILENAME = I_FILE_APPL
*    EXCEPTIONS
*      OTHERS            = 1.
*
*  IF SY-SUBRC <> 0.
*    E_FLG_OPEN_ERROR = TRUE.
*    MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
*        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    RAISE FE_FILE_OPEN_ERROR.
*  ENDIF.
** End Correction 24.09.2010 1505368 ********************

* open the file on the application server
  OPEN DATASET I_FILE_APPL FOR INPUT MESSAGE E_OS_MESSAGE
               IN BINARY MODE.
  IF NOT SY-SUBRC IS INITIAL.
    E_FLG_OPEN_ERROR = 'X'."TRUE.
    RAISE FE_FILE_OPEN_ERROR.
    EXIT.
  ENDIF.                            " not sy-subrc is initial
  CLOSE DATASET I_FILE_APPL.

* read data from application server
  CALL FUNCTION 'ZC13Z_RAWDATA_READ'
    EXPORTING
      I_FILE           = I_FILE_APPL
    IMPORTING
      E_FILE_SIZE      = L_ORLN
      E_LINES          = L_LINES
    TABLES
      E_RCGREPFILE_TAB = L_DATA_TAB
    EXCEPTIONS
      NO_PERMISSION    = 1
      OPEN_FAILED      = 2
      READ_ERROR       = 3
* Begin Correction 24.09.2010 1505368 ********************
      PATH_ERROR       = 4
      OTHERS           = 5.
* End Correction 24.09.2010 1505368 ********************

  IF NOT SY-SUBRC IS INITIAL.
    CASE SY-SUBRC.
      WHEN 1.
*       no auhtority
        RAISE AP_NO_AUTHORITY.
      WHEN OTHERS.
        RAISE AP_FILE_OPEN_ERROR.
    ENDCASE.
  ENDIF.


*  check if data table is empty
  READ TABLE L_DATA_TAB INDEX 1.
  IF SY-SUBRC IS INITIAL.
    L_FILELENGTH = L_ORLN.
    CALL FUNCTION 'C13Z_DOWNLOAD'
        EXPORTING
               BIN_FILESIZE        = L_FILELENGTH
*               CODEPAGE            = ' '
               FILENAME            = L_FILENAME
               FILETYPE            = LC_FILEFORMAT_BINARY
*               mode                = ' '
*               WK1_N_FORMAT        = ' '
*               WK1_N_SIZE          = ' '
*               WK1_T_FORMAT        = ' '
*               WK1_T_SIZE          = ' '
*               COL_SELECT          = ' '
*               COL_SELECTMASK      = ' '
          IMPORTING
               FILELENGTH          = L_FILELENGTH
          TABLES
               DATA_TAB            = L_DATA_TAB
*               FIELDNAMES          =
          EXCEPTIONS
               FILE_OPEN_ERROR     = 1
               FILE_WRITE_ERROR    = 2
               INVALID_FILESIZE    = 3
               INVALID_TABLE_WIDTH = 4
               INVALID_TYPE        = 5
               NO_BATCH            = 6
               UNKNOWN_ERROR       = 7
               OTHERS              = 8.
    IF NOT SY-SUBRC IS INITIAL.
      CASE SY-SUBRC.
        WHEN 2 .
          RAISE FE_FILE_OPEN_ERROR.
        WHEN OTHERS.
          RAISE FE_FILE_WRITE_ERROR.
      ENDCASE.
    ENDIF.                          " not sy-subrc is initial

  ELSE.

*   file on application server has no contents
    RAISE AP_FILE_EMPTY.

  ENDIF.                            " sy-subrc is initial





ENDFUNCTION.
