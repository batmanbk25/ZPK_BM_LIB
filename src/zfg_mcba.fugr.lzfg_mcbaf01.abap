*----------------------------------------------------------------------*
***INCLUDE LZFG_MCBAF01.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  UPDATE_FIELD_USE_KEYGRP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPS_MC_BUSFLD   Field config
*      -->LPS_BUSELE      Element data
*      <--LPW_FIELD       Change fields
*----------------------------------------------------------------------*
FORM UPDATE_FIELD_USE_KEYGRP
  USING    LPS_MC_BUSFLD  TYPE ZST_MCBA_FIELD_CHANGE
           LPS_RECORD     TYPE ANY
  CHANGING LPW_FIELD      TYPE ANY.

  DATA:
    LS_MC_BUSKEYG         TYPE ZTB_MC_BUSKEYG,
    LS_MC_BUSKEYE         TYPE ZTB_MC_BUSKEYE,
    LS_MC_BUSKEYM         TYPE ZTB_MC_BUSKEYGM,
    LW_KEYGVAL            TYPE ZDD_MCKEYGVAL,
    LW_KEYVAL             TYPE TEXT100.
  FIELD-SYMBOLS:
    <LF_KEY>              TYPE ANY.

* Lay key group ID
  READ TABLE GT_MC_BUSKEYG INTO LS_MC_BUSKEYG
    WITH KEY KEYGRP = LPS_MC_BUSFLD-KEYGRP.
  IF SY-SUBRC IS INITIAL.
    CLEAR: LW_KEYGVAL.

*   Build key group value
    LOOP AT GT_MC_BUSKEYE INTO LS_MC_BUSKEYE
      WHERE KEYGRP = LPS_MC_BUSFLD-KEYGRP.
      ASSIGN COMPONENT LS_MC_BUSKEYE-FIELDNAME
        OF STRUCTURE LPS_RECORD TO <LF_KEY>.
      IF SY-SUBRC IS INITIAL.
        IF <LF_KEY> IS INITIAL.
          CLEAR: LW_KEYVAL.
        ELSE.
          LW_KEYVAL = <LF_KEY>.
        ENDIF.
        CONCATENATE LW_KEYGVAL LW_KEYVAL INTO LW_KEYGVAL.
      ELSE.
        RETURN.
      ENDIF.
    ENDLOOP.

*   Get new value
    READ TABLE GT_MC_BUSKEYM INTO LS_MC_BUSKEYM
      WITH KEY  KEYGRP  = LPS_MC_BUSFLD-KEYGRP
                KEYGVAL = LW_KEYGVAL BINARY SEARCH.
    IF SY-SUBRC IS INITIAL.
      IF LS_MC_BUSKEYM-TOVALUE IS INITIAL.
        CLEAR: LPW_FIELD.
      ELSE.
        LPW_FIELD = LS_MC_BUSKEYM-TOVALUE.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " UPDATE_FIELD_USE_KEYGRP

*&---------------------------------------------------------------------*
*&      Form  GET_MAP_DATA
*&---------------------------------------------------------------------*
*       Get map data
*----------------------------------------------------------------------*
FORM GET_MAP_DATA .

* Get map id
  SELECT *
    FROM ZTB_MC_BUSMAP
    INTO TABLE GT_MC_BUSMAP.
  SORT GT_MC_BUSMAP BY MCMAPID MCFRVAL.

* Get key group
  SELECT *
    FROM ZTB_MC_BUSKEYG
    INTO TABLE GT_MC_BUSKEYG
     FOR ALL ENTRIES IN GS_MCCF_BUSTAB-FIELDS
   WHERE KEYGRP = GS_MCCF_BUSTAB-FIELDS-KEYGRP.
  SORT GT_MC_BUSKEYG BY KEYGRP.

* Get key group elements
  SELECT *
    FROM ZTB_MC_BUSKEYE
    INTO TABLE GT_MC_BUSKEYE.
  SORT GT_MC_BUSKEYE BY KEYGRP FPOSI.

