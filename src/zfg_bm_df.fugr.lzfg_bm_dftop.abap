FUNCTION-POOL ZFG_BM_DF.                    "MESSAGE-ID ..

INCLUDE ZIN_COMMONTOP.
* INCLUDE LZFG_BM_DFD...                     " Local class definition

**********************************************************************
* TYPES
**********************************************************************
TYPES:
  BEGIN OF GTY_STRUCT_ID,
    RECORDID                  TYPE CHAR32,
    RECORDGUID                TYPE SYSUUID_C32,
  END OF GTY_STRUCT_ID.

**********************************************************************
* CONSTANTS
**********************************************************************
CONSTANTS:
  GC_CHKTYP_FORMAT            TYPE ZDD_BM_DF_CHKTYP VALUE 1,
  GC_CHKTYP_FM                TYPE ZDD_BM_DF_CHKTYP VALUE 2,
  GC_CHKTYP_LIST              TYPE ZDD_BM_DF_CHKTYP VALUE 3,

  "$. Region: Format Check list
* dd-mm-yyyy
  GC_CFORMAT_D1	              TYPE ZDD_BM_DF_FORMAT VALUE 'D1',
  GC_REGEX_D1                 TYPE STRING
                                VALUE '^(\d{2})-(\d{2})-(\d{4})(\s)*$',
  GC_REGEX_REPLACE_D1         TYPE STRING VALUE `$3$2$1`,
  GC_TFORMAT_D1               TYPE STRING VALUE 'dd-mm-yyyy',
* dd/mm/yyyy
  GC_CFORMAT_D2	              TYPE ZDD_BM_DF_FORMAT VALUE 'D2',
  GC_REGEX_D2                 TYPE STRING
                                VALUE '^(\d{2})/(\d{2})/(\d{4})(\s)*$',
  GC_REGEX_REPLACE_D2         TYPE STRING VALUE `$3$2$1`,
  GC_TFORMAT_D2               TYPE STRING VALUE 'dd/mm/yyyy',
* yyyy-mm-dd
  GC_CFORMAT_D3	              TYPE ZDD_BM_DF_FORMAT VALUE 'D3',
  GC_REGEX_D3                 TYPE STRING
                                VALUE '^(\d{4})-(\d{2})-(\d{2})(\s)*$',
  GC_REGEX_REPLACE_D3         TYPE STRING VALUE `$1$2$3`,
  GC_TFORMAT_D3               TYPE STRING VALUE 'yyyy-mm-dd',
* dd-mmm-yyyy hh:mm:ss
  GC_CFORMAT_D4	              TYPE ZDD_BM_DF_FORMAT VALUE 'D4',
  GC_REGEX_D4                 TYPE STRING
    VALUE '^(\d{2})-(\C{3})-(\d{4}) (\d{2}):(\d{2}):(\d{2})(\s)*$',
  GC_REGEX_REPLACE_D4         TYPE STRING VALUE `$1.$2.$3`,
  GC_TFORMAT_D4               TYPE STRING VALUE 'dd-mmm-yyyy hh:mm:ss',
* dd.mm.yyyy
  GC_CFORMAT_D5               TYPE ZDD_BM_DF_FORMAT VALUE 'D5',
  GC_REGEX_D5                 TYPE STRING
                                VALUE '^(\d{2}).(\d{2}).(\d{4})(\s)*$',
  GC_REGEX_REPLACE_D5         TYPE STRING VALUE `$3$2$1`,
  GC_TFORMAT_D5               TYPE STRING VALUE 'dd.mm.yyyy',
* mm-yyyy
  GC_CFORMAT_M1	              TYPE ZDD_BM_DF_FORMAT VALUE 'M1',
  GC_REGEX_M1                 TYPE STRING
                                VALUE '^(\d{2})/(\d{4})(\s)*$',
  GC_REGEX_REPLACE_M1         TYPE STRING VALUE `$2$1`,
  GC_TFORMAT_M1               TYPE STRING VALUE 'mm-yyyy',
* Number
  GC_CFORMAT_NUM              TYPE ZDD_BM_DF_FORMAT VALUE 'NUM',
  GC_REGEX_NUM                TYPE STRING
                                VALUE '^(\d+)(\s)*$',
  GC_REGEX_REPLACE_NUM        TYPE STRING VALUE `$1`,
  GC_TFORMAT_NUM              TYPE STRING VALUE 'Number',
* Currency
  GC_CFORMAT_CUR              TYPE ZDD_BM_DF_FORMAT VALUE 'CUR',
  GC_REGEX_CUR                TYPE STRING
                                VALUE '^(\d+)(\s)*$',
  GC_REGEX_REPLACE_CUR        TYPE STRING VALUE `$1$2$3`,
  GC_TFORMAT_CUR              TYPE STRING VALUE 'Currency',
* Decimal
  GC_CFORMAT_DEC              TYPE ZDD_BM_DF_FORMAT VALUE 'DEC',
  GC_REGEX_DEC                TYPE STRING VALUE
                                '^(\d+)(?:(\s)*|([.,])([\d]+))(\s)*$',
  GC_REGEX_REPLACE_DEC        TYPE STRING VALUE `$1.$4`,
  GC_TFORMAT_DEC              TYPE STRING VALUE 'Decimal',
* Char
  GC_CFORMAT_CHR              TYPE ZDD_BM_DF_FORMAT VALUE 'CHR',
  "$. Endregion: Format Check list

* Field code
  GC_FIELD_COUNTRY            TYPE FIELDNAME VALUE 'COUNTRY',
  GC_FIELD_REGION             TYPE FIELDNAME VALUE 'REGION',
  GC_FIELD_CITY               TYPE FIELDNAME VALUE 'CITY',
  GC_FIELD_DISTRICT           TYPE FIELDNAME VALUE 'DISTRICT',
  GC_FIELD_DATE_CHK02         TYPE FIELDNAME VALUE 'DATE_CHK02',
  GC_FIELD_DATE_CHK03         TYPE FIELDNAME VALUE 'DATE_CHK03'.

**********************************************************************
* TYPES
**********************************************************************


**********************************************************************
* DATA
**********************************************************************
DATA:
  GT_COUNTRY                  TYPE TABLE OF T005,
  GT_REGIONS                  TYPE TABLE OF ZST_REGION,
  GT_CITY                     TYPE TABLE OF ZST_CITY,
  GT_DISTRICT                 TYPE TABLE OF ZST_DISTRICT,
  GT_DF_TYPE                  TYPE TABLE OF ZTB_BM_DF_TYP,
  GT_DF_TYPLS                 TYPE TABLE OF ZTB_BM_DF_TYPLS,
  GT_DF_TYPEC                 TYPE TABLE OF ZTB_BM_DF_TYP_EC,
  GT_DF_ECODE                 TYPE TABLE OF ZTB_BM_DF_EC,
  GT_DF_CHKGRP_DAT            TYPE TABLE OF ZST_BM_DF_CHKGRP_DAT.
