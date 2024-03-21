FUNCTION ZFM_ALV_EXCL_FC_FM.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     REFERENCE(T_EXCL_FC) TYPE  SLIS_T_EXTAB
*"--------------------------------------------------------------------
DATA: LS_FUNCTION  TYPE SLIS_EXTAB.

*----------------------------------------------------*
  LS_FUNCTION-FCODE = '&RNT_PREV'.
  APPEND LS_FUNCTION TO T_EXCL_FC.
  LS_FUNCTION-FCODE = '&VEXCEL'.
  APPEND LS_FUNCTION TO T_EXCL_FC.
  LS_FUNCTION-FCODE = '&AQW'.
  APPEND LS_FUNCTION TO T_EXCL_FC.
  LS_FUNCTION-FCODE = '%PC'.
  APPEND LS_FUNCTION TO T_EXCL_FC.
  LS_FUNCTION-FCODE = '%SL'.
  APPEND LS_FUNCTION TO T_EXCL_FC.
  LS_FUNCTION-FCODE = '&INFO'.
  APPEND LS_FUNCTION TO T_EXCL_FC.
  LS_FUNCTION-FCODE = '&GRAPH'.
  APPEND LS_FUNCTION TO T_EXCL_FC.





ENDFUNCTION.
