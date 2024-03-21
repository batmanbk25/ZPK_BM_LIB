FUNCTION ZFM_OLE_EXCEL_SHEETS_COPY.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_EXCEL) TYPE  OLE2_OBJECT OPTIONAL
*"     REFERENCE(I_ORG_SHEETIX) TYPE  I
*"     REFERENCE(T_SHEET_COPY) TYPE  ZTT_SHEET_KEY
*"--------------------------------------------------------------------
DATA:
    LS_ORG_SHEET    TYPE OLE2_OBJECT,
    LS_DES_SHEET    TYPE OLE2_OBJECT,
    LS_EXCEL        TYPE OLE2_OBJECT,
    LW_RC           TYPE I,
    LW_DESSHEETNO   TYPE I,
    LS_SHEET_COPY   TYPE ZST_SHEET_KEY.

* Init
  CHECK: I_ORG_SHEETIX IS NOT INITIAL, T_SHEET_COPY[] IS NOT INITIAL.

* Choose excel application
  IF I_EXCEL IS INITIAL.
    LS_EXCEL = GS_OLE_EXCEL.
  ELSE.
    LS_EXCEL = I_EXCEL.
  ENDIF.

  CALL METHOD OF LS_EXCEL 'Worksheets' = LS_ORG_SHEET
    EXPORTING #1 = I_ORG_SHEETIX.
  CALL METHOD OF LS_ORG_SHEET 'Activate'.

* Copy sheet:
  LOOP AT T_SHEET_COPY INTO LS_SHEET_COPY FROM 2.
*   Copy active sheet to before
    CALL METHOD OF LS_ORG_SHEET 'Copy'  = LS_DES_SHEET
      EXPORTING #1 = LS_ORG_SHEET.
  ENDLOOP.

  LOOP AT T_SHEET_COPY INTO LS_SHEET_COPY
    WHERE SHEET_NAME IS NOT INITIAL.
    CALL METHOD OF LS_EXCEL 'Worksheets' = LS_DES_SHEET
      EXPORTING #1 = LS_SHEET_COPY-SHEETNO.
*    CALL METHOD OF LS_DES_SHEET 'Activate'.
*    CALL METHOD OF LS_DES_SHEET 'Select'.
    SET PROPERTY OF LS_DES_SHEET 'NAME' = LS_SHEET_COPY-SHEET_NAME.
  ENDLOOP.

*  DATA:
*    LS_SHEETS       TYPE OLE2_OBJECT,
*    LS_ACT_WIND     TYPE OLE2_OBJECT,
*    LS_ORG_SHEET    TYPE OLE2_OBJECT,
*    LS_DES_SHEET    TYPE OLE2_OBJECT,
*    LS_EXCEL        TYPE OLE2_OBJECT,
*    LS_CELLS        TYPE OLE2_OBJECT,
*    LW_RC           TYPE I,
*    LW_DESSHEETNO   TYPE I,
*    LS_SHEETNAME    TYPE SOI_SHEETS,
*    LT_SHEETNAME    TYPE SOI_SHEETS_TABLE,
*    LW_GRIDLINE     TYPE TEXT10.
** Get all cells of first sheet to copy
*  CALL METHOD OF LS_ORG_SHEET 'Cells' = LS_CELLS.
*  CALL METHOD OF LS_CELLS 'Select'.
*  CALL METHOD OF LS_CELLS 'Copy'.
** Copy sheet:
*  LOOP AT LT_SHEETNAME INTO LS_SHEETNAME.
*    LW_RC = SY-TABIX.
**   First sheet, change name, not copy
*    IF LW_RC = 1.
*      CALL METHOD OF LS_EXCEL 'Worksheets' = LS_DES_SHEET
*        EXPORTING #1 = LW_RC.
*      SET PROPERTY OF LS_DES_SHEET  'NAME' = LS_SHEETNAME-SHEET_NAME.
*      CALL METHOD OF LS_DES_SHEET 'Activate'.
*      CALL METHOD OF LS_EXCEL 'ActiveWindow' = LS_ACT_WIND.
*      GET PROPERTY OF LS_ACT_WIND 'DisplayGridlines' = LW_GRIDLINE.
*    ELSE.
**     Add new sheet
*      CALL METHOD OF LS_SHEETS      'Add' = LS_DES_SHEET."LS_NEWSHEET.
*
*      SET PROPERTY OF LS_DES_SHEET  'NAME' = LS_SHEETNAME-SHEET_NAME.
*      CALL METHOD OF LS_DES_SHEET 'Activate'.
*      CALL METHOD OF LS_DES_SHEET 'Select'.
*
**     Copy data to active sheet
*      CALL METHOD OF LS_DES_SHEET 'Cells' = LS_CELLS.
*      CALL METHOD OF LS_CELLS 'Select'.
*      CALL METHOD OF LS_DES_SHEET 'Paste'.
*    ENDIF.
*  ENDLOOP.

** Set display grid line
*  LOOP AT T_DES_SHEETNAME INTO LS_SHEETNAME.
*    LW_RC = SY-TABIX.
*    CALL METHOD OF LS_EXCEL 'Worksheets' = LS_DES_SHEET
*      EXPORTING #1 = LW_RC.
*    CALL METHOD OF LS_DES_SHEET 'Activate'.
*    CASE LW_GRIDLINE.
*      WHEN '0'.
*        SET PROPERTY OF LS_ACT_WIND 'DisplayGridlines' = 'False'.
*      WHEN '1'.
*        SET PROPERTY OF LS_ACT_WIND 'DisplayGridlines' = 'True'.
*      WHEN OTHERS.
*    ENDCASE.
*  ENDLOOP.

*    Cells.Select
*    Selection.Copy
*    Sheets("Sheet2").Select
*    Cells.Select
*    Selection.PasteSpecial Paste:=xlPasteColumnWidths,
*Operation:=xlNone, _
*        SkipBlanks:=False, Transpose:=False
*    ActiveSheet.Paste
*    Application.CutCopyMode = False
*    Application.Run "a.XLS!Macro1"
*    Application.Goto Reference:="Macro1"





ENDFUNCTION.
