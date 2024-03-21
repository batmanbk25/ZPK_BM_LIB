FUNCTION CONVERSION_EXIT_ZZALL_OUTPUT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(INPUT) TYPE  ANY
*"     REFERENCE(I_DOMNAME) TYPE  DOMNAME
*"  EXPORTING
*"     REFERENCE(OUTPUT) TYPE  ANY
*"--------------------------------------------------------------------
  DATA:
      LT_DD07V 	      TYPE TABLE OF DD07V,
      LS_DD07V        TYPE DD07V.

  OUTPUT = INPUT.
*  CONDENSE OUTPUT.

  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      DOMNAME        = I_DOMNAME
      TEXT           = 'X'
      LANGU          = SY-LANGU"'E'
    TABLES
      DD07V_TAB      = LT_DD07V
    EXCEPTIONS
      WRONG_TEXTFLAG = 1
      OTHERS         = 2.
  IF SY-SUBRC IS INITIAL.
    READ TABLE LT_DD07V INTO LS_DD07V
      WITH KEY DOMVALUE_L = OUTPUT.
    IF SY-SUBRC IS INITIAL.
      OUTPUT = LS_DD07V-DDTEXT.
    ENDIF.
  ENDIF.





ENDFUNCTION.
