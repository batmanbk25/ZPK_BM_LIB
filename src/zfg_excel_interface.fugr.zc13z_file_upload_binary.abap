FUNCTION ZC13Z_FILE_UPLOAD_BINARY.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_FILE_FRONT_END)
*"     VALUE(I_FILE_APPL) LIKE  RCGFILETR-FTAPPL
*"     VALUE(I_FILE_OVERWRITE) TYPE  ESP1_BOOLEAN DEFAULT ESP1_FALSE
*"  EXPORTING
*"     VALUE(E_FLG_OPEN_ERROR) TYPE  ESP1_BOOLEAN
*"     VALUE(E_OS_MESSAGE) TYPE  C
*"  EXCEPTIONS
*"      FE_FILE_NOT_EXISTS
*"      FE_FILE_READ_ERROR
*"      AP_NO_AUTHORITY
*"      AP_FILE_OPEN_ERROR
*"      AP_FILE_EXISTS
*"      AP_CONVERT_ERROR
*"--------------------------------------------------------------------
CONSTANTS: LC_FILEFORMAT_BINARY        LIKE RLGRAP-FILETYPE
                                         VALUE 'BIN'.

  DATA: L_FILELENGTH    TYPE I.
  DATA: L_DATA_TAB      LIKE RCGREPFILE OCCURS 10 WITH HEADER LINE.
  DATA: L_FILENAME      TYPE STRING.
  DATA: L_AUTH_FILENAME LIKE AUTHB-FILENAME.
  DATA: L_LINES         TYPE I.

* Function body -------------------------------------------------------
* init
  E_FLG_OPEN_ERROR = ''."false.
  CLEAR E_OS_MESSAGE.

  L_FILENAME = I_FILE_FRONT_END.

* check the authority to write the file to the application server
*  l_auth_filename = i_file_appl.
*  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
*       EXPORTING
**           PROGRAM          =
*            activity         = sabc_act_write
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
*    MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
*        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*    RAISE AP_FILE_OPEN_ERROR.
*  ENDIF.
** End Correction 24.09.2010 1505368 ********************

* open the file on the application server for reading to check if the
* file exists on the application server
  OPEN DATASET I_FILE_APPL FOR INPUT MESSAGE E_OS_MESSAGE
       IN BINARY MODE.
  IF SY-SUBRC <> 0.
*   nothing to do
  ELSEIF I_FILE_OVERWRITE = space."FALSE.
    CLOSE DATASET I_FILE_APPL.
    RAISE AP_FILE_EXISTS.
  ENDIF.
  CLOSE DATASET I_FILE_APPL.

* upload the file
  CALL FUNCTION 'C13Z_UPLOAD'
     EXPORTING
*       CODEPAGE                      = ' '
       FILENAME                      = L_FILENAME
       FILETYPE                      = LC_FILEFORMAT_BINARY
*       HEADLEN                       = ' '
*       LINE_EXIT                     = ' '
*       TRUNCLEN                      = ' '
*       USER_FORM                     = ' '
*       USER_PROG                     = ' '
*       DAT_D_FORMAT                  = ' '
     IMPORTING
       FILELENGTH                    = L_FILELENGTH
     TABLES
       DATA_TAB                      = L_DATA_TAB
     EXCEPTIONS
       CONVERSION_ERROR              = 1
       FILE_OPEN_ERROR               = 2
       FILE_READ_ERROR               = 3
       INVALID_TYPE                  = 4
       NO_BATCH                      = 5
       UNKNOWN_ERROR                 = 6
       INVALID_TABLE_WIDTH           = 7
       GUI_REFUSE_FILETRANSFER       = 8
       CUSTOMER_ERROR                = 9
       NO_AUTHORITY                  = 10
       BAD_DATA_FORMAT               = 11
       HEADER_NOT_ALLOWED            = 12
       SEPARATOR_NOT_ALLOWED         = 13
       HEADER_TOO_LONG               = 14
       UNKNOWN_DP_ERROR              = 15
       ACCESS_DENIED                 = 16
       DP_OUT_OF_MEMORY              = 17
       DISK_FULL                     = 18
       DP_TIMEOUT                    = 19
       NOT_SUPPORTED_BY_GUI          = 20
       ERROR_NO_GUI                  = 21
       OTHERS                        = 22
       .

  IF NOT SY-SUBRC IS INITIAL.
    CASE SY-SUBRC.
      WHEN 2 .
        RAISE FE_FILE_NOT_EXISTS.
      WHEN OTHERS.
        RAISE FE_FILE_READ_ERROR.
    ENDCASE.
  ENDIF.

* count lines in rawdata table
  DESCRIBE TABLE L_DATA_TAB LINES L_LINES.

* write file to frontend
  CALL FUNCTION 'ZC13Z_RAWDATA_WRITE'
    EXPORTING
      I_FILE           = I_FILE_APPL
      I_FILE_SIZE      = L_FILELENGTH
      I_LINES          = L_LINES
    TABLES
      I_RCGREPFILE_TAB = L_DATA_TAB
    EXCEPTIONS
      NO_PERMISSION    = 1
      OPEN_FAILED      = 2
      OTHERS           = 3.

  IF NOT SY-SUBRC IS INITIAL.
    CASE SY-SUBRC.
      WHEN 1.
*       no auhtority
        RAISE AP_NO_AUTHORITY.
      WHEN OTHERS.
        RAISE AP_FILE_OPEN_ERROR.
    ENDCASE.
  ENDIF.





ENDFUNCTION.
