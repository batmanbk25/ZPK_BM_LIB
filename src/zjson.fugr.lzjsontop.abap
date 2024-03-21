FUNCTION-POOL ZJSON.                        "MESSAGE-ID ..

TYPES:BEGIN OF tab_struct,
        fieldname TYPE fieldname,
        type      TYPE c,
      END OF tab_struct.

*&---------------------------------------------------------------------*
FORM write_array_to_json TABLES p_itab USING p_tree CHANGING p_json.

  DATA w_dref_str TYPE REF TO data.
  DATA w_data TYPE string.
  DATA w_json_elem TYPE string.
  DATA w_json_lines TYPE string.
  DATA w_field TYPE string.
  DATA w_tab_struct TYPE  tab_struct.
  DATA w_field_table TYPE string.

  FIELD-SYMBOLS <wa> TYPE ANY.
  FIELD-SYMBOLS <field> TYPE ANY.

  CLEAR p_json.
  CONCATENATE p_json '[' INTO p_json.
  CREATE DATA w_dref_str LIKE p_itab.
  ASSIGN w_dref_str->* TO <wa>.
  LOOP AT p_itab INTO <wa>.
    CLEAR w_json_elem.
    CONCATENATE w_json_lines ',' INTO w_json_lines.
    CLEAR w_data.
    w_field = '<wa>'.
    ASSIGN (w_field) TO <field>.
    CALL FUNCTION 'Z_JSON_OUT'
      EXPORTING
        struc = <field>
      IMPORTING
        json  = w_data.
    CONCATENATE w_json_elem ',' w_data INTO w_json_elem.
    SHIFT w_json_elem.
    CONCATENATE w_json_lines w_json_elem INTO w_json_lines.
  ENDLOOP.
  SHIFT w_json_lines.
  CONCATENATE p_json w_json_lines ']' INTO p_json.

ENDFORM.                    "write_array_to_json

*&---------------------------------------------------------------------*
FORM write_itab_to_json TABLES p_itab p_istruct USING p_tree CHANGING
p_json.

  DATA w_dref_str TYPE REF TO data.
  DATA w_data TYPE string.
  DATA w_json_elem TYPE string.
  DATA w_json_lines TYPE string.
  DATA w_field TYPE string.
  DATA w_struct TYPE tab_struct.
  DATA w_field_table TYPE string.

  FIELD-SYMBOLS <wa> TYPE ANY.
  FIELD-SYMBOLS <field> TYPE ANY.
  FIELD-SYMBOLS <table> TYPE STANDARD TABLE.

  CLEAR p_json.
  CONCATENATE p_json '[' INTO p_json.
  CREATE DATA w_dref_str LIKE p_itab.
  ASSIGN w_dref_str->* TO <wa>.
  LOOP AT p_itab INTO <wa>.
    CLEAR w_json_elem.
    CONCATENATE w_json_lines ',{' INTO w_json_lines.
    LOOP AT p_istruct INTO w_struct.
      CASE w_struct-type.
        WHEN 'T'.
          CLEAR w_data.
          CONCATENATE '<wa>-' w_struct-fieldname INTO w_field.
          ASSIGN (w_field) TO <table>.
          w_field_table =  w_struct-fieldname.
          IF p_tree IS NOT INITIAL AND <table>[] IS NOT INITIAL.
            w_field_table = 'children'.
          ENDIF.
          CALL FUNCTION 'Z_JSON_OUT'
            EXPORTING
              tree = p_tree
            IMPORTING
              json = w_data
            TABLES
              itab = <table>.
          CONCATENATE w_json_elem ',' '"'  w_field_table  '"' ':'
w_data  INTO w_json_elem.
        WHEN OTHERS.
          CLEAR w_data.
          CONCATENATE '<wa>-' w_struct-fieldname INTO w_field.
          ASSIGN (w_field) TO <field>.
          CALL FUNCTION 'Z_JSON_OUT'
            EXPORTING
              struc = <field>
            IMPORTING
              json  = w_data.
          CONCATENATE w_json_elem ',' '"' w_struct-fieldname '"' ':'
