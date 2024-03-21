*&---------------------------------------------------------------------*
*&  Include           ZIN_EXCEL_INTERFACE_XLWB
*&---------------------------------------------------------------------*

INCLUDE ZXLWB_INCLUDE .
*----------------------------------------------------------------------*
*       CLASS LCL_BM_VIEWER DEFINITION
*----------------------------------------------------------------------*
* Redefinition XLWB viewer
*----------------------------------------------------------------------*
CLASS LCL_BM_VIEWER DEFINITION INHERITING FROM LCL_VIEWER .
  PUBLIC SECTION.
    METHODS:
      APPL_SAVEAS REDEFINITION.
ENDCLASS.                    "LCL_BM_VIEWER DEFINITION
TYPES:
  TY_MODE             TYPE CHAR2 .
CONSTANTS:
  BEGIN OF C_MODE ,
    WORKBENCH         TYPE TY_MODE VALUE 'WB' ,
    VIEWER            TYPE TY_MODE VALUE 'VR' ,
  END   OF C_MODE .
DATA:
  GR_WORKBENCH        TYPE REF TO LCL_WORKBENCH ,
  GR_VIEWER           TYPE REF TO LCL_BM_VIEWER ,
*  gr_viewer           TYPE REF TO lcl_viewer ,
  GV_MODE             TYPE TY_MODE ,
  GV_VIEWER_BUNDLE_COLLECT
                      TYPE FLAG,
* TuanBA add to set default file name when save
  GW_DEFAULT_FILE     TYPE STRING.

*----------------------------------------------------------------------*
*       CLASS LCL_BM_VIEWER IMPLEMENTATION
*----------------------------------------------------------------------*
* Redefinition XLWB viewer
*----------------------------------------------------------------------*
CLASS LCL_BM_VIEWER IMPLEMENTATION .
  METHOD APPL_SAVEAS .
    DATA:
      LW_FILENAME             TYPE STRING,
      LW_EXTENSION             TYPE STRING,
      LW_FILEPATH             TYPE STRING,
      LW_USERACTION           TYPE I,
      LW_FULLPATH             TYPE STRING,
      LW_COMMANDLINE          TYPE STRING,
      LW_URLPATH              TYPE CHAR300.

*   If no default file, process as original
    IF GW_DEFAULT_FILE IS INITIAL.
      SUPER->APPL_SAVEAS( ).
    ELSE.
      SPLIT GW_DEFAULT_FILE AT '.' INTO LW_FILENAME LW_EXTENSION.
      TRANSLATE LW_EXTENSION TO LOWER CASE.

*     Call dialog to save file
      CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
        EXPORTING
          DEFAULT_FILE_NAME    = LW_FILENAME
          DEFAULT_EXTENSION    = LW_EXTENSION
          FILE_FILTER          = GC_EXCEL_FILTER
        CHANGING
          FILENAME             = GW_DEFAULT_FILE
          PATH                 = LW_FILEPATH
          FULLPATH             = LW_FULLPATH
          USER_ACTION          = LW_USERACTION
        EXCEPTIONS
          CNTL_ERROR           = 1
          ERROR_NO_GUI         = 2
          NOT_SUPPORTED_BY_GUI = 3
          OTHERS               = 4.
      CHECK LW_USERACTION <> CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL.

*     Save file to Location user choose
      LW_URLPATH = 'FILE://' && LW_FULLPATH.
      CALL METHOD R_EXCELOLE->R_DOCPROXY->SAVE_DOCUMENT_TO_URL
        EXPORTING
          URL = LW_URLPATH.

*     Open file after save
      LW_COMMANDLINE = '"' && LW_FULLPATH && '"'.
      CALL FUNCTION 'WS_EXECUTE'
        EXPORTING
          PROGRAM            = 'EXCEL'
          COMMANDLINE        = LW_COMMANDLINE
        EXCEPTIONS
          FRONTEND_ERROR     = 1
          PROG_NOT_FOUND     = 3
          GUI_REFUSE_EXECUTE = 5
          OTHERS             = 6.
    ENDIF.

  ENDMETHOD .                    "APPL_SAVEAS
ENDCLASS.                    "LCL_BM_VIEWER IMPLEMENTATION
