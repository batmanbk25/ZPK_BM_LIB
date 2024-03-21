FUNCTION ZFM_SPELLAMOUNT1.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_NUMBER) TYPE  NUMC_50 OPTIONAL
*"     REFERENCE(I_CURTX) TYPE  TEXT20 OPTIONAL
*"     REFERENCE(I_CURR) OPTIONAL
*"     REFERENCE(I_WAERS) TYPE  WAERS OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_TEXT) TYPE  STRING
*"     REFERENCE(IN_WORDS) TYPE  SPELL
*"--------------------------------------------------------------------
TYPES:
     BEGIN OF LTY_DIGIT_SPELL,
       DIGIT    TYPE N,
       POSITION TYPE N,
       NO_UNIT TYPE XMARK,
       SPELL    TYPE CHAR10,
     END OF LTY_DIGIT_SPELL,
     BEGIN OF LTY_GROUP_UNIT_SPELL,
       NO_DIGIT TYPE N,
       SPELL    TYPE CHAR10,
     END OF LTY_GROUP_UNIT_SPELL.

  DEFINE APPEND_DIGIT.
    LS_DIGIT_SPELL = &1.
    APPEND LS_DIGIT_SPELL TO LT_DIGIT_SPELL.
  END-OF-DEFINITION.

  DEFINE APPEND_GROUP.
    LS_GRP_UNIT_SPELL = &1.
    APPEND LS_GRP_UNIT_SPELL TO LT_GRP_UNIT_SPELL.
  END-OF-DEFINITION.

  CONSTANTS:
*    LC_REMAIN             TYPE CHAR2 VALUE 'lẻ'. " TUNGHX EDIT 8/10/2012 -> "LẺ" THÀNH "LINH"
     LC_REMAIN             TYPE CHAR4 VALUE 'linh'.

  DATA:
    LT_DIGIT_SPELL        TYPE TABLE OF LTY_DIGIT_SPELL
                                  WITH KEY DIGIT POSITION,
    LS_DIGIT_SPELL        TYPE LTY_DIGIT_SPELL,
    LT_GRP_UNIT_SPELL     TYPE TABLE OF LTY_GROUP_UNIT_SPELL,
    LS_GRP_UNIT_SPELL     TYPE LTY_GROUP_UNIT_SPELL,
    LW_NUMBER             TYPE NUMC_50,
    LW_NUMBER_LENGTH      TYPE I,
    LW_GRP9               TYPE N LENGTH 9,
    LW_GRP9_LPOS          TYPE I,
    LW_GRP9_RPOS          TYPE I,
    LW_GRP9_LENGTH_AFTER  TYPE I,
    LW_GRP9_LENGTH        TYPE I,
    LW_GRP9_UNIT_SPELL    TYPE CHAR10,
    LW_GRP9_COUNT         TYPE I,
    LW_GRP3               TYPE N LENGTH 3,
    LW_GRP3_LPOS          TYPE I,
    LW_GRP3_RPOS          TYPE I,
    LW_GRP3_LENGTH_AFTER  TYPE I,
    LW_GRP3_LENGTH        TYPE I,
    LW_GRP3_UNIT_SPELL    TYPE CHAR10,
    LW_GRP_LENGTH_AFTER   TYPE I,
    LW_DIGIT              TYPE N,
    LW_DIGIT_LPOS         TYPE I,
    LW_DIGIT_RPOS         TYPE I,
    LW_DIGIT_LNEXT        TYPE I,
    LW_DIGIT_LENGTH_AFTER TYPE I,
    LW_HAS_VALUE_DIGIT    TYPE XMARK,
    LW_CHAR               TYPE C,
    CU_SPELL              TYPE SPELL,
    LW_SPELLSUM1          TYPE STRING,
    LW_SPELLSUM2          TYPE STRING.

* Initilization
  CLEAR: E_TEXT, LT_DIGIT_SPELL, LW_HAS_VALUE_DIGIT.
  LW_NUMBER = I_NUMBER.
  IF  I_CURR IS NOT INITIAL
  AND I_WAERS IS NOT INITIAL.
    WRITE I_CURR TO LW_NUMBER CURRENCY I_WAERS NO-SIGN NO-GROUPING
       DECIMALS 0.
  ENDIF.
  CONDENSE LW_NUMBER.
