FUNCTION ZFM_SCR_FIELD_CONVERT_TO_OUT.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_FIELDNAME) TYPE  CHAR61 OPTIONAL
*"  CHANGING
*"     REFERENCE(C_FIELD) TYPE  ANY
*"--------------------------------------------------------------------
DATA:
    LW_TABNAME    TYPE TABNAME,
    LW_FNAME      TYPE FNAM_____4,
    LS_DFIES      TYPE DFIES,
    LS_DD04V      TYPE DD04V,
    LW_DATEL      TYPE DDOBJNAME,
    LW_CONVEXIT   TYPE CONVEXIT,
    LW_FMCONV     TYPE RS38L_FNAM.

  IF I_FIELDNAME IS INITIAL.
*   Get field name by type of screen element
    DESCRIBE FIELD C_FIELD HELP-ID LW_FNAME.
  ELSE.
    LW_FNAME = I_FIELDNAME.
  ENDIF.

  IF LW_FNAME CA '-'.
*   If type is 'like', get table name, field name
    SPLIT LW_FNAME AT '-' INTO LW_TABNAME LW_FNAME.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        TABNAME        = LW_TABNAME
        LFIELDNAME     = LW_FNAME
      IMPORTING
        DFIES_WA       = LS_DFIES
      EXCEPTIONS
        NOT_FOUND      = 1
        INTERNAL_ERROR = 2
        OTHERS         = 3.
    IF SY-SUBRC IS INITIAL.
      LW_CONVEXIT = LS_DFIES-CONVEXIT.
    ENDIF.
  ELSE.
    LW_DATEL = LW_FNAME.
*   if LPW_Fieldname Is data element, Get data element info
    CALL FUNCTION 'DDIF_DTEL_GET'
      EXPORTING
        NAME          = LW_DATEL
        LANGU         = SY-LANGU
      IMPORTING
        DD04V_WA      = LS_DD04V
      EXCEPTIONS
        ILLEGAL_INPUT = 1
        OTHERS        = 2.
    IF SY-SUBRC = 0.
      LW_CONVEXIT = LS_DD04V-CONVEXIT.
    ENDIF.
  ENDIF.

  IF LW_CONVEXIT IS NOT INITIAL.
*   Get Function module Output of Conversion exit
    CONCATENATE 'CONVERSION_EXIT_' LW_CONVEXIT '_OUTPUT' INTO LW_FMCONV.

*   Check FM exists
    CALL FUNCTION 'FUNCTION_EXISTS'
      EXPORTING
        FUNCNAME                 = LW_FMCONV
     EXCEPTIONS
       FUNCTION_NOT_EXIST       = 1
       OTHERS                   = 2.
    IF SY-SUBRC IS INITIAL.
*     Call FM conversion exit to convert data output
      CALL FUNCTION LW_FMCONV
        EXPORTING
          INPUT         = C_FIELD
       IMPORTING
         OUTPUT        = C_FIELD.
    ENDIF.
  ENDIF.





ENDFUNCTION.
