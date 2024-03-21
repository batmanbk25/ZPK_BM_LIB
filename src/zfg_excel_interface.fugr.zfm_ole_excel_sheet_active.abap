FUNCTION ZFM_OLE_EXCEL_SHEET_ACTIVE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_EXCEL) TYPE  OLE2_OBJ OPTIONAL
*"     REFERENCE(I_SHEET_IX) TYPE  I OPTIONAL
*"     REFERENCE(I_SHEET_NAME) TYPE  TEXT256 OPTIONAL
*"--------------------------------------------------------------------
DATA:
    LS_ACTIVE_SHEET     TYPE OLE2_OBJECT,
    LS_EXCEL            TYPE OLE2_OBJECT.

* Init
  CHECK I_SHEET_IX IS NOT INITIAL
     OR I_SHEET_NAME IS NOT INITIAL.

* Choose excel application
  IF I_EXCEL IS INITIAL.
    LS_EXCEL = GS_OLE_EXCEL.
  ELSE.
    LS_EXCEL = I_EXCEL.
  ENDIF.

* Active sheet
  IF I_SHEET_IX IS NOT INITIAL.
    CALL METHOD OF LS_EXCEL 'Worksheets' = LS_ACTIVE_SHEET
      EXPORTING #1 = I_SHEET_IX.
  ELSE.
    CALL METHOD OF LS_EXCEL 'Worksheets' = LS_ACTIVE_SHEET
      EXPORTING #1 = I_SHEET_NAME.
  ENDIF.
  CALL METHOD OF LS_ACTIVE_SHEET 'Activate'.





ENDFUNCTION.
