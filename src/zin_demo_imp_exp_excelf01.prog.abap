*&---------------------------------------------------------------------*
*&  Include           ZIN_DEMO_IMP_EXCELF01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  SELECT_FILE
*&---------------------------------------------------------------------*
*       Select file to import
*----------------------------------------------------------------------*
FORM SELECT_FILE CHANGING LPW_FILENAME TYPE LOCALFILE.
  DATA:
    LT_FILETABLE        TYPE FILETABLE,
    LS_FILETABLE        TYPE FILE_TABLE,
    LW_RC               TYPE I.

  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
    EXPORTING
      WINDOW_TITLE            = 'Choose file'
      DEFAULT_EXTENSION       = 'xls'
      FILE_FILTER             = 'xls||xlsx'
    CHANGING
      FILE_TABLE              = LT_FILETABLE
      RC                      = LW_RC
    EXCEPTIONS
      FILE_OPEN_DIALOG_FAILED = 1
      CNTL_ERROR              = 2
      ERROR_NO_GUI            = 3
      NOT_SUPPORTED_BY_GUI    = 4
      OTHERS                  = 5.
  IF LT_FILETABLE IS NOT INITIAL.
    READ TABLE LT_FILETABLE INTO LS_FILETABLE INDEX 1.
    LPW_FILENAME = LS_FILETABLE-FILENAME.
  ENDIF.

ENDFORM.                    " SELECT_FILE
*&---------------------------------------------------------------------*
*&      Form  IMPORT_FILE
*&---------------------------------------------------------------------*
*       Import data from excel file
*----------------------------------------------------------------------*
FORM IMPORT_FILE.
  DATA:
    LT_EXCEL_MAPPING  TYPE TABLE OF ZST_EXCEL_MAPPING,
    LS_EXCEL_MAPPING  TYPE ZST_EXCEL_MAPPING,
    LT_SHEETROWST     TYPE TABLE OF ZST_SHEET_ROWST,
    LS_SHEETROWST     TYPE ZST_SHEET_ROWST,
    LS_LAYOUT         TYPE LVC_S_LAYO.
  FIELD-SYMBOLS:
    <LF_IMP_DATA>     TYPE ZST_EXCEL_DEMO_L,
    <LF_FIELDCAT>     TYPE LVC_S_FCAT.

  LS_LAYOUT-CWIDTH_OPT = 'X'.

* Get field catelog
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = GC_STRUCTURE_ITM
      I_INTERNAL_TABNAME     = GC_STRUCTURE_ITM
    CHANGING
      CT_FIELDCAT            = GT_FIELDCAT
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

* Mapping field in structure with column in excel
  LOOP AT GT_FIELDCAT ASSIGNING <LF_FIELDCAT>.
    IF <LF_FIELDCAT>-COL_POS > 12.
      <LF_FIELDCAT>-NO_OUT = 'X'.
    ENDIF.
    LS_EXCEL_MAPPING-SHEETNAME = 'Sheet1'.
    LS_EXCEL_MAPPING-FIELDNAME = <LF_FIELDCAT>-FIELDNAME.
    LS_EXCEL_MAPPING-COLUMN    = <LF_FIELDCAT>-COL_POS.
    APPEND LS_EXCEL_MAPPING TO LT_EXCEL_MAPPING.
  ENDLOOP.

* Set row start in each sheet
  LS_SHEETROWST-SHEETNAME = 'Sheet1'.
  LS_SHEETROWST-ROWST     = 3.
  APPEND LS_SHEETROWST TO LT_SHEETROWST.

* Import data
  CALL FUNCTION 'ZFM_FILE_EXCEL_IMP2TAB'
    EXPORTING
      I_LOCALFILE     = P_LOFILE
      T_EXCEL_MAPPING = LT_EXCEL_MAPPING
      T_FIELDCAT      = GT_FIELDCAT
      T_SHEET_ROWST   = LT_SHEETROWST
      I_NEEDOPEN      = 'X'
      I_CLOSEFILE     = 'X'
    IMPORTING
      T_IMPTAB        = GT_IMP_DATA
    EXCEPTIONS
      OPENFILE_ERROR  = 1
      NO_MAPPING      = 2
      READ_DATA_ERROR = 3
      MAPPING_ERROR   = 4
      OTHERS          = 5.

  CALL FUNCTION 'ZFM_PRSC_PRESAVE'
    EXPORTING
      I_REPID       = SY-REPID.

  LOOP AT GT_IMP_DATA ASSIGNING <LF_IMP_DATA>.
    DO 9 TIMES.
      CONCATENATE <LF_IMP_DATA>-DESCR <LF_IMP_DATA>-DESCR
             INTO <LF_IMP_DATA>-DESCR.
    ENDDO.
  ENDLOOP.
