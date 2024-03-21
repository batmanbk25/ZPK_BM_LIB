FUNCTION-POOL ZFG_DIALOG_PROCESS  MESSAGE-ID ZMS_LIB_PROG.

INCLUDE ZIN_COMMONTOP.

*--------------------------------------------------------------------*
* CONSTANTS
*--------------------------------------------------------------------*
CONSTANTS:
  GC_MSG_CL             TYPE ARBGB VALUE 'ZMS_LIB_PROG',
  GC_MSGNR_REQUIRED     TYPE MSGNR VALUE '001',
  GC_MSGNR_INVALID      TYPE MSGNR VALUE '002',
  GC_SMODE_CREATE       TYPE ZDD_SCR_MODE VALUE '01',
  GC_SMODE_CHANGE       TYPE ZDD_SCR_MODE VALUE '02',
  GC_SMODE_DISPLAY      TYPE ZDD_SCR_MODE VALUE '03',
  GC_FIELD_SHEETNO      TYPE FIELDNAME VALUE 'SHEETNO',
  GC_EVTYPE_INIT        TYPE ZDD_PROG_EVTYPE VALUE '110',
  GC_EVTYPE_OPEN        TYPE ZDD_PROG_EVTYPE VALUE '120',
  GC_EVTYPE_PBO         TYPE ZDD_PROG_EVTYPE VALUE '130',
  GC_EVTYPE_CHANGED     TYPE ZDD_PROG_EVTYPE VALUE '410',
  GC_EVTYPE_PAI         TYPE ZDD_PROG_EVTYPE VALUE '420',
  GC_EVTYPE_FCODE       TYPE ZDD_PROG_EVTYPE VALUE '430',
  GC_TOGGLE_ON          TYPE ZDD_BM_TOGGLE VALUE '1',
  GC_TOGGLE_OFF         TYPE ZDD_BM_TOGGLE VALUE '0',
  GC_ICON_COLLAPSE      TYPE ICONNAME VALUE 'ICON_DATA_AREA_COLLAPSE',
  GC_ICON_EXPAND        TYPE ICONNAME VALUE 'ICON_DATA_AREA_EXPAND',
  GC_FIELDSTS_INACTIVE  TYPE ZDD_FIELDSTS VALUE '0000',
* Excel workbench: Form name Prefix
  GC_XLWB_FORM_PREF     TYPE WWWDATATAB-OBJID VALUE 'ZXLWB_',
* Region of excel workbench
  GC_XLWB_RELID         TYPE WWWDATATAB-RELID VALUE 'MI' .

*--------------------------------------------------------------------*
* TYPES
*--------------------------------------------------------------------*
*TYPES:
*  BEGIN OF GTY_RP_EXCEL,
*    SHEETNO     TYPE ZDD_SHEETNO,
*    SHEETDATA   TYPE ANY,
*  END OF GTY_RP_EXCEL.

TYPES:
  BEGIN OF GTY_CURSOR_INFO,
    DYNNR         TYPE DYNNR,
    FIELDNAME     TYPE FIELDNAME,
    LINE          TYPE I,
    OFFSET        TYPE I,
  END OF GTY_CURSOR_INFO,
  BEGIN OF GTY_SCR_ERR_FIELDS,
    DYNNR         TYPE DYNNR,
    ERR_FIELDS    TYPE ZTT_ERR_FIELD,
  END OF GTY_SCR_ERR_FIELDS..

*--------------------------------------------------------------------*
* ZTC_PROG
*--------------------------------------------------------------------*
DATA:
  GW_MSG_SHOWED       TYPE ZST_ERR_FIELD,
  GT_PROG_STEP        TYPE TABLE OF ZTB_PROG_STEP,
  GT_FIELD_DB         TYPE TABLE OF ZTB_FIELD_DB,
  GT_FIELD_DESC       TYPE TABLE OF ZTB_FIELD_DESC,
  GT_ERR_FIELD        TYPE TABLE OF ZST_ERR_FIELD,
  GS_LAST_CUSOR_FIELD TYPE GTY_CURSOR_INFO,
* Current check row in PAI
  GW_CURR_CHECKROW    TYPE I,

*--------------------------------------------------------------------*
* PROG FLOW
*--------------------------------------------------------------------*
  GT_PROG_FLOW        TYPE TABLE OF ZTB_PROG_FLOW,
  GT_PROG_PRSV        TYPE TABLE OF ZTB_PROG_PRSV,
  GT_PROG_PRSF        TYPE TABLE OF ZTB_PROG_PRSF,
  GT_USR_ROLE         TYPE TABLE OF ZTB_BM_USR_ROLE,
  GT_ROLE_FLD         TYPE TABLE OF ZST_BM_ROLE_FLD.
TABLES: ZST_BM_OUTTYP.
FIELD-SYMBOLS: <FS_STRUCT>  TYPE ANY.

**********************************************************************
* Output excel
**********************************************************************
DATA:
  GS_MULTITHREAD      TYPE ZST_BM_MT_INFO,
  GT_EX_SHEETS        TYPE TABLE OF ZTB_EXCEL_SHEETS,
  GT_EX_SHEET_LAYOUT  TYPE TABLE OF ZTB_SHEET_LAYOUT.

**********************************************************************
* UPDATE FIELDS INTTAB
**********************************************************************
FIELD-SYMBOLS:
  <GFT_UPDTAB>        TYPE TABLE.
DATA:
  GW_UPDTAB_SELCHK    TYPE XMARK.

*--------------------------------------------------------------------*
* MACRO START********************************************************
*--------------------------------------------------------------------*
DEFINE END.
  DATA LW_FUNCNAME TYPE CHAR30.

  SELECT SINGLE FUNCNAME INTO LW_FUNCNAME
    FROM TFDIR
    WHERE FUNCNAME = 'ZFM_CR_CACT'.
  CHECK SY-SUBRC = 0.

  CALL FUNCTION 'ZFM_CR_CACT'
    EXCEPTIONS
      INVALID = 1
      OTHERS  = 2.
  CHECK SY-SUBRC = 0.
END-OF-DEFINITION.
DEFINE BEGIN.
  END.
END-OF-DEFINITION.
*--------------------------------------------------------------------*
* MACRO END**********************************************************
*--------------------------------------------------------------------*
