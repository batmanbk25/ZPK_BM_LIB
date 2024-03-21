FUNCTION ZFM_SCREEN_PAI.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_STRUCT) TYPE  ANY
*"     REFERENCE(I_CPROG) TYPE  CPROG DEFAULT SY-CPROG
*"     REFERENCE(I_CPROG_DATA) TYPE  CPROG DEFAULT SY-CPROG
*"     REFERENCE(I_DYNNR) TYPE  DYNNR DEFAULT SY-DYNNR
*"     REFERENCE(I_AUTO_STOP) TYPE  XMARK DEFAULT 'X'
*"     REFERENCE(I_INITIAL) TYPE  XMARK OPTIONAL
*"     REFERENCE(I_NO_CHECK) TYPE  XMARK OPTIONAL
*"     REFERENCE(I_WARN_REQUIRED) TYPE  XMARK OPTIONAL
*"     VALUE(I_CONFIG_PROG) TYPE  SY-REPID OPTIONAL
*"  EXPORTING
*"     REFERENCE(T_ERR_FIELD) TYPE  ZTT_ERR_FIELD
*"     REFERENCE(E_ERROR) TYPE  XMARK
*"--------------------------------------------------------------------
DATA: LT_SCR_CHKSTEP  TYPE  ZTT_SCR_CHKSTEP.

*----------------------------------------------------*
* Clear show mesage class
  CLEAR: GW_MSG_SHOWED.

* Assign data
  ASSIGN I_STRUCT TO <FS_STRUCT>.

* Prepare field status
  PERFORM PREPARE_FIELD_STATUS USING I_CPROG
                               CHANGING I_CONFIG_PROG.

* Preapare check steps
  PERFORM PREPARE_PROG_STEP_SCR USING I_CONFIG_PROG
                                      I_CPROG_DATA
                                      I_DYNNR
                                CHANGING LT_SCR_CHKSTEP.

* Process fields
  CALL FUNCTION 'ZFM_SCREEN_FIELD_PROCESS'
    EXPORTING
      T_FIELD         = GT_FIELD_DB
      I_CPROG_DATA    = I_CPROG_DATA
      I_CPROG         = I_CPROG
      I_AUTO_STOP     = I_AUTO_STOP
      I_DYNNR         = I_DYNNR
      I_INITIAL       = I_INITIAL
      I_NO_CHECK      = I_NO_CHECK
      I_WARN_REQUIRED = I_WARN_REQUIRED
      T_SCR_CHKSTEP   = LT_SCR_CHKSTEP
    IMPORTING
      T_ERR_FIELD     = T_ERR_FIELD
      E_ERROR         = E_ERROR.





ENDFUNCTION.