w_data INTO w_json_elem.
      ENDCASE.
    ENDLOOP.
    SHIFT w_json_elem.
    CONCATENATE w_json_lines w_json_elem '}' INTO w_json_lines.
  ENDLOOP.
  SHIFT w_json_lines.
  CONCATENATE p_json w_json_lines ']' INTO p_json.

ENDFORM.                    "write_itab_to_json

*&---------------------------------------------------------------------*
FORM write_field_to_json USING p_field CHANGING p_json.

  DATA w_field TYPE string.

  w_field  = p_field.

  CALL FUNCTION 'Z_JSON_FORMATER_VALUE'
    CHANGING
      str = w_field.

  CONCATENATE '"' w_field '"' INTO p_json.

ENDFORM.                    "write_struc_to_json

*&---------------------------------------------------------------------*
FORM write_struc_to_json TABLES p_istruct USING p_struc CHANGING p_json.

  DATA w_data TYPE string.
  DATA w_json_elem TYPE string.
  DATA w_field TYPE string.
  DATA w_struct TYPE tab_struct.
  DATA w_field_table TYPE string.

  FIELD-SYMBOLS <field> TYPE ANY.
  FIELD-SYMBOLS <table> TYPE STANDARD TABLE.

  LOOP AT p_istruct INTO w_struct.
    CASE w_struct-type.
      WHEN 'T'.
        CLEAR w_data.
        CONCATENATE 'p_struc-' w_struct-fieldname INTO w_field.
        ASSIGN (w_field) TO <table>.
        w_field_table = w_struct-fieldname.
        CALL FUNCTION 'Z_JSON_OUT'
          IMPORTING
            json = w_data
          TABLES
            itab = <table>.
        CONCATENATE w_json_elem ',' '"'  w_field_table  '"' ':'
w_data  INTO w_json_elem.
      WHEN OTHERS.
        CLEAR w_data.
        CONCATENATE 'p_struc-' w_struct-fieldname INTO w_field.
        ASSIGN (w_field) TO <field>.
        CALL FUNCTION 'Z_JSON_OUT'
          EXPORTING
            struc = <field>
          IMPORTING
            json  = w_data.
        CONCATENATE w_json_elem ',' '"' w_struct-fieldname '"' ':'
w_data INTO w_json_elem.
    ENDCASE.
  ENDLOOP.
  SHIFT w_json_elem.
  CONCATENATE '{' w_json_elem '}' INTO p_json.

ENDFORM.                    "write_struc_to_json


*----------------------------------------------------------------------*
FORM get_fieldname_struc TABLES p_istructfield USING p_struc.

  DATA w_dref_str TYPE REF TO data.
  DATA i_table_desc TYPE sydes_desc.
  DATA wa_names TYPE sydes_nameinfo.
  DATA wa_types TYPE sydes_typeinfo.
  DATA w_tab_struct TYPE tab_struct.
  DATA wa_names_continue TYPE sydes_nameinfo.
  DATA w_from TYPE i.
  DATA w_to TYPE i.

  FIELD-SYMBOLS <struc> TYPE ANY.

  CREATE DATA w_dref_str LIKE p_struc.
  ASSIGN w_dref_str->* TO <struc>.
  DESCRIBE FIELD <struc> INTO i_table_desc.
  READ TABLE i_table_desc-types INTO wa_types INDEX 1.
  IF wa_types-table_kind EQ 'T'.
    READ TABLE i_table_desc-types INTO wa_types INDEX wa_types-from.
  ENDIF.
  w_from = wa_types-from.
  w_to = wa_types-to.
  LOOP AT i_table_desc-types INTO wa_types FROM w_from TO w_to.
    CLEAR p_istructfield.
    CHECK wa_types-idx_name GT 0.
    READ TABLE i_table_desc-names INTO wa_names INDEX wa_types-idx_name.
    MOVE wa_names-name TO w_tab_struct-fieldname.
*   ADE - Le nom du champ peut être sur 2 lignes
    IF wa_names-continue EQ '*'.
      CLEAR wa_names_continue.
      wa_types-idx_name = wa_types-idx_name + 1.
      READ TABLE i_table_desc-names INTO wa_names_continue INDEX
