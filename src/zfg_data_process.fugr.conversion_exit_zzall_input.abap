FUNCTION CONVERSION_EXIT_ZZALL_INPUT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(INPUT) TYPE  ANY
*"     REFERENCE(I_DOMNAME) TYPE  DOMNAME
*"  EXPORTING
*"     REFERENCE(OUTPUT) TYPE  ANY
*"----------------------------------------------------------------------
  DATA:
      LT_DD07V 	      TYPE TABLE OF DD07V,
      LS_DD07V        TYPE DD07V,
      LO_EXCEPTION    TYPE REF TO CX_ROOT.

  TRY .
      OUTPUT = INPUT.
    CATCH CX_ROOT INTO LO_EXCEPTION.
  ENDTRY.

  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      DOMNAME        = I_DOMNAME
      TEXT           = 'X'
      LANGU          = SY-LANGU "'E'
    TABLES
      DD07V_TAB      = LT_DD07V
    EXCEPTIONS
      WRONG_TEXTFLAG = 1
      OTHERS         = 2.
  IF SY-SUBRC IS INITIAL.
    READ TABLE LT_DD07V INTO LS_DD07V
      WITH KEY DDTEXT = INPUT.
    IF SY-SUBRC IS INITIAL.
      OUTPUT = LS_DD07V-DOMVALUE_L.
    ENDIF.
  ENDIF.





ENDFUNCTION.
