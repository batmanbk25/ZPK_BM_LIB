FUNCTION ZFM_MC_BUSTAB_UPDATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_TABNAME) TYPE  TABNAME
*"     REFERENCE(I_TABMCID) TYPE  ZDD_TABMCID
*"  CHANGING
*"     REFERENCE(T_TABDATA) TYPE  TABLE
*"--------------------------------------------------------------------
* Get config
  CALL FUNCTION 'ZFM_MC_GET_CONFIG_TAB'
    EXPORTING
      I_TABNAME           = I_TABNAME
      I_TABMCID           = I_TABMCID
    IMPORTING
      E_MCCF_BUSTAB       = GS_MCCF_BUSTAB.

* Change table data
  PERFORM CHANGE_MULTI_RECORDS
    USING GS_MCCF_BUSTAB-FIELDS
    CHANGING T_TABDATA.





ENDFUNCTION.
