FUNCTION Z_JSON_OBJET.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(ENT) TYPE  STRING
*"     REFERENCE(TBL) TYPE  ZGY_0004
*"  EXPORTING
*"     REFERENCE(RET) TYPE  STRING
*"--------------------------------------------------------------------
DATA w_tbl TYPE zgs_0004.
  DATA w_sep.
  DATA w_lng TYPE i.

  CONCATENATE '"' ent '":{' INTO ret.
  DESCRIBE TABLE tbl LINES w_lng.

  LOOP AT tbl INTO w_tbl.
    CONCATENATE ret '"' w_tbl-id '":"' w_tbl-tx '"' INTO ret.
    IF sy-tabix < w_lng.
      CONCATENATE ret ',' INTO ret.
    ENDIF.
  ENDLOOP.

  CONCATENATE ret '}' INTO ret.

ENDFUNCTION.

*+---------------------------------------------------------------------
FORM pf_objadd USING p_id p_tx i_tbl TYPE zgy_0004.
*+-------------------------------------------------------------------
  DATA w_tbl TYPE zgs_0004.

  w_tbl-id = p_id.
  w_tbl-tx = p_tx.
  APPEND w_tbl TO i_tbl.

ENDFORM.                    "pf_json_objet_add
*+---------------------------------------------------------------------
FORM pf_json_begin USING p_id p_ret.
*+-------------------------------------------------------------------

  CONCATENATE p_ret '{' INTO p_ret.

ENDFORM.
*+---------------------------------------------------------------------
FORM pf_json_end USING p_id p_ret.
*+-------------------------------------------------------------------

  CONCATENATE p_ret '}' INTO p_ret.

ENDFORM.
*+---------------------------------------------------------------------
FORM pf_json_sep USING p_id p_ret.
*+-------------------------------------------------------------------

  CONCATENATE p_ret ',' INTO p_ret.

ENDFORM.
*+---------------------------------------------------------------------
FORM pf_json_open USING p_id p_ret.
*+-------------------------------------------------------------------

  CONCATENATE p_ret '"' p_id '":{' INTO p_ret.

ENDFORM.
*+---------------------------------------------------------------------
FORM pf_json_add USING p_id p_txt p_ret.
*+-------------------------------------------------------------------

  CONCATENATE p_ret '"' p_id '":"' p_txt '"' INTO p_ret.

ENDFORM.
