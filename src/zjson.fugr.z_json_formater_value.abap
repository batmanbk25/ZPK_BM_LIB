FUNCTION Z_JSON_FORMATER_VALUE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(STR) TYPE  ANY
*"--------------------------------------------------------------------
REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN str WITH '\n'.

* OH OH... en entrée il peut déjà y avoir \" et dans ce cas il deviendrait \\" donc on défait et refait.
  REPLACE ALL OCCURRENCES OF '\"' IN str WITH '"'.
  REPLACE ALL OCCURRENCES OF '"' IN str WITH '\"'.





ENDFUNCTION.
