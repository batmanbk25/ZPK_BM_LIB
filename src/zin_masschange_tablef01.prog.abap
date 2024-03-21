*&---------------------------------------------------------------------*
*&  Include           ZIN_DTG99_011F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  0000_MAIN_PROC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM 0000_MAIN_PROC .
  PERFORM P010_MASSCHANGE_TABLE.
ENDFORM.                    " 0000_MAIN_PROC

*&---------------------------------------------------------------------*
*&      Form  P010_MASSCHANGE_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM P010_MASSCHANGE_TABLE .
  DATA:
    LT_REF_DATA       TYPE REF TO DATA,
    LS_REF_STR        TYPE REF TO DATA,
    LW_PRC_RECORDS    TYPE NUMC10.
  FIELD-SYMBOLS:
    <LF_DATA_STR>     TYPE ANY.

* Create structure data
  CREATE DATA GS_OTHER_DATA-REF_TAB TYPE STANDARD TABLE OF
         (P_TABNM).
  ASSIGN GS_OTHER_DATA-REF_TAB->* TO <GFT_TAB_DATA>.
  CREATE DATA LS_REF_STR LIKE LINE OF <GFT_TAB_DATA>.
  ASSIGN LS_REF_STR->* TO <LF_DATA_STR>.

* Show free selection
  CALL FUNCTION 'ZFM_DATTAB_FREE_SELECTION'
    EXPORTING
      I_TABLE               = P_TABNM
    IMPORTING
      T_WHERE_CLAUSES       = GT_WHERE_CLAUSES
    CHANGING
      C_SELID               = GW_SELID
    EXCEPTIONS
      ERROR                 = 1
      OTHERS                = 2.
  IF SY-SUBRC <> 0.
    RETURN.
  ENDIF.

* Select and Process data using cursor
  CALL FUNCTION 'ZFM_DATTAB_PROCESS_CURSOR'
    EXPORTING
      I_TABLE               = P_TABNM
      T_WHERE_CLAUSES       = GT_WHERE_CLAUSES
      I_PACKSIZE            = P_PSIZE
      I_PRC_SUB             = '9000_PROCESS_PACK'
      I_COUNT_ALL           = P_CNALL
      I_COMMIT              = GC_XMARK.

* Message Successful
  MESSAGE S548(ZMC_REG_01).

ENDFORM.                    " P010_MASSCHANGE_TABLE

*&---------------------------------------------------------------------*
*&      Form  9000_PROCESS_PACK
*&---------------------------------------------------------------------*
*       Process each pack data
*----------------------------------------------------------------------*
*      <--LPT_TAB_DATA  Pack data
*----------------------------------------------------------------------*
FORM 9000_PROCESS_PACK
  CHANGING LPT_TAB_DATA TYPE ANY TABLE.

  CASE GC_XMARK.
    WHEN P_MCTYUP.
      PERFORM 9000_UPDATE_PACK
        CHANGING LPT_TAB_DATA .
    WHEN P_MCTYBU.
      PERFORM 9000_BACKUP_DATA
        CHANGING LPT_TAB_DATA .
    WHEN P_MCTYFM.
      CALL FUNCTION 'OM_FUNC_MODULE_EXIST'
        EXPORTING
          FUNCTION_MODULE       = P_FMNAME
        EXCEPTIONS
          NOT_EXISTENT          = 1
          OTHERS                = 2.
      CHECK SY-SUBRC IS INITIAL.

      CALL FUNCTION P_FMNAME
        CHANGING
          T_TABDATA = LPT_TAB_DATA.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " 9000_PROCESS_PACK

*&---------------------------------------------------------------------*
*&      Form  9000_UPDATE_PACK
*&---------------------------------------------------------------------*
*       Update DB
*----------------------------------------------------------------------*
*      <--LPT_TAB_DATA  Pack data
*----------------------------------------------------------------------*
FORM 9000_UPDATE_PACK
  CHANGING LPT_TAB_DATA TYPE ANY TABLE.

* Get update table
  CALL FUNCTION 'ZFM_MC_BUSTAB_UPDATE'
    EXPORTING
      I_TABNAME       = P_TABNM
      I_TABMCID       = P_TABMID
    CHANGING
      T_TABDATA       = LPT_TAB_DATA.

* Update to DB
  UPDATE (P_TABNM) FROM TABLE LPT_TAB_DATA.

ENDFORM.                    " 9000_UPDATE_PACK

*&---------------------------------------------------------------------*
*&      Form  9000_BACKUP_DATA
*&---------------------------------------------------------------------*
*       Back up data
*----------------------------------------------------------------------*
*      <--LPT_TAB_DATA  Pack data
*----------------------------------------------------------------------*
FORM 9000_BACKUP_DATA
  CHANGING LPT_TAB_DATA TYPE ANY TABLE.
  DATA:
    LR_DATA         TYPE REF TO DATA.
  FIELD-SYMBOLS:
    <LFT_TAB_DATA>  TYPE ANY TABLE.

* Create structure data
  CREATE DATA LR_DATA TYPE STANDARD TABLE OF (P_TABBU).
  ASSIGN LR_DATA->* TO <LFT_TAB_DATA>.
* EHP7 up
*  MOVE-CORRESPONDING LPT_TAB_DATA TO <LFT_TAB_DATA>.
* EPH6 down
  CALL FUNCTION 'ZFM_DATA_TABLE_MOVE_CORRESPOND'
    CHANGING
      C_SRC_TAB       = LPT_TAB_DATA
      C_DES_TAB       = <LFT_TAB_DATA>.

* Insert data to backup table
*  INSERT (P_TABBU) FROM TABLE LPT_TAB_DATA ACCEPTING DUPLICATE KEYS.
  INSERT (P_TABBU) FROM TABLE <LFT_TAB_DATA> ACCEPTING DUPLICATE KEYS.
  IF SY-SUBRC IS NOT INITIAL.
    UPDATE (P_TABBU) FROM TABLE <LFT_TAB_DATA>.
  ENDIF.
  CLEAR: <LFT_TAB_DATA>[].

ENDFORM.                    " 9000_BACKUP_DATA

*&---------------------------------------------------------------------*
*&      Form  1000_PBO
*&---------------------------------------------------------------------*
*       PBO screen 1000
*----------------------------------------------------------------------*
FORM 1000_PBO .
  LOOP AT SCREEN.
    CASE GC_XMARK.
      WHEN P_MCTYUP.
        IF SCREEN-GROUP1 IS NOT INITIAL
        AND SCREEN-GROUP1 <> 'UP'.
          SCREEN-ACTIVE = '0'.
          MODIFY SCREEN.
        ENDIF.
      WHEN P_MCTYBU.
        IF SCREEN-GROUP1 IS NOT INITIAL
        AND SCREEN-GROUP1 <> 'BU'.
          SCREEN-ACTIVE = '0'.
          MODIFY SCREEN.
        ENDIF.
      WHEN P_MCTYFM.
        IF SCREEN-GROUP1 IS NOT INITIAL
        AND SCREEN-GROUP1 <> 'FM'.
          SCREEN-ACTIVE = '0'.
          MODIFY SCREEN.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " 1000_PBO
