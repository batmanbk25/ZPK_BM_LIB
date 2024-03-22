*&---------------------------------------------------------------------*
*& Include          ZIN_BM_TRAN_RQF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZCORE_IN_DOWN_UP_TRF01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      FORM  INIT
*&---------------------------------------------------------------------*
FORM INIT .
* Init Download Local Folder Path
  DATA:
    LW_DESKTOP_PATH TYPE STRING.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GET_DESKTOP_DIRECTORY
    CHANGING
      DESKTOP_DIRECTORY = LW_DESKTOP_PATH
    EXCEPTIONS
      CNTL_ERROR        = 1.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  CALL METHOD CL_GUI_CFW=>UPDATE_VIEW.

  P_PATH = LW_DESKTOP_PATH.
ENDFORM.                    " INIT


*&---------------------------------------------------------------------*
*&      Form  MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM MODIFY_SCREEN.
  LOOP AT SCREEN.
    IF SCREEN-NAME = 'P_KPATH' OR SCREEN-NAME = 'P_RPATH'.
      SCREEN-INPUT = '0'.
    ENDIF.

    CASE 'X'.
      WHEN P_DOWRQ.
        IF SCREEN-NAME = '%_P_UPL_TR_%_APP_%-TEXT' OR SCREEN-NAME = 'P_UPL_TR'.
          SCREEN-ACTIVE = '0'.
        ENDIF.
      WHEN P_UPLRQ.
        IF SCREEN-NAME = '%_P_DOW_TR_%_APP_%-TEXT' OR SCREEN-NAME = 'P_DOW_TR'.
          SCREEN-ACTIVE = '0'.
        ENDIF.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.                    " MODIFY_SCREEN


*&---------------------------------------------------------------------*
*&      FORM  GET_F4_TRKORR
*&---------------------------------------------------------------------*
FORM GET_F4_TRKORR.

  TYPE-POOLS SCTSC.

  DATA: LW_TR_TYPE    LIKE  TRPARI-W_LONGSTAT,
        LW_TR_STATUS  LIKE  TRPARI-W_LONGSTAT,
        LW_TRKORR     TYPE  E070-TRKORR,
        LS_DYNPFIELD  LIKE DYNPREAD,
        LT_DYNPFIELDS LIKE DYNPREAD OCCURS 0.

  " Get Tranport Request Name From Current Field
  GET CURSOR FIELD LS_DYNPFIELD-FIELDNAME.
  APPEND LS_DYNPFIELD TO LT_DYNPFIELDS.
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = SY-CPROG
      DYNUMB     = SY-DYNNR
    TABLES
      DYNPFIELDS = LT_DYNPFIELDS.
  READ TABLE LT_DYNPFIELDS INTO LS_DYNPFIELD INDEX 1.
  LW_TRKORR = LS_DYNPFIELD-FIELDVALUE.

  " Popup Dialog Tranport Request Search Help
  LW_TR_TYPE = SCTSC_TYPES_ALL.
  LW_TR_STATUS = SCTSC_STATES_RELEASED. " SCTSC_STATES_CHANGEABLE.
  CALL FUNCTION 'TR_F4_REQUESTS'
    EXPORTING
      IV_USERNAME         = SPACE
      IV_TRKORR_PATTERN   = LW_TRKORR
      IV_TRFUNCTIONS      = LW_TR_TYPE
      IV_TRSTATUS         = LW_TR_STATUS
    IMPORTING
      EV_SELECTED_REQUEST = LW_TRKORR.

  " Modify Transport Request Return Value To Current Field
  LS_DYNPFIELD-FIELDVALUE = LW_TRKORR.
  MODIFY LT_DYNPFIELDS FROM LS_DYNPFIELD
                       INDEX 1
                       TRANSPORTING FIELDVALUE.
  CALL FUNCTION 'DYNP_VALUES_UPDATE'
    EXPORTING
      DYNAME     = SY-CPROG
      DYNUMB     = SY-DYNNR
    TABLES
      DYNPFIELDS = LT_DYNPFIELDS.

ENDFORM.                               " GET_F4_TRKORR


