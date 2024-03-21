FUNCTION ZFM_SCR_PBO.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_CPROG) TYPE  CPROG DEFAULT SY-CPROG
*"     REFERENCE(I_DYNNR) TYPE  DYNNR DEFAULT SY-DYNNR
*"     REFERENCE(I_CSTEP) TYPE  ZDD_CHECK_STEP OPTIONAL
*"     VALUE(T_SCR_CHKSTEP) TYPE  ZTT_SCR_CHKSTEP OPTIONAL
*"     REFERENCE(I_MODE) TYPE  ZDD_SCR_MODE DEFAULT '01'
*"     VALUE(I_CONFIG_PROG) TYPE  SY-REPID OPTIONAL
*"     VALUE(I_CLEAR_INACTIVE) TYPE  XMARK OPTIONAL
*"     REFERENCE(I_SET_LIST_VALUES) TYPE  XMARK OPTIONAL
*"     VALUE(I_SET_LIST_DEFAULT) TYPE  XMARK DEFAULT 'X'
*"     VALUE(I_DISABLE_LBOX_1VAL) TYPE  XMARK OPTIONAL
*"     REFERENCE(I_ROLE_FSTS) TYPE  XMARK OPTIONAL
*"  EXPORTING
*"     REFERENCE(I_ERR_FIELD) TYPE  ZST_ERR_FIELD
*"--------------------------------------------------------------------
DATA:
      LS_FIELD_DB   TYPE ZTB_FIELD_DB,
      LS_SCREEN_GRP TYPE ZTB_FIELD_DB,
      LT_FIELD_DB   TYPE TABLE OF ZTB_FIELD_DB,
      LW_FULLFIELD  TYPE CHAR100,
      LS_ERR_FIELD  TYPE ZST_ERR_FIELD,
      LS_HL_FIELD   TYPE ZST_ERR_FIELD,
      LT_ERR_FIELD  TYPE TABLE OF ZST_ERR_FIELD,
      LT_HL_FIELD   TYPE TABLE OF ZST_ERR_FIELD,
      LT_SCR_STEP   TYPE ZTT_SCR_CHKSTEP,
      LW_DISABLE_F  TYPE XMARK,
      LS_SCREEN     TYPE SCREEN.
  FIELD-SYMBOLS:
    <LF_ERR_FIELD>    TYPE ANY.

* Init
  CLEAR: LT_ERR_FIELD, LT_HL_FIELD.
*--------------------------------------------------------------------*
* Modify screen
*--------------------------------------------------------------------*
* Prepare field status
  PERFORM PREPARE_FIELD_STATUS
    USING I_CPROG
 CHANGING I_CONFIG_PROG.

* Preapare check steps
  PERFORM PREPARE_PROG_STEP
    USING I_CONFIG_PROG
          I_DYNNR
 CHANGING LT_SCR_STEP.

  IF LT_SCR_STEP[] IS INITIAL.
    LT_FIELD_DB = GT_FIELD_DB.
  ELSE.
    LOOP AT GT_FIELD_DB INTO LS_FIELD_DB.
      READ TABLE LT_SCR_STEP TRANSPORTING NO FIELDS
        WITH KEY CSTEP = LS_FIELD_DB-CSTEP.
      IF SY-SUBRC IS INITIAL.
        APPEND LS_FIELD_DB TO LT_FIELD_DB.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Display screen elements as config in ZTC_PROG->Field status
  IF LT_FIELD_DB[] IS NOT INITIAL.
    LOOP AT SCREEN.
      LS_SCREEN = SCREEN.

      PERFORM 9999_MODIFY_SGROUP
        USING LT_FIELD_DB
              I_DYNNR
              I_CLEAR_INACTIVE
              I_MODE
        CHANGING SCREEN.

*     Find field on screen
      READ TABLE LT_FIELD_DB INTO LS_FIELD_DB
        WITH KEY  FIELDNAME  = SCREEN-NAME
                  DYNNR      = I_DYNNR
                  TABCONTROL = SPACE.
      IF SY-SUBRC IS NOT INITIAL.
*       Find field on subscreen
        READ TABLE LT_FIELD_DB INTO LS_FIELD_DB
          WITH KEY  FIELDNAME  = SCREEN-NAME
                    SUBSCR     = I_DYNNR
                    TABCONTROL = SPACE.
        IF SY-SUBRC IS NOT INITIAL.
*         Find label field on screen
          READ TABLE LT_FIELD_DB INTO LS_FIELD_DB
            WITH KEY  LABELF      = SCREEN-NAME
                      DYNNR       = I_DYNNR
                      TABCONTROL  = SPACE.
          IF SY-SUBRC IS NOT INITIAL.
*         Find label field on subscreen
            READ TABLE LT_FIELD_DB INTO LS_FIELD_DB
              WITH KEY  LABELF     = SCREEN-NAME
                        SUBSCR     = I_DYNNR
                        TABCONTROL = SPACE.
          ENDIF.
        ENDIF.
      ENDIF.
      IF SY-SUBRC IS INITIAL
      AND LS_FIELD_DB-FIELDSTS IS NOT INITIAL.
*       Inactive elements
        IF LS_FIELD_DB-FIELDSTS = GC_FIELDSTS_INACTIVE.
          SCREEN-ACTIVE = SCREEN-INPUT = SCREEN-OUTPUT = '0'.
          IF I_CLEAR_INACTIVE = GC_XMARK
          AND LS_FIELD_DB-FIELDNAME = SCREEN-NAME.
            PERFORM CLEAR_INACTIVE
              USING LS_FIELD_DB.
          ENDIF.
        ELSEIF LS_FIELD_DB-FIELDSTS IS NOT INITIAL.
          SCREEN-OUTPUT     = LS_FIELD_DB-FIELDSTS+1(1).
