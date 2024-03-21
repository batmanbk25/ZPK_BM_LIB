FUNCTION ZFM_MC_GET_CONFIG_TAB.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_TABNAME) TYPE  TABNAME
*"     REFERENCE(I_TABMCID) TYPE  ZDD_TABMCID
*"  EXPORTING
*"     REFERENCE(E_MCCF_BUSTAB) TYPE  ZST_MCCF_BUSTAB
*"--------------------------------------------------------------------
DATA:
    LS_MC_BUSTAB    TYPE ZTB_MC_BUSTAB.

  CLEAR: GS_MCCF_BUSTAB.

* Check data got
  IF I_TABNAME      = GS_MCCF_BUSTAB-TABNAME
    AND I_TABMCID   = GS_MCCF_BUSTAB-TABMCID.
    E_MCCF_BUSTAB   = GS_MCCF_BUSTAB.
    RETURN.
  ENDIF.

* Get Tabname and Change ID
  SELECT SINGLE TABNAME TABMCID
    FROM ZTB_MC_BUSTAB
    INTO LS_MC_BUSTAB
   WHERE TABNAME = I_TABNAME
     AND TABMCID = I_TABMCID.
  MOVE-CORRESPONDING LS_MC_BUSTAB TO GS_MCCF_BUSTAB.

* Get change fields
  SELECT  FIELDNAME
          MCTYP
          FIELDVAL
          MCMAPID
          FUNCNAME
          KEYGRP
*          TABNAME
*          TABMCID
*          FPOSI
    FROM ZTB_MC_BUSTABF
    INTO TABLE GS_MCCF_BUSTAB-FIELDS
   WHERE TABNAME = I_TABNAME
     AND TABMCID = I_TABMCID
    ORDER BY FPOSI.
*  SORT GS_MCCF_BUSTAB-FIELDS BY FIELDNAME.

  PERFORM GET_MAP_DATA.





ENDFUNCTION.
