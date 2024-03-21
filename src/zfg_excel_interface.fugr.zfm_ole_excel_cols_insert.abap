FUNCTION ZFM_OLE_EXCEL_COLS_INSERT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_EXCEL) TYPE  OLE2_OBJECT OPTIONAL
*"     REFERENCE(I_WORKSHEET) TYPE  OLE2_OBJECT OPTIONAL
*"     REFERENCE(I_LEFT) TYPE  I OPTIONAL
*"     REFERENCE(I_COLS) TYPE  I OPTIONAL
*"--------------------------------------------------------------------
DATA:
    LS_EXCEL  TYPE OLE2_OBJECT,
    LW_COL    TYPE I,
    LS_COLS   TYPE OLE2_OBJECT,
    LS_COL1   TYPE OLE2_OBJECT,
    LS_COL2   TYPE OLE2_OBJECT.

  CHECK I_COLS > 0.
* Choose excel application
  IF I_EXCEL IS INITIAL.
    LS_EXCEL = GS_OLE_EXCEL.
  ELSE.
    LS_EXCEL = I_EXCEL.
  ENDIF.

  LW_COL = I_LEFT + I_COLS - 1.

* Select first cell
  CALL METHOD OF LS_EXCEL 'Columns' = LS_COL1
    EXPORTING
    #1 = I_LEFT.

* Select last cell
  CALL METHOD OF LS_EXCEL 'Columns' = LS_COL2
    EXPORTING
    #1 = LW_COL.

* Select all row
  CALL METHOD OF LS_EXCEL 'Range' = LS_COLS
    EXPORTING
    #1 = LS_COL1
    #2 = LS_COL2.

* Set row bold
  CALL METHOD OF LS_COLS 'Insert'.
  FREE OBJECT LS_COL1.
  FREE OBJECT LS_COL2.
  FREE OBJECT LS_COLS.





ENDFUNCTION.
