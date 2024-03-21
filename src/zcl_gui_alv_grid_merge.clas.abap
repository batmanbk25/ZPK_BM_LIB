class ZCL_GUI_ALV_GRID_MERGE definition
  public
  inheriting from CL_GUI_ALV_GRID
  create public .

public section.

  data ZSTYLEFNAME type FIELDNAME value 'ZSTYLE' ##NO_TEXT.

  methods Z_SET_MERGE
    importing
      !ROW1 type I
      !COL1 type I
      !ROW2 type I
      !COL2 type I .
  methods Z_SET_MERGE_MULTI
    importing
      !T_CELLS_MERGE type ZTT_CELLS_MERGE .
  methods Z_SET_CELL_STYLE
    importing
      !ROW type I optional
      !COL type I optional
      !STYLE type LVC_STYLE
      !STYLE2 type LVC_STYLE optional .
  methods Z_SET_FIXED_COL_ROW
    importing
      !COL type I
      !ROW type I .

  methods REFRESH_TABLE_DISPLAY
    redefinition .
protected section.
private section.

  methods ZSET_CUS_DISPLAY .
ENDCLASS.



CLASS ZCL_GUI_ALV_GRID_MERGE IMPLEMENTATION.


METHOD REFRESH_TABLE_DISPLAY.

  CALL METHOD SUPER->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE      = IS_STABLE
      I_SOFT_REFRESH = I_SOFT_REFRESH
    EXCEPTIONS
      FINISHED       = 1
      OTHERS         = 2.
  CHECK SY-SUBRC IS INITIAL.

* Set customize display
  CALL METHOD ZSET_CUS_DISPLAY.

ENDMETHOD.


METHOD ZSET_CUS_DISPLAY.
  DATA:
    LW_ROWPOS TYPE I,
    LT_FCAT   TYPE LVC_T_FCAT,
    LW_NOCELL TYPE I.

  FIELD-SYMBOLS:
    <LFT_OUTTAB> TYPE TABLE,
    <LFT_STYLE>  TYPE ZTT_BM_LVC_STYL,
    <LFS_STYLE>  TYPE ZST_BM_LVC_STYL.

* Get output data
  ASSIGN MT_OUTTAB->* TO <LFT_OUTTAB>.
  LOOP AT <LFT_OUTTAB> ASSIGNING FIELD-SYMBOL(<LF_OUTTAB>).
    LW_ROWPOS = SY-TABIX.
    CALL METHOD ME->GET_FRONTEND_FIELDCATALOG
      IMPORTING
        ET_FIELDCATALOG = LT_FCAT.

*   Check customize style exists
    ASSIGN COMPONENT ZSTYLEFNAME OF STRUCTURE <LF_OUTTAB>
      TO <LFT_STYLE>.
    IF SY-SUBRC IS INITIAL.
      LOOP AT <LFT_STYLE> ASSIGNING <LFS_STYLE>.
*       Get column position by fieldname
        READ TABLE LT_FCAT INTO DATA(LS_FCAT)
          WITH KEY FIELDNAME = <LFS_STYLE>-FIELDNAME.
        IF SY-SUBRC IS INITIAL.
*         Get cell data
          READ TABLE MT_DATA ASSIGNING FIELD-SYMBOL(<LF_DATA>)
            WITH KEY ROW_POS = LW_ROWPOS
                     COL_POS = LS_FCAT-COL_POS.
          IF SY-SUBRC IS INITIAL.
*           Set merge info
            IF <LFS_STYLE>-MERGEVERT IS NOT INITIAL
            OR <LFS_STYLE>-MERGEHORIZ IS NOT INITIAL.
              IF <LFS_STYLE>-MERGEVERT > 0.
                <LF_DATA>-MERGEVERT   = <LFS_STYLE>-MERGEVERT - 1.
              ELSE.
                CLEAR: <LF_DATA>-MERGEVERT.
              ENDIF.
              IF <LFS_STYLE>-MERGEHORIZ > 0.
                <LF_DATA>-MERGEHORIZ  = <LFS_STYLE>-MERGEHORIZ - 1.
              ELSE.
                CLEAR: <LF_DATA>-MERGEHORIZ.
              ENDIF.
            ENDIF.
*           Set style
            IF <LFS_STYLE>-STYLE IS NOT INITIAL
            OR <LFS_STYLE>-STYLE2 IS NOT INITIAL.
              <LF_DATA>-STYLE  = <LF_DATA>-STYLE + <LFS_STYLE>-STYLE.
              <LF_DATA>-STYLE2 = <LF_DATA>-STYLE2 + <LFS_STYLE>-STYLE2.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ELSE.
      RETURN.
    ENDIF.
  ENDLOOP.

  LW_NOCELL = LINES( LT_FCAT ) * LINES( <LFT_OUTTAB> ).
  IF LW_NOCELL < 1000.
*   Now still transfer the changed data
    CALL METHOD ME->SET_DATA_TABLE
      CHANGING
        DATA_TABLE = MT_DATA[].

