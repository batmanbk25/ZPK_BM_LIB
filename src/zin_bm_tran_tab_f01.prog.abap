*&---------------------------------------------------------------------*
*&  Include           ZPG_BM_TRAN_TAB
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
  CASE 'X'.
    WHEN P_TRATB.
      PERFORM TRANS_SPEC_TABLE.
    WHEN P_ALLCS.
      CASE 'X'.
        WHEN P_TRATR.
          PERFORM TRANS_CUS_TABLE.
        WHEN P_TRADL.
          PERFORM DOWNLOAD_CUS_TABLE.
        WHEN P_TRAUL.
          PERFORM UPLOAD_CUS_TABLE.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " MAIN_PRO

*&---------------------------------------------------------------------*
*&      Form  TRANS_SPEC_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM TRANS_SPEC_TABLE .
  DATA:
    LT_OBJECT        TYPE TABLE OF GTY_OBJECT,
    LS_KEY           TYPE E071K,
    LS_OBJ           TYPE KO200,
    LS_ERROR         TYPE IWERRORMSG,
    LR_DATA          TYPE REF TO DATA,
    LT_FCAT          TYPE LVC_T_FCAT,
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
ENDFORM.                    " TRANS_SPEC_TABLE

*&---------------------------------------------------------------------*
*&      Form  TRANS_CUS_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM TRANS_CUS_TABLE .
  DATA:
    LT_TABNAME       TYPE DDTABNAMES,
    LT_OBJECT        TYPE TABLE OF GTY_OBJECT,
    LS_KEY           TYPE E071K,
    LS_OBJ           TYPE KO200,
    LS_ERROR         TYPE IWERRORMSG,
    LR_DATA          TYPE REF TO DATA,
    LT_FCAT          TYPE LVC_T_FCAT,
    LW_KEY_LENG      TYPE NUMC06,
    LT_WHERE_CLAUSES TYPE RSDS_WHERE_TAB.      "Where clause.

  FIELD-SYMBOLS:
    <LF_E071K>       TYPE E071K,
    <LFT_DATA_TABLE> TYPE TABLE.

  SELECT OBJ_NAME
    FROM TADIR AS T INNER JOIN DD02L AS D
      ON T~OBJ_NAME = D~TABNAME
    INTO TABLE LT_TABNAME
   WHERE DEVCLASS IN S_PACKG
     AND OBJECT = 'TABL'
    AND CONTFLAG = 'C'
    AND MAINFLAG = 'X'.

  LOOP AT LT_TABNAME INTO DATA(LS_TABNAME).
    LS_KEY-PGMID = 'R3TR'.
    LS_KEY-OBJECT = 'TABU'.
    LS_KEY-OBJNAME = LS_TABNAME.
    LS_KEY-MASTERNAME = LS_KEY-OBJNAME.
    LS_KEY-MASTERTYPE = LS_KEY-OBJECT.
    CONCATENATE SY-MANDT '*' INTO LS_KEY-TABKEY.
    MOVE-CORRESPONDING LS_KEY TO LS_OBJ.
    LS_OBJ-OBJFUNC = 'K'.
    LS_OBJ-OBJ_NAME = LS_KEY-OBJNAME.
    APPEND LS_OBJ TO GT_OBJ.
    APPEND LS_KEY TO GT_KEY.
  ENDLOOP.

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
ENDFORM.                    " TRANS_CUS_TABLE

*&---------------------------------------------------------------------*
*&      Form  DOWNLOAD_CUS_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM DOWNLOAD_CUS_TABLE .
  DATA:
    LT_TABNAME       TYPE DDTABNAMES .

  SELECT OBJ_NAME
    FROM TADIR AS T INNER JOIN DD02L AS D
      ON T~OBJ_NAME = D~TABNAME
    INTO TABLE LT_TABNAME
   WHERE DEVCLASS IN S_PACKG
     AND OBJECT = 'TABL'
    AND CONTFLAG = 'C'
    AND MAINFLAG = 'X'.

  CALL FUNCTION 'ZFM_BM_DATA2XML_FILE'
    EXPORTING
      IT_TABNAME = LT_TABNAME
      I_OPENFILE = 'X'.
ENDFORM.                    " DOWNLOAD_CUS_TABLE

*&---------------------------------------------------------------------*
*&      Form  UPLOAD_CUS_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM UPLOAD_CUS_TABLE .
  DATA:
    LT_TABNAME       TYPE DDTABNAMES .

  CALL FUNCTION 'ZFM_BM_DATA_FROM_XML_FILE'
    EXPORTING
      I_SHOWDATA  = 'X'
      I_UPDATE_DB = 'X'.
ENDFORM.                    " UPLOAD_CUS_TABLE


*&---------------------------------------------------------------------*
*& Form 1000_PBO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM 1000_PBO .
  CASE 'X'.
    WHEN P_ALLCS.
      CASE 'X'.
        WHEN P_TRAUL.
          LOOP AT SCREEN.
            IF SCREEN-GROUP1 = 'TTB' OR SCREEN-NAME CS 'S_PACKG'.
              SCREEN-ACTIVE = '0'.
              MODIFY SCREEN.
            ENDIF.
          ENDLOOP.
        WHEN OTHERS.
          LOOP AT SCREEN.
            IF SCREEN-GROUP1 CS 'TTB'.
              SCREEN-ACTIVE = '0'.
              MODIFY SCREEN.
            ENDIF.
          ENDLOOP.
      ENDCASE.
    WHEN P_TRATB.
      LOOP AT SCREEN.
        IF SCREEN-GROUP1 CS 'TCS'.
          SCREEN-ACTIVE = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.