ENDFORM.                    " IMPORT_FILE

*&---------------------------------------------------------------------*
*&      Form  EXPORT_FILE
*&---------------------------------------------------------------------*
*       Export data to excel file
*----------------------------------------------------------------------*
FORM EXPORT_FILE.
  DATA:
    LT_MAIN_DATA        TYPE TABLE OF ZST_EXCEL,
    LT_EXCEL_EXPORT     TYPE TABLE OF ZST_EXCEL_EXP,
    LS_EXCEL_EXPORT     TYPE ZST_EXCEL_EXP.

* Get data
  GT_EXP_DATA = GT_IMP_DATA.

* Convert main data
  CALL FUNCTION 'ZFM_FILE_EXCEL_TABLE_CONV_LVC'
    EXPORTING
      I_START_ROW = 11
      I_START_COL = 1
    TABLES
      T_OUTTAB    = GT_EXP_DATA
      T_FIELDCAT  = GT_FIELDCAT
      T_EXCEL     = LT_MAIN_DATA.

* Prepare data
  LS_EXCEL_EXPORT-INSRW = 'X'.          "Insert row when export data
  LS_EXCEL_EXPORT-EXDAT = LT_MAIN_DATA. "Data export
  CLEAR LS_EXCEL_EXPORT-BLDRW.
  APPEND LS_EXCEL_EXPORT TO LT_EXCEL_EXPORT.

* Export data
  CALL FUNCTION 'ZFM_FILE_EXCEL_EXPORT'
    EXPORTING
      I_LOGICALFILE     = GC_LOGICAL_FILE
      T_SQUARE_DATA     = LT_EXCEL_EXPORT
    EXCEPTIONS
      SAVE_TEMPLATE_ERR = 1
      OPEN_FILE_ERR     = 2
      EXPORT_ERR        = 3
      OTHERS            = 4.
ENDFORM.                    "EXPORT_FILE


*&---------------------------------------------------------------------*
*&      Form  EXPORT_FILE2
*&---------------------------------------------------------------------*
*       Export data to using config
*----------------------------------------------------------------------*
FORM EXPORT_FILE2.
  DATA:
    LT_MAIN_DATA        TYPE TABLE OF ZST_EXCEL,
    LT_EXCEL_EXPORT     TYPE TABLE OF ZST_EXCEL_EXP,
    LS_EXCEL_EXPORT     TYPE ZST_EXCEL_EXP.

* Get data
  GS_DATA-TITLE1 = TEXT-001.
  GS_DATA-TITLE2 = TEXT-002.
  GS_DATA-TITLE3 = TEXT-003.
  GS_DATA-DETAIL = GT_IMP_DATA.

  CALL FUNCTION 'ZFM_RP_OUTPUT_EXCEL'
    EXPORTING
      I_TABNAME     = GC_STRUCTURE
      I_DATA        = GS_DATA
      I_LOGICALFILE = GC_LOGICAL_FILE.
ENDFORM.                    "EXPORT_FILE2
* Data declarations
DATA:
  GROUP LIKE RZLLITAB-CLASSNAME VALUE 'MT_GRP',"Parallel process group.
*  GROUP LIKE RZLLITAB-CLASSNAME VALUE ' ',"Parallel process group.
  "SPACE = group default (all servers)
  WP_AVAILABLE TYPE I,            "Number of free work processes
  WP_TOTAL TYPE I,                "Total number of dialog work
  MSG(80) VALUE SPACE,            "Container for error messages
  INFO LIKE RFCSI, C,             "Message text
  JOBS TYPE I VALUE 10,           "Number of parallel jobs
  SND_JOBS TYPE I VALUE 1,        "Work packets sent for processing
  RCV_JOBS TYPE I VALUE 1,        "Work packet replies received
  EXCP_FLAG(1) TYPE C,            "Number of RESOURCE_FAILUREs
  TASKNAME(4) TYPE N VALUE '0001',"Task name
  BEGIN OF TASKLIST OCCURS 10,    "Task administration
    TASKNAME(4) TYPE C,
    RFCDEST  LIKE RFCSI-RFCDEST,
    RFCHOST  LIKE RFCSI-RFCHOST,
  END OF TASKLIST.
