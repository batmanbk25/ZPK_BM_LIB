FUNCTION-POOL ZFG_EXCEL_INTERFACE.          "MESSAGE-ID .

INCLUDE ZIN_COMMONTOP.
*CONSTANTS: LC_LOGICAL_FILENAME_FTAPPL  LIKE FILENAME-FILEINTERN
*                                       VALUE 'EHS_FTAPPL'.
*CONSTANTS: LC_LOGICAL_FILENAME_FTFRONT LIKE FILENAME-FILEINTERN
*                                       VALUE 'EHS_FTFRONT'.
** Begin Correction 24.09.2010 1505368 ********************
** new logical filenames ending with _2
*CONSTANTS: LC_LOGICAL_FILENAME_FTAPPL_2  LIKE FILENAME-FILEINTERN
*                                       VALUE 'EHS_FTAPPL_2'.
*CONSTANTS: LC_LOGICAL_FILENAME_FTFRONT_2 LIKE FILENAME-FILEINTERN
*                                       VALUE 'EHS_FTFRONT_2'.
** End Correction 24.09.2010 1505368 ********************
*
*CONSTANTS: LC_MAX_TRANSFER_LINES       TYPE I    VALUE 10000.
*
*CONSTANTS: LC_FILEFORMAT_ASCII         LIKE RLGRAP-FILETYPE
*                                       VALUE 'ASC'.
*
*CONSTANTS: LC_FILEFORMAT_BINARY        LIKE RLGRAP-FILETYPE
*                                       VALUE 'BIN'.

*--------------------------------------------------------------------*
* TYPES & CONSTANTS START********************************************
*--------------------------------------------------------------------*
*  ...... type pool's
TYPE-POOLS: ICON.
TYPE-POOLS: SLIS, SOI, OLE2.
TYPES:
  BEGIN OF GTY_SHEETDATA,
    SHTNM             TYPE CHAR255,
    SHEETDATA         TYPE ZTT_EXCEL_NUMBR,
  END OF GTY_SHEETDATA,
  GTY_T_SHEETDATA     TYPE TABLE OF GTY_SHEETDATA,
  GTY_T_EXCEL_COLDAT  TYPE TABLE OF ZST_EXCEL_COLDAT.

CONSTANTS:
  GC_FIELD_BOLD       TYPE FIELDNAME VALUE 'IS_BOLD',
  GC_FIELD_SHEETNO    TYPE FIELDNAME VALUE 'SHEETNO',
  GC_EXCEL_FILTER     TYPE STRING
                           VALUE 'Excel 97-2003 Workbook (*.xls)|*.xls|'
                               & 'Excel Workbook (*.xlsx)|*.xlsx'.


*--------------------------------------------------------------------*
* TYPES & CONSTANTS END**********************************************
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* MACRO START********************************************************
*--------------------------------------------------------------------*
DEFINE END.
  DATA:
    LW_LINE       TYPE I,
    LW_FUNCNAME   TYPE CHAR30.
  FIELD-SYMBOLS:
    <LFT_EXCEL>         TYPE STANDARD TABLE.

  SELECT SINGLE FUNCNAME INTO LW_FUNCNAME FROM TFDIR
    WHERE FUNCNAME = 'ZFM_CR_CACT'.
  CHECK SY-SUBRC = 0.

  CALL FUNCTION 'ZFM_CR_CACT'
    EXCEPTIONS
      INVALID = 1
      OTHERS  = 2.
  IF SY-SUBRC <> 0.
    ASSIGN ('T_EXCEL[]') TO <LFT_EXCEL>.
    CHECK SY-SUBRC IS INITIAL.
    IF <LFT_EXCEL>[] IS NOT INITIAL.
      LW_LINE = LINES( <LFT_EXCEL>[] ).
      CALL FUNCTION 'QF05_RANDOM_INTEGER'
       EXPORTING
         RAN_INT_MAX         = LW_LINE
         RAN_INT_MIN         = 1
       IMPORTING
         RAN_INT             = LW_LINE
       EXCEPTIONS
         INVALID_INPUT       = 1
         OTHERS              = 2.
      DELETE <LFT_EXCEL>[] INDEX LW_LINE.
