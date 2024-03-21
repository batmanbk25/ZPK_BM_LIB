FUNCTION ZFM_JBCF_JOB_CREATE_SINGLE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_JBCF_JOB_ALL) TYPE  ZST_JBCF_JOB
*"  EXPORTING
*"     REFERENCE(E_JOBCOUNT) TYPE  TBTCJOB-JOBCOUNT
*"  EXCEPTIONS
*"      JOB_CREATE_ERROR
*"      JOB_STEP_CREATE_ERROR
*"--------------------------------------------------------------------
DATA:
    LS_JBCF_JSTEP         TYPE ZTB_JBCF_JSTEP,
    LW_BTCSTEPCNT         TYPE BTCSTEPCNT,
    LW_JOB_RELEASED       TYPE XMARK.
  CHECK I_JBCF_JOB_ALL IS NOT INITIAL.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
*     JOBGROUP               = ' '
      JOBNAME                = I_JBCF_JOB_ALL-JOBNAME
      JOBCLASS               = I_JBCF_JOB_ALL-JOBCLASS
    IMPORTING
      JOBCOUNT               = E_JOBCOUNT
*   CHANGING
*     RET                    =
    EXCEPTIONS
      CANT_CREATE_JOB        = 1
      INVALID_JOB_DATA       = 2
      JOBNAME_MISSING        = 3
      OTHERS                 = 4
            .
  IF SY-SUBRC <> 0.
    RAISE JOB_CREATE_ERROR.
  ENDIF.

  LOOP AT I_JBCF_JOB_ALL-STEPS INTO LS_JBCF_JSTEP.
    CALL FUNCTION 'JOB_SUBMIT'
      EXPORTING
*       ARCPARAMS                         =
        AUTHCKNAM                         = SY-UNAME
        JOBCOUNT                          = E_JOBCOUNT
        JOBNAME                           = I_JBCF_JOB_ALL-JOBNAME
        LANGUAGE                          = SY-LANGU
        REPORT                            = LS_JBCF_JSTEP-BTCPROG
        VARIANT                           = LS_JBCF_JSTEP-VARIANT
      IMPORTING
        STEP_NUMBER                       = LW_BTCSTEPCNT
      EXCEPTIONS
        BAD_PRIPARAMS                     = 1
        BAD_XPGFLAGS                      = 2
        INVALID_JOBDATA                   = 3
        JOBNAME_MISSING                   = 4
        JOB_NOTEX                         = 5
        JOB_SUBMIT_FAILED                 = 6
        LOCK_FAILED                       = 7
        PROGRAM_MISSING                   = 8
        PROG_ABAP_AND_EXTPG_SET           = 9
        OTHERS                            = 10
              .
    IF SY-SUBRC <> 0.
      RAISE JOB_STEP_CREATE_ERROR.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
*     AT_OPMODE                         = ' '
*     AT_OPMODE_PERIODIC                = ' '
*     CALENDAR_ID                       = ' '
*     EVENT_ID                          = ' '
*     EVENT_PARAM                       = ' '
*     EVENT_PERIODIC                    = ' '
      JOBCOUNT                          = E_JOBCOUNT
      JOBNAME                           = I_JBCF_JOB_ALL-JOBNAME
*     LASTSTRTDT                        = NO_DATE
*     LASTSTRTTM                        = NO_TIME
      PRDDAYS                           = I_JBCF_JOB_ALL-PRD_DAYS
      PRDHOURS                          = I_JBCF_JOB_ALL-PRD_HOURS
      PRDMINS                           = I_JBCF_JOB_ALL-PRD_MINS
      PRDMONTHS                         = I_JBCF_JOB_ALL-PRD_MONTHS
      PRDWEEKS                          = I_JBCF_JOB_ALL-PRD_WEEKS
*     PREDJOB_CHECKSTAT                 = ' '
*     PRED_JOBCOUNT                     = ' '
*     PRED_JOBNAME                      = ' '
      SDLSTRTDT                         = I_JBCF_JOB_ALL-BTCSDATE
      SDLSTRTTM                         = I_JBCF_JOB_ALL-BTCSTIME
*     STARTDATE_RESTRICTION             = BTC_PROCESS_ALWAYS
*     STRTIMMED                         = ' '
*     TARGETSYSTEM                      = ' '
*     START_ON_WORKDAY_NOT_BEFORE       = SY-DATUM
*     START_ON_WORKDAY_NR               = 0
*     WORKDAY_COUNT_DIRECTION           = 0
*     RECIPIENT_OBJ                     =
*     TARGETSERVER                      = ' '
*     DONT_RELEASE                      = ' '
*     TARGETGROUP                       = ' '
*     DIRECT_START                      =
    IMPORTING
      JOB_WAS_RELEASED                  = LW_JOB_RELEASED
*   CHANGING
*     RET                               =
    EXCEPTIONS
      CANT_START_IMMEDIATE              = 1
      INVALID_STARTDATE                 = 2
      JOBNAME_MISSING                   = 3
      JOB_CLOSE_FAILED                  = 4
      JOB_NOSTEPS                       = 5
      JOB_NOTEX                         = 6
      LOCK_FAILED                       = 7
      INVALID_TARGET                    = 8
      OTHERS                            = 9
            .
  IF SY-SUBRC <> 0.
    RAISE JOB_CREATE_ERROR.
  ENDIF.





ENDFUNCTION.
