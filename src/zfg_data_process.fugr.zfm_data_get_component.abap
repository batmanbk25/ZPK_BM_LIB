FUNCTION ZFM_DATA_GET_COMPONENT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_COMPONENT_NAME) TYPE  FIELDNAME
*"     REFERENCE(I_STRUCTURE)
*"  EXPORTING
*"     REFERENCE(E_COMPONENT_VALUE) TYPE  ANY
*"--------------------------------------------------------------------
FIELD-SYMBOLS:
    <LF_VALUE>        TYPE ANY.

  IF I_COMPONENT_NAME IS NOT INITIAL.
    ASSIGN COMPONENT I_COMPONENT_NAME
      OF STRUCTURE I_STRUCTURE TO <LF_VALUE>.
    IF SY-SUBRC IS INITIAL.
      E_COMPONENT_VALUE = <LF_VALUE>.
    ENDIF.
  ENDIF.





ENDFUNCTION.
