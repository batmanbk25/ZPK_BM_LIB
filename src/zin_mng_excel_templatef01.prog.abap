*&---------------------------------------------------------------------*
*&  Include           ZIN_MNG_EXCEL_TEMPLATEF01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  0000_MAIN_PROC
*&---------------------------------------------------------------------*
*       Main process
*----------------------------------------------------------------------*
FORM 0000_MAIN_PROC.
* Get list of program template
  PERFORM 0010_GET_PROG_TEMPLATE.

* Check status of excel file on App.Server
  PERFORM 0020_CHECK_FILE_STATUS.

* Show data
  PERFORM 0030_SHOW_DATA.

ENDFORM.                    " 0000_MAIN_PROC

*&---------------------------------------------------------------------*
*&      Form  0010_GET_PROG_TEMPLATE
*&---------------------------------------------------------------------*
*       Get prog template
*----------------------------------------------------------------------*
FORM 0010_GET_PROG_TEMPLATE .
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_PROG_EXCEL
    FROM ZTB_PROG
   WHERE CFEX1S = GC_XMARK
      OR CFEXMS = GC_XMARK.

ENDFORM.                    " 0010_GET_PROG_TEMPLATE

*&---------------------------------------------------------------------*
*&      Form  0020_CHECK_FILE_STATUS
*&---------------------------------------------------------------------*
*       Check status of excel file on App.Server
*----------------------------------------------------------------------*
FORM 0020_CHECK_FILE_STATUS.
  DATA:
    LW_MESSAGE              TYPE TEXT100.
  FIELD-SYMBOLS:
    <LF_PROG_EXCEL>         TYPE ZST_BM_PROG_EXCEL.

  LOOP AT GT_PROG_EXCEL ASSIGNING <LF_PROG_EXCEL>.
*   Open to check Logical file exists
    OPEN DATASET <LF_PROG_EXCEL>-LOGICAL_FILE
      FOR INPUT MESSAGE LW_MESSAGE IN BINARY MODE.
*   If open success then file exists
    IF SY-SUBRC IS INITIAL.
      <LF_PROG_EXCEL>-UPLOADED = GC_XMARK.
*     nothing to do
    ELSE.
      CLEAR: <LF_PROG_EXCEL>-UPLOADED.
    ENDIF.
    CLOSE DATASET <LF_PROG_EXCEL>-LOGICAL_FILE.
  ENDLOOP.

ENDFORM.                    " 0020_CHECK_FILE_STATUS

*&---------------------------------------------------------------------*
*&      Form  0030_SHOW_DATA
*&---------------------------------------------------------------------*
*       Show data
*----------------------------------------------------------------------*
FORM 0030_SHOW_DATA .
  CALL SCREEN 0100.
ENDFORM.                    " 0030_SHOW_DATA

*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'ZGS_100'.
  SET TITLEBAR 'ZGT_100'.

  PERFORM 100_PBO.
ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  100_PAI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE 100_PAI INPUT.
  CALL FUNCTION 'ZFM_SCR_SIMPLE_FC_PROCESS'.
  CALL METHOD GO_ALV_FILE->CHECK_CHANGED_DATA.

  CASE SY-UCOMM.
    WHEN GC_FC_SETFOLD.
      PERFORM 100_PROCESS_FC_SETFOLD.
    WHEN GC_FC_IMPORT.
      PERFORM 100_PROCESS_FC_IMPORT.
    WHEN GC_FC_EXPORT.
      PERFORM 100_PROCESS_FC_EXPORT.
    WHEN GC_FC_REMAP.
      PERFORM 100_PROCESS_FC_REMAP.
    WHEN GC_FC_SELALL.
      PERFORM 100_PROCESS_FC_SELALL.
    WHEN GC_FC_SELNONE.
      PERFORM 100_PROCESS_FC_SELNONE.
    WHEN GC_FC_REBUILD.
      PERFORM 100_PROCESS_FC_REBUILD.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " 100_PAI  INPUT

*&---------------------------------------------------------------------*
*&      Form  100_PROCESS_FC_IMPORT
*&---------------------------------------------------------------------*
*       Import file
*----------------------------------------------------------------------*
FORM 100_PROCESS_FC_IMPORT .
  FIELD-SYMBOLS:
    <LF_PROG_EXCEL>       TYPE ZST_BM_PROG_EXCEL.

