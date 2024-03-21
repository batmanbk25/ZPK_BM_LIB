FUNCTION ZFM_BM_PAR_GET.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_VAR_NAME) TYPE  RVARI_VNAM
*"  EXPORTING
*"     REFERENCE(E_ACTIVE) TYPE  ZDD_BM_ACTIVE
*"     REFERENCE(E_VAR_VALUE)
*"--------------------------------------------------------------------
DATA:
      LW_VAR_VALUE      TYPE ZDD_BM_PARVL.",
*    LS_USR_INFO       TYPE ZST_USR_INFO.

* Clear export parameters
  CLEAR E_VAR_VALUE.

* Get value of var
  SELECT ACTIV PARVL
    FROM ZTB_BM_SCP_PAR
    INTO (E_ACTIVE, LW_VAR_VALUE)
    UP TO 1 ROWS
  WHERE REGIO = SPACE "LS_USR_INFO-REGIO
    AND PARNM = I_VAR_NAME.  " Variant ID
  ENDSELECT.
  IF SY-SUBRC IS INITIAL.
    E_VAR_VALUE = LW_VAR_VALUE.
  ENDIF.





ENDFUNCTION.
