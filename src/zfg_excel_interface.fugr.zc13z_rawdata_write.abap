FUNCTION ZC13Z_RAWDATA_WRITE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_FILE) LIKE  RCGIEDIAL-IEFILE
*"     VALUE(I_FILE_SIZE) TYPE  I DEFAULT 0
*"     VALUE(I_LINES) TYPE  I DEFAULT 0
*"     VALUE(I_FILE_OVERWRITE) TYPE  ESP1_BOOLEAN DEFAULT ESP1_TRUE
*"     VALUE(I_LOG_FILENAME) TYPE  FILEINTERN DEFAULT SPACE
*"  TABLES
*"      I_RCGREPFILE_TAB STRUCTURE  RCGREPFILE
*"  EXCEPTIONS
*"      NO_PERMISSION
*"      OPEN_FAILED
*"      AP_FILE_EXISTS
*"      CLOSE_FAILED
*"      WRITE_FAILED
*"--------------------------------------------------------------------
* lokal data -----------------------------------------------------------

  DATA L_LEN TYPE I.
  DATA L_ALL_LINES_LEN TYPE I.
* Begin Correction 23.11.2010 1505368 ********************
  DATA: L_LOG_FILENAME TYPE FILEINTERN,
        l_stack_tab      TYPE sys_callst,
        l_stack_wa       TYPE sys_calls.
* End Correction 23.11.2010 1505368 **********************
  DATA L_DIFF_LEN TYPE I.
  DATA L_FILENAME LIKE  AUTHB-FILENAME.
* Begin Correction 20.11.2005 899632 *******************
  DATA L_SUBRC LIKE SY-SUBRC.
* End Correction 20.11.2005 899632 *********************

* function body --------------------------------------------------------
* init
  L_FILENAME = I_FILE.

** check the authority for file
*  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
*       EXPORTING
**           PROGRAM          =
*            ACTIVITY         = SABC_ACT_WRITE
** Authority Check allows right now only 60 Character
*            FILENAME         = L_FILENAME(60)
*       EXCEPTIONS
*            NO_AUTHORITY     = 1
*            ACTIVITY_UNKNOWN = 2
*            OTHERS           = 3.
*  IF SY-SUBRC <> 0.
*    RAISE NO_PERMISSION.
*  ENDIF.

** Begin Correction 24.09.2010 1505368 ********************
*  CASE SY-CPROG.
*    WHEN 'RC1EXPPG'.
*       IF ( I_LOG_FILENAME NE LC_LOG_FILENAME_EXP_PHR_2  AND
*            I_LOG_FILENAME NE LC_LOG_FILENAME_EXP_SUB_2  AND
*            I_LOG_FILENAME NE LC_LOG_FILENAME_EXP_SRC_2  AND
*            I_LOG_FILENAME NE LC_LOG_FILENAME_EXP_PROP_2 AND
*            I_LOG_FILENAME NE LC_LOG_FILENAME_EXP_TEMPL_2 ).
*
** Begin Correction 10.02.2011 1552798  ********************
*          MESSAGE I153(C$) WITH SY-CPROG SY-REPID SY-SUBRC
*                       'C13Z_RAWDATA_WRITE'.
**         interner System-Fehler! (&1 &2 &3 &4)
*          RAISE OPEN_FAILED.
** End Correction 10.02.2011 1552798  ********************
*        ELSE.
*          L_LOG_FILENAME = I_LOG_FILENAME.
*        ENDIF.
*    WHEN 'RC1TCG3Z' OR
*         'RC1TCG3Y'.
*      L_LOG_FILENAME = LC_LOGICAL_FILENAME_FTAPPL_2.
*    WHEN 'SAPLC14S'.
*      L_LOG_FILENAME = LC_LOG_FILENAME_EXP_TEMPL_2.
** Begin Correction 10.02.2011 1552798  ********************
*    WHEN 'RC1IMPPG'.
*      L_LOG_FILENAME = LC_LOG_FILENAME_IMP_REP_2.
*    WHEN 'RCVDEVEN' OR
*         'SAPLCVE9'.
** End Correction 10.02.2011 1552798  ********************
*      L_LOG_FILENAME = LC_LOGICAL_DOKX_EXPPATH.
*    WHEN OTHERS.
*      MESSAGE I153(C$) WITH SY-CPROG SY-REPID SY-SUBRC
*                           'C13Z_RAWDATA_WRITE'.
**     interner System-Fehler! (&1 &2 &3 &4)
*      RAISE OPEN_FAILED.
*  ENDCASE.
*
** Begin Correction 10.02.2011 1552798  ********************
** validate physical filename against logical filename
*  CALL FUNCTION 'FILE_VALIDATE_NAME'
*    EXPORTING
*      logical_filename  = L_LOG_FILENAME
*    CHANGING
*      physical_filename = I_FILE
*    EXCEPTIONS
*      OTHERS            = 1.
*
*  IF ( sy-subrc <> 0 AND
*     L_LOG_FILENAME <> LC_LOGICAL_DOKX_EXPPATH ).
*    MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
*      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    RAISE OPEN_FAILED.
*  ENDIF.
** End Correction 10.02.2011 1552798  ********************
** End Correction 24.09.2010 1505368 ********************

