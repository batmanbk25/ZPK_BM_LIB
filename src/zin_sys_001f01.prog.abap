*&---------------------------------------------------------------------*
*&  Include           ZIN_SYS_001F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  9000_INIT_PROC
*&---------------------------------------------------------------------*
*       Init process
*----------------------------------------------------------------------*
FORM 0000_INIT_PROC .
*  CALL FUNCTION 'ZFM_PROG_INIT_DATA'
*   IMPORTING
*     T_ALL_BUKRS          = GT_ALL_BUK.

  SELECT *
    FROM ZTB_BM_DATGROUP
    INTO TABLE GT_DATGROUP.
  SORT GT_DATGROUP BY DATGR.

  SELECT *
    FROM ZTB_BM_DATTYPE
    INTO TABLE GT_DATTYPE_ALL.
  SORT GT_DATTYPE BY DATGR DATTY.

  SELECT *
    FROM ZTB_BM_DATCON
    INTO TABLE GT_DATCON.
  SORT GT_DATCON BY DATGR DATTY DATCON.

ENDFORM.                    " 9000_INIT_PROC

*&---------------------------------------------------------------------*
*&      Form  9000_MAIN_PROC
*&---------------------------------------------------------------------*
*       Main process
*----------------------------------------------------------------------*
FORM 0000_MAIN_PROC .
* Get config data
  PERFORM 0010_GET_CONIG_DATA.

* Get business data
  PERFORM 0020_GET_BUSINESS_DATA.

* Show data
  PERFORM 0030_SHOW_DATA.

ENDFORM.                    " 9000_MAIN_PROC

*&---------------------------------------------------------------------*
*&      Form  0010_GET_CONIG_DATA
*&---------------------------------------------------------------------*
*       Get config data
*----------------------------------------------------------------------*
FORM 0010_GET_CONIG_DATA .

* Get data type to get
  GT_DATTYPE = GT_DATTYPE_ALL.
  IF P_DATGR IS NOT INITIAL.
    DELETE GT_DATTYPE WHERE DATGR <> P_DATGR.
  ENDIF.

ENDFORM.                    " 0010_GET_CONIG_DATA

*&---------------------------------------------------------------------*
*&      Form  0020_GET_BUSINESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0020_GET_BUSINESS_DATA.
  DATA:
    LT_DATTYPE_GR     TYPE TABLE OF ZTB_BM_DATTYPE,
    LS_DATTYPE        TYPE ZTB_BM_DATTYPE,
    LREF_DATA         TYPE REF TO DATA,
    LW_WHERE_STR      TYPE STRING.
  FIELD-SYMBOLS:
    <LFT_DATA>        TYPE STANDARD TABLE.

  LT_DATTYPE_GR = GT_DATTYPE.
  SORT LT_DATTYPE_GR BY TABNM.
  DELETE ADJACENT DUPLICATES FROM LT_DATTYPE_GR COMPARING TABNM.

  LOOP AT LT_DATTYPE_GR INTO LS_DATTYPE.
*   Build table structure data
    CREATE DATA LREF_DATA TYPE STANDARD TABLE OF (LS_DATTYPE-TABNM).
    ASSIGN LREF_DATA->* TO <LFT_DATA>.

*   Build where clause
    CONCATENATE LS_DATTYPE-BUKFN 'IN S_BUKRS AND'
                LS_DATTYPE-CRDFN 'IN S_CRDAT'
           INTO LW_WHERE_STR SEPARATED BY SPACE.

*   Get data
    SELECT *
      FROM (LS_DATTYPE-TABNM)
      INTO TABLE <LFT_DATA>
     WHERE (LW_WHERE_STR).
    IF LS_DATTYPE-DELDUP = GC_XMARK.
      SORT <LFT_DATA>.
      DELETE ADJACENT DUPLICATES FROM <LFT_DATA>.
    ENDIF.

*   Check data fit and put to result
    PERFORM 9000_CHECK_RECORD_FIT
      USING <LFT_DATA>
            LS_DATTYPE.
  ENDLOOP.

ENDFORM.                    " 0020_GET_BUSINESS_DATA

*&---------------------------------------------------------------------*
*&      Form  9000_CHECK_RECORD_FIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LPT_DATA    Table data
*      -->LPS_DATTYPE Data type config
*----------------------------------------------------------------------*
FORM 9000_CHECK_RECORD_FIT
  USING   LPT_DATA      TYPE STANDARD TABLE
          LPS_DATTYPE   TYPE ZTB_BM_DATTYPE.
  DATA:
    LS_DATTYPE          TYPE ZTB_BM_DATTYPE,
    LS_DATCON           TYPE ZTB_BM_DATCON,
    LREF_DATA           TYPE REF TO DATA,
    LW_EQUAL            TYPE XMARK,
    LS_SYS_01           TYPE ZST_SYS_001.
  FIELD-SYMBOLS:
    <LF_DATA>           TYPE ANY,
    <LF_VALUE>          TYPE ANY,
    <LF_SYS_01>         TYPE ZST_SYS_001.

