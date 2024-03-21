FUNCTION ZFM_EXCEL_GETDIMENS_CONFIG_CEL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     REFERENCE(E_DIMENSION) TYPE  SOI_DIMENSION_ITEM
*"  TABLES
*"      T_EXCEL_DATA TYPE  ZTT_EXCEL
*"--------------------------------------------------------------------
DATA:
    LW_END_ROW      TYPE I,
    LW_END_COL      TYPE I,
    LT_ROWS         TYPE TABLE OF I WITH HEADER LINE,
    LT_COLS         TYPE TABLE OF I WITH HEADER LINE,
*    LS_EXCEL_DATA   TYPE SOI_GENERIC_ITEM,
    LS_EXCEL_DATA   TYPE ZST_EXCEL,
    LW_LAST_INDEX   TYPE I.

  CLEAR: E_DIMENSION.

  CHECK T_EXCEL_DATA[] IS NOT INITIAL.
* Get all rows and cols
  LOOP AT T_EXCEL_DATA INTO LS_EXCEL_DATA.
    LW_END_ROW = LS_EXCEL_DATA-ROW.
    LW_END_COL = LS_EXCEL_DATA-COLUMN.
    COLLECT LW_END_ROW  INTO LT_ROWS.
    COLLECT LW_END_COL  INTO LT_COLS.
  ENDLOOP.

  SORT: LT_ROWS, LT_COLS.

  READ TABLE LT_ROWS INTO E_DIMENSION-ROW INDEX 1.
  DESCRIBE TABLE LT_ROWS LINES LW_LAST_INDEX.
  READ TABLE LT_ROWS INTO LW_END_ROW INDEX LW_LAST_INDEX.

  READ TABLE LT_COLS INTO E_DIMENSION-COLUMN INDEX 1.
  DESCRIBE TABLE LT_COLS LINES LW_LAST_INDEX.
  READ TABLE LT_COLS INTO LW_END_COL INDEX LW_LAST_INDEX.

  E_DIMENSION-ROWS    = LW_END_ROW - E_DIMENSION-ROW + 1.
  E_DIMENSION-COLUMNS = LW_END_COL - E_DIMENSION-COLUMN + 1.





ENDFUNCTION.
