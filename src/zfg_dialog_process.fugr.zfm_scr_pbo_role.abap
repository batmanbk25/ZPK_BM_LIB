FUNCTION ZFM_SCR_PBO_ROLE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_CPROG) TYPE  CPROG DEFAULT SY-CPROG
*"     REFERENCE(I_DYNNR) TYPE  DYNNR DEFAULT SY-DYNNR
*"     VALUE(I_CONFIG_PROG) TYPE  SY-REPID OPTIONAL
*"--------------------------------------------------------------------
DATA:
    LS_ROLE_FLD   TYPE ZST_BM_ROLE_FLD,
    LT_ROLE_FLD   TYPE TABLE OF ZST_BM_ROLE_FLD,
    LW_FULLFIELD  TYPE CHAR100,
    LS_ERR_FIELD  TYPE ZST_ERR_FIELD,
    LS_HL_FIELD   TYPE ZST_ERR_FIELD,
    LT_ERR_FIELD  TYPE TABLE OF ZST_ERR_FIELD,
    LT_HL_FIELD   TYPE TABLE OF ZST_ERR_FIELD,
    LT_SCR_STEP   TYPE  ZTT_SCR_CHKSTEP.
  FIELD-SYMBOLS:
    <LF_ERR_FIELD>    TYPE ANY.

* Init
  CLEAR: LT_ERR_FIELD, LT_HL_FIELD.
*--------------------------------------------------------------------*
* Modify screen
*--------------------------------------------------------------------*
* Prepare field status
  PERFORM PREPARE_FIELD_STATUS_ROLE
    USING I_CPROG
 CHANGING I_CONFIG_PROG.

  LOOP AT GT_ROLE_FLD INTO LS_ROLE_FLD
    WHERE REPID = I_CONFIG_PROG.
    APPEND LS_ROLE_FLD TO LT_ROLE_FLD.
  ENDLOOP.

* Display screen elements as config in ZTC_PROG->Field status
  IF LT_ROLE_FLD[] IS NOT INITIAL.
    LOOP AT SCREEN.
*     Find field on screen
      READ TABLE LT_ROLE_FLD INTO LS_ROLE_FLD
        WITH KEY  FULLFIELD = SCREEN-NAME BINARY SEARCH.
      IF SY-SUBRC IS INITIAL
      AND LS_ROLE_FLD-FIELDSTS IS NOT INITIAL.
*       Inactive elements
        IF LS_ROLE_FLD-FIELDSTS = GC_FIELDSTS_INACTIVE.
          SCREEN-ACTIVE   = '0'.
*       Active elements (only if not label)
        ELSE.
          IF SCREEN-INPUT <> LS_ROLE_FLD-FIELDSTS+0(1).
            SCREEN-INPUT      = '0'.
          ENDIF.
          IF SCREEN-OUTPUT <> LS_ROLE_FLD-FIELDSTS+1(1).
            SCREEN-OUTPUT     = '0'.
          ENDIF.
          IF SCREEN-REQUIRED <> LS_ROLE_FLD-FIELDSTS+2(1).
            SCREEN-REQUIRED   = '0'.
          ENDIF.
          IF SCREEN-DISPLAY_3D <> LS_ROLE_FLD-FIELDSTS+3(1).
            SCREEN-DISPLAY_3D = '0'.
          ENDIF.
        ENDIF.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.

    PERFORM PBO_MODIFY_TABCONTROL_ROLE
      USING LT_ROLE_FLD
            I_DYNNR
            I_CPROG.
  ENDIF.





ENDFUNCTION.