*  CREATE DATA LREF_DATA TYPE (LPS_DATTYPE-TABNM).
*  ASSIGN LREF_DATA->* TO <LF_DATA>.

* Loop all data
  LOOP AT LPT_DATA ASSIGNING <LF_DATA>.
    CLEAR: LS_SYS_01.
    ASSIGN COMPONENT LPS_DATTYPE-BUKFN OF STRUCTURE <LF_DATA>
      TO <LF_VALUE>.
    IF SY-SUBRC IS INITIAL.
      LS_SYS_01-BUKRS = <LF_VALUE>.
    ENDIF.
    ASSIGN COMPONENT LPS_DATTYPE-CRDFN OF STRUCTURE <LF_DATA>
      TO <LF_VALUE>.
    IF SY-SUBRC IS INITIAL AND LPS_DATTYPE-IGCRD IS INITIAL.
      LS_SYS_01-CRDAT = <LF_VALUE>.
    ENDIF.
    ASSIGN COMPONENT LPS_DATTYPE-PERFN OF STRUCTURE <LF_DATA>
      TO <LF_VALUE>.
    IF SY-SUBRC IS INITIAL AND <LF_VALUE> IS NOT INITIAL.
      CASE LPS_DATTYPE-PERFM.
        WHEN GC_PERFM_YYYYMMDD OR GC_PERFM_YYYYMM.
          LS_SYS_01-PERSL = <LF_VALUE>(6).
        WHEN GC_PERFM_YYMM.
          LS_SYS_01-PERSL(2) = '20'.
          LS_SYS_01-PERSL+2  = <LF_VALUE>(4).
      ENDCASE.
    ENDIF.
    IF P_SHOWUS IS NOT INITIAL.
      ASSIGN COMPONENT LPS_DATTYPE-CRUFN OF STRUCTURE <LF_DATA>
        TO <LF_VALUE>.
      IF SY-SUBRC IS INITIAL.
        LS_SYS_01-CRUSR = <LF_VALUE>.
      ENDIF.
    ENDIF.

    LS_SYS_01-QUANT = 1.

*   Loop all data types of table
    LOOP AT GT_DATTYPE INTO LS_DATTYPE
      WHERE TABNM = LPS_DATTYPE-TABNM.
      LS_SYS_01-DATTY = LS_DATTYPE-DATTY.
      LS_SYS_01-DATNM = LS_DATTYPE-DATNM.

*     Loop all OR conditions
      LW_EQUAL = GC_XMARK.
      LOOP AT GT_DATCON INTO LS_DATCON
        WHERE DATGR = LS_DATTYPE-DATGR
          AND DATTY = LS_DATTYPE-DATTY.
*       Check condition 1
        PERFORM 9000_COMPARE_DATA
          USING <LF_DATA>
                LS_DATCON-FIELD1
                LS_DATCON-VALUE1
       CHANGING LW_EQUAL.
        CHECK LW_EQUAL = GC_XMARK.

*       Check condition 2
        PERFORM 9000_COMPARE_DATA
          USING <LF_DATA>
                LS_DATCON-FIELD2
                LS_DATCON-VALUE2
       CHANGING LW_EQUAL.
        CHECK LW_EQUAL = GC_XMARK.

*       Check condition 3
        PERFORM 9000_COMPARE_DATA
          USING <LF_DATA>
                LS_DATCON-FIELD3
                LS_DATCON-VALUE3
       CHANGING LW_EQUAL.

*       Fit condditionss => exit OR loop
        IF LW_EQUAL = GC_XMARK.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF LW_EQUAL = GC_XMARK.
        IF P_SHOWUS IS INITIAL.
*         Fit condditionss => increase quantity
          READ TABLE GT_SYS_001 ASSIGNING <LF_SYS_01>
            WITH KEY BUKRS = LS_SYS_01-BUKRS
                     CRDAT = LS_SYS_01-CRDAT
                     DATTY = LS_SYS_01-DATTY
                     PERSL = LS_SYS_01-PERSL
                     CRUSR = LS_SYS_01-CRUSR.
          IF SY-SUBRC IS INITIAL.
            <LF_SYS_01>-QUANT = <LF_SYS_01>-QUANT + 1.
          ELSE.
            APPEND LS_SYS_01 TO GT_SYS_001.
          ENDIF.
        ELSE.
