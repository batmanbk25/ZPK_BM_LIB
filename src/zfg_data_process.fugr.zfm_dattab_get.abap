FUNCTION ZFM_DATTAB_GET.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_TABLE) TYPE  TABNAME
*"     REFERENCE(T_WHERE_CLAUSES) TYPE  TT_RSDSWHERE
*"  EXPORTING
*"     REFERENCE(T_TABLE_DATA) TYPE  ANY TABLE
*"--------------------------------------------------------------------
* Init
  CLEAR T_TABLE_DATA.

* Check where clause
  IF T_WHERE_CLAUSES IS NOT INITIAL.
*   Get data from database
    SELECT *
      INTO TABLE T_TABLE_DATA
      FROM (I_TABLE)
      WHERE (T_WHERE_CLAUSES).
  ELSE.
*   Get data from database
    SELECT *
      INTO TABLE T_TABLE_DATA
      FROM (I_TABLE).
  ENDIF.





ENDFUNCTION.