* Upload files
  LOOP AT GT_PROG_EXCEL ASSIGNING <LF_PROG_EXCEL>
    WHERE SELECTED = GC_XMARK AND PHYSICFILE IS NOT INITIAL.
    CALL FUNCTION 'ZC13Z_FILE_UPLOAD_BINARY'
      EXPORTING
        I_FILE_FRONT_END         = <LF_PROG_EXCEL>-PHYSICFILE
        I_FILE_APPL              = <LF_PROG_EXCEL>-LOGICAL_FILE
        I_FILE_OVERWRITE         = GC_XMARK
      IMPORTING
        E_OS_MESSAGE             = <LF_PROG_EXCEL>-MESSAGE
      EXCEPTIONS
        FE_FILE_NOT_EXISTS       = 1
        FE_FILE_READ_ERROR       = 2
        AP_NO_AUTHORITY          = 3
        AP_FILE_OPEN_ERROR       = 4
        AP_FILE_EXISTS           = 5
        AP_CONVERT_ERROR         = 6
        OTHERS                   = 7.
    IF SY-SUBRC <> 0.
      <LF_PROG_EXCEL>-MTYPE       = GC_MTYPE_E.
    ELSE.
      <LF_PROG_EXCEL>-UPLOADED    = GC_XMARK.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " 100_PROCESS_FC_IMPORT

*&---------------------------------------------------------------------*
*&      Form  9000_GET_LIST_FILES
*&---------------------------------------------------------------------*
*       Get list physical file
*----------------------------------------------------------------------*
FORM 9000_GET_LIST_FILES
  CHANGING  LPT_FILE_TABLE   TYPE RSTT_T_FILES
            LPW_FOLDER       TYPE STRING.

  DATA:
    LW_FULLPATH           TYPE STRING,
    LW_FOLDER             TYPE STRING,
    LS_FILE_TABLE         TYPE FILE_INFO,
    LT_FILE_TABLE         TYPE TABLE OF FILE_INFO,
    LW_COUNT              TYPE I,
    LW_TITLE              TYPE STRING,
    LW_RC                 TYPE I.
  FIELD-SYMBOLS:
    <LF_FILE_TABLE>       TYPE FILE_INFO.

  LW_TITLE              = TEXT-001.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_BROWSE
    EXPORTING
      WINDOW_TITLE         = LW_TITLE
      INITIAL_FOLDER       = LPW_FOLDER
    CHANGING
      SELECTED_FOLDER      = LPW_FOLDER
    EXCEPTIONS
      NOT_SUPPORTED_BY_GUI = 1
      ERROR_NO_GUI         = 2
      CNTL_ERROR           = 3
      OTHERS               = 4.
  IF SY-SUBRC IS NOT INITIAL OR LPW_FOLDER IS INITIAL.
    CLEAR: LPT_FILE_TABLE, LPW_FOLDER, RCGFILETR-FTFRONT.
    RETURN.
  ENDIF.

  CLEAR: LPT_FILE_TABLE.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_LIST_FILES
    EXPORTING
      DIRECTORY                   = LPW_FOLDER
      FILTER                      = '*.xls'
      FILES_ONLY                  = GC_XMARK
    CHANGING
      FILE_TABLE                  = LPT_FILE_TABLE
      COUNT                       = LW_COUNT
    EXCEPTIONS
      CNTL_ERROR                  = 1
      DIRECTORY_LIST_FILES_FAILED = 2
      WRONG_PARAMETER             = 3
      ERROR_NO_GUI                = 4
      NOT_SUPPORTED_BY_GUI        = 5
      OTHERS                      = 6.

  RCGFILETR-FTFRONT = LW_FOLDER = LPW_FOLDER.

*  CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_SET_CURRENT
*    EXPORTING
*      CURRENT_DIRECTORY            = LW_FOLDER
*    CHANGING
*      RC                           = LW_RC
*    EXCEPTIONS
*      OTHERS                       = 5.


ENDFORM.                    " 9000_GET_LIST_FILES

*&---------------------------------------------------------------------*
*&      Form  100_PROCESS_FC_SETFOLD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 100_PROCESS_FC_SETFOLD .
* Get list files
  PERFORM 9000_GET_LIST_FILES
    CHANGING  GT_PHYSIC_FILE
              GW_FOLDER.

* Mapping physical files and logical files
  PERFORM 9000_MAPPING_FILES.
ENDFORM.                    " 100_PROCESS_FC_SETFOLD

