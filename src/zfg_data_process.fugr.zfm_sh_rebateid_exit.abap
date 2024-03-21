FUNCTION ZFM_SH_REBATEID_EXIT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------

* EXIT immediately, if you do not want to handle this step
  IF CALLCONTROL-STEP <> 'SELONE' AND
     CALLCONTROL-STEP <> 'SELECT' AND
     " AND SO ON
     CALLCONTROL-STEP <> 'DISP'.
    EXIT.
  ENDIF.

*"----------------------------------------------------------------------
* STEP SELONE  (Select one of the elementary searchhelps)
*"----------------------------------------------------------------------
* This step is only called for collective searchhelps. It may be used
* to reduce the amount of elementary searchhelps given in SHLP_TAB.
* The compound searchhelp is given in SHLP.
* If you do not change CALLCONTROL-STEP, the next step is the
* dialog, to select one of the elementary searchhelps.
* If you want to skip this dialog, you have to return the selected
* elementary searchhelp in SHLP and to change CALLCONTROL-STEP to
* either to 'PRESEL' or to 'SELECT'.
  IF CALLCONTROL-STEP = 'SELONE'.
*   PERFORM SELONE .........
    EXIT.
  ENDIF.

*"----------------------------------------------------------------------
* STEP PRESEL  (Enter selection conditions)
*"----------------------------------------------------------------------
* This step allows you, to influence the selection conditions either
* before they are displayed or in order to skip the dialog completely.
* If you want to skip the dialog, you should change CALLCONTROL-STEP
* to 'SELECT'.
* Normaly only SHLP-SELOPT should be changed in this step.
  IF CALLCONTROL-STEP = 'PRESEL'.
*   PERFORM PRESEL ..........
    EXIT.
  ENDIF.
*"----------------------------------------------------------------------
* STEP SELECT    (Select values)
*"----------------------------------------------------------------------
* This step may be used to overtake the data selection completely.
* To skip the standard seletion, you should return 'DISP' as following
* step in CALLCONTROL-STEP.
* Normally RECORD_TAB should be filled after this step.
* Standard function module F4UT_RESULTS_MAP may be very helpfull in this
* step.
  IF CALLCONTROL-STEP = 'SELECT'.
*    DATA : T_FIELDS LIKE TABLE OF SHLP_TAB-FIELDDESCR.
*    DATA : W_FIELDS LIKE LINE OF SHLP_TAB-FIELDDESCR.
*    IF SY-UNAME = 'CT.ABAP'.
*      BREAK-POINT.
*    ENDIF.
*    SELECT *
*    FROM ZTB_RB_HEADER
*    INTO TABLE @DATA(LT_REBATE).
*
*    CALL FUNCTION 'ZFM_AUTH_USER_VEN'
*      EXPORTING
*        IT_INPUT  = LT_REBATE
*      IMPORTING
*        IT_OUTPUT = LT_REBATE.
*
*    LOOP AT SHLP_TAB.
*      LOOP AT SHLP_TAB-FIELDDESCR INTO W_FIELDS.
*        DATA : L_FNAME TYPE DFIES-LFIELDNAME.
*        L_FNAME = W_FIELDS-FIELDNAME.
*        CALL FUNCTION 'F4UT_PARAMETER_RESULTS_PUT'
*          EXPORTING
*            PARAMETER         = W_FIELDS-FIELDNAME
**           OFF_SOURCE        = 0
**           LEN_SOURCE        = 0
**           VALUE             =
*            FIELDNAME         = L_FNAME
*          TABLES
*            SHLP_TAB          = SHLP_TAB
*            RECORD_TAB        = RECORD_TAB
*            SOURCE_TAB        = LT_REBATE
*          CHANGING
*            SHLP              = SHLP
*            CALLCONTROL       = CALLCONTROL
*          EXCEPTIONS
*            PARAMETER_UNKNOWN = 1
*            OTHERS            = 2.
*      ENDLOOP.
*    ENDLOOP.
*   PERFORM STEP_SELECT TABLES RECORD_TAB SHLP_TAB
*                       CHANGING SHLP CALLCONTROL RC.
*   IF RC = 0.
*     CALLCONTROL-STEP = 'DISP'.
*   ELSE.
*     CALLCONTROL-STEP = 'EXIT'.
*   ENDIF.
    EXIT. "Don't process STEP DISP additionally in this call.
  ENDIF.
*"----------------------------------------------------------------------
* STEP DISP     (Display values)
*"----------------------------------------------------------------------
* This step is called, before the selected data is displayed.
* You can e.g. modify or reduce the data in RECORD_TAB
* according to the users authority.
* If you want to get the standard display dialog afterwards, you
* should not change CALLCONTROL-STEP.
* If you want to overtake the dialog on you own, you must return
* the following values in CALLCONTROL-STEP:
* - "RETURN" if one line was selected. The selected line must be
*   the only record left in RECORD_TAB. The corresponding fields of
*   this line are entered into the screen.
* - "EXIT" if the values request should be aborted
* - "PRESEL" if you want to return to the selection dialog
* Standard function modules F4UT_PARAMETER_VALUE_GET and
* F4UT_PARAMETER_RESULTS_PUT may be very helpfull in this step.
  IF CALLCONTROL-STEP = 'DISP' AND RECORD_TAB[] IS NOT INITIAL.
*    TYPES: BEGIN OF LTY_REBATE,
*             MANDT TYPE ZTB_RB_HEADER-MANDT,
*             RBID  TYPE ZTB_RB_HEADER-RBID,
*             RBDES TYPE ZTB_RB_HEADER-RBDES,
*             EXTNR TYPE ZTB_RB_HEADER-EXTNR,
*             DATAB TYPE ZTB_RB_HEADER-DATAB,
*             DATBI TYPE ZTB_RB_HEADER-DATBI,
*             LIFNR TYPE ZTB_RB_HEADER-LIFNR,
*           END OF LTY_REBATE.
*    DATA: LS_REBATE TYPE LTY_REBATE.
*
*    " Kiểm tra phân quyền
*    SELECT LIFNR
*    INTO TABLE @DATA(LT_USER_VEN)
*    FROM ZTB_MM_USER_VEN
*    WHERE BNAME = @SY-UNAME.
*    IF SY-SUBRC NE 0.
*      DELETE RECORD_TAB[].
*    ELSE.
*      SORT LT_USER_VEN BY LIFNR.
*      " Kiểm tra nếu user đc phân quyền full thì ko check
*      READ TABLE LT_USER_VEN TRANSPORTING NO FIELDS
*        WITH KEY LIFNR = SPACE
*        BINARY SEARCH.
*      IF SY-SUBRC = 0.
*        EXIT.
*      ELSE.
*        LOOP AT RECORD_TAB.
*          DATA(LW_TABIX) = SY-TABIX.
*          LS_REBATE-LIFNR = RECORD_TAB-STRING+408(10).
*          READ TABLE LT_USER_VEN TRANSPORTING NO FIELDS
*            WITH KEY LIFNR = LS_REBATE-LIFNR
*            BINARY SEARCH.
*          IF SY-SUBRC NE 0.
*            DELETE RECORD_TAB[] INDEX LW_TABIX.
*          ENDIF.
*        ENDLOOP.
*      ENDIF.
*    ENDIF.
*   PERFORM AUTHORITY_CHECK TABLES RECORD_TAB SHLP_TAB
*                           CHANGING SHLP CALLCONTROL.
    EXIT.
  ENDIF.
ENDFUNCTION.
