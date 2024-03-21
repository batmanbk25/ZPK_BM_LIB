FUNCTION ZFM_JBCF_CREATE_JOB.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"--------------------------------------------------------------------
DATA:
    LS_JBCF_JOB_ALL     TYPE ZST_JBCF_JOB,
    LW_JOBCOUNT         TYPE TBTCJOB-JOBCOUNT.

  CALL FUNCTION 'ZFM_JBCF_GET_CONFIG'
*   IMPORTING
*     T_JBCF_JOB_ALL       =
            .

  LOOP AT GT_JBCF_JOB_ALL INTO LS_JBCF_JOB_ALL.
    CALL FUNCTION 'ZFM_JBCF_JOB_CREATE_SINGLE'
      EXPORTING
        I_JBCF_JOB_ALL              = LS_JBCF_JOB_ALL
      IMPORTING
        E_JOBCOUNT                  = LW_JOBCOUNT
      EXCEPTIONS
        JOB_CREATE_ERROR            = 1
        JOB_STEP_CREATE_ERROR       = 2
        OTHERS                      = 3.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDLOOP.





ENDFUNCTION.
