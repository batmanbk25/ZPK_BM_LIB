*&---------------------------------------------------------------------*
*& Report  ZPG_BM_TEST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZPG_BM_TEST.
TYPE-POOLS ole2.
************************************************************************
* Types Definitions
************************************************************************
TYPES: ty_line(1500) TYPE c.
TYPES: BEGIN OF ty_vbak,
       vbeln TYPE vbeln,
       vkorg TYPE vkorg,
       vtweg TYPE vtweg,
       spart TYPE spart,
       END OF ty_vbak.
TYPES: BEGIN OF ty_vbap,
       vbeln TYPE vbeln,
       posnr TYPE posnr,
       matnr TYPE matnr,
       werks TYPE werks,
       END OF ty_vbap.
************************************************************************
* Internal table and work area declarations
************************************************************************
DATA: it_tab1 TYPE TABLE OF ty_line, " Contains records for first sheet
      it_tab2 TYPE TABLE OF ty_line, " Contains records for second sheet
      it_vbak TYPE TABLE OF ty_vbak, " Header details from VBAK table
      it_vbap TYPE TABLE OF ty_vbap, "Item details from VBAP table
      wa_tab TYPE ty_line,
      wa_vbak TYPE ty_vbak,
      wa_vbap TYPE ty_vbap.
************************************************************************
* OLE objects Declarations
************************************************************************
DATA: w_excel TYPE ole2_object,
      w_workbook TYPE ole2_object,
      w_worksheet TYPE ole2_object,
      w_columns  TYPE ole2_object,
      w_column_ent TYPE ole2_object,
      w_cell TYPE ole2_object,
      w_int TYPE ole2_object,
      w_range TYPE ole2_object.
************************************************************************
* Data declarations
************************************************************************
DATA: w_deli(1) TYPE c, "Delimiter
      w_hex TYPE x,
      w_rc TYPE i.
************************************************************************
* Field Symbols
************************************************************************
FIELD-SYMBOLS: <fs> .
************************************************************************
* Constants
************************************************************************
CONSTANTS wl_c09(2) TYPE n VALUE 09.
************************************************************************
* File Selection
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS: p_file   LIKE rlgrap-filename.
SELECTION-SCREEN END OF BLOCK block1.
* F4 Help for File name
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name = sy-repid
      field_name   = 'P_FILE'
    IMPORTING
      file_name    = p_file.
START-OF-SELECTION.
  PERFORM download_excel.
*&---------------------------------------------------------------------*
*&      Form  download_excel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM download_excel.
  CREATE OBJECT w_excel 'EXCEL.APPLICATION'. "Create object for Excel
  SET PROPERTY OF w_excel  'VISIBLE' = 1. "In background Mode
  CALL METHOD OF w_excel 'WORKBOOKS' = w_workbook.
  CALL METHOD OF w_workbook 'ADD'. "Create a new Workbook
  SET PROPERTY OF w_excel 'SheetsInNewWorkbook' = 3. "No of sheets
  PERFORM fill_data. " Fill the internal tables with the req. data
* Downloading header details to first sheet
  PERFORM download_sheet TABLES it_tab1 USING 1 'Header Details'.
  GET PROPERTY OF w_excel 'ActiveSheet' = w_worksheet.
* Protect the first worksheet with a password
  CALL METHOD OF w_worksheet 'PROTECT'
    EXPORTING #1 = 'infy@123'.
* Downloading item details to second sheet
  PERFORM download_sheet TABLES it_tab2 USING 2 'Item Details'.
  GET PROPERTY OF w_excel 'ActiveSheet' = w_worksheet.
* Protect the second worksheet with a password
  CALL METHOD OF w_worksheet 'PROTECT'
    EXPORTING #1 = 'infy:123'.
* Save the Excel file
  GET PROPERTY OF w_excel 'ActiveWorkbook' = w_workbook.
  CALL METHOD OF w_workbook 'SAVEAS'
    EXPORTING #1 = p_file.
  FREE OBJECT: w_worksheet, w_excel.
ENDFORM.                    "download_excel
*&---------------------------------------------------------------------*
*&      Form  fill_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fill_data.
  SELECT vbeln
         vkorg
         vtweg
         spart INTO TABLE it_vbak FROM vbak.
  SELECT vbeln
        posnr
        matnr
        werks INTO TABLE it_vbap FROM vbap.
  ASSIGN w_deli TO <fs> TYPE 'X'.
  w_hex = wl_c09.
  <fs> = w_hex.
  CONCATENATE 'Sales Document' 'Sales Organization'
              'Distribution Channel' 'Division'
              INTO wa_tab SEPARATED BY w_deli.
  APPEND wa_tab TO it_tab1.
  LOOP AT it_vbak INTO wa_vbak.
    CONCATENATE wa_vbak-vbeln wa_vbak-vkorg
                wa_vbak-vtweg wa_vbak-spart
                INTO wa_tab SEPARATED BY w_deli.
    APPEND wa_tab TO it_tab1.
  ENDLOOP.
  CONCATENATE 'Sales Document' 'Item'
              'Material' 'Ware House'
              INTO wa_tab SEPARATED BY w_deli.
  APPEND wa_tab TO it_tab2.
  LOOP AT it_vbap INTO wa_vbap.
    CONCATENATE wa_vbap-vbeln wa_vbap-posnr
                wa_vbap-matnr wa_vbap-werks
                INTO wa_tab SEPARATED BY w_deli.
    APPEND wa_tab TO it_tab2.
  ENDLOOP.
ENDFORM.                    "fill_data
*&---------------------------------------------------------------------*
*&      Form  download_sheet
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SHEET    text
*      -->P_NAME     text
*----------------------------------------------------------------------*
FORM download_sheet TABLES p_tab
                    USING p_sheet TYPE i
                          p_name TYPE string.
  CALL METHOD OF w_excel 'WORKSHEETS' = w_worksheet
    EXPORTING
    #1 = p_sheet.
  CALL METHOD OF w_worksheet 'ACTIVATE'.
  SET PROPERTY OF w_worksheet 'NAME' = p_name.
  CALL METHOD OF w_excel 'Range' = w_range
    EXPORTING
    #1 = 'A1'
    #2 = 'D1'.
  CALL METHOD OF w_range 'INTERIOR' = w_int.
  SET PROPERTY OF w_int 'ColorIndex' = 6.
  SET PROPERTY OF w_int 'Pattern' = 1.
* Initially unlock all the columns( by default all the columns are
*locked )
  CALL METHOD OF w_excel 'Columns' = w_columns.
  SET PROPERTY OF w_columns 'Locked' = 0.
* Locking and formatting first column
  CALL METHOD OF w_excel 'Columns' = w_columns
    EXPORTING
    #1 = 1.
  SET PROPERTY OF w_columns  'Locked' = 1.
  SET PROPERTY OF w_columns  'NumberFormat' = '@'.
* Export the contents in the internal table to the clipboard
  CALL METHOD cl_gui_frontend_services=>clipboard_export
    IMPORTING
      data                 = p_tab[]
    CHANGING
      rc                   = w_rc
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
* Paste the contents in the clipboard to the worksheet
  CALL METHOD OF w_worksheet 'Paste'.
* Autofit the columns according to the contents
  CALL METHOD OF w_excel 'Columns' = w_columns.
  CALL METHOD OF w_columns 'AutoFit'.
  FREE OBJECT: w_columns, w_range.
ENDFORM.                    "download_sheet