wa_types-idx_name.
      CONCATENATE w_tab_struct-fieldname wa_names_continue-name INTO
w_tab_struct-fieldname.
    ENDIF.

    MOVE wa_types-table_kind TO w_tab_struct-type.
    APPEND w_tab_struct TO p_istructfield.
  ENDLOOP.

ENDFORM.                    "get_fieldname_struc


*&---------------------------------------------------------------------*
FORM get_fieldname_table TABLES p_itab p_istructfield.

  DATA w_dref_str TYPE REF TO data.
  DATA i_table_desc TYPE sydes_desc.
  DATA wa_names TYPE sydes_nameinfo.
  DATA wa_types TYPE sydes_typeinfo.
  DATA w_tab_struct TYPE tab_struct.
  DATA w_fieldname TYPE fieldname.
  DATA w_index TYPE i.


  FIELD-SYMBOLS <table> TYPE ANY.

  CREATE DATA w_dref_str LIKE p_itab.
  ASSIGN w_dref_str->* TO <table>.
  DESCRIBE FIELD <table> INTO i_table_desc.
  LOOP AT i_table_desc-types INTO wa_types.
    CLEAR p_istructfield.
    CHECK wa_types-idx_name GT 0 AND wa_types-back EQ 1.
    READ TABLE i_table_desc-names INTO wa_names INDEX wa_types-idx_name.

    MOVE wa_names-name TO w_tab_struct-fieldname.
* si le champs fait plus de 30 caracteres
    IF wa_names-continue EQ '*'.
      w_fieldname = wa_names-name.
      w_index = wa_types-idx_name + 1.
      READ TABLE i_table_desc-names INTO wa_names INDEX w_index.
      CONCATENATE w_fieldname wa_names-name INTO w_tab_struct-fieldname.
    ENDIF.
*
    MOVE wa_types-table_kind TO w_tab_struct-type.
    APPEND w_tab_struct TO p_istructfield.
    CLEAR w_fieldname.
  ENDLOOP.

ENDFORM.                    "get_fieldname_table


*&---------------------------------------------------------------------*
FORM write_istruc_to_json TABLES p_istruc CHANGING p_json.

  DATA w_data TYPE string.
  DATA w_json_elem TYPE string.
  DATA w_istruc TYPE zgs_0004.

  LOOP AT p_istruc INTO w_istruc.
    CLEAR w_data.
    CALL FUNCTION 'Z_JSON_OUT'
      EXPORTING
        struc = w_istruc-tx
      IMPORTING
        json  = w_data.
    CONCATENATE w_json_elem ',' '"' w_istruc-id '"' ':' w_data INTO
w_json_elem.
  ENDLOOP.
  SHIFT w_json_elem.
  CONCATENATE '{' w_json_elem '}' INTO p_json.

ENDFORM.                    "write_struc_to_json



*&---------------------------------------------------------------------*
*&      Form  json_to_struc
*&---------------------------------------------------------------------*
FORM json_to_struc USING p_json CHANGING p_struc.

  DATA w_pos_deb_nom TYPE i.
  DATA w_pos_fin_nom TYPE i.
  DATA w_pos_deb_val TYPE i.
  DATA w_pos_fin_val TYPE i.
  DATA w_lenfield TYPE i.
  DATA w_lenvalue TYPE i.
  DATA w_field TYPE string.
  DATA w_value TYPE string.
  DATA i_table_desc TYPE sydes_desc.
  DATA w_type TYPE sydes_typeinfo.

  FIELD-SYMBOLS <champ> TYPE ANY.
  FIELD-SYMBOLS <table> TYPE STANDARD TABLE.

  w_pos_deb_nom = 2.
  WHILE p_json+w_pos_fin_val CS '":'.
    w_pos_fin_nom = w_pos_fin_val + sy-fdpos.
    w_pos_deb_val = w_pos_fin_nom + 2.
    PERFORM get_offset_close USING p_json w_pos_deb_val CHANGING
