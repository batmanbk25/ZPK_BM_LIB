FUNCTION ZFM_BM_DF_STR_CHECK.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_TABNM) TYPE  TABNAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_RETURN) TYPE  BAPIRET2_T
*"     REFERENCE(ET_FIELD_EC) TYPE  ZTT_BM_DF_FIELD_EC
*"  CHANGING
*"     REFERENCE(C_STRUCT)
*"     REFERENCE(C_ROOTSTR) OPTIONAL
*"----------------------------------------------------------------------
  DATA:
    LS_DF_STR                 TYPE ZST_BM_DF_STR.
  FIELD-SYMBOLS:
    <LF_ROOTSTR>              TYPE ANY.

  IF C_ROOTSTR IS INITIAL.
    ASSIGN C_STRUCT TO <LF_ROOTSTR>.
  ELSE.
    ASSIGN C_ROOTSTR TO <LF_ROOTSTR>.
  ENDIF.

* Get data format config
  PERFORM DF_STR_GET_CONFIG
    USING I_TABNM
          C_STRUCT
    CHANGING LS_DF_STR.

* Reset cheking group data
  DELETE GT_DF_CHKGRP_DAT WHERE TABNM = LS_DF_STR-TABNM.

* Check data format structure
  PERFORM DF_STR_CHECK
    USING LS_DF_STR
    CHANGING C_STRUCT
             <LF_ROOTSTR>
             ET_RETURN
             ET_FIELD_EC.

ENDFUNCTION.
