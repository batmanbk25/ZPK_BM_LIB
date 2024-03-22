FUNCTION ZFM_DATA_EXPRESSION_CALC .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(C_RECORD) TYPE  ANY
*"     REFERENCE(C_EXPRESSION) TYPE  ZDD_BM_AGGEX
*"     REFERENCE(C_AGGFIG) TYPE  ANY
*"----------------------------------------------------------------------

  DATA :
   LW_ACTOR                   TYPE ZDD_BM_AGGEX,
   LW_ACTOR_TMP               TYPE ZDD_BM_AGGEX,
   LT_ACTOR                   LIKE TABLE OF LW_ACTOR,
   LT_ACTOR_TMP               LIKE TABLE OF LW_ACTOR,
   LT_ACTOR_LOOP              LIKE TABLE OF LW_ACTOR,
   LT_SEPARATOR               TYPE TABLE OF C,
   LW_SEPARATOR               TYPE C,
   LW_AGGFIG                  TYPE FLOAT.
  FIELD-SYMBOLS:
    <LF_ACTOR>                TYPE ZDD_BM_AGGEX,
    <LF_ACTOR_FIELD>          TYPE ANY.

* Prepare separators
  APPEND '(' TO LT_SEPARATOR.
  APPEND ')' TO LT_SEPARATOR.
  APPEND '/' TO LT_SEPARATOR.
  APPEND '+' TO LT_SEPARATOR.
  APPEND '*' TO LT_SEPARATOR.
  APPEND '-' TO LT_SEPARATOR.

* Prepare actors
  APPEND C_EXPRESSION TO LT_ACTOR.

* Separate all minimum actors
  LOOP AT LT_SEPARATOR INTO LW_SEPARATOR.
    CLEAR: LT_ACTOR_LOOP.
    LOOP AT LT_ACTOR INTO LW_ACTOR.
      CLEAR: LT_ACTOR_TMP.
      SPLIT LW_ACTOR AT LW_SEPARATOR INTO TABLE LT_ACTOR_TMP.
      LOOP AT LT_ACTOR_TMP INTO LW_ACTOR_TMP.
        CONDENSE LW_ACTOR_TMP.
        IF SY-TABIX <> 1.
          APPEND LW_SEPARATOR TO LT_ACTOR_LOOP.
        ENDIF.
        APPEND LW_ACTOR_TMP TO LT_ACTOR_LOOP.
      ENDLOOP.
    ENDLOOP.
    LT_ACTOR = LT_ACTOR_LOOP.
  ENDLOOP.

* Replace fieldname in actor with it's value
  LOOP AT LT_ACTOR ASSIGNING <LF_ACTOR>.
    IF <LF_ACTOR>(1) = '#'.
      ASSIGN COMPONENT <LF_ACTOR>+1 OF STRUCTURE C_RECORD
        TO <LF_ACTOR_FIELD>.
      IF SY-SUBRC IS INITIAL.
        <LF_ACTOR> = <LF_ACTOR_FIELD>.
        CONDENSE <LF_ACTOR>.
      ELSE.
        MESSAGE A001(ZMS_COL_LIB) WITH <LF_ACTOR>+1 C_EXPRESSION.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Rebuld expression
  CONCATENATE LINES OF LT_ACTOR INTO C_EXPRESSION SEPARATED BY SPACE.

* Calculate expression
  CALL FUNCTION 'EVAL_FORMULA'
    EXPORTING
      FORMULA = C_EXPRESSION
    IMPORTING
*     VALUE   = C_AGGFIG.
      VALUE   = LW_AGGFIG.

  C_AGGFIG   = LW_AGGFIG.

ENDFUNCTION.