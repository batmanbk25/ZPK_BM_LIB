*&---------------------------------------------------------------------*
*&  Include           ZIN_IMP_TAB_FROM_EXCELF01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  0000_MAIN_PROC
*&---------------------------------------------------------------------*
*       Main process
*----------------------------------------------------------------------*
FORM 0000_MAIN_PROC.
  DATA:
    LREF_DATA         TYPE REF TO DATA,
    LREF_DATA2        TYPE REF TO DATA,
    LREF_DATA3        TYPE REF TO DATA,
    LT_EXCEL_MAPPING  TYPE ZTT_EXCEL_MAPPING,
    LS_EXCEL_MAPPING  TYPE ZST_EXCEL_MAPPING,
    LS_FIELDCAT       TYPE LVC_S_FCAT.
  FIELD-SYMBOLS:
    <LF_NEW_DATA>     TYPE ANY,
    <LF_NEW_VALUE>    TYPE ANY,
    <LF_ORG_DATA>     TYPE ANY,
    <LF_ORG_VALUE>    TYPE ANY.

* Build structure data
  CALL FUNCTION 'ZFM_DATTAB_BUILD_WITH_KEYS'
    EXPORTING
      I_TABNAME           = P_TABNM
    IMPORTING
      E_REF_TABDATA       = LREF_DATA
      E_REF_TABDATA2      = LREF_DATA2
      E_REF_TABDATA3      = LREF_DATA3
    CHANGING
      T_FIELDCAT          = GT_FIELDCAT.
  ASSIGN LREF_DATA->* TO <GFT_NEW_DATA>.
  ASSIGN LREF_DATA2->* TO <GFT_ORG_DATA>.
  ASSIGN LREF_DATA3->* TO <GFT_ORG_DATA_TMP>.

  CREATE DATA LREF_DATA LIKE LINE OF <GFT_ORG_DATA>.
  ASSIGN LREF_DATA->* TO <LF_ORG_DATA>.

* Import data from excel
  CALL FUNCTION 'ZFM_FILE_EXCEL_IMP2TAB_ATM'
    EXPORTING
      I_LOCALFILE           = P_FILENM
      I_READING_LINE        = P_RLINES
    IMPORTING
      T_IMPTAB              = <GFT_NEW_DATA>
      T_EXCEL_MAPPING	      = LT_EXCEL_MAPPING
    CHANGING
      T_FIELDCAT            = GT_FIELDCAT
    EXCEPTIONS
      OPENFILE_ERROR        = 1
      NO_MAPPING            = 2
      READ_DATA_ERROR       = 3
      MAPPING_ERROR         = 4
      OTHERS                = 5.

  READ TABLE GT_FIELDCAT INTO LS_FIELDCAT
    WITH KEY DOMNAME = 'MANDT'.
  IF SY-SUBRC IS INITIAL.
    LOOP AT <GFT_NEW_DATA> ASSIGNING <LF_NEW_DATA>.
      ASSIGN COMPONENT LS_FIELDCAT-FIELDNAME OF STRUCTURE <LF_NEW_DATA>
        TO <LF_NEW_VALUE>.
      IF SY-SUBRC IS INITIAL.
        <LF_NEW_VALUE> = SY-MANDT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF P_GETORG IS NOT INITIAL.
*   Get original data to update
    CALL FUNCTION 'ZFM_DATA_ORIGINAL_GET'
      EXPORTING
        T_TABLE_CURRENT          = <GFT_NEW_DATA>
        T_FIELDCAT               = GT_FIELDCAT
      IMPORTING
        T_TABLE_ORIGINAL         = <GFT_ORG_DATA>
      EXCEPTIONS
        NO_STRUCTURE             = 1
        CONFLICT_STRUCTURE       = 2
        NO_DATA                  = 3
        OTHERS                   = 4.
    IF SY-SUBRC <> 0.
      MESSAGE S008(ZMS_COL_LIB).
      STOP.
    ENDIF.
  ENDIF.

* Loop new data to update original data
  LOOP AT <GFT_NEW_DATA> ASSIGNING <LF_NEW_DATA>.
*   Find original data
    READ TABLE <GFT_ORG_DATA> INTO <LF_ORG_DATA>
      FROM <LF_NEW_DATA>.
    IF SY-SUBRC IS INITIAL.
      LOOP AT LT_EXCEL_MAPPING INTO LS_EXCEL_MAPPING.
        UNASSIGN: <LF_ORG_VALUE>, <LF_NEW_VALUE>.
        ASSIGN COMPONENT LS_EXCEL_MAPPING-FIELDNAME
          OF STRUCTURE <LF_ORG_DATA> TO <LF_ORG_VALUE>.
        ASSIGN COMPONENT LS_EXCEL_MAPPING-FIELDNAME
          OF STRUCTURE <LF_NEW_DATA> TO <LF_NEW_VALUE>.
        CHECK: <LF_NEW_VALUE> IS ASSIGNED, <LF_ORG_VALUE> IS ASSIGNED.
        <LF_ORG_VALUE> = <LF_NEW_VALUE>.
      ENDLOOP.
      <LF_NEW_DATA> = <LF_ORG_DATA>.
    ENDIF.
  ENDLOOP.

* Show change data
  CALL SCREEN 100.
*  CALL FUNCTION 'ZFM_ALV_DISPLAY'
*    EXPORTING
*      IT_FIELDCAT                       = GT_FIELDCAT
*    TABLES
*      T_OUTTAB                          = <GFT_NEW_DATA>.