* check if file exists if we arn't allowed to overwrite file
  IF I_FILE_OVERWRITE = SPACE."FALSE.
* Begin Correction 20.11.2005 899632 *******************
    CLEAR L_SUBRC.
    CATCH SYSTEM-EXCEPTIONS OPEN_DATASET_NO_AUTHORITY = 1
                            DATASET_TOO_MANY_FILES = 2
                            OTHERS = 4.
      OPEN DATASET I_FILE FOR INPUT IN BINARY MODE.
      L_SUBRC = SY-SUBRC.
    ENDCATCH.
    IF L_SUBRC <> 0.
*     nothing
    ELSE.
      CATCH SYSTEM-EXCEPTIONS OTHERS = 4.
        CLOSE DATASET I_FILE.
      ENDCATCH.
      RAISE AP_FILE_EXISTS.
    ENDIF.
    CATCH SYSTEM-EXCEPTIONS OTHERS = 4.
      CLOSE DATASET I_FILE.
    ENDCATCH.
* End Correction 20.11.2005 899632 *********************
  ENDIF.

* open dataset for writing
* Begin Correction 20.11.2005 899632 *******************
  CLEAR L_SUBRC.
  CATCH SYSTEM-EXCEPTIONS OPEN_DATASET_NO_AUTHORITY = 1
                          DATASET_TOO_MANY_FILES = 2
                          OTHERS = 4.
    OPEN DATASET I_FILE FOR OUTPUT IN BINARY MODE.
    L_SUBRC = SY-SUBRC.
  ENDCATCH.
  IF NOT SY-SUBRC IS INITIAL OR
     NOT  L_SUBRC IS INITIAL.
    RAISE OPEN_FAILED.
* End Correction 20.11.2005 899632 *********************
  ELSE.
    L_LEN = LG_MAX_LEN.

*   If no I_FILE_SIZE then I_LINES has to be 0.

    IF I_FILE_SIZE = 0.
       I_LINES = 0.
    ENDIF.

    LOOP AT I_RCGREPFILE_TAB.
*     last line is shorter perhaps
      IF SY-TABIX = I_LINES.
        L_ALL_LINES_LEN = LG_MAX_LEN * ( I_LINES - 1 ).
        L_DIFF_LEN = I_FILE_SIZE - L_ALL_LINES_LEN.
        L_LEN = L_DIFF_LEN.
      ENDIF.
*     write data in file
* Begin Correction 20.11.2005 899632 *******************
      CATCH SYSTEM-EXCEPTIONS DATASET_WRITE_ERROR = 1
                              OTHERS = 4.
        TRANSFER I_RCGREPFILE_TAB TO I_FILE LENGTH L_LEN.
      ENDCATCH.
* End Correction 20.11.2005 899632 *********************
* Begin Correction 0682669 20.11.2003 **********************************
      IF NOT SY-SUBRC IS INITIAL.
         RAISE WRITE_FAILED.
      ENDIF.
* End Correction 0682669 20.11.2003 ************************************

    ENDLOOP.
  ENDIF.

* close the dataset
* Begin Correction 20.11.2005 899632 *******************
  CATCH SYSTEM-EXCEPTIONS DATASET_CANT_CLOSE = 1
                          OTHERS = 4.
    CLOSE DATASET I_FILE.
  ENDCATCH.
* End Correction 20.11.2005 899632 *********************
* Begin Correction 0682669 20.11.2003 **********************************
  IF NOT SY-SUBRC IS INITIAL.
    RAISE CLOSE_FAILED.
  ENDIF.
* End Correction 0682669 20.11.2003 ************************************





ENDFUNCTION.