w_pos_fin_val.
    w_lenfield = w_pos_fin_nom - w_pos_deb_nom.
    w_field = p_json+w_pos_deb_nom(w_lenfield).
    CONCATENATE 'p_struc-' w_field INTO w_field.
    w_lenvalue = w_pos_fin_val - w_pos_deb_val.
    w_value = p_json+w_pos_deb_val(w_lenvalue).
    ASSIGN (w_field) TO <champ>. "if sy-subrc <> 0 that mean: field don't exist in the structure
    IF sy-subrc EQ 0.
      DESCRIBE FIELD <champ> INTO i_table_desc.
      READ TABLE i_table_desc-types INTO w_type INDEX 1.
      CASE w_type-table_kind.
        WHEN 'T'.
          ASSIGN (w_field) TO <table>.
          REFRESH <table>.
          CALL FUNCTION 'Z_JSON_IN'
            EXPORTING
              json = w_value
            TABLES
              itab = <table>.
          <champ> = <table>.
        WHEN OTHERS.
          CALL FUNCTION 'Z_JSON_IN'
            EXPORTING
              json  = w_value
            IMPORTING
              struc = <champ>.
      ENDCASE.
*     w_pos_deb_nom = w_pos_fin_val + 2. "YOA11072008
    ENDIF.
    w_pos_deb_nom = w_pos_fin_val + 2. "YOA11072008
  ENDWHILE.

ENDFORM.                    "json_to_struc


*&---------------------------------------------------------------------*
*&      Form  json_to_itab
*&---------------------------------------------------------------------*
FORM json_to_itab TABLES p_itab USING p_json.

  DATA w_pos_deb_line TYPE i.
  DATA w_pos_fin_line TYPE i.
  DATA w_lenline TYPE i.
  DATA w_line TYPE string.

  CLEAR p_itab. "ADDING CBO
  REFRESH p_itab. "ADDING CBO
  WHILE p_json+w_pos_fin_line CS '{'.
    CLEAR p_itab. "ADDING CBO
    w_pos_deb_line = w_pos_fin_line + sy-fdpos.
    PERFORM get_offset_close USING p_json w_pos_deb_line CHANGING
w_pos_fin_line.
    w_lenline = w_pos_fin_line - w_pos_deb_line.
    w_line = p_json+w_pos_deb_line(w_lenline).
    PERFORM json_to_struc USING w_line CHANGING p_itab.
    APPEND p_itab TO p_itab.
  ENDWHILE.

ENDFORM.                    "json_to_itab


*&---------------------------------------------------------------------*
*&      Form  json_to_array
*&---------------------------------------------------------------------*
FORM json_to_array TABLES p_itab USING p_json.

  DATA w_pos_deb_val TYPE i.
  DATA w_pos_fin_val TYPE i.
  DATA w_pos_deb_lit TYPE i.
  DATA w_lenvalue TYPE i.
  DATA w_field TYPE string.
  DATA w_value TYPE string.

  FIELD-SYMBOLS <champ> TYPE ANY.

  REFRESH p_itab. "ADDING CBO : a little clear and refresh to avoid getting the last values
  WHILE p_json+w_pos_fin_val CS '"'.
    CLEAR p_itab."ADDING CBO
    w_pos_deb_val = sy-fdpos + w_pos_fin_val.
    PERFORM get_offset_close USING p_json w_pos_deb_val CHANGING
w_pos_fin_val.
    w_lenvalue = w_pos_fin_val - w_pos_deb_val.
    w_value = p_json+w_pos_deb_val(w_lenvalue).
    CALL FUNCTION 'Z_JSON_IN'
      EXPORTING
        json  = w_value
      IMPORTING
        struc = p_itab.
    APPEND p_itab TO p_itab.
    w_pos_fin_val = w_pos_fin_val + 1.
  ENDWHILE.

ENDFORM.                    "json_to_array


