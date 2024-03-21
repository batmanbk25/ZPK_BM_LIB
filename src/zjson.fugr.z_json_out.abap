FUNCTION Z_JSON_OUT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(TREE) TYPE  C OPTIONAL
*"     REFERENCE(STRUC) OPTIONAL
*"  EXPORTING
*"     VALUE(JSON) TYPE  STRING
*"  TABLES
*"      ITAB TYPE  STANDARD TABLE OPTIONAL
*"      ISTRUC TYPE  ZGY_0004 OPTIONAL
*"--------------------------------------------------------------------
TYPE-POOLS: sydes.

  DATA : i_structfield TYPE tab_struct OCCURS 0.
  DATA : w_lines TYPE i.

  IF itab IS SUPPLIED.
    PERFORM get_fieldname_table TABLES itab i_structfield.
    DESCRIBE TABLE i_structfield LINES w_lines.
    IF w_lines EQ 0.
      PERFORM write_array_to_json TABLES itab USING tree CHANGING json.
    ELSE.
      PERFORM write_itab_to_json TABLES itab i_structfield USING tree CHANGING json.
    ENDIF.
  ELSEIF struc IS SUPPLIED.
    PERFORM get_fieldname_struc TABLES i_structfield USING struc.
    IF i_structfield[] IS INITIAL.
      PERFORM write_field_to_json USING struc CHANGING json.
    ELSE.
      PERFORM write_struc_to_json TABLES i_structfield USING struc CHANGING json.
    ENDIF.
  ELSEIF istruc IS SUPPLIED.
    PERFORM write_istruc_to_json TABLES istruc CHANGING json.
  ENDIF.





ENDFUNCTION.
