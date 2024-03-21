FUNCTION ZFM_OLE_EXCEL_OPEN.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_FILENAME) TYPE  LOCALFILE
*"  EXPORTING
*"     REFERENCE(E_EXCEL) TYPE  OLE2_OBJECT
*"     REFERENCE(E_WORKBOOK) TYPE  OLE2_OBJECT
*"     REFERENCE(E_WORKSHEET) TYPE  OLE2_OBJECT
*"  EXCEPTIONS
*"      EXCEL_APP_ERR
*"      FILE_OPEN_ERR
*"--------------------------------------------------------------------
DATA:
      LT_RETURN   TYPE TABLE OF BAPIRET2.

  CREATE OBJECT GS_OLE_EXCEL 'Excel.Application'.
  IF SY-SUBRC NE 0.
    RAISE EXCEL_APP_ERR.
  ENDIF.
  SET PROPERTY OF GS_OLE_EXCEL 'DISPLAYALERTS'    = 0.
  CALL METHOD OF GS_OLE_EXCEL 'Workbooks' = GS_OLE_WORKBOOK.
*  SET PROPERTY OF GS_OLE_EXCEL 'VISIBLE'          = 0.
  IF SY-SUBRC NE 0.
    RAISE EXCEL_APP_ERR.
  ENDIF.
* Open worksheet
  CALL METHOD OF GS_OLE_WORKBOOK 'Open' EXPORTING #1 = I_FILENAME.
  IF SY-SUBRC IS NOT INITIAL.
    RAISE FILE_OPEN_ERR.
  ENDIF.

  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      USERNAME = SY-UNAME
    IMPORTING
      DEFAULTS = GS_DEFAULTS
    TABLES
      RETURN   = LT_RETURN.

  SET PROPERTY OF GS_OLE_EXCEL 'UseSystemSeparators' = 'False'.
  CASE GS_DEFAULTS-DCPFM.
    WHEN SPACE.
      SET PROPERTY OF GS_OLE_EXCEL 'DecimalSeparator' = ','.
      SET PROPERTY OF GS_OLE_EXCEL 'ThousandsSeparator' = '.'.
    WHEN 'X'.
      SET PROPERTY OF GS_OLE_EXCEL 'DecimalSeparator' = '.'.
      SET PROPERTY OF GS_OLE_EXCEL 'ThousandsSeparator' = ','.
    WHEN 'Y'.
      SET PROPERTY OF GS_OLE_EXCEL 'ThousandsSeparator' = SPACE.
      SET PROPERTY OF GS_OLE_EXCEL 'DecimalSeparator' = ','.
  ENDCASE.

  E_EXCEL     = GS_OLE_EXCEL.
  E_WORKBOOK  = GS_OLE_WORKBOOK.

**********************************************************************
  IF SY-UNAME = 'TUANBA'.
*    SET PROPERTY OF GS_OLE_EXCEL 'Visible'       = 1.
  ENDIF.
**********************************************************************





ENDFUNCTION.
