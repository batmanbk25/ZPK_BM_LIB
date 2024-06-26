FUNCTION ZFM_DATTAB_BUILD_WITH_KEYS.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_TABNAME) TYPE  TABNAME OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_REF_TABDATA) TYPE REF TO DATA
*"     REFERENCE(E_REF_TABDATA2) TYPE REF TO DATA
*"     REFERENCE(E_REF_TABDATA3) TYPE REF TO DATA
*"  CHANGING
*"     REFERENCE(T_FIELDCAT) TYPE  LVC_T_FCAT OPTIONAL
*"--------------------------------------------------------------------
DATA:
    LT_KEYS                       TYPE TABLE OF FIELDNAME,
    LS_FIELDCAT                   TYPE LVC_S_FCAT.

* Get fieldcatalog
  IF T_FIELDCAT IS INITIAL.
    CHECK I_TABNAME IS NOT INITIAL.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        I_STRUCTURE_NAME             = I_TABNAME
        I_INTERNAL_TABNAME           = I_TABNAME
      CHANGING
        CT_FIELDCAT                  = T_FIELDCAT
      EXCEPTIONS
        INCONSISTENT_INTERFACE       = 1
        PROGRAM_ERROR                = 2
        OTHERS                       = 3.
  ENDIF.

* Init
  CLEAR LT_KEYS.
  LOOP AT T_FIELDCAT INTO LS_FIELDCAT WHERE KEY = GC_XMARK.
    APPEND LS_FIELDCAT-FIELDNAME TO LT_KEYS.
  ENDLOOP.

* Create table
  CREATE DATA E_REF_TABDATA TYPE STANDARD TABLE OF
         (I_TABNAME) WITH KEY (LT_KEYS).

  IF E_REF_TABDATA2 IS REQUESTED.
    CREATE DATA E_REF_TABDATA2 TYPE STANDARD TABLE OF
           (I_TABNAME) WITH KEY (LT_KEYS).
  ENDIF.

  IF E_REF_TABDATA3 IS REQUESTED.
    CREATE DATA E_REF_TABDATA3 TYPE STANDARD TABLE OF
           (I_TABNAME) WITH KEY (LT_KEYS).
  ENDIF.





ENDFUNCTION.
