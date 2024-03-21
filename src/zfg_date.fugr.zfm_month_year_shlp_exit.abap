FUNCTION ZFM_MONTH_YEAR_SHLP_EXIT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     VALUE(SHLP) TYPE  SHLP_DESCR
*"     VALUE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"--------------------------------------------------------------------
DATA:
    LS_SELMONTH     TYPE ZST_MONTH_YEAR,
    LT_SELMONTH     TYPE TABLE OF ZST_MONTH_YEAR.

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      ACTUAL_MONTH                     = SY-DATUM(6)
    IMPORTING
      SELECTED_MONTH                   = LS_SELMONTH-MONTH
    EXCEPTIONS
      FACTORY_CALENDAR_NOT_FOUND       = 1
      HOLIDAY_CALENDAR_NOT_FOUND       = 2
      MONTH_NOT_FOUND                  = 3
      OTHERS                           = 4.
  IF SY-SUBRC IS INITIAL AND LS_SELMONTH-MONTH IS NOT INITIAL.
    LS_SELMONTH-YEAR = LS_SELMONTH-MONTH(4).
    CLEAR: LT_SELMONTH.
    APPEND LS_SELMONTH TO LT_SELMONTH.
    CALL FUNCTION 'F4UT_RESULTS_MAP'
      EXPORTING
        SOURCE_STRUCTURE   = 'ZST_MONTH_YEAR'
      TABLES
        SHLP_TAB           = SHLP_TAB
        RECORD_TAB         = RECORD_TAB
        SOURCE_TAB         = LT_SELMONTH
      CHANGING
        SHLP               = SHLP
        CALLCONTROL        = CALLCONTROL
      EXCEPTIONS
        ILLEGAL_STRUCTURE  = 1
        OTHERS             = 2.
  ENDIF.
  CALLCONTROL-STEP = 'RETURN'.
* EXIT immediately, if you do not want to handle this step
  IF CALLCONTROL-STEP <> 'SELONE'   AND
     CALLCONTROL-STEP <> 'SELECT'   AND
     CALLCONTROL-STEP <> 'PRESEL1'  AND
     CALLCONTROL-STEP <> 'DISP'     AND
     CALLCONTROL-STEP <> 'RETURN'.
    EXIT.
  ENDIF.
* STEP SELECT    (Select values)
* This step may be used to overtake the data selection completely.
* To skip the standard seletion, you should return 'DISP' as following
* step in CALLCONTROL-STEP.
* Normally RECORD_TAB should be filled after this step.
* Standard function module F4UT_RESULTS_MAP may be very helpfull in this
* step.
  IF CALLCONTROL-STEP = 'SELECT'.
  ENDIF.
* STEP DISP     (Display values)
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
  IF CALLCONTROL-STEP = 'DISP'.
  ENDIF.





ENDFUNCTION.