*&---------------------------------------------------------------------*
*&      Form  9000_MAPPING_FILES
*&---------------------------------------------------------------------*
*       Mapping files
*----------------------------------------------------------------------*
FORM 9000_MAPPING_FILES .
  DATA:
    LW_FOLDER             TYPE STRING,
    LW_FULLPATH           TYPE STRING,
    LS_FILE_TABLE         TYPE FILE_INFO.
  FIELD-SYMBOLS:
    <LF_PROG_EXCEL>       TYPE ZST_BM_PROG_EXCEL.

  CHECK GT_PHYSIC_FILE IS NOT INITIAL.

* Map physical files and logical files
  LOOP AT GT_PROG_EXCEL ASSIGNING <LF_PROG_EXCEL>
    WHERE LOGICAL_FILE IS NOT INITIAL.
*   Find physical file with name same logical file
    LOOP AT GT_PHYSIC_FILE INTO LS_FILE_TABLE
      WHERE FILENAME CS <LF_PROG_EXCEL>-LOGICAL_FILE.
      CONCATENATE GW_FOLDER
                  LS_FILE_TABLE-FILENAME
             INTO <LF_PROG_EXCEL>-PHYSICFILE SEPARATED BY GW_SEPARATOR.
      EXIT.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " 9000_MAPPING_FILES

*&---------------------------------------------------------------------*
*&      Form  100_PROCESS_FC_REMAP
*&---------------------------------------------------------------------*
*       Remapping physical files and logical files
*----------------------------------------------------------------------*
FORM 100_PROCESS_FC_REMAP .
* Mapping physical files and logical files
  PERFORM 9000_MAPPING_FILES.

ENDFORM.                    " 100_PROCESS_FC_REMAP

*&---------------------------------------------------------------------*
*&      Form  100_PROCESS_FC_EXPORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 100_PROCESS_FC_EXPORT.
  DATA:
    LW_FOLDER             TYPE STRING,
    LW_FULLPATH           TYPE STRING,
    LS_FILE_TABLE         TYPE FILE_INFO,
    LW_TITLE              TYPE STRING.
  FIELD-SYMBOLS:
    <LF_PROG_EXCEL>       TYPE ZST_BM_PROG_EXCEL.

  LW_TITLE = TEXT-002.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_BROWSE
    EXPORTING
      WINDOW_TITLE         = LW_TITLE
    CHANGING
      SELECTED_FOLDER      = LW_FOLDER
    EXCEPTIONS
      NOT_SUPPORTED_BY_GUI = 1
      ERROR_NO_GUI         = 2
      CNTL_ERROR           = 3
      OTHERS               = 4.
  CHECK SY-SUBRC IS INITIAL AND LW_FOLDER IS NOT INITIAL.

  LOOP AT GT_PROG_EXCEL ASSIGNING <LF_PROG_EXCEL>
    WHERE UPLOADED = GC_XMARK.
    CLEAR: LW_FULLPATH.
*   Get fullpath file name
    CONCATENATE LW_FOLDER <LF_PROG_EXCEL>-LOGICAL_FILE
           INTO LW_FULLPATH SEPARATED BY GW_SEPARATOR.
    IF <LF_PROG_EXCEL>-LOGICAL_FILE NS '.xls'.
      CONCATENATE LW_FULLPATH '.xls'
             INTO LW_FULLPATH.
    ENDIF.

*   Download to frontend
    CALL FUNCTION 'ZC13Z_FILE_DOWNLOAD_BINARY'
      EXPORTING
        I_FILE_FRONT_END          = LW_FULLPATH
        I_FILE_APPL               = <LF_PROG_EXCEL>-LOGICAL_FILE
        I_FILE_OVERWRITE          = GC_XMARK
      EXCEPTIONS
        FE_FILE_OPEN_ERROR        = 1
        FE_FILE_EXISTS            = 2
        FE_FILE_WRITE_ERROR       = 3
        AP_NO_AUTHORITY           = 4
        AP_FILE_OPEN_ERROR        = 5
        AP_FILE_EMPTY             = 6
        OTHERS                    = 7.
  ENDLOOP.

ENDFORM.                    " 100_PROCESS_FC_EXPORT

*&---------------------------------------------------------------------*
*&      Form  0000_INIT_PROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0000_INIT_PROC .
  IF GW_SEPARATOR IS INITIAL.
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>GET_FILE_SEPARATOR
      CHANGING
        FILE_SEPARATOR       = GW_SEPARATOR
      EXCEPTIONS
        NOT_SUPPORTED_BY_GUI = 1
        ERROR_NO_GUI         = 2
        CNTL_ERROR           = 3
        OTHERS               = 4.
  ENDIF.