* Set digit spelling
  APPEND_DIGIT:
         '00 không',
         '10 một',
         '20 hai',
         '30 ba',
         '40 bốn',
         '50 năm',
         '60 sáu',
         '70 bảy',
         '80 tám',
         '90 chín',
         '11 mốt',
         '41 tư',
         '51 lăm',
         '12Xmười'.
  APPEND_GROUP: '1mươi',
          '2trăm',
          '3nghìn',
          '6triệu',
          '9tỷ'.

* Standard input
  SHIFT LW_NUMBER LEFT DELETING LEADING '0'.

* Get length
  LW_NUMBER_LENGTH  = STRLEN( LW_NUMBER ).
  LW_GRP9_RPOS      = LW_NUMBER_LENGTH.

  WHILE LW_GRP9_RPOS > 0.
*   Get group 9 length (max 9)
    LW_GRP9_LENGTH     = LW_GRP9_RPOS MOD 9.
    IF LW_GRP9_LENGTH  = 0.
      LW_GRP9_LENGTH   = 9.
    ENDIF.

*   Get right position, left position, length after and value of group
    LW_GRP9_LPOS         = LW_NUMBER_LENGTH - LW_GRP9_RPOS.
    LW_GRP9              = LW_NUMBER+LW_GRP9_LPOS(LW_GRP9_LENGTH).
    LW_GRP9_LENGTH_AFTER = LW_GRP9_RPOS - LW_GRP9_LENGTH.

    LW_GRP3_RPOS         = LW_GRP9_LENGTH.
    WHILE LW_GRP3_RPOS > 0.
*     Get group length (max 3)
      LW_GRP3_LENGTH     = LW_GRP3_RPOS MOD 3.
      IF LW_GRP3_LENGTH  = 0.
        LW_GRP3_LENGTH   = 3.
      ENDIF.

*     Get right position, left position, length after and value of group
      LW_GRP3_LPOS         = 9 - LW_GRP3_RPOS.
      LW_GRP3              = LW_GRP9+LW_GRP3_LPOS(LW_GRP3_LENGTH).
      LW_GRP3_LENGTH_AFTER = LW_GRP3_RPOS - LW_GRP3_LENGTH.

*     Spell if group <> 0
      IF LW_GRP3 IS NOT INITIAL.
*       Spell each digit
        DO 3 TIMES.
*       Get right, left position, length after and value of digit
          LW_DIGIT_LPOS         = SY-INDEX - 1.
          LW_DIGIT_RPOS         = 3 - LW_DIGIT_LPOS.
          LW_DIGIT              = LW_GRP3+LW_DIGIT_LPOS(1).
          LW_DIGIT_LENGTH_AFTER = LW_DIGIT_RPOS - 1.

*         Get standard spell
          CLEAR LS_DIGIT_SPELL.
          READ TABLE LT_DIGIT_SPELL INTO LS_DIGIT_SPELL
              WITH KEY DIGIT    = LW_DIGIT POSITION = 0.

*         Spell by position
          CASE LW_DIGIT_RPOS.
*           Unit
            WHEN 1.
*             Spell when digit <> 0
              IF LW_DIGIT IS NOT INITIAL.
*               Get ten unit
                LW_DIGIT_LNEXT     = LW_DIGIT_LPOS - 1.
                IF LW_GRP3+LW_DIGIT_LNEXT(1) IS INITIAL.
                  IF  LW_HAS_VALUE_DIGIT IS NOT INITIAL.
*                   Add 'láº»' to text
                    CONCATENATE E_TEXT LC_REMAIN INTO E_TEXT
                      SEPARATED BY SPACE.
                  ENDIF.
                ELSEIF LW_GRP3+LW_DIGIT_LNEXT(1) <> 1.
*                 Get spell by position
                  READ TABLE LT_DIGIT_SPELL INTO LS_DIGIT_SPELL
                    WITH KEY DIGIT    = LW_DIGIT
                             POSITION = LW_DIGIT_RPOS.
                ENDIF.
*               Mark has value digit
                LW_HAS_VALUE_DIGIT = 'X'.
              ELSE.
                CLEAR LS_DIGIT_SPELL.
              ENDIF.
            WHEN 2.
