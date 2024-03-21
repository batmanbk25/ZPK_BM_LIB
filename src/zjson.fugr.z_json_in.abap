FUNCTION Z_JSON_IN.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(JSON) TYPE  STRING
*"  EXPORTING
*"     REFERENCE(STRUC)
*"  TABLES
*"      ITAB TYPE  STANDARD TABLE OPTIONAL
*"--------------------------------------------------------------------
TYPE-POOLS: sydes.

  DATA w_len TYPE i.
  w_len = STRLEN( json ).
  CHECK w_len GT 1.
  w_len = w_len - 1.
  IF json(1) EQ '{' AND json+w_len(1) EQ '}'.
    PERFORM json_to_struc USING json CHANGING struc.
  ELSEIF json(1) EQ '[' AND json+w_len(1) EQ ']'.
    IF json+1(1) EQ '{'.
      PERFORM json_to_itab TABLES itab USING json.
    ELSE.
      PERFORM json_to_array TABLES itab USING json.
    ENDIF.
  ELSEIF json(1) EQ '"' AND json+w_len(1) EQ '"'.
    w_len = w_len - 1.
    struc = json+1(w_len).
    CALL FUNCTION 'Z_JSON_DEFORMATER_VALUE'
      CHANGING
        str = struc.
  ENDIF.





ENDFUNCTION.