ENDFORM.                    " 0000_INIT_PROC

*&---------------------------------------------------------------------*
*&      Form  100_PBO
*&---------------------------------------------------------------------*
*       PBO for screen 100
*----------------------------------------------------------------------*
FORM 100_PBO .
  DATA:
    LS_VARIANT        TYPE DISVARIANT,
    LS_LAYOUT         TYPE LVC_S_LAYO.
  FIELD-SYMBOLS:
    <LF_PROG_EXCEL>   TYPE ZST_BM_PROG_EXCEL.

  IF GO_ALV_FILE IS INITIAL.
    LS_VARIANT-REPORT = SY-REPID.
    LS_VARIANT-HANDLE = '1'.
    LS_LAYOUT-CWIDTH_OPT = 'X'.

    CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR'
      EXPORTING
        I_CUS_CONTROL_NAME         = 'CUS_ALV_FILE'
        I_STRUCTURE_NAME           = 'ZST_BM_PROG_EXCEL'
        IS_VARIANT                 = LS_VARIANT
        IS_LAYOUT                  = LS_LAYOUT
      IMPORTING
        E_ALV_GRID                 = GO_ALV_FILE
*       E_DOCKING                  =
*       E_CUS_CONTAINER            =
      CHANGING
        IT_OUTTAB                  = GT_PROG_EXCEL
*       IT_FIELDCATALOG            =
              .
  ELSE.
    CALL METHOD GO_ALV_FILE->REFRESH_TABLE_DISPLAY.
  ENDIF.
ENDFORM.                    " 100_PBO

*&---------------------------------------------------------------------*
*&      Form  100_PROCESS_FC_SELALL
*&---------------------------------------------------------------------*
*       Select all
*----------------------------------------------------------------------*
FORM 100_PROCESS_FC_SELALL .
  DATA:
    LS_PROG_EXCEL         TYPE ZST_BM_PROG_EXCEL.

  LS_PROG_EXCEL-SELECTED = GC_XMARK.
  MODIFY GT_PROG_EXCEL FROM LS_PROG_EXCEL TRANSPORTING SELECTED
    WHERE SELECTED = SPACE.

ENDFORM.                    " 100_PROCESS_FC_SELALL

*&---------------------------------------------------------------------*
*&      Form  100_PROCESS_FC_SELNONE
*&---------------------------------------------------------------------*
*       Deselect all
*----------------------------------------------------------------------*
FORM 100_PROCESS_FC_SELNONE .
  DATA:
    LS_PROG_EXCEL         TYPE ZST_BM_PROG_EXCEL.

  MODIFY GT_PROG_EXCEL FROM LS_PROG_EXCEL TRANSPORTING SELECTED
    WHERE SELECTED = SPACE.

ENDFORM.                    " 100_PROCESS_FC_SELNONE

*&---------------------------------------------------------------------*
*&      Form  100_PROCESS_FC_REBUILD
*&---------------------------------------------------------------------*
*       Rebuild template excel
*----------------------------------------------------------------------*
FORM 100_PROCESS_FC_REBUILD .
  DATA:
    LT_PROG_EXCEL_1SHEET  TYPE TABLE OF ZTB_PROG,
    LT_PROG_EXCEL_MSHEET  TYPE TABLE OF ZTB_PROG,
    LS_PROG_EXCEL         TYPE ZTB_PROG.

  SELECT DISTINCT MANDT REPORT
    FROM ZTB_EXCEL_LAYOUT
    INTO TABLE LT_PROG_EXCEL_1SHEET.
  LOOP AT LT_PROG_EXCEL_1SHEET INTO LS_PROG_EXCEL.
    UPDATE ZTB_PROG SET CFEX1S = GC_XMARK
     WHERE REPID = LS_PROG_EXCEL-REPID.
  ENDLOOP.

  SELECT DISTINCT MANDT REPID
    FROM ZTB_EXCEL_SHEETS
    INTO TABLE LT_PROG_EXCEL_MSHEET.
  LOOP AT LT_PROG_EXCEL_MSHEET INTO LS_PROG_EXCEL.
    UPDATE ZTB_PROG SET CFEXMS = GC_XMARK
     WHERE REPID = LS_PROG_EXCEL-REPID.
  ENDLOOP.
  COMMIT WORK.

* Get list of program template
  PERFORM 0010_GET_PROG_TEMPLATE.

* Check status of excel file on App.Server
  PERFORM 0020_CHECK_FILE_STATUS.

ENDFORM.                    " 100_PROCESS_FC_REBUILD
