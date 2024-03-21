FUNCTION ZFM_OLE_EXCEL_ROWS_DELETE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_EXCEL) TYPE  OLE2_OBJECT OPTIONAL
*"     REFERENCE(I_WORKSHEET) TYPE  OLE2_OBJECT OPTIONAL
*"     REFERENCE(I_TOP) TYPE  I OPTIONAL
*"     REFERENCE(I_ROWS) TYPE  I OPTIONAL
*"--------------------------------------------------------------------
DATA:
    LS_EXCEL  TYPE OLE2_OBJECT,
    LW_ROW    TYPE I,
    LS_ROWS   TYPE OLE2_OBJECT,
    LS_ROW1   TYPE OLE2_OBJECT,
    LS_ROW2   TYPE OLE2_OBJECT.

  CHECK I_ROWS > 0.
* Choose excel application
  IF I_EXCEL IS INITIAL.
    LS_EXCEL = GS_OLE_EXCEL.
  ELSE.
    LS_EXCEL = I_EXCEL.
  ENDIF.

  LW_ROW = I_TOP + I_ROWS - 1.

* Select first cell
  CALL METHOD OF LS_EXCEL 'Rows' = LS_ROW1
    EXPORTING
    #1 = I_TOP.

* Select last cell
  CALL METHOD OF LS_EXCEL 'Rows' = LS_ROW2
    EXPORTING
    #1 = LW_ROW.

* Select all row
  CALL METHOD OF LS_EXCEL 'Range' = LS_ROWS
    EXPORTING
    #1 = LS_ROW1
    #2 = LS_ROW2.

* Set row bold
  CALL METHOD OF LS_ROWS 'Delete'.
  FREE OBJECT LS_ROW1.
  FREE OBJECT LS_ROW2.
  FREE OBJECT LS_ROWS.





ENDFUNCTION.