*&---------------------------------------------------------------------*
*&      Form  OUTPUT_DATA
*&---------------------------------------------------------------------*
*       Output data
*----------------------------------------------------------------------*
FORM OUTPUT_DATA .
  DATA:
    GT_DATA_SHEET     TYPE ZTT_RP_EXCEL_DEMO,
    GS_DATA_SHEET     TYPE ZST_RP_EXCEL_DEMO,
    LS_EXCEL_FILE_OUT TYPE ZST_EXCEL_FILE_OUT,
    LT_EXCEL_FILE_OUT TYPE TABLE OF ZST_EXCEL_FILE_OUT.

* Get data
  GS_DATA-TITLE1 = TEXT-001.
  GS_DATA-TITLE2 = TEXT-002.
  GS_DATA-TITLE3 = TEXT-003.
  GS_DATA-LOGO   = 'NIKOP'.
  GS_DATA-DETAIL = GT_IMP_DATA.

** Output report
*  CALL FUNCTION 'ZFM_RP_OUTPUT'
*    EXPORTING
*      I_ITEMS_FNAME = 'DETAIL'
*      I_LOGICALFILE = GC_LOGICAL_FILE
*    CHANGING
*      I_DATA        = GS_DATA.
*  RETURN.

*
  IF P_ALV = 'X'.
    CALL FUNCTION 'ZFM_RP_OUTPUT_ALV'
      EXPORTING
        I_RP_DATA     = GS_DATA
        I_ITEMS_FNAME = 'DETAIL'.
  ENDIF.

  IF P_EXC = 'X'.
    IF 1 = 2.
      DO 1000 TIMES.
        APPEND LINES OF GT_IMP_DATA TO GS_DATA-DETAIL.
      ENDDO.
*      CALL FUNCTION 'ZFM_FILE_EXCEL_REPORT_EXPORT'
      CALL FUNCTION 'ZFM_RP_OUTPUT_EXCEL'
*      CALL FUNCTION 'ZFM_RP_OUTPUT_EXCEL_NUM'
        EXPORTING
          I_DATA        = GS_DATA
          I_LOGICALFILE = GC_LOGICAL_FILE
*          I_LARGE_FILE  = 'X'
          .
    ELSEIF 2 = 3.
      GS_DATA_SHEET-SHEETNO   = 1.
      MOVE-CORRESPONDING GS_DATA TO GS_DATA_SHEET.
*      GS_DATA_SHEET-SHEETDATA = GS_DATA.
      APPEND GS_DATA_SHEET TO GT_DATA_SHEET.

      GS_DATA_SHEET-SHEETNO   = 2.
      MOVE-CORRESPONDING GS_DATA TO GS_DATA_SHEET.
      APPEND GS_DATA_SHEET TO GT_DATA_SHEET.

      CALL FUNCTION 'ZFM_RP_OUTPUT_EXCEL_SHEETS'
        EXPORTING
          T_DATA                   = GT_DATA_SHEET
          I_LOGICALFILE            = GC_LOGICAL_FILE
       EXCEPTIONS
         NO_CONFIG                = 1
         OTHERS                   = 2.
    ELSE.
      DO 25000 TIMES.
        APPEND LINES OF GT_IMP_DATA TO GS_DATA-DETAIL.
      ENDDO.
      GS_DATA_SHEET-SHEETNO   = 1.
      MOVE-CORRESPONDING GS_DATA TO GS_DATA_SHEET.
      APPEND GS_DATA_SHEET TO GT_DATA_SHEET.

      GS_DATA_SHEET-SHEETNO   = 2.
      MOVE-CORRESPONDING GS_DATA TO GS_DATA_SHEET.
      APPEND GS_DATA_SHEET TO GT_DATA_SHEET.

      GET REFERENCE OF GT_DATA_SHEET INTO LS_EXCEL_FILE_OUT-FILEDATA.
      LS_EXCEL_FILE_OUT-FILENAME = 'a.xls'.
      APPEND LS_EXCEL_FILE_OUT TO LT_EXCEL_FILE_OUT.

*      GET REFERENCE OF GT_DATA_SHEET INTO LS_EXCEL_FILE_OUT-FILEDATA.
*      LS_EXCEL_FILE_OUT-FILENAME = 'c.xls'.
*      APPEND LS_EXCEL_FILE_OUT TO LT_EXCEL_FILE_OUT.

