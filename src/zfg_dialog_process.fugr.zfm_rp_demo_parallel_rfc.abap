FUNCTION ZFM_RP_DEMO_PARALLEL_RFC.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  EXCEPTIONS
*"      NO_CONFIG
*"      NO_FIELD_SHEETNAME
*"--------------------------------------------------------------------
DATA:
    LS_EXCEL_FILE_OUT TYPE ZST_EXCEL_FILE_OUT,
    LW_FOLDER_PATH    TYPE STRING,
    LW_MSG            TYPE ZDD_MESSAGE_01 VALUE SPACE,
    LS_TASK           TYPE ZST_BM_TASK,
    LW_TASKNAME(4)    TYPE N,
    LS_EXFILE_DATA    TYPE ZST_EXFILE_DATA.
  FIELD-SYMBOLS:
    <LFT_FILEDATA>    TYPE TABLE.

*  CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_BROWSE
*    CHANGING
*      SELECTED_FOLDER      = LW_FOLDER_PATH
*    EXCEPTIONS
*      CNTL_ERROR           = 1
*      ERROR_NO_GUI         = 2
*      NOT_SUPPORTED_BY_GUI = 3
*      OTHERS               = 4.

  GS_MULTITHREAD-CLASSNAME      = '562'.
  GS_MULTITHREAD-CLASSNAME      = 'MT_GRP'.
* Initial tasks
  CALL FUNCTION 'SPBT_INITIALIZE'
    EXPORTING
      GROUP_NAME                      = GS_MULTITHREAD-CLASSNAME
    IMPORTING
      MAX_PBT_WPS                     = GS_MULTITHREAD-WP_TOTAL
      FREE_PBT_WPS                    = GS_MULTITHREAD-WP_AVAIL
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
      RETURN.
      MESSAGE E836(BT). "Group not defined.
    WHEN 2.
      RETURN.
      "System error.  Stop and check system log for error
      "analysis.
    WHEN 3.
      RETURN.
      "Programming error.  Stop and correct program.
      MESSAGE E833(BT). "PBT environment was already initialized.
    WHEN 4.
      RETURN.
      "No resources:
      MESSAGE E837(BT). "All servers currently busy.
    WHEN 5.
      RETURN.
      "Check your servers, network, operation modes.
    WHEN 6 OR 0.

  ENDCASE.

  LS_TASK-TASKNAME              = 0001.
  GS_MULTITHREAD-SEND_JOBS      = 0.
  GS_MULTITHREAD-TOTALJOBS      = 10.

  DO.
    LW_TASKNAME = LS_TASK-TASKNAME.
*    CALL FUNCTION 'RFC_SYSTEM_INFO'
    CALL FUNCTION 'ZFM_RFC_SYSTEM_INFO'
      STARTING NEW TASK LW_TASKNAME
    DESTINATION IN GROUP GS_MULTITHREAD-CLASSNAME
    PERFORMING RECEIVE_DEMO_PARALLEL_RFC ON END OF TASK
    EXCEPTIONS
      COMMUNICATION_FAILURE = 1 MESSAGE LW_MSG
      SYSTEM_FAILURE        = 2  MESSAGE LW_MSG
      RESOURCE_FAILURE      = 3.  "MUST handle this exception.
    CASE SY-SUBRC.
      WHEN 0.
        CLEAR: LS_TASK-MESSAGE.
        CALL FUNCTION 'SPBT_GET_PP_DESTINATION'
        IMPORTING
          RFCDEST = LS_TASK-RFCDEST
        EXCEPTIONS
          OTHERS  = 1.

*       Append task to list
        APPEND LS_TASK TO GS_MULTITHREAD-TASKLIST.

*       Set new task
        LS_TASK-TASKNAME              = LS_TASK-TASKNAME + 1.
        GS_MULTITHREAD-SEND_JOBS      = GS_MULTITHREAD-SEND_JOBS + 1.
        GS_MULTITHREAD-TOTALJOBS      = GS_MULTITHREAD-TOTALJOBS - 1.
        IF GS_MULTITHREAD-TOTALJOBS   = 0.
          EXIT.
        ENDIF.
      WHEN 1 OR 2.
        LS_TASK-MESSAGE = LW_MSG.
        APPEND LS_TASK TO GS_MULTITHREAD-ERRORTASKS.
        "Remove server from list of available servers.
        CALL FUNCTION 'SPBT_GET_PP_DESTINATION'
        EXPORTING
          RFCDEST   = LS_TASK-RFCDEST
        EXCEPTIONS
          OTHERS    = 1.
        "Then remove from list of available servers.
        CALL FUNCTION 'SPBT_DO_NOT_USE_SERVER'
          IMPORTING
            SERVERNAME                  = LS_TASK-RFCDEST
          EXCEPTIONS
            INVALID_SERVER_NAME         = 1
            NO_MORE_RESOURCES_LEFT      = 2
            PBT_ENV_NOT_INITIALIZED_YET = 3
            OTHERS                      = 4.
        CLEAR: LW_MSG.
      WHEN 3.
        "No resources, wait and repeat CALL FUNCTION until processed
        MESSAGE I837(BT) INTO LS_TASK-MESSAGE.
        APPEND LS_TASK TO GS_MULTITHREAD-ERRORTASKS.
        IF GS_MULTITHREAD-EXCP_FLAG = SPACE.
          GS_MULTITHREAD-EXCP_FLAG = 'X'. "Mark RESOURCE_FAILURE
          "Wait up to 1 second.
          WAIT UNTIL
            GS_MULTITHREAD-RECV_JOBS >= GS_MULTITHREAD-SEND_JOBS
            UP TO '1' SECONDS.
        ELSE.
          "Second times RESOURCE_FAILURE, Wait up to 5 second.
          WAIT UNTIL
            GS_MULTITHREAD-RECV_JOBS >= GS_MULTITHREAD-SEND_JOBS
            UP TO '5' SECONDS.
          IF SY-SUBRC = 0.
            CLEAR GS_MULTITHREAD-EXCP_FLAG.
          ELSE.  "No replies
            "Endless loop handling
          ENDIF.
        ENDIF.
      WHEN OTHERS.
        LS_TASK-TASKNAME              = LS_TASK-TASKNAME + 1.
    ENDCASE.
  ENDDO.

* Wait for end of job:  replies from all RFC tasks.
* Receive remaining asynchronous replies
  WAIT UNTIL GS_MULTITHREAD-RECV_JOBS >= GS_MULTITHREAD-SEND_JOBS.
  SORT GS_MULTITHREAD-TASKLIST BY RECV_INDEX.
  LOOP AT GS_MULTITHREAD-TASKLIST INTO LS_TASK.
    WRITE:/  'Received task:', LS_TASK-TASKNAME COLOR 1,
    30  'Destination: ', LS_TASK-RFCDEST COLOR 1.
  ENDLOOP.





ENDFUNCTION.
