FUNCTION ZC13Z_RAWDATA_READ.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_FILE) TYPE  RCGIEDIAL-IEFILE
*"  EXPORTING
*"     VALUE(E_FILE_SIZE) TYPE  DRAO-ORLN
*"     VALUE(E_LINES) TYPE  I
*"  TABLES
*"      E_RCGREPFILE_TAB STRUCTURE  RCGREPFILE
*"  EXCEPTIONS
*"      NO_PERMISSION
*"      OPEN_FAILED
*"      READ_ERROR
*"      PATH_ERROR
*"--------------------------------------------------------------------
TYPE-POOLS SABC .
* lokal data -----------------------------------------------------------
* Begin Correction 23.11.2010 1505368 ********************
  DATA: L_LOG_FILENAME   TYPE FILEINTERN,
        L_STACK_TAB      TYPE SYS_CALLST,
        L_STACK_WA       TYPE SYS_CALLS.
* End Correction 23.11.2010 1505368 **********************

  DATA : L_LEN LIKE SY-TABIX.
  DATA : L_FILENAME LIKE  AUTHB-FILENAME.
* Begin Correction 20.11.2005 899632 *******************
  DATA L_SUBRC LIKE SY-SUBRC.
* End Correction 20.11.2005 899632 *********************


* function body --------------------------------------------------------

* assign value
  L_FILENAME = I_FILE.

** check the authority for file
*  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
*       EXPORTING
**           PROGRAM          =
*            ACTIVITY         = SABC_ACT_READ
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
*
*  CASE sy-cprog.
*     WHEN 'RC1IMPPG'.
*      IF ( I_LOG_FILENAME NE LC_LOG_FILENAME_IMP_PHR_2  AND
*           I_LOG_FILENAME NE LC_LOG_FILENAME_IMP_SUB_2  AND
*           I_LOG_FILENAME NE LC_LOG_FILENAME_IMP_SRC_2  AND
*           I_LOG_FILENAME NE LC_LOG_FILENAME_IMP_PROP_2 AND
*           I_LOG_FILENAME NE LC_LOG_FILENAME_IMP_REP_2 AND
*           I_LOG_FILENAME NE LC_LOG_FILENAME_IMP_TEMPL_2 ).
*
*          CALL FUNCTION 'SYSTEM_CALLSTACK'
*            EXPORTING
*              MAX_LEVEL          = 2
*            IMPORTING
*              ET_CALLSTACK       = l_stack_tab .
*
*          READ TABLE l_stack_tab INTO l_stack_Wa INDEX 2.
*          IF ( sy-subrc = 0 ).
*            IF l_stack_wa-progname = 'SAPLC14S' OR
*               l_stack_wa-progname = 'SAPLC14SX' OR
*               l_stack_wa-progname = 'SAPLCVE9'.
*               l_log_filename = space.
*            ELSE.
*              sy-subrc = 1.
*            ENDIF.
*
*          ENDIF.
*
*          IF sy-subrc = 1.
*            MESSAGE I153(C$) WITH SY-CPROG SY-REPID SY-SUBRC
*                         'C13Z_RAWDATA_WRITE'.
**           interner System-Fehler! (&1 &2 &3 &4)
*            RAISE OTHERS.
*          ENDIF.
*        MESSAGE I153(C$) WITH SY-CPROG SY-REPID SY-SUBRC
*                         'C13Z_RAWDATA_READ'.
**       interner System-Fehler! (&1 &2 &3 &4)
*        RAISE PATH_ERROR.
*      ELSE.
*        L_LOG_FILENAME = I_LOG_FILENAME.
*      ENDIF.
*    WHEN 'SAPLC13E'.
*      l_log_filename = LC_LOG_FILENAME_IMP_TEMPL_2.
*    WHEN 'SAPLC13G'.
*      l_log_filename = LC_LOG_FILENAME_IMP_REP_2.
*    WHEN 'RC1TCG3Z' OR
*         'RC1TCG3Y'.
*      l_log_filename = LC_LOGICAL_FILENAME_FTAPPL_2.
*    WHEN 'SAPLC14S'.
**     already tested in function group
*      l_log_filename = space.
*
*    WHEN OTHERS.
*     MESSAGE I153(C$) WITH SY-CPROG SY-REPID SY-SUBRC
*                          'C13Z_RAWDATA_READ'.
**     interner System-Fehler! (&1 &2 &3 &4)
*     EXIT.
*  ENDCASE.

** validate physical filename against logical filename
** if logical filename is given
*  IF ( L_LOG_FILENAME NE SPACE ).
*    CALL FUNCTION 'FILE_VALIDATE_NAME'
*      EXPORTING
*        LOGICAL_FILENAME  = L_LOG_FILENAME
*      CHANGING
*        PHYSICAL_FILENAME = I_FILE
*      EXCEPTIONS
*        OTHERS            = 1.
*
*    IF SY-SUBRC <> 0.
*      MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
*        WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*      RAISE PATH_ERROR.
*    ENDIF.
*  ENDIF.
** End Correction 24.09.2010 1505368 ********************

* read the raw-file from the appl.server
* Begin Correction 20.11.2005 899632 *******************
  CLEAR L_SUBRC.
  CATCH SYSTEM-EXCEPTIONS OPEN_DATASET_NO_AUTHORITY = 1
                          DATASET_TOO_MANY_FILES = 2
                          OTHERS = 4.
    OPEN DATASET I_FILE FOR INPUT IN BINARY MODE.
    L_SUBRC = SY-SUBRC.
  ENDCATCH.
  IF SY-SUBRC <> 0 OR
      L_SUBRC <> 0.
    RAISE OPEN_FAILED.
  ENDIF.
* End Correction 20.11.2005 899632 *********************

* Begin Correction 21.03.2005 816266 *******************
  CATCH SYSTEM-EXCEPTIONS DATASET_READ_ERROR = 11
                          OTHERS = 12.
    DO.
    CLEAR L_LEN.
    CLEAR E_RCGREPFILE_TAB.
    READ DATASET I_FILE INTO E_RCGREPFILE_TAB-ORBLK LENGTH L_LEN.
    IF SY-SUBRC <> 0.
* Begin Correction 20.11.2005 899632 *******************
      IF L_LEN > 0.
* End Correction 20.11.2005 899632 *********************
        E_FILE_SIZE = E_FILE_SIZE + L_LEN.
        APPEND E_RCGREPFILE_TAB.
      ENDIF.
      EXIT.
    ENDIF.
    E_FILE_SIZE = E_FILE_SIZE + L_LEN.
    APPEND E_RCGREPFILE_TAB.
  ENDDO.
  ENDCATCH.
  IF SY-SUBRC > 10.
    RAISE READ_ERROR.
  ENDIF.
* End Correction 31.03.2005 816266 *********************

  DESCRIBE TABLE E_RCGREPFILE_TAB LINES E_LINES.

* Begin Correction 20.11.2005 899632 *******************
  CATCH SYSTEM-EXCEPTIONS DATASET_CANT_CLOSE = 1
                          OTHERS = 4.
    CLOSE DATASET I_FILE.
  ENDCATCH.
  IF NOT SY-SUBRC IS INITIAL.
*  but there wasn't any error at the reading of the data
  ENDIF.
* End Correction 20.11.2005 899632 *********************





ENDFUNCTION.