*&---------------------------------------------------------------------*
*&      FORM  GET_F4_LOCAL_PATH
*&---------------------------------------------------------------------*
FORM GET_F4_LOCAL_PATH .

  DATA: LS_DYNPFIELD  LIKE DYNPREAD,
        LT_DYNPFIELDS LIKE DYNPREAD OCCURS 0,
        LW_PATH       TYPE STRING.

* Get Tranport Request Name From Current Field
  GET CURSOR FIELD LS_DYNPFIELD-FIELDNAME.
  APPEND LS_DYNPFIELD TO LT_DYNPFIELDS.
  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME     = SY-CPROG
      DYNUMB     = SY-DYNNR
    TABLES
      DYNPFIELDS = LT_DYNPFIELDS.
  READ TABLE LT_DYNPFIELDS INTO LS_DYNPFIELD INDEX 1.
  LW_PATH = LS_DYNPFIELD-FIELDVALUE.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_BROWSE
    EXPORTING
      WINDOW_TITLE    = 'Select Target Folder On Front End'
      INITIAL_FOLDER  = LW_PATH
    CHANGING
      SELECTED_FOLDER = LW_PATH.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  P_PATH = LW_PATH.

ENDFORM.                    " GET_F4_LOCAL_PATH


*&---------------------------------------------------------------------*
*&      FORM  CHECK_CONDITION
*&---------------------------------------------------------------------*
FORM CHECK_CONDITION.
  CASE 'X'.
    WHEN P_DOWRQ.
      IF P_TRKORR = ''.
        MESSAGE 'Please fill Request/Task for download' TYPE 'E'.
      ENDIF.
    WHEN P_UPLRQ.
      IF P_TRKORR = ''.
        MESSAGE 'Please fill Request/Task for upload' TYPE 'E'.
      ENDIF.
  ENDCASE.
ENDFORM.                    " CHECK_CONDITION


*&---------------------------------------------------------------------*
*&      FORM  GET_APPLICATION_FILE_PATH
*&---------------------------------------------------------------------*
FORM GET_APPLICATION_FILE_PATH.

  DATA: LW_REQ    TYPE TEXT255,
        LW_OFFSET TYPE I,
        LW_NUM    TYPE CHAR10,
        LW_INST   TYPE CHAR10.

  DATA: LW_PATH     TYPE ESEFTFRONT.

  " Get Cofile and Data file name
  LW_REQ = P_TRKORR.
  CALL FUNCTION 'STRING_REVERSE'
    EXPORTING
      STRING  = LW_REQ
      LANG    = ''
    IMPORTING
      RSTRING = LW_REQ.

  FIND FIRST OCCURRENCE OF 'K' IN LW_REQ MATCH OFFSET LW_OFFSET.
  LW_OFFSET = STRLEN( LW_REQ ) - LW_OFFSET.

  LW_NUM = P_TRKORR+LW_OFFSET.
  LW_OFFSET = LW_OFFSET - 1.
  LW_INST = P_TRKORR(LW_OFFSET).

  " Get full path cofile and data file from source application server
  CLEAR: LW_PATH, LW_OFFSET.
  LW_PATH = P_PATH.
  LW_OFFSET = STRLEN( LW_PATH ) - 1.
  IF LW_PATH+LW_OFFSET(1) <> '\'.
    CONCATENATE LW_PATH '\' INTO LW_PATH.
  ENDIF.
  CONCATENATE LW_PATH 'K' LW_NUM '.' LW_INST INTO GW_KFILE_LOCAL.
  CONCATENATE LW_PATH 'R' LW_NUM '.' LW_INST INTO GW_RFILE_LOCAL.
  CONCATENATE P_KPATH 'K' LW_NUM '.' LW_INST INTO GW_KFILE_SERVER.
  CONCATENATE P_RPATH 'R' LW_NUM '.' LW_INST INTO GW_RFILE_SERVER.

ENDFORM.                    " GET_APPLICATION_FILE_PATH


*&---------------------------------------------------------------------*
*&      FORM  DOWNLOAD_PROCESSING
*&---------------------------------------------------------------------*
FORM DOWNLOAD_PROCESSING.

  DATA: LW_LOCAL_FILE_PATH  TYPE string,
        LW_KFILE_EXISTS     TYPE BOOLEAN,
        LW_RFILE_EXISTS     TYPE BOOLEAN,
        LW_TEXT_QUESTION    TYPE STRING,
        LW_QUESTION         TYPE C.

  DATA: LW_FLG_OPEN_ERROR  TYPE BOOLEAN,
        LW_OS_MESSAGE(100) TYPE C.