*         Fit condditionss => increase quantity
          READ TABLE GT_SYS_001 ASSIGNING <LF_SYS_01>
            WITH KEY BUKRS = LS_SYS_01-BUKRS
                     CRDAT = LS_SYS_01-CRDAT
                     DATTY = LS_SYS_01-DATTY
                     CRUSR = LS_SYS_01-CRUSR.
          IF SY-SUBRC IS INITIAL.
            <LF_SYS_01>-QUANT = <LF_SYS_01>-QUANT + 1.
          ELSE.
            APPEND LS_SYS_01 TO GT_SYS_001.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " 9000_CHECK_RECORD_FIT

*&---------------------------------------------------------------------*
*&      Form  9000_COMPARE_DATA
*&---------------------------------------------------------------------*
*       Compare data
*----------------------------------------------------------------------*
*      -->LPS_DATA        Data
*      -->LPW_FIELDNAME   Fieldname
*      -->LPW_VALUE       Value
*      <--LPW_EQUAL       Equal flag
*----------------------------------------------------------------------*
FORM 9000_COMPARE_DATA
  USING   LPS_DATA
          LPW_FIELD     TYPE FIELDNAME
          LPW_VALUE     TYPE ZDD_BM_FDVAL
 CHANGING LPW_EQUAL     TYPE XMARK.

  FIELD-SYMBOLS:
    <LF_COND_FIELD> TYPE ANY,             "Condition Field
    <LF_COND_VALUE> TYPE ANY.             "Condition value

*----------------------------------------------------*
* Init
  CLEAR LPW_EQUAL.
  UNASSIGN: <LF_COND_FIELD>, <LF_COND_VALUE>.

  IF LPW_FIELD IS INITIAL AND LPW_VALUE IS INITIAL.
    LPW_EQUAL = GC_XMARK.
    RETURN.
  ENDIF.

* Get Condition field in called program
  ASSIGN COMPONENT LPW_FIELD OF STRUCTURE LPS_DATA TO <LF_COND_FIELD>.
  CHECK SY-SUBRC IS INITIAL.
  IF LPW_VALUE IS INITIAL.
    IF <LF_COND_FIELD> IS INITIAL.
      LPW_EQUAL = GC_XMARK.
    ENDIF.
  ELSEIF LPW_VALUE(1) = ''''.
    IF <LF_COND_FIELD> = LPW_VALUE+1.
      LPW_EQUAL = GC_XMARK.
    ENDIF.
  ELSE.
*   Get Condition value in called program
    ASSIGN (LPW_VALUE) TO <LF_COND_VALUE>.
    CHECK SY-SUBRC IS INITIAL.
    IF <LF_COND_FIELD> = <LF_COND_VALUE>.
      LPW_EQUAL = GC_XMARK.
    ENDIF.
  ENDIF.
ENDFORM.                    " 9000_COMPARE_DATA

*&---------------------------------------------------------------------*
*&      Form  0030_SHOW_DATA
*&---------------------------------------------------------------------*
*       Show data
*----------------------------------------------------------------------*
FORM 0030_SHOW_DATA .
  DATA:
    LS_VARIANT    TYPE DISVARIANT.

  IF P_SHOWUS IS INITIAL.
    LS_VARIANT-HANDLE = '1'.
  ELSE.
    LS_VARIANT-HANDLE = '2'.
  ENDIF.
  SORT GT_SYS_001 BY BUKRS DATTY CRDAT.

*  CALL FUNCTION 'ZFM_GET_DESC_FOR_FIELD'
*    EXPORTING
*      I_DES_FIELD          = 'BUKRS'
*      I_DES_TFIELD         = 'BUTXT'
**     I_SRC_FIELD          =
**     I_SRC_TFIELD         =
*      T_SRC_DATA           = GT_ALL_BUK
**     I_SORT_DES_TAB       = 'X'
*    CHANGING
*      T_DES_DATA           = GT_SYS_001
*            .

  CALL FUNCTION 'ZFM_ALV_DISPLAY'
    EXPORTING
*     I_LASTCOL                         =
      I_STRUCTURE_NAME                  = 'ZST_SYS_001'
*     IT_FIELDCAT                       =
*     IS_LAYOUT_LVC                     =
*     IT_EXCLUDING                      =
      IS_VARIANT                        = LS_VARIANT
    TABLES
      T_OUTTAB                          = GT_SYS_001
            .

ENDFORM.                    " 0030_SHOW_DATA
