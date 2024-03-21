FUNCTION ZFM_RP_OUTPUT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_REPORT) TYPE  PROGRAMM DEFAULT SY-CPROG
*"     REFERENCE(I_TABNAME) TYPE  TABNAME OPTIONAL
*"     REFERENCE(I_LOGICALFILE) TYPE  ESEFTAPPL OPTIONAL
*"     REFERENCE(I_SMARTFORM) TYPE  TDSFNAME OPTIONAL
*"     REFERENCE(I_ITEMS_FNAME) TYPE  FIELDNAME DEFAULT 'ITEMS'
*"     REFERENCE(IT_FIELDCAT) TYPE  LVC_T_FCAT OPTIONAL
*"     REFERENCE(I_DEFAULT_FILENAME) TYPE  STRING OPTIONAL
*"     REFERENCE(I_LARGE_FILE) TYPE  XMARK OPTIONAL
*"     REFERENCE(T_ALV_LAYOUT) TYPE  ZTT_ALV_LAYOUT OPTIONAL
*"     REFERENCE(T_EXCEL_LAYOUT) TYPE  ZTT_EXCEL_LAYOUT OPTIONAL
*"  CHANGING
*"     REFERENCE(I_DATA)
*"----------------------------------------------------------------------
DATA:
    LW_LOGICALFILE TYPE ESEFTAPPL,
    LW_DEFAULT_FILENAME TYPE STRING,
    LW_SMARTFORM   TYPE TDSFNAME,
    LW_FULLNAME    TYPE TEXT60.
  FIELD-SYMBOLS:
    <LF_DATA>      TYPE ANY.

  CONCATENATE '(' SY-CPROG ')P_DIS_RP' INTO LW_FULLNAME.
  ASSIGN (LW_FULLNAME) TO <LF_DATA>.
  IF SY-SUBRC IS INITIAL AND <LF_DATA> is INITIAL.
*   Do not show report, export report data to memory
    EXPORT I_DATA TO MEMORY ID I_REPORT.
  ELSE.
*----------------------------------------------------------------------
*Hien thi khi du lieu ko co - START
*----------------------------------------------------------------------
*    ASSIGN COMPONENT I_ITEMS_FNAME OF STRUCTURE I_DATA TO <LF_DATA>.
*    IF ( SY-SUBRC IS INITIAL AND
*         <LF_DATA> IS INITIAL )
*    OR I_DATA IS INITIAL.
*      MESSAGE S000(ZMS_MM) DISPLAY LIKE 'W'.
*      RETURN.
*    ENDIF.
*----------------------------------------------------------------------
*Hien thi khi du lieu ko co - END
*----------------------------------------------------------------------
*   Display report using ALV
    CONCATENATE '(' SY-CPROG ')P_ALV' INTO LW_FULLNAME.
    ASSIGN (LW_FULLNAME) TO <LF_DATA>.
    IF SY-SUBRC IS INITIAL
    AND <LF_DATA> = 'X'.
      CALL FUNCTION 'ZFM_RP_OUTPUT_ALV'
        EXPORTING
          I_REPORT      = I_REPORT
          I_TABNAME     = I_TABNAME
          I_RP_DATA     = I_DATA
          I_ITEMS_FNAME = I_ITEMS_FNAME
          IT_FIELDCAT   = IT_FIELDCAT
          T_ALV_LAYOUT  = T_ALV_LAYOUT.
    ENDIF.

*   Display report using Excel
    CONCATENATE '(' SY-CPROG ')P_EXC' INTO LW_FULLNAME.
    ASSIGN (LW_FULLNAME) TO <LF_DATA>.
    IF SY-SUBRC IS INITIAL
    AND <LF_DATA> = 'X'.
      IF I_LOGICALFILE IS NOT INITIAL.
        LW_LOGICALFILE = I_LOGICALFILE.
      ELSE.
        CONCATENATE '(' SY-CPROG ')GC_LOGICALFILE' INTO LW_FULLNAME.
        ASSIGN (LW_FULLNAME) TO <LF_DATA>.
        IF SY-SUBRC IS INITIAL.
          LW_LOGICALFILE = <LF_DATA>.
        ELSE.
          LW_LOGICALFILE = SY-TCODE.
        ENDIF.
      ENDIF.
      CALL FUNCTION 'ZFM_RP_OUTPUT_EXCEL'
        EXPORTING
          I_REPORT            = I_REPORT
          I_TABNAME           = I_TABNAME
          I_DATA              = I_DATA
          I_LOGICALFILE       = LW_LOGICALFILE
          I_DEFAULT_FILENAME  = I_DEFAULT_FILENAME
          I_LARGE_FILE        = I_LARGE_FILE
          T_EXCEL_LAYOUT      = T_EXCEL_LAYOUT.
    ENDIF.

*   Display report using Smartform
    CONCATENATE '(' SY-CPROG ')P_SMF' INTO LW_FULLNAME.
    ASSIGN (LW_FULLNAME) TO <LF_DATA>.
    IF SY-SUBRC IS INITIAL
    AND <LF_DATA> = 'X'.
      IF I_SMARTFORM IS NOT INITIAL.
        LW_SMARTFORM = I_SMARTFORM.
      ELSE.
        CONCATENATE '(' SY-CPROG ')GC_SMARTFORM' INTO LW_FULLNAME.
        ASSIGN (LW_FULLNAME) TO <LF_DATA>.
        IF SY-SUBRC IS INITIAL.
          LW_SMARTFORM = <LF_DATA>.
        ELSE.
          LW_SMARTFORM = SY-TCODE.
        ENDIF.
      ENDIF.
      CALL FUNCTION 'ZFM_RP_OUTPUT_SMF'
        EXPORTING
          I_SMARTFORM = LW_SMARTFORM
          I_DATA      = I_DATA.
    ENDIF.
  ENDIF.





ENDFUNCTION.