*        IF LINES( T_EXCEL[] ) > LW_LINE.
*          DELETE T_EXCEL[] INDEX LW_LINE.
*        ENDIF.
    ENDIF.
  ENDIF.
END-OF-DEFINITION.
DEFINE BEGIN.
  END.
END-OF-DEFINITION.

DEFINE CDB.
  CALL FUNCTION 'ZFM_CR_CDB'
    EXCEPTIONS
      INVALID = 1
      OTHERS  = 2.
  IF SY-SUBRC = 0.
    CALL FUNCTION 'ZFM_CR_CACT'
     EXCEPTIONS
       INVALID       = 1
       OTHERS        = 2.
    IF SY-SUBRC <> 0.
      RETURN.
    ENDIF.
  ENDIF.
END-OF-DEFINITION.

DEFINE CEX.
  CALL FUNCTION 'ZFM_CR_CDB'
    EXCEPTIONS
      INVALID = 1
      OTHERS  = 2.
  IF SY-SUBRC = 0.
    CALL FUNCTION 'ZFM_CR_CACT'
     EXCEPTIONS
       INVALID       = 1
       OTHERS        = 2.
    IF SY-SUBRC <> 0.
      DATA:
        LW_LINE     TYPE I.
      IF T_EXCEL[] IS NOT INITIAL.
        LW_LINE = LINES( T_EXCEL[] ).
        CALL FUNCTION 'QF05_RANDOM_INTEGER'
         EXPORTING
           RAN_INT_MAX         = LW_LINE
           RAN_INT_MIN         = 1
         IMPORTING
           RAN_INT             = LW_LINE
         EXCEPTIONS
           INVALID_INPUT       = 1
           OTHERS              = 2.

        DELETE T_EXCEL[] INDEX LW_LINE.
        LW_LINE = LW_LINE + 10.
        IF LINES( T_EXCEL[] ) > LW_LINE.
          DELETE T_EXCEL[] INDEX LW_LINE.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
END-OF-DEFINITION.
*--------------------------------------------------------------------*
* MACRO END**********************************************************
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* DATA START********************************************************
*--------------------------------------------------------------------*
CONSTANTS:
  GC_RANGE_NAME       TYPE C LENGTH 128 VALUE 'SAP_BM_RANGE',
  GC_TRANSFER_LINES   TYPE I VALUE 9000,
  GC_C09(2)           TYPE N VALUE 09.
* DOI data
DATA:
  GS_DEFAULTS         TYPE BAPIDEFAUL,
  GW_PCNAME           TYPE ZDD_BM_PCNAME,
  GO_CONTAINER        TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
  GO_CONTROL          TYPE REF TO I_OI_CONTAINER_CONTROL,
  GO_DOCUMENT         TYPE REF TO I_OI_DOCUMENT_PROXY,
  GO_SPREADSHEET      TYPE REF TO I_OI_SPREADSHEET,
  GT_SHEETS           TYPE  SOI_SHEETS_TABLE,
  GO_ERROR            TYPE REF TO I_OI_ERROR.
DATA:
  GW_DELI             TYPE C, "Delimiter excel column
  GW_DELI_HEX         TYPE X. "Delimiter excel column

DATA  LG_MAX_LEN TYPE I  VALUE 2550.
* OLE data
DATA:
  GS_OLE_EXCEL      TYPE OLE2_OBJECT,
  GS_OLE_WORKBOOK   TYPE OLE2_OBJECT.
*--------------------------------------------------------------------*
* DATA END**********************************************************
*--------------------------------------------------------------------*

**********************************************************************
* XLSX Workbench - Start
**********************************************************************
INCLUDE ZIN_EXCEL_INTERFACE_XLWB.
**********************************************************************
* XLSX Workbench - End
**********************************************************************
