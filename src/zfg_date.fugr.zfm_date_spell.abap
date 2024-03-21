FUNCTION ZFM_DATE_SPELL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_DATUM) TYPE  DATUM OPTIONAL
*"     REFERENCE(I_SPMON) TYPE  SPMON OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_DATET)
*"--------------------------------------------------------------------
IF I_DATUM IS NOT INITIAL.
    CONCATENATE TEXT-001 I_DATUM+6(2)
                TEXT-002 I_DATUM+4(2)
                TEXT-003 I_DATUM(4)
           INTO E_DATET SEPARATED BY SPACE.
  ENDIF.
  IF I_SPMON IS NOT INITIAL.
    CONCATENATE TEXT-002 I_DATUM+4(2)
                TEXT-003 I_DATUM(4)
           INTO E_DATET SEPARATED BY SPACE.
  ENDIF.





ENDFUNCTION.