* Get key group map values
  SELECT *
    FROM ZTB_MC_BUSKEYGM
    INTO TABLE GT_MC_BUSKEYM
     FOR ALL ENTRIES IN GT_MC_BUSKEYG
   WHERE KEYGRP = GT_MC_BUSKEYG-KEYGRP.
  SORT GT_MC_BUSKEYM BY KEYGRP KEYGVAL.

ENDFORM.                    " GET_MAP_DATA

*&---------------------------------------------------------------------*
*&      Form  CHANGE_SINGLE_RECORD
*&---------------------------------------------------------------------*
*       Change single record  using list of changing field
*----------------------------------------------------------------------*
*      -->LPT_FIELD_CHANGE  List fields change
*      <--LPS_RECORD        Record data
*----------------------------------------------------------------------*
FORM CHANGE_SINGLE_RECORD
  USING    LPT_FIELD_CHANGE   TYPE ZTT_MCBA_FIELD_CHANGE
  CHANGING LPS_RECORD         TYPE ANY.

  DATA:
    LS_FIELD_CHANGE   TYPE ZST_MCBA_FIELD_CHANGE,
    LW_MCFRVAL        TYPE ZTB_MC_BUSMAP-MCFRVAL,
    LS_MC_BUSMAP      TYPE ZTB_MC_BUSMAP.
  FIELD-SYMBOLS:
    <LF_FIELD>        TYPE ANY.

  LOOP AT LPT_FIELD_CHANGE INTO LS_FIELD_CHANGE.
    ASSIGN COMPONENT LS_FIELD_CHANGE-FIELDNAME OF STRUCTURE LPS_RECORD
      TO <LF_FIELD>.
    IF SY-SUBRC IS INITIAL.
      CASE LS_FIELD_CHANGE-MCTYP.
*       Fix value
        WHEN GC_MCTYP_FIXVAL.
          IF LS_FIELD_CHANGE-FIELDVAL IS INITIAL.
            CLEAR: <LF_FIELD>.
          ELSE.
            <LF_FIELD> = LS_FIELD_CHANGE-FIELDVAL.
          ENDIF.
*       Map value
        WHEN GC_MCTYP_MAPVAL.
          LW_MCFRVAL = <LF_FIELD>.
          READ TABLE GT_MC_BUSMAP INTO LS_MC_BUSMAP
            WITH KEY  MCMAPID = LS_FIELD_CHANGE-MCMAPID
                      MCFRVAL = LW_MCFRVAL BINARY SEARCH.
          IF SY-SUBRC IS INITIAL.
            <LF_FIELD> = LS_MC_BUSMAP-MCTOVAL.
          ENDIF.
*       FM process
        WHEN GC_MCTYP_FMPRC.
*          CALL FUNCTION 'ZFM_MC_EX_CONV_FLD'
          CALL FUNCTION LS_FIELD_CHANGE-FUNCNAME
            CHANGING
              C_FIELD       = <LF_FIELD>
              C_RECORD      = LPS_RECORD.
*       Use key group
        WHEN GC_MCTYP_KEYGR.
          PERFORM UPDATE_FIELD_USE_KEYGRP
            USING LS_FIELD_CHANGE
                  LPS_RECORD
            CHANGING <LF_FIELD>.
      ENDCASE.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " CHANGE_SINGLE_RECORD

*&---------------------------------------------------------------------*
*&      Form  CHANGE_MULTI_RECORDS
*&---------------------------------------------------------------------*
*       Change multi records  using list of changing field
*----------------------------------------------------------------------*
*      -->LPT_FIELD_CHANGE  List fields change
*      <--LPT_TABDATA       Table data
*----------------------------------------------------------------------*
FORM CHANGE_MULTI_RECORDS
  USING    LPT_FIELD_CHANGE   TYPE ZTT_MCBA_FIELD_CHANGE
  CHANGING LPT_TABDATA        TYPE TABLE.

  FIELD-SYMBOLS:
    <LF_TABSTR>       TYPE ANY.

  LOOP AT LPT_TABDATA ASSIGNING <LF_TABSTR>.