*   Auto redraw data
    CALL METHOD SET_AUTO_REDRAW
      EXPORTING
        ENABLE = 1.
  ENDIF.
ENDMETHOD.


METHOD Z_SET_CELL_STYLE.
**************************************************************************
*   Method attributes.                                                   *
**************************************************************************
* Instantiation: Public
**************************************************************************


  FIELD-SYMBOLS <FS_DATA> TYPE LVC_S_DATA.
  IF ROW IS INITIAL.
    IF COL IS INITIAL.
* Beides leer -> nichts zu tun.
      EXIT.
    ELSE.
* Nur Spalte setze komplette Spalte
      LOOP AT MT_DATA ASSIGNING <FS_DATA>
            WHERE COL_POS = COL.
        <FS_DATA>-STYLE  = <FS_DATA>-STYLE + STYLE.
        <FS_DATA>-STYLE2 = <FS_DATA>-STYLE2 + STYLE2.
      ENDLOOP.
    ENDIF.
  ELSE.
    IF COL IS INITIAL.
* Nur Zeile eingegeben -> komplette Zeile setzen
      LOOP AT MT_DATA ASSIGNING <FS_DATA>
            WHERE ROW_POS = ROW.
        <FS_DATA>-STYLE  = <FS_DATA>-STYLE + STYLE.
        <FS_DATA>-STYLE2 = <FS_DATA>-STYLE2 + STYLE2.
      ENDLOOP.
    ELSE.
      READ TABLE MT_DATA ASSIGNING <FS_DATA>
          WITH KEY ROW_POS = ROW
                   COL_POS = COL.
      IF SY-SUBRC EQ 0.
        <FS_DATA>-STYLE  = <FS_DATA>-STYLE + STYLE.
        <FS_DATA>-STYLE2 = <FS_DATA>-STYLE2 + STYLE2.
      ELSE.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMETHOD.


method Z_SET_FIXED_COL_ROW.

  me->set_fixed_cols( col ).
  me->set_fixed_rows( row ).

endmethod.


METHOD Z_SET_MERGE.
  FIELD-SYMBOLS <LF_DATA> TYPE LVC_S_DATA.

  CHECK COL1 > 0 AND ROW1 > 0.
  CHECK COL1 <= COL2
    AND ROW1 <= ROW2.

  LOOP AT MT_DATA ASSIGNING <LF_DATA>
    WHERE ROW_POS BETWEEN ROW1 AND ROW2
      AND COL_POS BETWEEN COL1 AND COL2.
    IF <LF_DATA>-ROW_POS  = ROW1
    AND <LF_DATA>-COL_POS = COL1.
      <LF_DATA>-MERGEVERT   = ROW2 - ROW1.
      <LF_DATA>-MERGEHORIZ  = COL2 - COL1.
    ELSE.
      CLEAR <LF_DATA>-MERGEVERT.
      CLEAR <LF_DATA>-MERGEHORIZ.
      CLEAR <LF_DATA>-VALUE.
    ENDIF.
  ENDLOOP.

ENDMETHOD.


METHOD Z_SET_MERGE_MULTI.
  FIELD-SYMBOLS <LF_CELL_MERGE> TYPE ZST_CELLS_MERGE.
  FIELD-SYMBOLS <LF_DATA> TYPE LVC_S_DATA.

  LOOP AT T_CELLS_MERGE ASSIGNING <LF_CELL_MERGE>.
    CHECK <LF_CELL_MERGE>-COL1 > 0 AND <LF_CELL_MERGE>-ROW1 > 0.
    CHECK <LF_CELL_MERGE>-COL1 <= <LF_CELL_MERGE>-COL2
      AND <LF_CELL_MERGE>-ROW1 <= <LF_CELL_MERGE>-ROW2.

    LOOP AT MT_DATA ASSIGNING <LF_DATA>
      WHERE ROW_POS BETWEEN <LF_CELL_MERGE>-ROW1 AND <LF_CELL_MERGE>-ROW2
        AND COL_POS BETWEEN <LF_CELL_MERGE>-COL1 AND <LF_CELL_MERGE>-COL2.
      IF <LF_DATA>-ROW_POS  = <LF_CELL_MERGE>-ROW1
      AND <LF_DATA>-COL_POS = <LF_CELL_MERGE>-COL1.
        <LF_DATA>-MERGEVERT   = <LF_CELL_MERGE>-ROW2 - <LF_CELL_MERGE>-ROW1 + 1.
        <LF_DATA>-MERGEHORIZ  = <LF_CELL_MERGE>-COL2 - <LF_CELL_MERGE>-COL1 + 1.
      ELSE.
        CLEAR <LF_DATA>-MERGEVERT.
        CLEAR <LF_DATA>-MERGEHORIZ.
        CLEAR <LF_DATA>-VALUE.
      ENDIF.
    ENDLOOP.

  ENDLOOP.
ENDMETHOD.
ENDCLASS.
