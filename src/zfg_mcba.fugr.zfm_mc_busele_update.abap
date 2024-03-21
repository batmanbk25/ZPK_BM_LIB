FUNCTION ZFM_MC_BUSELE_UPDATE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_MCCF_BUSELE) TYPE  ZST_MCCF_BUSELE
*"  CHANGING
*"     REFERENCE(C_BUSELE)
*"--------------------------------------------------------------------
* Change single record  using list of changing field
  PERFORM CHANGE_SINGLE_RECORD
    USING I_MCCF_BUSELE-FIELDS
    CHANGING C_BUSELE.





ENDFUNCTION.