*   Change single record  using list of changing field
    PERFORM CHANGE_SINGLE_RECORD
      USING LPT_FIELD_CHANGE
      CHANGING <LF_TABSTR>.
  ENDLOOP.
ENDFORM.                    " CHANGE_MULTI_RECORDS

*&---------------------------------------------------------------------*
*&      Form  0100_SHOW_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0100_SHOW_ALV .
  DATA:
    LS_VARIANT            TYPE DISVARIANT,
    LS_LAYOUT             TYPE LVC_S_LAYO,
    LS_FIELDCAT           TYPE LVC_S_FCAT.
  FIELD-SYMBOLS:
    <LF_FIELDCAT>         TYPE LVC_S_FCAT.

  LS_VARIANT-REPORT     = SY-REPID.
  LS_VARIANT-HANDLE     = SY-DYNNR.
  LS_LAYOUT-CWIDTH_OPT  = GC_XMARK.
  LS_LAYOUT-EDIT        = GC_XMARK.
  IF GO_ALV_TABINP IS INITIAL.
    CALL FUNCTION 'ZFM_ALV_DISPLAY_SCR'
     EXPORTING
       I_CPROG                    = SY-REPID
       I_CUS_CONTROL_NAME         = 'CUS_ALV_BP'
       I_STRUCTURE_NAME           = GW_TABNMINP
       IS_VARIANT                 = LS_VARIANT
       IS_LAYOUT                  = LS_LAYOUT
     IMPORTING
       E_ALV_GRID                 = GO_ALV_TABINP
     CHANGING
       IT_OUTTAB                  = <GT_TABINP>.
  ELSE.
    CALL METHOD GO_ALV_TABINP->SET_FRONTEND_LAYOUT
      EXPORTING
        IS_LAYOUT = LS_LAYOUT.

    CALL METHOD GO_ALV_TABINP->REFRESH_TABLE_DISPLAY.
  ENDIF.
ENDFORM.                    " 0100_SHOW_ALV

*&---------------------------------------------------------------------*
*&      Form  9999_IMPORT_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM 9999_IMPORT_FILE
  USING LPS_RCGFILETR   TYPE ZST_ICL_WC_FILE.
  DATA:
    LT_TABINPFCAT     TYPE LVC_T_FCAT,
    LT_EXCEL_MAPPING  TYPE ZTT_EXCEL_MAPPING,
    LS_EXCEL_MAPPING  TYPE ZST_EXCEL_MAPPING .

  CLEAR: <GT_TABINP>.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME             = GW_TABNMINP
      I_INTERNAL_TABNAME           = GW_TABNMINP
    CHANGING
      CT_FIELDCAT                  = LT_TABINPFCAT
    EXCEPTIONS
      INCONSISTENT_INTERFACE       = 1
      PROGRAM_ERROR                = 2
      OTHERS                       = 3.


  CALL FUNCTION 'ZFM_FILE_EXCEL_IMP2TAB_ATM'
    EXPORTING
      I_LOCALFILE           = LPS_RCGFILETR-PCFILE
    IMPORTING
      T_IMPTAB              = <GT_TABINP>
      T_EXCEL_MAPPING        = LT_EXCEL_MAPPING
    CHANGING
      T_FIELDCAT            = LT_TABINPFCAT
    EXCEPTIONS
      OPENFILE_ERROR        = 1
      NO_MAPPING            = 2
      READ_DATA_ERROR       = 3
      MAPPING_ERROR         = 4
      OTHERS                = 5.
ENDFORM.                    " 9999_IMPORT_FILE