*&---------------------------------------------------------------------*
*&      Form  get_offset_close
*&---------------------------------------------------------------------*
FORM get_offset_close USING p_json p_offset_open CHANGING
p_offset_close.

  DATA w_offset TYPE i.
  DATA w_copen TYPE c.
  DATA w_cclose TYPE c.
  DATA w_pos_echap TYPE i.
  DATA i_result_tabopen TYPE match_result_tab.
  DATA w_result_tabopen TYPE LINE OF match_result_tab.
  DATA i_result_tabclose TYPE match_result_tab.
  DATA w_result_tabclose TYPE LINE OF match_result_tab.
  DATA w_offsetclose_old TYPE i.

  CONSTANTS : c_echap TYPE c VALUE '\'.

  w_copen = p_json+p_offset_open(1).
  CASE w_copen.
    WHEN '"'. w_cclose = '"'.
    WHEN '{'. w_cclose = '}'.
    WHEN '['. w_cclose = ']'.
  ENDCASE.
  w_offset = p_offset_open + 1.
  IF w_copen EQ '"'.
    FIND ALL OCCURRENCES OF w_cclose IN p_json+w_offset RESULTS
i_result_tabclose.
    LOOP AT i_result_tabclose INTO w_result_tabclose.
      w_pos_echap = w_offset + w_result_tabclose-offset - 1.
      CHECK p_json+w_pos_echap(1) NE c_echap.
      EXIT.
    ENDLOOP.
    p_offset_close = w_offset + w_result_tabclose-offset + 1. "CBO due to change in the else statement
  ELSE.
    FIND ALL OCCURRENCES OF w_copen IN p_json+w_offset RESULTS
i_result_tabopen.
    PERFORM nettoyage TABLES i_result_tabopen USING p_json w_offset.
    FIND ALL OCCURRENCES OF w_cclose IN p_json+w_offset RESULTS
i_result_tabclose.
    PERFORM nettoyage TABLES i_result_tabclose USING p_json w_offset.

*    LOOP AT i_result_tabclose INTO w_result_tabclose.
*      LOOP AT i_result_tabopen INTO w_result_tabopen WHERE offset BETWEEN w_offsetclose_old AND w_result_tabclose-offset.
*        EXIT.
*      ENDLOOP.
*      w_offsetclose_old = w_result_tabclose-offset.
*      CHECK sy-subrc NE 0.
*      EXIT.
*    ENDLOOP.

*   CHANGING CBO : We look to the first close where no open is set before
*                by removing each open corresponding of each close
    DATA w_last_idx LIKE sy-tabix.
    LOOP AT i_result_tabclose INTO w_result_tabclose.
      CLEAR: w_result_tabopen.
      w_last_idx = -1.
      LOOP AT i_result_tabopen INTO w_result_tabopen WHERE offset
BETWEEN 0 AND w_result_tabclose-offset.
        w_last_idx = sy-tabix.
      ENDLOOP.
      IF NOT w_last_idx = -1 .
        DELETE i_result_tabopen INDEX w_last_idx.
      ELSE.
        p_offset_close = w_offset + w_result_tabclose-offset + 1.
        EXIT.
      ENDIF.
    ENDLOOP.

  ENDIF.
*  p_offset_close = w_offset + w_result_tabclose-offset + 1.
ENDFORM.                    "get_offset_close


*&---------------------------------------------------------------------*
*&      Form  nettoyage
*&---------------------------------------------------------------------*
FORM nettoyage TABLES i_tab USING p_json p_offset.

  DATA w_tab TYPE LINE OF match_result_tab.
  DATA w_len TYPE i.
  DATA i_result_tabguillemet TYPE match_result_tab.
  DATA w_result_tabguillemet TYPE LINE OF match_result_tab.
  DATA w_pos_echap TYPE i.
  DATA w_count TYPE i.
  DATA w_parite TYPE p DECIMALS 1.

  CONSTANTS : c_echap TYPE c VALUE '\'.

  LOOP AT i_tab INTO w_tab.
    FIND ALL OCCURRENCES OF '"' IN p_json+p_offset(w_tab-offset)
RESULTS i_result_tabguillemet.
    CLEAR w_count.
    LOOP AT i_result_tabguillemet INTO w_result_tabguillemet WHERE
offset LT w_tab-offset.
      w_pos_echap = p_offset + w_result_tabguillemet-offset - 1.
      CHECK p_json+w_pos_echap(1) NE c_echap.
      w_count = w_count + 1.
    ENDLOOP.
    w_parite = FRAC( w_count / 2 ).
    CHECK w_parite IS NOT INITIAL.
    DELETE i_tab.
  ENDLOOP.

ENDFORM.                    "nettoyage