* Assign Program Name Similar T-Code CG3Y
  SY-CPROG = 'RC1TCG3Y'.

* Check cofile Exist on Front End
  CLEAR: LW_KFILE_EXISTS.
  LW_LOCAL_FILE_PATH = GW_KFILE_LOCAL.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIST
    EXPORTING
      FILE                 = LW_LOCAL_FILE_PATH
    RECEIVING
      RESULT               = LW_KFILE_EXISTS
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      WRONG_PARAMETER      = 3
      NOT_SUPPORTED_BY_GUI = 4
      OTHERS               = 5.

* Check data file Exist on Front End
  CLEAR: LW_RFILE_EXISTS.
  LW_LOCAL_FILE_PATH = GW_RFILE_LOCAL.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIST
    EXPORTING
      FILE                 = LW_LOCAL_FILE_PATH
    RECEIVING
      RESULT               = LW_RFILE_EXISTS
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      WRONG_PARAMETER      = 3
      NOT_SUPPORTED_BY_GUI = 4
      OTHERS               = 5.

  IF LW_KFILE_EXISTS = 'X' AND LW_RFILE_EXISTS = 'X'.
    CONCATENATE 'Cofile'
                GW_KFILE_LOCAL
                'and data file'
                GW_RFILE_LOCAL
                'exist on Front End. Do you want to override ?'
           INTO LW_TEXT_QUESTION SEPARATED BY SPACE.
  ELSEIF LW_KFILE_EXISTS = 'X' AND LW_RFILE_EXISTS = ''.
    CONCATENATE 'Cofile' GW_KFILE_LOCAL
                'exists in Front End. Do you want to override ?'
           INTO LW_TEXT_QUESTION SEPARATED BY SPACE.
  ELSEIF LW_KFILE_EXISTS = '' AND LW_RFILE_EXISTS = 'X'.
    CONCATENATE 'Data file' GW_RFILE_LOCAL
                'exists in Front End. Do you want to override ?'
           INTO LW_TEXT_QUESTION SEPARATED BY SPACE.
  ENDIF.

  IF LW_KFILE_EXISTS <> '' AND LW_RFILE_EXISTS <> ''.
    LW_QUESTION = 'T'.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR       = 'Override confirmation'
        TEXT_QUESTION  = LW_TEXT_QUESTION
        ICON_BUTTON_1  = 'icon_booking_ok'
      IMPORTING
        ANSWER         = LW_QUESTION
      EXCEPTIONS
        TEXT_NOT_FOUND = 1
        OTHERS         = 2.
    IF LW_QUESTION = '0'.
      MESSAGE 'Cancel action' TYPE 'S'.
      EXIT.
    ENDIF.
  ENDIF.

* Download cofile with ASCII file type
* Can Use Function Module ARCHIVFILE_SERVER_TO_CLIENT
  CALL FUNCTION 'C13Z_FILE_DOWNLOAD_ASCII'
    EXPORTING
      I_FILE_FRONT_END    = GW_KFILE_LOCAL
      I_FILE_APPL         = GW_KFILE_SERVER
      I_FILE_OVERWRITE    = 'X'
    IMPORTING
      E_FLG_OPEN_ERROR    = LW_FLG_OPEN_ERROR
      E_OS_MESSAGE        = LW_OS_MESSAGE
    EXCEPTIONS
      FE_FILE_OPEN_ERROR  = 1
      FE_FILE_EXISTS      = 2
      FE_FILE_WRITE_ERROR = 3
      AP_NO_AUTHORITY     = 4
      AP_FILE_OPEN_ERROR  = 5
      AP_FILE_EMPTY       = 6
      OTHERS              = 7.

  IF SY-SUBRC <> 0 OR LW_FLG_OPEN_ERROR = 'X'.
    CONCATENATE 'Can not open cofile' GW_KFILE_SERVER 'for download.'
                LW_OS_MESSAGE
           INTO GW_MESSAGE_OUTPUT SEPARATED BY SPACE.
    MESSAGE GW_MESSAGE_OUTPUT TYPE 'E'.
  ELSE.
    CONCATENATE 'Download cofile to' GW_KFILE_LOCAL 'successfully'
           INTO GW_MESSAGE_OUTPUT SEPARATED BY SPACE.
    MESSAGE GW_MESSAGE_OUTPUT TYPE 'I'.
  ENDIF.