*             Spell only digit <> 0
              IF LW_DIGIT IS INITIAL.
                CLEAR LS_DIGIT_SPELL.
              ELSE.
*               Get spell by position
                READ TABLE LT_DIGIT_SPELL INTO LS_DIGIT_SPELL
                  WITH KEY DIGIT    = LW_DIGIT
                           POSITION = LW_DIGIT_RPOS.
*               Mark has value digit
                LW_HAS_VALUE_DIGIT = 'X'.
              ENDIF.

            WHEN 3.
*             Spell only digit <> 0
              IF  LW_DIGIT IS INITIAL.
                IF LW_HAS_VALUE_DIGIT IS INITIAL.
                  CLEAR LS_DIGIT_SPELL.
                ENDIF.
              ELSE.
*               Mark has value digit
                LW_HAS_VALUE_DIGIT = 'X'.
              ENDIF.
          ENDCASE.

*         Add spell to E_TEXT
          IF LS_DIGIT_SPELL IS NOT INITIAL.
            CONCATENATE E_TEXT LS_DIGIT_SPELL-SPELL INTO E_TEXT
              SEPARATED BY SPACE.
            IF LS_DIGIT_SPELL-NO_UNIT IS INITIAL.
*             Spell digit unit
              READ TABLE LT_GRP_UNIT_SPELL INTO LS_GRP_UNIT_SPELL
                WITH KEY NO_DIGIT = LW_DIGIT_LENGTH_AFTER.
              IF SY-SUBRC IS INITIAL.
                CONCATENATE E_TEXT LS_GRP_UNIT_SPELL-SPELL INTO E_TEXT
                  SEPARATED BY SPACE.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDDO.
*       Spell group unit < 9 digits
        LW_GRP_LENGTH_AFTER = LW_GRP3_LENGTH_AFTER MOD 9.
        READ TABLE LT_GRP_UNIT_SPELL INTO LS_GRP_UNIT_SPELL
          WITH KEY NO_DIGIT = LW_GRP_LENGTH_AFTER.
        IF SY-SUBRC IS INITIAL.
          CONCATENATE E_TEXT LS_GRP_UNIT_SPELL-SPELL INTO E_TEXT
            SEPARATED BY SPACE.
        ENDIF.
      ENDIF.
      LW_GRP3_RPOS = LW_GRP3_RPOS - LW_GRP3_LENGTH.
    ENDWHILE.
    IF LW_GRP9 IS NOT INITIAL.
*     Spell group unit > 9 digits
      LW_GRP9_COUNT = LW_GRP9_LENGTH_AFTER DIV 9.
      DO LW_GRP9_COUNT TIMES.
        READ TABLE LT_GRP_UNIT_SPELL INTO LS_GRP_UNIT_SPELL
        WITH KEY NO_DIGIT = 9.
        IF SY-SUBRC IS INITIAL.
          CONCATENATE E_TEXT LS_GRP_UNIT_SPELL-SPELL INTO E_TEXT
            SEPARATED BY SPACE.
        ENDIF.
      ENDDO.
    ENDIF.
    LW_GRP9_RPOS = LW_GRP9_RPOS - LW_GRP9_LENGTH.
  ENDWHILE.

* Spell zero
  IF LW_NUMBER = 0.
    READ TABLE LT_DIGIT_SPELL INTO LS_DIGIT_SPELL
      WITH KEY DIGIT = 0.
    IF SY-SUBRC IS INITIAL.
      E_TEXT = LS_DIGIT_SPELL-SPELL.
    ENDIF.
  ENDIF.