*&---------------------------------------------------------------------*
*&      Form  9999_BUILD_UPDFIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPW_SUB_TABNAME  text
*      -->LPW_SUB_FNAME  text
*      -->LPW_SUB_REQUIRED  text
*      <--LPT_FIELDS  text
*      <--LPW_TITLE  text
*----------------------------------------------------------------------*
FORM 9999_BUILD_UPDFIELDS
  USING LPW_SUB_TABNAME   TYPE TABNAME
        LPW_SUB_FNAME     TYPE FIELDNAME
        LPW_SUB_REQUIRED  TYPE XMARK
  CHANGING LPT_FIELDS     TYPE TY_SVAL.
  DATA:
    LW_TABTYPE            TYPE TABNAME,
    LS_DD40V              TYPE DD40V,
    LT_FIELDCAT           TYPE LVC_T_FCAT,
    LS_FIELDCAT           TYPE LVC_S_FCAT,
    LS_SVAL               TYPE SVAL,
    LT_FNAME              TYPE RSDSSELOPT_T.

  LS_DD40V-ROWTYPE = LPW_SUB_TABNAME.

* Get fieldcat of Items table
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME   = LS_DD40V-ROWTYPE
      I_INTERNAL_TABNAME = LS_DD40V-ROWTYPE
    CHANGING
      CT_FIELDCAT        = LT_FIELDCAT
    EXCEPTIONS
      OTHERS             = 3.

  CALL FUNCTION 'ZFM_SUBMIT_DATA_TO_SELOPT'
    EXPORTING
      I_LOW            = LPW_SUB_FNAME
    IMPORTING
      ER_SELOPT        = LT_FNAME.


  LOOP AT LT_FIELDCAT INTO LS_FIELDCAT
    WHERE FIELDNAME IN LT_FNAME.
    LS_SVAL-TABNAME       = LS_FIELDCAT-TABNAME.
    LS_SVAL-FIELDNAME     = LS_FIELDCAT-FIELDNAME.
    LS_SVAL-FIELD_OBL     = LPW_SUB_REQUIRED.
    APPEND LS_SVAL TO LPT_FIELDS.
  ENDLOOP.
ENDFORM.                    " 9999_BUILD_UPDFIELDS

*&---------------------------------------------------------------------*
*&      Form  0100_PROCESS_FC_SAVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM 0100_PROCESS_FC_SAVE.

  INSERT (GW_TABNMINP) FROM TABLE <GT_TABINP>
    ACCEPTING DUPLICATE KEYS.
  IF SY-SUBRC IS NOT INITIAL.
    UPDATE (GW_TABNMINP) FROM TABLE <GT_TABINP>.
  ENDIF.
  COMMIT WORK.
ENDFORM.                    " 0100_PROCESS_FC_SAVE

*&---------------------------------------------------------------------*
*&      Form  0100_PROCESS_FC_IMPSTD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0100_PROCESS_FC_IMPSTD .
  DATA:
    LT_FIELDS	      TYPE TABLE OF	SVAL,
    LS_FIELDS	      TYPE SVAL,
    LW_RETURNCODE   TYPE C,
    LW_TABNAME      TYPE TABNAME.

  PERFORM 9999_BUILD_UPDFIELDS
    USING 'ZST_ICL_WC_FILE'
          'PCFILE'
          GC_XMARK
   CHANGING LT_FIELDS.

  CALL FUNCTION 'POPUP_GET_VALUES_USER_CHECKED'
    EXPORTING
      FORMNAME        = '9999_SET_FILENAME_AND_IMPORT'
      POPUP_TITLE     = TEXT-001
      PROGRAMNAME     = SY-REPID
    IMPORTING
      RETURNCODE      = LW_RETURNCODE
    TABLES
      FIELDS          = LT_FIELDS
    EXCEPTIONS
      ERROR_IN_FIELDS = 1
      OTHERS          = 2.
ENDFORM.                    " 0100_PROCESS_FC_IMPSTD