* Download data file with BIN file type
*  CALL FUNCTION 'ZC13Z_FILE_DOWNLOAD_BINARY'
  CALL FUNCTION 'C13Z_FILE_DOWNLOAD_BINARY'
    EXPORTING
      I_FILE_FRONT_END    = GW_RFILE_LOCAL
      I_FILE_APPL         = GW_RFILE_SERVER
      I_FILE_OVERWRITE    = 'X'
    IMPORTING
      E_FLG_OPEN_ERROR    = LW_FLG_OPEN_ERROR
      E_OS_MESSAGE        = LW_OS_MESSAGE
    EXCEPTIONS
      FE_FILE_OPEN_ERROR  = 1
      FE_FILE_EXISTS      = 2
      FE_FILE_WRITE_ERROR = 3
      AP_NO_AUTHORITY     = 4
      AP_FILE_OPEN_ERROR  = 5
      AP_FILE_EMPTY       = 6
      OTHERS              = 7.

  IF SY-SUBRC <> 0 OR LW_FLG_OPEN_ERROR = 'X'.
    CONCATENATE 'Can not open data file' GW_RFILE_SERVER 'for download.'
                LW_OS_MESSAGE
           INTO GW_MESSAGE_OUTPUT SEPARATED BY SPACE.
    MESSAGE GW_MESSAGE_OUTPUT TYPE 'E'.
  ELSE.
    CONCATENATE 'Download data file to' GW_RFILE_LOCAL 'successfully'
           INTO GW_MESSAGE_OUTPUT SEPARATED BY SPACE.
    MESSAGE GW_MESSAGE_OUTPUT TYPE 'I'.
  ENDIF.

ENDFORM.                    " DOWNLOAD_PROCESSING


*&---------------------------------------------------------------------*
*&      FORM  UPLOAD_PROCESSING
*&---------------------------------------------------------------------*
FORM UPLOAD_PROCESSING.

  DATA: LW_KFILE_EXISTS  TYPE BOOLEAN,
        LW_RFILE_EXISTS  TYPE BOOLEAN,
        LW_TEXT_QUESTION TYPE STRING,
        LW_KFILE         TYPE STRING,
        LW_RFILE         TYPE STRING,
        LW_QUESTION      TYPE C,
        lw_server_file_path type dxfile-filename.

  DATA: LW_FLG_OPEN_ERROR  TYPE BOOLEAN,
        LW_OS_MESSAGE(100) TYPE C.

  DATA: LW_FILE  TYPE DXFILE-FILENAME,
        LW_XFLAG TYPE XFLAG.

  " Assign Program Name Similar T-Code CG3Y
  SY-CPROG = 'RC1TCG3Z'.

  " Check cofile Exist on Application Server
  CLEAR: LW_KFILE_EXISTS.
  lw_server_file_path = GW_KFILE_SERVER.

