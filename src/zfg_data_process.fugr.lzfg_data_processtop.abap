FUNCTION-POOL ZFG_DATA_PROCESS.             "MESSAGE-ID ..

INCLUDE ZIN_COMMONTOP.

*--------------------------------------------------------------------*
* TYPES AND CONSCTANTS***********************************************
*--------------------------------------------------------------------*
CONSTANTS:
  GC_MARK       TYPE XMARK    VALUE 'X'.

* START
*--------------------------------------------------------------------*
* ZFM_DATA_UPDATE_TABLE
* ZFM_DATA_ORIGINAL_GET
*--------------------------------------------------------------------*
TYPE-POOLS: RSDS, SLIS.
TYPES:
  BEGIN OF GTY_KEY_FIELDS,
    TABNAME           TYPE TABNAME,
    FIELDNAME         TYPE LVC_FNAME,
    VALUE             TYPE CHAR255,
  END OF GTY_KEY_FIELDS,
  GTY_T_KEY_FIELDS    TYPE TABLE OF GTY_KEY_FIELDS,
  BEGIN OF GTY_S_RANGES_TAB,
    SIGN(1)     TYPE C,
    OPTION(2)   TYPE C,
    LOW(255)    TYPE C,
    HIGH(255)   TYPE C,
    END OF GTY_S_RANGES_TAB,
  BEGIN OF GTY_SELECTION,
    FIELD_NAME  LIKE DD03D-FIELDNAME,           "Field name
    RANGES_TAB  TYPE GTY_S_RANGES_TAB OCCURS 0, "Range table
    LOG_COND(3) TYPE C,                         "Logical condition
  END OF GTY_SELECTION.
*--------------------------------------------------------------------*
* ZFM_DATA_UPDATE_TABLE
* ZFM_DATA_ORIGINAL_GET
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* TYPES AND CONSCTANTS***********************************************
*--------------------------------------------------------------------*
* END
*--------------------------------------------------------------------*


*--------------------------------------------------------------------*
* DATA***************************************************************
*--------------------------------------------------------------------*
* START
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* ZFM_DATA_VALIDATE
*--------------------------------------------------------------------*
DATA:
  GTR_DATATYPE      TYPE RANGE OF DATATYPE_D. "Data type.
*--------------------------------------------------------------------*
* ZFM_DATA_VALIDATE
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* ZFM_DATA_UPDATE_TABLE
* ZFM_DATA_ORIGINAL_GET
*--------------------------------------------------------------------*
DATA:
  GW_TABNAME          TYPE TABNAME,
  GW_TAB_RQ           TYPE E070-TRKORR,
  GT_FIELDCAT         TYPE LVC_T_FCAT,
  GT_KEYFIELDS        TYPE GTY_T_KEY_FIELDS,
  GT_SELECTION        TYPE TABLE OF GTY_SELECTION, "Logical condition
  GT_WHERE_CLAUSES  TYPE RSDS_WHERE_TAB.        "Where clause
FIELD-SYMBOLS:
  <GFT_DATA_TABLE> TYPE TABLE,
  <GF_DATA_STR>    TYPE ANY,
  <GFT_DATA_ORG>   TYPE TABLE.
*--------------------------------------------------------------------*
* ZFM_DATA_UPDATE_TABLE
* ZFM_DATA_ORIGINAL_GET
*--------------------------------------------------------------------*

**********************************************************************
* Get data description
**********************************************************************
DATA:
  GT_TAB_DESC         TYPE TABLE OF ZTB_BM_TAB_DESC.
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
DATA:
  GS_DEFAULTS         TYPE BAPIDEFAUL.

**********************************************************************
* ZFM_DATA_COMPARE_STR
**********************************************************************
DATA:
  GT_FCAT_COMPARE     TYPE LVC_T_FCAT.

**********************************************************************
* TABLE FREE SELECTION
**********************************************************************
DATA:
  GT_RSDSTABS       TYPE TABLE OF RSDSTABS,
  GT_RSDS_TRANGE    TYPE RSDS_TRANGE,
  GT_RSDSFIELDS     TYPE TABLE OF RSDSFIELDS,
  GT_EXCL_FIELDS    TYPE TABLE OF RSDSFIELDS,
  GT_RSDSFCODE      TYPE TABLE OF RSDSFCODE,
  GW_DATTAB_CURSOR  TYPE CURSOR.

*--------------------------------------------------------------------*
* DATA***************************************************************
*--------------------------------------------------------------------*
* END
*--------------------------------------------------------------------*

*--------------------------------------------------------------------*
* MACRO START********************************************************
*--------------------------------------------------------------------*
DEFINE END.
  SELECT SINGLE * FROM TFDIR
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

DATA:
  GT_XML_DATA TYPE TABLE OF ZST_BM_DATA_XML.