*      GET REFERENCE OF GT_DATA_SHEET INTO LS_EXCEL_FILE_OUT-FILEDATA.
*      LS_EXCEL_FILE_OUT-FILENAME = 'b.xls'.
*      APPEND LS_EXCEL_FILE_OUT TO LT_EXCEL_FILE_OUT.
*
*      GET REFERENCE OF GT_DATA_SHEET INTO LS_EXCEL_FILE_OUT-FILEDATA.
*      LS_EXCEL_FILE_OUT-FILENAME = 'd.xls'.
*      APPEND LS_EXCEL_FILE_OUT TO LT_EXCEL_FILE_OUT.
*
*      GET REFERENCE OF GT_DATA_SHEET INTO LS_EXCEL_FILE_OUT-FILEDATA.
*      LS_EXCEL_FILE_OUT-FILENAME = 'e.xls'.
*      APPEND LS_EXCEL_FILE_OUT TO LT_EXCEL_FILE_OUT.

      IF 1 = 1.
*      CALL FUNCTION 'ZFM_RP_OUTPUT_EXCEL_FILES'
        CALL FUNCTION 'ZFM_RP_OUTPUT_EXCEL_FILES_MT'
          EXPORTING
            T_EXCEL_FILE_OUT         = LT_EXCEL_FILE_OUT
            I_LOGICALFILE            = GC_LOGICAL_FILE
          EXCEPTIONS
            NO_CONFIG                = 1
            NO_FIELD_SHEETNAME       = 2
            OTHERS                   = 3.
      ELSE.
        CALL FUNCTION 'ZFM_RP_DEMO_PARALLEL_RFC'
          EXCEPTIONS
            NO_CONFIG                = 1
            NO_FIELD_SHEETNAME       = 2
            OTHERS                   = 3.

      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " OUTPUT_DATA
*
* This routine is triggered when an RFC call completes and
* returns.  The routine uses RECEIVE to collect IMPORT and TABLE
* data from the RFC function module.
*
* Note that the WRITE keyword is not supported in asynchronous
* RFC.  If you need to generate a list, then your RFC function
* module should return the list data in an internal table.  You
* can then collect this data and output the list at the conclusion
* of processing.
*
FORM RETURN_INFO USING TASKNAME.

  DATA:  INFO_RFCDEST LIKE TASKLIST-RFCDEST.

  RECEIVE RESULTS FROM FUNCTION 'RFC_SYSTEM_INFO'
  IMPORTING RFCSI_EXPORT = INFO
  EXCEPTIONS
  COMMUNICATION_FAILURE = 1
  SYSTEM_FAILURE  = 2.

  RCV_JOBS = RCV_JOBS + 1.  "Receiving data
  IF SY-SUBRC NE 0.
*  * Handle communication and system failure
    ...
  ELSE.
    READ TABLE TASKLIST WITH KEY TASKNAME = TASKNAME.
    IF SY-SUBRC = 0.  "Register data
      TASKLIST-RFCHOST = INFO-RFCHOST.
      MODIFY TASKLIST INDEX SY-TABIX.
    ENDIF.
  ENDIF.
  ...
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  EXPORT_EXCELS_MT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXPORT_EXCELS_MT.

* Optional call to SBPT_INITIALIZE to check the
* group in which parallel processing is to take place.
* Could be used to optimize sizing of work packets
* work / WP_AVAILABLE).
  CALL FUNCTION 'SPBT_INITIALIZE'
    EXPORTING
      GROUP_NAME                      = GROUP
    IMPORTING
      MAX_PBT_WPS                     = WP_TOTAL
      FREE_PBT_WPS                    = WP_AVAILABLE
    EXCEPTIONS
      INVALID_GROUP_NAME              = 1 "See transaction RZ12
      INTERNAL_ERROR                  = 2 "SAP system error; see  SM21
      PBT_ENV_ALREADY_INITIALIZED     = 3 "FM ALREADY called
      CURRENTLY_NO_RESOURCES_AVAIL    = 4 "No dialog work processes
      NO_PBT_RESOURCES_FOUND          = 5 "No servers in the group
      CANT_INIT_DIFFERENT_PBT_GROUPS  = 6 "You have already initialized
      OTHERS  = 7.
  CASE SY-SUBRC.
