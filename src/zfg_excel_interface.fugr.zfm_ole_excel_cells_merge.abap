FUNCTION ZFM_OLE_EXCEL_CELLS_MERGE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_EXCEL) TYPE  OLE2_OBJECT
*"     REFERENCE(I_ROW1) TYPE  I
*"     REFERENCE(I_COL1) TYPE  I
*"     REFERENCE(I_ROW2) TYPE  I
*"     REFERENCE(I_COL2) TYPE  I
*"--------------------------------------------------------------------
DATA:
    LS_OLE_CELL1 TYPE OLE2_OBJECT,
    LS_OLE_CELL2 TYPE OLE2_OBJECT,
    LS_RANGE     TYPE OLE2_OBJECT.

  CALL METHOD OF I_EXCEL 'Cells' = LS_OLE_CELL1
    EXPORTING
    #1 = I_ROW1
    #2 = I_COL1.

  CALL METHOD OF I_EXCEL 'Cells' = LS_OLE_CELL2
    EXPORTING
    #1 = I_ROW2
    #2 = I_COL2.

  CALL METHOD OF I_EXCEL 'Range' = LS_RANGE
    EXPORTING
    #1 = LS_OLE_CELL1
    #2 = LS_OLE_CELL2.

  CALL METHOD OF LS_RANGE 'Merge'.

  FREE OBJECT LS_OLE_CELL1.
  FREE OBJECT LS_OLE_CELL2.
  FREE OBJECT LS_RANGE.





ENDFUNCTION.
