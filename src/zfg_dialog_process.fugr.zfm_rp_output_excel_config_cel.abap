FUNCTION ZFM_RP_OUTPUT_EXCEL_CONFIG_CEL.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_REPORT) TYPE  PROGRAMM DEFAULT SY-CPROG
*"     REFERENCE(I_TABNAME) TYPE  TABNAME OPTIONAL
*"     REFERENCE(I_DATA)
*"     REFERENCE(I_DATA_CONFIG) OPTIONAL
*"     REFERENCE(I_LOGICALFILE) TYPE  ESEFTAPPL
*"     REFERENCE(I_DEFAULT_FILENAME) TYPE  STRING OPTIONAL
*"     REFERENCE(I_NO_ASK) TYPE  XMARK OPTIONAL
*"     REFERENCE(I_OPEN_FILE) TYPE  XMARK DEFAULT 'X'
*"  TABLES
*"      T_EXCEL_LAYOUT STRUCTURE  ZTB_EXCEL_LAYOUT OPTIONAL
*"  EXCEPTIONS
*"      SAVE_TEMPLATE_ERR
*"      OPEN_FILE_ERR
*"      EXPORT_ERR
*"--------------------------------------------------------------------
**---------------------------------------------------------*
** Function ID:       ZFM_RP_OUTPUT_EXCEL_CONFIG_CEL
** Function name:     Kết xuất ra excel - config theo từng cell
** Created by:      NGOCNV8
** Created date:    05/11/2014
** Content explanation: - Vẫn sử dụng giải pháp kết xuất excel của a TuấnBA
**                      nhưng thêm I_DATA_CONFIG dùng để cấu hình định dạng
**                      cho từng Cell báo cáo
**---------------------------------------------------------*
  DATA:
    LT_EXCEL_LAYOUT  TYPE TABLE OF ZTB_EXCEL_LAYOUT,
    LS_EXCEL_LAYOUT  TYPE ZTB_EXCEL_LAYOUT,
    LT_EXCEL_EX      TYPE TABLE OF ZST_EXCEL_EXP,
    LS_PAGESETUP     TYPE ZST_EXCEL_PAGESETUP.
  FIELD-SYMBOLS:
    <LF_DATA>     TYPE ANY,
    <LFT_ITEMS>   TYPE ANY TABLE.

  CLEAR: LT_EXCEL_EX[].

  IF T_EXCEL_LAYOUT[] IS NOT INITIAL.
    LT_EXCEL_LAYOUT = T_EXCEL_LAYOUT[].
  ELSE.
    SELECT *
      INTO TABLE LT_EXCEL_LAYOUT
      FROM ZTB_EXCEL_LAYOUT
     WHERE REPORT  = I_REPORT.
  ENDIF.
  CALL FUNCTION 'ZFM_EXCEL_GETHEADER_CONFIG_CEL'
    EXPORTING
      I_REPORT              = I_REPORT
      I_TABNAME             = I_TABNAME
      I_HEADER              = I_DATA
      I_HEADER_CONFIG       = I_DATA_CONFIG
      T_EXCEL_LAYOUT        = LT_EXCEL_LAYOUT
   IMPORTING
      T_EXCEL_EXP           = LT_EXCEL_EX
      E_PAGESETUP           = LS_PAGESETUP.

  CALL FUNCTION 'ZFM_EXCEL_GET_ITEMS_CONFIG_CEL'
    EXPORTING
      I_DATA               = I_DATA
      I_DATA_CONFIG        = I_DATA_CONFIG
      T_EXCEL_LAYOUT       = LT_EXCEL_LAYOUT
    IMPORTING
      T_EXCEL_EXP          = LT_EXCEL_EX.
  CALL FUNCTION 'ZFM_EXCEL_EXPORT_CONFIG_CEL'
    EXPORTING
      I_LOGICALFILE            = I_LOGICALFILE
      I_DEFAULT_FILENAME       = I_DEFAULT_FILENAME
      I_OPEN_FILE              = I_OPEN_FILE
      I_NO_ASK                 = I_NO_ASK
      T_SQUARE_DATA            = LT_EXCEL_EX
      I_PAGESETUP              = LS_PAGESETUP
      I_DATA                   = I_DATA
    EXCEPTIONS
      SAVE_TEMPLATE_ERR        = 1
      OPEN_FILE_ERR            = 2
      EXPORT_ERR               = 3
      OTHERS                   = 4 .
  CASE SY-SUBRC.
    WHEN 1.
      MESSAGE S003 DISPLAY LIKE GC_MTYPE_E.
      RAISE SAVE_TEMPLATE_ERR.
    WHEN 2.
      MESSAGE S004 DISPLAY LIKE GC_MTYPE_E.
      RAISE OPEN_FILE_ERR.
    WHEN 3.
      MESSAGE S005 DISPLAY LIKE GC_MTYPE_E.
      RAISE EXPORT_ERR.
    WHEN 4.
      MESSAGE S006 DISPLAY LIKE GC_MTYPE_E.
      RAISE EXPORT_ERR.
  ENDCASE.





ENDFUNCTION.
