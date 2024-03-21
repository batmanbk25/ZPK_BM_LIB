FUNCTION ZFM_DATA_COND_AGG_TO_SET.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(T_CONDITIONS) TYPE  ZTT_BM_FIELD_COND
*"  EXPORTING
*"     REFERENCE(T_COND_SET) TYPE  ZTT_BM_COND_SET
*"----------------------------------------------------------------------

  DATA:
    LS_CONDITION              TYPE ZST_BM_FIELD_COND,
    LS_COND_SET               TYPE ZST_BM_COND_SET,
    LS_TAB_RANGE              TYPE RSDSRANGE_S_SSEL,
    LS_FLD_RANGE              TYPE RSDSFRANGE_S_SSEL,
    LS_RANGE                  TYPE RSDSSELOPT.

  SORT T_CONDITIONS BY CONDID RTABLE RFIELD RANGID .
  LOOP AT T_CONDITIONS INTO LS_CONDITION.
*   Init Condition set
    AT NEW CONDID.
      CLEAR: LS_COND_SET.
      LS_COND_SET-CONDID      = LS_CONDITION-CONDID.
    ENDAT.

*   Init table range
    AT NEW RTABLE.
      CLEAR: LS_TAB_RANGE.
      LS_TAB_RANGE-TABLENAME  = LS_CONDITION-RTABLE.
    ENDAT.

*   Init field range
    AT NEW RFIELD.
      CLEAR: LS_FLD_RANGE.
      LS_FLD_RANGE-FIELDNAME  = LS_CONDITION-RFIELD.
    ENDAT.

*   Collect range values: Sign, Option, Low, High
    LS_RANGE-SIGN             = LS_CONDITION-RSIGN.
    LS_RANGE-OPTION           = LS_CONDITION-ROPTI.
    LS_RANGE-LOW              = LS_CONDITION-RLOW.
    LS_RANGE-HIGH             = LS_CONDITION-RHIGH.
    APPEND LS_RANGE TO LS_FLD_RANGE-SELOPT_T.

*   Complete field range
    AT END OF RFIELD.
      APPEND LS_FLD_RANGE TO LS_TAB_RANGE-FRANGE_T.
    ENDAT.

*   Complete Table range
    AT END OF RTABLE.
      APPEND LS_TAB_RANGE TO LS_COND_SET-TAB_COND.
    ENDAT.

*   Complete condition set
    AT END OF CONDID.
      APPEND LS_COND_SET TO T_COND_SET.
    ENDAT.
  ENDLOOP.

ENDFUNCTION.
