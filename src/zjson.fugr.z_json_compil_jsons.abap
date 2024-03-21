FUNCTION Z_JSON_COMPIL_JSONS.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     REFERENCE(JSON) TYPE  STRING
*"  TABLES
*"      JSONS TYPE  ZGY_0004
*"--------------------------------------------------------------------
DATA w_jsons TYPE zgs_0004.
  CLEAR json.

  LOOP AT jsons INTO w_jsons.

    CONCATENATE json ',"' w_jsons-id '":' w_jsons-tx INTO json.

  ENDLOOP.

  SHIFT json.

  CONCATENATE  '{' json '}' INTO json.





ENDFUNCTION.
