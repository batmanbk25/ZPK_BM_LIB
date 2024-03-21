FUNCTION ZFM_SCR_GET_FIELD_LABEL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_PROG) TYPE  SYCPROG DEFAULT SY-CPROG
*"     REFERENCE(I_DYNNR) TYPE  DYNNR DEFAULT SY-DYNNR
*"     REFERENCE(I_FIELDNAME) TYPE  CHAR61 OPTIONAL
*"     REFERENCE(I_FIELD) TYPE  ANY OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_SCRTEXT_L) TYPE  SCRTEXT_L
*"--------------------------------------------------------------------
CONSTANTS:
*   Screen type: Selection screen
    LC_DYNNR_S TYPE C VALUE 'S'.

  DATA:
    LW_FNAME        TYPE CHAR61.

  IF I_FIELDNAME IS NOT INITIAL.
*   Get type of screen
    IF I_PROG IS NOT INITIAL AND I_DYNNR IS NOT INITIAL.
*     If screen type: selection screen, get text from program text
      PERFORM GET_FIELD_LABEL_PROGTEXT
        USING I_FIELDNAME
              I_PROG
        CHANGING E_SCRTEXT_L.
    ELSE.
*     Get label by name of screen element
      PERFORM GET_FIELD_LABEL_ABAPDIC
        USING  I_FIELDNAME
        CHANGING E_SCRTEXT_L.
    ENDIF.
  ENDIF.

  IF I_FIELD IS SUPPLIED AND E_SCRTEXT_L IS INITIAL.
*   Get label by type of screen element
    DESCRIBE FIELD I_FIELD HELP-ID LW_FNAME.
    PERFORM GET_FIELD_LABEL_ABAPDIC
      USING  LW_FNAME
      CHANGING E_SCRTEXT_L.
  ENDIF.

  IF E_SCRTEXT_L IS INITIAL.
    IF I_FIELDNAME IS NOT INITIAL.
      E_SCRTEXT_L = I_FIELDNAME.
    ELSEIF LW_FNAME IS NOT INITIAL.
      E_SCRTEXT_L = LW_FNAME.
    ENDIF.
  ENDIF.





ENDFUNCTION.
