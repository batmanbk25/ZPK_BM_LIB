*&---------------------------------------------------------------------*
*& Include ZIN_DTG99_011TOP               Report ZPG_DTG99_011
*&
*&---------------------------------------------------------------------*

*INCLUDE ZIN_COMMON_BPTOP.
INCLUDE ZIN_COMMONTOP.

**********************************************************************
* CONSTANTS
**********************************************************************
CONSTANTS:
  GC_TAB_QTTG       TYPE TABNAME VALUE 'ZTB1_PARTI_D',
  GC_TAB_QTD        TYPE TABNAME VALUE 'ZTB1_PAYMENT_D',
  GC_TAB_HICARD     TYPE TABNAME VALUE 'ZTB1_PARTI_D'.

**********************************************************************
* DATA
**********************************************************************
*TABLES:
*  ZST_TABKEY_HDR.",
*  ZTB_CV_CANHAN,
*  BUT000.

DATA:
*  GT_BUT000_CN      TYPE TABLE OF ZST_DCDC_CANHAN,
*  GT_CV_CANHAN      TYPE TABLE OF ZST_DCDC_CANHAN,
*  GT_BUT000_TC      TYPE TABLE OF ZST_DCDC_TOCHUC,
*  GT_CV_TOCHUC      TYPE TABLE OF ZST_DCDC_TOCHUC,
*  GT_PARTI_D        TYPE TABLE OF ZTB1_PARTI_D,
*  GT_CV_QTTG        TYPE TABLE OF ZTB_CV_QTTG,
*  GT_PAYMENT_D      TYPE TABLE OF ZTB1_PAYMENT_D,
*  GT_CV_QTD         TYPE TABLE OF ZTB_CV_QTD,
*  GT_HICARD         TYPE TABLE OF ZTB_HICARD,
*  GT_CV_THE         TYPE TABLE OF ZTB_CV_THE,
  GW_SELID          TYPE DYNSELID,
  GT_WHERE_CLAUSES  TYPE TT_RSDSWHERE,
  GS_OTHER_DATA     TYPE ZST_MCBA_REF_DATA,
  GW_CURSOR         TYPE CURSOR.
FIELD-SYMBOLS:
  <GFT_TAB_DATA>    TYPE ANY TABLE.

**********************************************************************
* PARAMETERS
**********************************************************************
SELECTION-SCREEN BEGIN OF BLOCK MCTYPE WITH FRAME TITLE TEXT-001.
PARAMETERS:
  P_MCTYUP          TYPE XMARK RADIOBUTTON GROUP MCTY
                               USER-COMMAND FCMCTY DEFAULT 'X',
  P_MCTYBU          TYPE XMARK RADIOBUTTON GROUP MCTY ,
  P_MCTYFM          TYPE XMARK RADIOBUTTON GROUP MCTY .
SELECTION-SCREEN END OF BLOCK MCTYPE.

SELECTION-SCREEN BEGIN OF BLOCK PAR WITH FRAME TITLE TEXT-002.
PARAMETERS:
  P_TABNM           TYPE TABNAME,
  P_TABMID          TYPE ZDD_TABMCID  MODIF ID UP,
  P_TABBU           TYPE TABNAME      MODIF ID BU,
  P_FMNAME          TYPE RS38L_FNAM   MODIF ID FM.
SELECTION-SCREEN END OF BLOCK PAR.

SELECTION-SCREEN BEGIN OF BLOCK PER WITH FRAME TITLE TEXT-003.
PARAMETERS:
  P_PSIZE           TYPE I DEFAULT 5000,
  P_CNALL           TYPE XMARK.
SELECTION-SCREEN END OF BLOCK PER.
