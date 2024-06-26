FUNCTION ZFM_POPUP_SET_DATA_INTTAB.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT_FIELDS) TYPE  TY_SVAL OPTIONAL
*"     VALUE(I_SELCHK) TYPE  XMARK OPTIONAL
*"     VALUE(I_POPUP_TITLE) TYPE  STRING OPTIONAL
*"     REFERENCE(I_SUB_TABNAME) TYPE  TABNAME OPTIONAL
*"     REFERENCE(I_SUB_FNAME) TYPE  FIELDNAME OPTIONAL
*"     REFERENCE(I_SUB_REQUIRED) TYPE  XMARK DEFAULT 'X'
*"     VALUE(I_REC_DEFAULT) TYPE  ANY OPTIONAL
*"  EXPORTING
*"     REFERENCE(RETURNCODE)
*"  CHANGING
*"     REFERENCE(C_TABLE) TYPE  ANY TABLE
*"----------------------------------------------------------------------
  DATA:
    LT_FIELDS	                TYPE TABLE OF	SVAL,
    LW_RETURNCODE             TYPE C,
    LR_DATA                   TYPE REF TO DATA.
  FIELD-SYMBOLS:
    <LF_REC_DEFAULT>          TYPE ANY.

  ASSIGN C_TABLE TO <GFT_UPDTAB>.
  GW_UPDTAB_SELCHK = I_SELCHK.

  IF IT_FIELDS IS INITIAL.
*   Gen record default values
    IF I_REC_DEFAULT IS SUPPLIED.
      ASSIGN I_REC_DEFAULT TO  <LF_REC_DEFAULT>.
    ELSE.
      CREATE DATA LR_DATA LIKE LINE OF <GFT_UPDTAB>.
      ASSIGN LR_DATA->* TO <LF_REC_DEFAULT>.

      IF LINES( C_TABLE ) = 1.
        READ TABLE <GFT_UPDTAB> INTO <LF_REC_DEFAULT> INDEX 1.
      ENDIF.
    ENDIF.

*   Build update fields
    PERFORM 9999_BUILD_UPDFIELDS
      USING I_SUB_TABNAME
            I_SUB_FNAME
            I_SUB_REQUIRED
            <LF_REC_DEFAULT>
     CHANGING LT_FIELDS
              I_POPUP_TITLE.
  ELSE.
    LT_FIELDS = IT_FIELDS.
  ENDIF.

* Popup to get values
  CALL FUNCTION 'POPUP_GET_VALUES_USER_CHECKED'
    EXPORTING
      FORMNAME        = '9999_SET_FIELDS_TO_INTTAB'
      POPUP_TITLE     = I_POPUP_TITLE
      PROGRAMNAME     = SY-REPID
    IMPORTING
      RETURNCODE      = LW_RETURNCODE
    TABLES
      FIELDS          = LT_FIELDS
    EXCEPTIONS
      ERROR_IN_FIELDS = 1
      OTHERS          = 2.

ENDFUNCTION.