* Spell five

  IF LW_NUMBER_LENGTH MOD 3 = 0.
    IF ( LW_NUMBER+2(1) MOD 5 = 0 OR LW_NUMBER+5(1) MOD 5 = 0 OR LW_NUMBER+8(1) MOD 5 = 0 OR LW_NUMBER+11(1) MOD 5 = 0 OR LW_NUMBER+14(1) MOD 5 = 0 OR LW_NUMBER+17(1) MOD 5 = 0 OR LW_NUMBER+20(1) MOD 5 = 0 OR LW_NUMBER+23(1) MOD 5 = 0 ) .
      REPLACE 'mười năm' WITH 'mười lăm'INTO E_TEXT.
      REPLACE 'hai năm' WITH 'hai lăm'INTO E_TEXT.
      REPLACE 'ba năm' WITH 'ba lăm'INTO E_TEXT.
      REPLACE 'bốn năm' WITH 'bốn lăm'INTO E_TEXT.
      REPLACE 'năm năm' WITH 'năm lăm'INTO E_TEXT.
      REPLACE 'sáu năm' WITH 'sáu lăm'INTO E_TEXT.
      REPLACE 'bảy năm' WITH 'bảy lăm'INTO E_TEXT.
      REPLACE 'tám năm' WITH 'tám lăm'INTO E_TEXT.
      REPLACE 'chín năm' WITH 'chín lăm'INTO E_TEXT.
    ENDIF.
  ELSEIF LW_NUMBER_LENGTH MOD 3 = 2.
    IF LW_NUMBER+1(1) MOD 5 = 0 OR LW_NUMBER+4(1) MOD 5 = 0 OR LW_NUMBER+7(1) MOD 5 = 0 OR LW_NUMBER+10(1) MOD 5 = 0 OR LW_NUMBER+13(1) MOD 5 = 0 OR LW_NUMBER+16(1) MOD 5 = 0 OR LW_NUMBER+19(1) MOD 5 = 0 OR LW_NUMBER+22(1) MOD 5 = 0 .
      REPLACE 'mười năm' WITH 'mười lăm'INTO E_TEXT.
      REPLACE 'hai năm' WITH 'hai lăm'INTO E_TEXT.
      REPLACE 'ba năm' WITH 'ba lăm'INTO E_TEXT.
      REPLACE 'bốn năm' WITH 'bốn lăm'INTO E_TEXT.
      REPLACE 'năm năm' WITH 'năm lăm'INTO E_TEXT.
      REPLACE 'sáu năm' WITH 'sáu lăm'INTO E_TEXT.
      REPLACE 'bảy năm' WITH 'bảy lăm'INTO E_TEXT.
      REPLACE 'tám năm' WITH 'tám lăm'INTO E_TEXT.
      REPLACE 'chín năm' WITH 'chín lăm'INTO E_TEXT.
    ENDIF.
  ELSEIF LW_NUMBER_LENGTH MOD 3 = 1.
    IF LW_NUMBER+3(1) MOD 5 = 0 OR LW_NUMBER+6(1) MOD 5 = 0 OR LW_NUMBER+9(1) MOD 5 = 0 OR LW_NUMBER+12(1) MOD 5 = 0 OR LW_NUMBER+15(1) MOD 5 = 0 OR LW_NUMBER+18(1) MOD 5 = 0 OR LW_NUMBER+3(1) MOD 21 = 0 OR LW_NUMBER+3(1) MOD 5 = 0 .
      REPLACE 'mười năm' WITH 'mười lăm'INTO E_TEXT.
      REPLACE 'hai năm' WITH 'hai lăm'INTO E_TEXT.
      REPLACE 'ba năm' WITH 'ba lăm'INTO E_TEXT.
      REPLACE 'bốn năm' WITH 'bốn lăm'INTO E_TEXT.
      REPLACE 'năm năm' WITH 'năm lăm'INTO E_TEXT.
      REPLACE 'sáu năm' WITH 'sáu lăm'INTO E_TEXT.
      REPLACE 'bảy năm' WITH 'bảy lăm'INTO E_TEXT.
      REPLACE 'tám năm' WITH 'tám lăm'INTO E_TEXT.
      REPLACE 'chín năm' WITH 'chín lăm'INTO E_TEXT.
    ENDIF.
  ENDIF.

* Add curency
  IF I_CURTX IS NOT INITIAL.
    CONCATENATE E_TEXT I_CURTX INTO E_TEXT SEPARATED BY SPACE.
  ENDIF.

* Upper case first character
  CONDENSE E_TEXT.
  LW_CHAR = E_TEXT(1).
  TRANSLATE LW_CHAR TO UPPER CASE.
  CONCATENATE LW_CHAR E_TEXT+1 INTO E_TEXT.

* DOC CAC SO THAP PHAN
  IF I_CURR < 1 AND I_CURR > 0.
    TRANSLATE E_TEXT TO LOWER CASE.
    CONCATENATE 'Không phẩy' E_TEXT INTO E_TEXT SEPARATED BY SPACE.
  ENDIF.





ENDFUNCTION.
