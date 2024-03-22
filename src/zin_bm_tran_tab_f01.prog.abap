*&---------------------------------------------------------------------*
*&  Include           ZPG_CE104_08_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  MAIN_PRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MAIN_PRO .
  DATA:
    LT_OBJECT        TYPE TABLE OF GTY_OBJECT,
    LS_KEY           TYPE E071K,
    LS_OBJ           TYPE KO200,
    LS_ERROR         TYPE IWERRORMSG,
    LR_DATA          TYPE REF TO DATA,
    LT_FCAT          TYPE lvc_T_Fcat,
    LW_KEY_LENG      TYPE NUMC06,
    LT_WHERE_CLAUSES TYPE RSDS_WHERE_TAB.      "Where clause.

  FIELD-SYMBOLS:
    <LF_E071K>       TYPE E071K,
    <LFT_DATA_TABLE> TYPE TABLE.

  IF S_OBJNM[] IS NOT INITIAL.
    IF LINES( S_OBJNM[] ) = 1.
      CALL FUNCTION 'ZFM_DATTAB_FREE_SELECTION'
        EXPORTING
          I_TABLE         = S_OBJNM-LOW
          I_MAXSELECT     = 12
        IMPORTING
          T_WHERE_CLAUSES = LT_WHERE_CLAUSES
        EXCEPTIONS
          ERROR           = 1
          OTHERS          = 2.

      CREATE DATA LR_DATA TYPE TABLE OF (S_OBJNM-LOW).
      ASSIGN LR_DATA->* TO <LFT_DATA_TABLE>.
      CALL FUNCTION 'ZFM_DATTAB_GET'
        EXPORTING
          I_TABLE         = S_OBJNM-LOW
          T_WHERE_CLAUSES = LT_WHERE_CLAUSES
        IMPORTING
          T_TABLE_DATA    = <LFT_DATA_TABLE>.

      CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
        EXPORTING
          I_STRUCTURE_NAME       = S_OBJNM-LOW
        CHANGING
          CT_FIELDCAT            = LT_FCAT
        EXCEPTIONS
          INCONSISTENT_INTERFACE = 1
          PROGRAM_ERROR          = 2
          OTHERS                 = 3.
      LOOP AT LT_FCAT INTO DATA(LS_FCAT)
        WHERE KEY = 'X'.
        LW_KEY_LENG = LW_KEY_LENG + LS_FCAT-INTLEN.
      ENDLOOP.

      LOOP AT <LFT_DATA_TABLE> ASSIGNING FIELD-SYMBOL(<LF_DATA_LINE>).
        LS_KEY-PGMID      = 'R3TR'.
        LS_KEY-OBJECT     = 'TABU'.
        LS_KEY-OBJNAME    = S_OBJNM-LOW.
        LS_KEY-MASTERNAME = LS_KEY-OBJNAME.
        LS_KEY-MASTERTYPE = LS_KEY-OBJECT.
*        CONCATENATE SY-MANDT '*' INTO LS_KEY-TABKEY.
        LS_KEY-TABKEY = <LF_DATA_LINE>(LW_KEY_LENG).
        MOVE-CORRESPONDING LS_KEY TO LS_OBJ.
        LS_OBJ-OBJFUNC = 'K'.
        LS_OBJ-OBJ_NAME = LS_KEY-OBJNAME.
        APPEND LS_OBJ TO GT_OBJ.
        APPEND LS_KEY TO GT_KEY.
      ENDLOOP.
    ELSE.
      LOOP AT S_OBJNM.
        LS_KEY-PGMID = 'R3TR'.
        LS_KEY-OBJECT = 'TABU'.
        LS_KEY-OBJNAME = S_OBJNM-LOW.
        LS_KEY-MASTERNAME = LS_KEY-OBJNAME.
        LS_KEY-MASTERTYPE = LS_KEY-OBJECT.
        CONCATENATE SY-MANDT '*' INTO LS_KEY-TABKEY.
        MOVE-CORRESPONDING LS_KEY TO LS_OBJ.
        LS_OBJ-OBJFUNC = 'K'.
        LS_OBJ-OBJ_NAME = LS_KEY-OBJNAME.
        APPEND LS_OBJ TO GT_OBJ.
        APPEND LS_KEY TO GT_KEY.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF GT_KEY[] IS NOT INITIAL.
    CALL FUNCTION 'IW_C_APPEND_OBJECTS_TO_REQUEST'
      IMPORTING
*       TRANSPORT_ORDER       =
*       IS_CANCELLED          =
        ERROR_MSG = LS_ERROR
      TABLES
        OBJECTS   = GT_OBJ
        KEYS      = GT_KEY.
  ENDIF.
  REFRESH: GT_KEY, GT_OBJ.
ENDFORM.                    " MAIN_PRO