*    WHEN 0.
      "Everything’s ok. Optionally set up for optimizing size of
      "work packets.
    WHEN 1.
      "Non-existent group name.  Stop report.
      MESSAGE E836. "Group not defined.
    WHEN 2.
      "System error.  Stop and check system log for error
      "analysis.
    WHEN 3.
      "Programming error.  Stop and correct program.
      MESSAGE E833. "PBT environment was already initialized.
    WHEN 4.
      "No resources: this may be a temporary problem.  You
      "may wish to pause briefly and repeat the call.  Otherwise
      "check your RFC group administration:  Group defined
      "in accordance with your requirements?
      MESSAGE E837. "All servers currently busy.
    WHEN 5.
      "Check your servers, network, operation modes.
    WHEN 6 OR 0.

* Do parallel processing.  Use CALL FUNCTION STARTING NEW TASK
* DESTINATION IN GROUP to call the function module that does the
* work.  Make a call for each record that is to be processed, or
* divide the records into work packets.  In each case, provide the
* set of records as an internal table in the CALL FUNCTION
* keyword (EXPORT, TABLES arguments).
      DO.
        CALL FUNCTION 'RFC_SYSTEM_INFO'
          STARTING NEW TASK TASKNAME
        DESTINATION IN GROUP GROUP  "Group Name in transaction RZ12
        PERFORMING RETURN_INFO ON END OF TASK
        EXCEPTIONS
          COMMUNICATION_FAILURE = 1 MESSAGE MSG
          SYSTEM_FAILURE        = 2  MESSAGE MSG
          RESOURCE_FAILURE      = 3.  "MUST handle this exception.
        CASE SY-SUBRC.
          WHEN 0.
            TASKLIST-TASKNAME = TASKNAME.
            CALL FUNCTION 'SPBT_GET_PP_DESTINATION'
            IMPORTING
              RFCDEST = TASKLIST-RFCDEST
            EXCEPTIONS
              OTHERS  = 1.
            APPEND TASKLIST.
            WRITE: /  'Started task: ', TASKLIST-TASKNAME COLOR 2.
            TASKNAME  = TASKNAME + 1.
            SND_JOBS  = SND_JOBS + 1.
            JOBS      = JOBS - 1.  "Number of existing jobs
            IF JOBS   = 0.
              EXIT.
            ENDIF.
          WHEN 1 OR 2.
            WRITE MSG.
            "Remove server from list of available servers.
            CALL FUNCTION 'SPBT_GET_PP_DESTINATION'
            EXPORTING
              RFCDEST   = TASKLIST-RFCDEST
            EXCEPTIONS
              OTHERS    = 1.
            "Then remove from list of available servers.
            CALL FUNCTION 'SPBT_DO_NOT_USE_SERVER'
              IMPORTING
                SERVERNAME                  = TASKLIST-RFCDEST
              EXCEPTIONS
                INVALID_SERVER_NAME         = 1
                NO_MORE_RESOURCES_LEFT      = 2
                PBT_ENV_NOT_INITIALIZED_YET = 3
                OTHERS                      = 4.
          WHEN 3.
            "No resources, wait and repeat CALL FUNCTION until processed
            MESSAGE I837.
            IF EXCP_FLAG = SPACE.
              EXCP_FLAG = 'X'. "Mark RESOURCE_FAILURE handling.
              "Wait up to 1 second.
              WAIT UNTIL RCV_JOBS >= SND_JOBS UP TO '1' SECONDS.
            ELSE.
              "Second times RESOURCE_FAILURE, Wait up to 5 second.
              WAIT UNTIL RCV_JOBS >= SND_JOBS UP TO '5' SECONDS.
              IF SY-SUBRC = 0.
                CLEAR EXCP_FLAG.
              ELSE.  "No replies
                "Endless loop handling
              ENDIF.
            ENDIF.
        ENDCASE.
      ENDDO.
*
*     Wait for end of job:  replies from all RFC tasks.
*     Receive remaining asynchronous replies
      WAIT UNTIL RCV_JOBS >= SND_JOBS.
      LOOP AT TASKLIST.
        WRITE:/  'Received task:', TASKLIST-TASKNAME COLOR 1,
        30  'Destination: ', TASKLIST-RFCDEST COLOR 1.
      ENDLOOP.

  ENDCASE.
ENDFORM.                    " EXPORT_EXCELS_MT
