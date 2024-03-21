FUNCTION ZFM_OLE_EXCEL_ROWS_SETBOLD.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_EXCEL) TYPE  OLE2_OBJECT OPTIONAL
*"     REFERENCE(I_LEFT) TYPE  I OPTIONAL
*"     REFERENCE(I_COLS) TYPE  I OPTIONAL
*"  TABLES
*"      T_BOLD_ROWS TYPE  ZTT_BOLD_ROW OPTIONAL
*"--------------------------------------------------------------------
DATA:
    LW_COL    TYPE I,
    LS_ROW    TYPE OLE2_OBJECT,
    LS_CELL1  TYPE OLE2_OBJECT,
    LS_CELL2  TYPE OLE2_OBJECT,
    LS_FONT   TYPE OLE2_OBJECT,
    LS_EXCEL  TYPE OLE2_OBJECT.

* Choose excel application
  IF I_EXCEL IS INITIAL.
    LS_EXCEL = GS_OLE_EXCEL.
  ELSE.
    LS_EXCEL = I_EXCEL.
  ENDIF.

  LW_COL = I_LEFT + I_COLS - 1.

* Set bold row
  LOOP AT T_BOLD_ROWS.
*   Select first cell
    CALL METHOD OF LS_EXCEL 'Cells' = LS_CELL1
      EXPORTING
      #1 = T_BOLD_ROWS-ROW
      #2 = I_LEFT.

*   Select last cell
    CALL METHOD OF LS_EXCEL 'Cells' = LS_CELL2
      EXPORTING
      #1 = T_BOLD_ROWS-ROW
      #2 = LW_COL.

*   Select all row
    CALL METHOD OF LS_EXCEL 'Range' = LS_ROW
      EXPORTING
      #1 = LS_CELL1
      #2 = LS_CELL2.

*   Set row bold
    CALL METHOD OF LS_ROW 'FONT' = LS_FONT.
    SET PROPERTY OF LS_FONT 'BOLD' = 1.
    FREE OBJECT LS_FONT.
    FREE OBJECT LS_CELL1.
    FREE OBJECT LS_CELL2.
    FREE OBJECT LS_ROW.
  ENDLOOP.





ENDFUNCTION.