ENDFORM.                    " 0000_MAIN_PROC

*&---------------------------------------------------------------------*
*&      Form  1000_PAI
*&---------------------------------------------------------------------*
*       PAI for screen 1000
*----------------------------------------------------------------------*
FORM 1000_PAI .
  DATA:
    LW_FILENAME         TYPE STRING,
    LW_RESULT           TYPE XMARK,
    LW_SUBRC            TYPE SY-SUBRC.

  CALL FUNCTION 'DD_EXIST_TABLE'
    EXPORTING
      TABNAME            = P_TABNM
      STATUS             = 'A'
*     NTAB               = ' '
    IMPORTING
      SUBRC              = LW_SUBRC
    EXCEPTIONS
      WRONG_STATUS       = 1
      OTHERS             = 2.
  IF SY-SUBRC <> 0 OR LW_SUBRC IS NOT INITIAL.
    MESSAGE S007(ZMS_COL_LIB) DISPLAY LIKE GC_MTYPE_E WITH P_TABNM.
    SET CURSOR FIELD 'P_TABNM'.
    STOP.
  ENDIF.

  LW_FILENAME = P_FILENM.
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIST
    EXPORTING
      FILE                 = LW_FILENAME
    RECEIVING
      RESULT               = LW_RESULT
    EXCEPTIONS
      CNTL_ERROR           = 1
      ERROR_NO_GUI         = 2
      WRONG_PARAMETER      = 3
      NOT_SUPPORTED_BY_GUI = 4
      OTHERS               = 5.
  IF SY-SUBRC <> 0 OR LW_RESULT IS INITIAL.
    MESSAGE S006(ZMS_COL_LIB) DISPLAY LIKE GC_MTYPE_E WITH LW_FILENAME.
    SET CURSOR FIELD 'P_FILENM'.
    STOP.
  ENDIF.

ENDFORM.                    " 1000_PAI
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'ZGS_100'.
  SET TITLEBAR 'ZGT_100'.

  PERFORM 100_PBO.

ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.
  CALL FUNCTION 'ZFM_SCR_SIMPLE_FC_PROCESS'.
  CASE SY-UCOMM.
    WHEN GC_FC_SAVE.
      PERFORM 100_PROCESS_FC_SAVE.
    WHEN 'FC_OLDDATA'.
      CALL FUNCTION 'ZFM_ALV_DISPLAY'
        EXPORTING
          IT_FIELDCAT                       = GT_FIELDCAT
          I_GRID_TITLE                      = 'Old data'
          I_SCREEN_START_COLUMN             = 5
          I_SCREEN_START_LINE               = 4
          I_SCREEN_END_COLUMN               = 150
          I_SCREEN_END_LINE                 = 30
*          IT_EXCLUDING                      =
        TABLES
          T_OUTTAB                          = <GFT_ORG_DATA>.

    WHEN OTHERS.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Form  100_PROCESS_FC_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 100_PROCESS_FC_SAVE .
  CONSTANTS:
    LC_PACK     TYPE I VALUE 5000.
  DATA:
    LW_PACK     TYPE I,
    LW_LINES    TYPE I.

  WHILE <GFT_NEW_DATA>[] IS NOT INITIAL.
    LW_LINES = LINES( <GFT_NEW_DATA> ).
    CLEAR: <GFT_ORG_DATA_TMP>.
    IF LW_LINES > LC_PACK.
      LW_PACK = LC_PACK.
    ELSE.
      LW_PACK = LINES( <GFT_NEW_DATA> ).
    ENDIF.
    APPEND LINES OF <GFT_NEW_DATA>
      FROM 1 TO LW_PACK TO <GFT_ORG_DATA_TMP> .
    DELETE <GFT_NEW_DATA> FROM 1 TO LW_PACK.
    INSERT (P_TABNM)
      FROM TABLE <GFT_ORG_DATA_TMP> ACCEPTING DUPLICATE KEYS.
    IF SY-SUBRC IS NOT INITIAL.
      UPDATE (P_TABNM) FROM TABLE <GFT_ORG_DATA_TMP>.
    ENDIF.
  ENDWHILE.

  COMMIT WORK.
  MESSAGE S009(ZMS_COL_LIB).
ENDFORM.                    " 100_PROCESS_FC_SAVE

*&---------------------------------------------------------------------*
*&      Form  100_PBO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 100_PBO .
  DATA:
    LS_LAYOUT     TYPE LVC_S_LAYO,
    LT_EXCL_FC    TYPE UI_FUNCTIONS.

  LS_LAYOUT-CWIDTH_OPT  = GC_XMARK.

  CALL FUNCTION 'ZFM_ALV_EXCL_EDIT_FC'
    IMPORTING
      T_EXCL_FC       = LT_EXCL_FC.


  CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR'
    EXPORTING
      I_CUS_CONTROL_NAME         = 'CUS_ALV_DATA'
      IS_LAYOUT                  = LS_LAYOUT
      IT_TOOLBAR_EXCLUDING       = LT_EXCL_FC
*   IMPORTING
*     E_ALV_GRID                 =
    CHANGING
      IT_OUTTAB                  = <GFT_NEW_DATA>
      IT_FIELDCATALOG            = GT_FIELDCAT.
ENDFORM.                    " 100_PBO
