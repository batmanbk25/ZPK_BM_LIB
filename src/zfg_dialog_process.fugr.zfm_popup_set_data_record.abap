FUNCTION ZFM_POPUP_SET_DATA_RECORD.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT_FIELDS) TYPE  TY_SVAL OPTIONAL
*"     VALUE(I_POPUP_TITLE) TYPE  STRING OPTIONAL
*"     REFERENCE(I_SUB_TABNAME) TYPE  TABNAME OPTIONAL
*"     REFERENCE(I_SUB_FNAME) TYPE  FIELDNAME OPTIONAL
*"     REFERENCE(I_SUB_REQUIRED) TYPE  XMARK DEFAULT 'X'
*"     REFERENCE(I_DB_CHECK) TYPE  XMARK OPTIONAL
*"  EXPORTING
*"     REFERENCE(RETURNCODE)
*"  CHANGING
*"     REFERENCE(C_RECORD) TYPE  ANY
*"----------------------------------------------------------------------
  DATA:
      LT_FIELDS	      TYPE TABLE OF	SVAL.

  IF IT_FIELDS IS INITIAL.
    PERFORM 9999_BUILD_UPDFIELDS
      USING I_SUB_TABNAME
            I_SUB_FNAME
            I_SUB_REQUIRED
            C_RECORD
     CHANGING LT_FIELDS
              I_POPUP_TITLE.
  ELSE.
    LT_FIELDS = IT_FIELDS.
  ENDIF.

* Popup
  IF I_DB_CHECK IS INITIAL.
    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
        POPUP_TITLE     = I_POPUP_TITLE
      IMPORTING
        RETURNCODE      = RETURNCODE
      TABLES
        FIELDS          = LT_FIELDS
      EXCEPTIONS
        ERROR_IN_FIELDS = 1
        OTHERS          = 2.
  ELSE.
    CALL FUNCTION 'POPUP_GET_VALUES_USER_HELP'
      EXPORTING
*       F1_FORMNAME     = ' '
*       F1_PROGRAMNAME  = ' '
*       F4_FORMNAME     = ' '
*       F4_PROGRAMNAME  = ' '
*       FORMNAME        = ' '
        POPUP_TITLE     = I_POPUP_TITLE
*       PROGRAMNAME     = ' '
      IMPORTING
        RETURNCODE      = RETURNCODE
      TABLES
        FIELDS          = LT_FIELDS
      EXCEPTIONS
        ERROR_IN_FIELDS = 1
        OTHERS          = 2.
    IF SY-SUBRC <> 0.
* Implement suitable error handling here
    ENDIF.
  ENDIF.
  CHECK RETURNCODE IS INITIAL.

* Set value in popup
  PERFORM 9999_SET_FIELDS_TO_RECORD
    USING LT_FIELDS
          GC_XMARK
    CHANGING C_RECORD.

ENDFUNCTION.
