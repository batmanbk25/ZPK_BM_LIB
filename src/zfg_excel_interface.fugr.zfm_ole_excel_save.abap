FUNCTION ZFM_OLE_EXCEL_SAVE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_FILENAME) TYPE  LOCALFILE
*"--------------------------------------------------------------------
GET PROPERTY OF GS_OLE_EXCEL 'ActiveWorkbook' = GS_OLE_WORKBOOK.

  CALL METHOD OF GS_OLE_WORKBOOK 'SAVEAS'
    EXPORTING
    #1 = I_FILENAME
    #2 = 1.

  CALL METHOD OF GS_OLE_WORKBOOK 'CLOSE'.
  CALL METHOD OF GS_OLE_EXCEL 'QUIT'.





ENDFUNCTION.