*         Active elements (only if not label)
          IF LS_FIELD_DB-LABELF <> SCREEN-NAME.
            SCREEN-INPUT      = LS_FIELD_DB-FIELDSTS+0(1).
            SCREEN-REQUIRED   = LS_FIELD_DB-FIELDSTS+2(1).
            SCREEN-DISPLAY_3D = LS_FIELD_DB-FIELDSTS+3(1).
          ENDIF.
          IF I_MODE = GC_SMODE_DISPLAY.
            SCREEN-INPUT      = '0'.
            SCREEN-REQUIRED   = '0'.
          ENDIF.
        ENDIF.
*        MODIFY SCREEN.
      ELSEIF SY-SUBRC IS NOT INITIAL
      AND I_MODE = GC_SMODE_DISPLAY.
        SCREEN-INPUT      = '0'.
        SCREEN-REQUIRED   = '0'.
*        MODIFY SCREEN.
      ENDIF.
      IF SCREEN <> LS_SCREEN.
        IF SCREEN-INPUT   <> 0
        OR SCREEN-OUTPUT  <> 0.
          SCREEN-ACTIVE   = '1'.
        ENDIF.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

    PERFORM PBO_MODIFY_TABCONTROL
      USING LT_FIELD_DB
            I_DYNNR
            I_MODE
            I_CPROG.
  ENDIF.

  IF I_ROLE_FSTS IS NOT INITIAL.
    CALL FUNCTION 'ZFM_SCR_PBO_ROLE'
      EXPORTING
        I_CPROG       = I_CPROG
        I_DYNNR       = I_DYNNR
        I_CONFIG_PROG = I_CONFIG_PROG.
  ENDIF.

*--------------------------------------------------------------------*
* Show message and forcus to error field
*--------------------------------------------------------------------*
* Import error fields to memory name:
*   "[ProgramName][ScreenNo]_ERR_FIELDS"
  PERFORM  ERROR_FIELDS_IMPORT
     USING I_CPROG I_DYNNR
  CHANGING LT_ERR_FIELD .

* Show error field and set cursor
  LOOP AT LT_ERR_FIELD INTO LS_ERR_FIELD.
    I_ERR_FIELD = LS_ERR_FIELD.
    IF LS_ERR_FIELD-DYNNR <> SY-DYNNR
    OR ( LS_ERR_FIELD-FPOSI > GW_MSG_SHOWED-FPOSI
     AND GW_MSG_SHOWED-FPOSI IS NOT INITIAL ).
      RETURN.
    ENDIF.

*   Get value from called program
    CONCATENATE '(' I_CPROG ')' LS_ERR_FIELD-FIELD INTO LW_FULLFIELD.
    ASSIGN (LW_FULLFIELD) TO <LF_ERR_FIELD>.
    IF SY-SUBRC IS INITIAL.
      CALL FUNCTION 'ZFM_SCR_SHOW_MSG_FOR_FIELD'
        EXPORTING
          I_RETURN    = LS_ERR_FIELD
          I_FIELD     = <LF_ERR_FIELD>
          I_CPROG     = I_CPROG
        IMPORTING
          E_DISABLE_F = LW_DISABLE_F.
    ELSE.
*     Show msg with no value
      CALL FUNCTION 'ZFM_SCR_SHOW_MSG_FOR_FIELD'
        EXPORTING
          I_RETURN    = LS_ERR_FIELD
          I_CPROG     = I_CPROG
        IMPORTING
          E_DISABLE_F = LW_DISABLE_F.
    ENDIF.
    IF LS_ERR_FIELD-TYPE = 'E' AND LW_DISABLE_F IS INITIAL.
      GW_MSG_SHOWED = LS_ERR_FIELD.
      EXIT.
    ENDIF.
  ENDLOOP.

* If no error, set cursor in last screen field
  IF SY-SUBRC IS NOT INITIAL.
*  AND GS_LAST_CUSOR_FIELD-LINE IS INITIAL.
    IF GS_LAST_CUSOR_FIELD-DYNNR = I_DYNNR.
      SET CURSOR FIELD GS_LAST_CUSOR_FIELD-FIELDNAME
                 LINE GS_LAST_CUSOR_FIELD-LINE
                 OFFSET GS_LAST_CUSOR_FIELD-OFFSET.
      CLEAR: GS_LAST_CUSOR_FIELD.
    ENDIF.
  ELSE.
    CLEAR: GS_LAST_CUSOR_FIELD.
  ENDIF.

* Highlight field
  PERFORM HIGHLIGHT_FIELDS_IMPORT
    USING I_CPROG
          I_DYNNR
    CHANGING LT_HL_FIELD.

  IF LT_HL_FIELD IS NOT INITIAL.
    CALL FUNCTION 'ZFM_SCR_HIGHLIGHT_FIELD'
      EXPORTING
        IT_FIELD = LT_HL_FIELD.
  ENDIF.

  IF I_SET_LIST_VALUES IS NOT INITIAL.
    LOOP AT LT_FIELD_DB INTO LS_FIELD_DB
      WHERE SETLIST = GC_XMARK
        AND ( DYNNR = I_DYNNR OR SUBSCR = I_DYNNR ).
      PERFORM SET_LIST_BOX_VALUE
        USING LS_FIELD_DB
              I_SET_LIST_DEFAULT
              I_DISABLE_LBOX_1VAL.
    ENDLOOP.
  ENDIF.





ENDFUNCTION.
