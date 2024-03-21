FUNCTION ZFM_SCREEN_FIELD_PROCESS.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_CPROG_DATA) TYPE  CPROG DEFAULT SY-CPROG
*"     REFERENCE(I_CPROG) TYPE  CPROG DEFAULT SY-CPROG
*"     REFERENCE(I_DYNNR) TYPE  DYNNR DEFAULT SY-DYNNR
*"     REFERENCE(T_FIELD) TYPE  ZTT_FIELD_DB OPTIONAL
*"     REFERENCE(I_AUTO_STOP) TYPE  XMARK DEFAULT 'X'
*"     VALUE(I_INITIAL) TYPE  XMARK OPTIONAL
*"     VALUE(I_NO_CHECK) TYPE  XMARK OPTIONAL
*"     REFERENCE(I_ALERT_1_ERROR) TYPE  XMARK DEFAULT 'X'
*"     REFERENCE(I_WARN_REQUIRED) TYPE  XMARK OPTIONAL
*"     REFERENCE(I_PROCESS_TYPE) TYPE  ZDD_SCR_PRCTY OPTIONAL
*"     VALUE(T_SCR_CHKSTEP) TYPE  ZTT_SCR_CHKSTEP OPTIONAL
*"  EXPORTING
*"     REFERENCE(T_ERR_FIELD) TYPE  ZTT_ERR_FIELD
*"     REFERENCE(E_ERROR) TYPE  XMARK
*"--------------------------------------------------------------------
DATA: LS_FIELD      TYPE ZTB_FIELD_DB,    " Field info need check value
        LT_FIELD      TYPE ZTT_FIELD_DB,    " List of field info  to check
        LT_FIELD_LOOP TYPE ZTT_FIELD_DB,    " List of field info  to check
        LW_PG_FIELD   TYPE CHAR100,         " Program field: ([PgName])FName
        LW_LOOPSTR    TYPE TABNM,           " Loop Structure name
        LW_FNAME      TYPE FIELDNAME.       " Field name

  FIELD-SYMBOLS: <LFT_LOOPTAB> TYPE ANY TABLE.  " Loop table of table control

*----------------------------------------------------*
* Init
  CLEAR: GT_ERR_FIELD[], T_ERR_FIELD, E_ERROR.
  LT_FIELD = T_FIELD.
  DELETE LT_FIELD WHERE REPID <> I_CPROG OR DYNNR <> I_DYNNR.

* Prepare field for process
  PERFORM PREPARE_FIELD_LIST CHANGING LT_FIELD
                                      LT_FIELD_LOOP.

* When init, no check data
  IF I_INITIAL = GC_XMARK.
    I_NO_CHECK = I_INITIAL.
  ENDIF.

* Process field on screen
  LOOP AT LT_FIELD INTO LS_FIELD.
* Init
    IF LS_FIELD-LOOPTAB IS INITIAL.
* Process each field on screen
      PERFORM PAI_SCR_PROCESS_EACH_FIELD USING  LS_FIELD
                                                I_INITIAL
                                                I_NO_CHECK
                                                I_WARN_REQUIRED
                                                0
                                                T_SCR_CHKSTEP
                                                I_CPROG_DATA.
    ELSE.
* Process each field on table control
      PERFORM PAI_SCR_PROCESS_FIELD_TAB USING LS_FIELD
                                              LT_FIELD_LOOP
                                              I_INITIAL
                                              I_NO_CHECK
                                              T_SCR_CHKSTEP
                                              I_WARN_REQUIRED
                                              I_CPROG_DATA.
    ENDIF.
  ENDLOOP.

* Export error fields to memory name:
* "[ProgramName][ScreenNo]_ERR_FIELDS"
  PERFORM SCR_ERROR_FIELDS_EXPORT
    USING I_CPROG I_DYNNR GT_ERR_FIELD I_AUTO_STOP I_ALERT_1_ERROR.

  T_ERR_FIELD = GT_ERR_FIELD.
  IF I_AUTO_STOP IS INITIAL AND GT_ERR_FIELD IS NOT INITIAL.
    E_ERROR = GC_XMARK.
  ENDIF.





ENDFUNCTION.