* local application server
  OPEN DATASET lw_server_file_path FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc = 0.
    LW_KFILE_EXISTS = 'X'.
  ELSE.
    LW_KFILE_EXISTS = space.
  ENDIF.
  CLOSE DATASET lw_server_file_path.
  " Check data file Exist on Application Server
  CLEAR: LW_RFILE_EXISTS.
  lw_server_file_path = GW_RFILE_SERVER.
  OPEN DATASET lw_server_file_path FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc = 0.
    LW_RFILE_EXISTS = 'X'.
  ELSE.
    LW_RFILE_EXISTS = space.
  ENDIF.
  CLOSE DATASET lw_server_file_path.

  IF LW_KFILE_EXISTS = 'X' AND LW_RFILE_EXISTS = 'X'.
    CONCATENATE 'Cofile' GW_KFILE_SERVER 'and data file' GW_RFILE_SERVER
                'exist on Application Server. Do you want to override ?'
           INTO LW_TEXT_QUESTION SEPARATED BY SPACE.
  ELSEIF LW_KFILE_EXISTS = 'X' AND LW_RFILE_EXISTS = ''.
    CONCATENATE 'Cofile' GW_KFILE_SERVER
                'exists on Application Server. Do you want to override ?'
           INTO LW_TEXT_QUESTION SEPARATED BY SPACE.
  ELSEIF LW_KFILE_EXISTS = '' AND LW_RFILE_EXISTS = 'X'.
    CONCATENATE 'Data file' GW_RFILE_SERVER
                'exists on Application Server. Do you want to override ?'
           INTO LW_TEXT_QUESTION SEPARATED BY SPACE.
  ENDIF.

  IF LW_KFILE_EXISTS <> '' AND LW_RFILE_EXISTS <> ''.
    LW_QUESTION = 'T'.
    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        TITLEBAR       = 'Override confirmation'
        TEXT_QUESTION  = LW_TEXT_QUESTION
        ICON_BUTTON_1  = 'icon_booking_ok'
      IMPORTING
        ANSWER         = LW_QUESTION
      EXCEPTIONS
        TEXT_NOT_FOUND = 1
        OTHERS         = 2.
    IF LW_QUESTION = '0'.
      MESSAGE 'Cancel action' TYPE 'S'.
      EXIT.
    ENDIF.
  ENDIF.

  " Upload cofile with ASCII file type
  CALL FUNCTION 'C13Z_FILE_UPLOAD_ASCII'
    EXPORTING
      I_FILE_FRONT_END   = GW_KFILE_LOCAL
      I_FILE_APPL        = GW_KFILE_SERVER
      I_FILE_OVERWRITE   = 'X'
    IMPORTING
      E_FLG_OPEN_ERROR   = LW_FLG_OPEN_ERROR
      E_OS_MESSAGE       = LW_OS_MESSAGE
    EXCEPTIONS
      FE_FILE_NOT_EXISTS = 1
      FE_FILE_READ_ERROR = 2
      AP_NO_AUTHORITY    = 3
      AP_FILE_OPEN_ERROR = 4
      AP_FILE_EXISTS     = 5
      AP_CONVERT_ERROR   = 6
      OTHERS             = 7.

  IF SY-SUBRC <> 0.
    CONCATENATE 'Can not open cofile' GW_KFILE_LOCAL 'for upload.' LW_OS_MESSAGE INTO GW_MESSAGE_OUTPUT SEPARATED BY SPACE.
    MESSAGE GW_MESSAGE_OUTPUT TYPE 'E'.
  ELSE.
    CONCATENATE 'Upload cofile to' GW_KFILE_SERVER 'successfully' INTO GW_MESSAGE_OUTPUT SEPARATED BY SPACE.
    MESSAGE GW_MESSAGE_OUTPUT TYPE 'I'.
  ENDIF.

  " Upload data file with BIN file type
  CALL FUNCTION 'ZC13Z_FILE_UPLOAD_BINARY'
    EXPORTING
      I_FILE_FRONT_END   = GW_RFILE_LOCAL
      I_FILE_APPL        = GW_RFILE_SERVER
      I_FILE_OVERWRITE   = 'X'
    IMPORTING
      E_FLG_OPEN_ERROR   = LW_FLG_OPEN_ERROR
      E_OS_MESSAGE       = LW_OS_MESSAGE
    EXCEPTIONS
      FE_FILE_NOT_EXISTS = 1
      FE_FILE_READ_ERROR = 2
      AP_NO_AUTHORITY    = 3
      AP_FILE_OPEN_ERROR = 4
      AP_FILE_EXISTS     = 5
      AP_CONVERT_ERROR   = 6
      OTHERS             = 7.

  IF SY-SUBRC <> 0.
    CONCATENATE 'Can not open data file' GW_RFILE_LOCAL 'for upload.'
                LW_OS_MESSAGE
           INTO GW_MESSAGE_OUTPUT SEPARATED BY SPACE.
    MESSAGE GW_MESSAGE_OUTPUT TYPE 'E'.
  ELSE.
    CONCATENATE 'Upload data file to' GW_RFILE_SERVER 'successfully'
           INTO GW_MESSAGE_OUTPUT SEPARATED BY SPACE.
    MESSAGE GW_MESSAGE_OUTPUT TYPE 'I'.
  ENDIF.
ENDFORM.                    " UPLOAD_PROCESSING
