FUNCTION ZFM_FILE_EXCEL_CONV2TAB_MAP.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(T_MAPPING) TYPE  ZTT_EXCEL_MAPPING
*"     VALUE(T_EXCEL) TYPE  ZTT_EXCEL_NUMBR
*"     REFERENCE(T_FIELDCAT) TYPE  LVC_T_FCAT
*"     REFERENCE(I_COMMA) TYPE  XMARK OPTIONAL
*"     REFERENCE(I_SHEETFIELD) TYPE  FIELDNAME OPTIONAL
*"     REFERENCE(I_ROWIXFIELD) TYPE  FIELDNAME OPTIONAL
*"     REFERENCE(I_SHEETNAME) TYPE  CHAR255 OPTIONAL
*"  EXPORTING
*"     REFERENCE(T_OUTTAB) TYPE  TABLE
*"--------------------------------------------------------------------
DATA:
      LS_MAPPING      TYPE ZST_EXCEL_MAPPING,
*      LS_EXCEL_DATA   TYPE SOI_GENERIC_ITEM,
      LS_EXCEL_DATA   TYPE ZST_EXCEL_NUMBR,
      LS_EXCEL_NUMBR  TYPE ZST_EXCEL_NUMBR,
      LT_EXCEL_NUMBR  TYPE TABLE OF ZST_EXCEL_NUMBR,
      LS_DATA         TYPE REF TO DATA,
      LS_DIMENS       TYPE SOI_DIMENSION_ITEM,
      LS_FIELDCAT     TYPE LVC_S_FCAT,
      LO_OREF         TYPE REF TO CX_ROOT,
      LW_DAY          TYPE NUMC2,
      LW_MONTH        TYPE NUMC2,
      LW_YEAR         TYPE NUMC4,
      LW_FMCONVEXIT   TYPE CHAR30.

  FIELD-SYMBOLS:
    <LF_DATA>       TYPE ANY,
    <LF_VALUE>      TYPE ANY.

* Standard data with data type is number
  LT_EXCEL_NUMBR[] = T_EXCEL[].
  REFRESH T_EXCEL[].
*  LOOP AT T_EXCEL[] INTO LS_EXCEL_DATA.
*    MOVE-CORRESPONDING LS_EXCEL_DATA TO LS_EXCEL_NUMBR.
*    APPEND LS_EXCEL_NUMBR TO LT_EXCEL_NUMBR.
*  ENDLOOP.

* Sort table by Row and column
  SORT LT_EXCEL_NUMBR BY ROW COLUMN.

* Get data
  LOOP AT LT_EXCEL_NUMBR INTO LS_EXCEL_NUMBR.
*   At new row, create a new record
    AT NEW ROW.
      CREATE DATA LS_DATA LIKE LINE OF T_OUTTAB.
      ASSIGN LS_DATA->* TO <LF_DATA>.
      CLEAR <LF_DATA>.
    ENDAT.
*   Get value of each column corresponding with field
    READ TABLE T_MAPPING INTO LS_MAPPING
      WITH KEY  SHEETNAME = I_SHEETNAME
                COLUMN = LS_EXCEL_NUMBR-COLUMN.

    IF SY-SUBRC IS INITIAL.
      ASSIGN COMPONENT LS_MAPPING-FIELDNAME OF STRUCTURE <LF_DATA>
        TO <LF_VALUE>.
      IF SY-SUBRC IS INITIAL.
*       Check data type of number and change thousand separate.
        READ TABLE T_FIELDCAT INTO LS_FIELDCAT
          WITH KEY FIELDNAME = LS_MAPPING-FIELDNAME.
        IF SY-SUBRC IS INITIAL.
          IF LS_FIELDCAT-DATATYPE = 'CURR'
          OR LS_FIELDCAT-DATATYPE = 'DEC'
          OR LS_FIELDCAT-DATATYPE = 'QUAN'.
            IF I_COMMA = 'X'.
              REPLACE ',' IN LS_EXCEL_NUMBR-VALUE WITH '.'.
            ENDIF.
          ENDIF.
        ENDIF.
*       Try to move value
        TRY.
            IF LS_EXCEL_NUMBR-VALUE IS INITIAL.
              CLEAR: <LF_VALUE>.
            ELSE.
              CASE LS_FIELDCAT-DATATYPE.
                WHEN 'DATS'.
                  IF LS_EXCEL_NUMBR-VALUE CS '/'.
                    SPLIT LS_EXCEL_NUMBR-VALUE AT '/'
                      INTO LW_DAY LW_MONTH LW_YEAR.
                    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT':
                      EXPORTING INPUT         = LW_MONTH
                      IMPORTING OUTPUT        = LW_MONTH,
                      EXPORTING INPUT         = LW_DAY
                      IMPORTING OUTPUT        = LW_DAY.
                    <LF_VALUE>(4)    = LW_YEAR.
                    <LF_VALUE>+4(2)  = LW_MONTH.
                    <LF_VALUE>+6(2)  = LW_DAY.
                  ELSEIF LS_EXCEL_NUMBR-VALUE CS '.'.
                    SPLIT LS_EXCEL_NUMBR-VALUE AT '.'
                      INTO LW_DAY LW_MONTH LW_YEAR.
                    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT':
                      EXPORTING INPUT         = LW_MONTH
                      IMPORTING OUTPUT        = LW_MONTH,
                      EXPORTING INPUT         = LW_DAY
                      IMPORTING OUTPUT        = LW_DAY.
                    <LF_VALUE>(4)    = LW_YEAR.
                    <LF_VALUE>+4(2)  = LW_MONTH.
                    <LF_VALUE>+6(2)  = LW_DAY.
                  ELSE.
                    MOVE LS_EXCEL_NUMBR-VALUE TO <LF_VALUE>.
                  ENDIF.
                WHEN OTHERS.
                  IF LS_FIELDCAT-CONVEXIT IS INITIAL.
                    MOVE LS_EXCEL_NUMBR-VALUE TO <LF_VALUE>.
                  ELSE.
                    CONCATENATE 'CONVERSION_EXIT_'
                                LS_FIELDCAT-CONVEXIT '_INPUT'
                           INTO LW_FMCONVEXIT.
                    "'CONVERSION_EXIT_ALPHA_INPUT'
                    CALL FUNCTION LW_FMCONVEXIT
                      EXPORTING
                        INPUT         = LS_EXCEL_NUMBR-VALUE
                      IMPORTING
                        OUTPUT        = <LF_VALUE>.
                  ENDIF.
              ENDCASE.
            ENDIF.
          CATCH CX_SY_CONVERSION_NO_NUMBER INTO LO_OREF.
        ENDTRY.
      ENDIF.
    ENDIF.
*   At end row, append new record to table
    AT END OF ROW.
      IF <LF_DATA> IS NOT INITIAL.
*       Update row index
        IF I_ROWIXFIELD IS NOT INITIAL.
          ASSIGN COMPONENT I_ROWIXFIELD OF STRUCTURE <LF_DATA>
            TO <LF_VALUE>.
          IF SY-SUBRC IS INITIAL.
            <LF_VALUE> = LS_EXCEL_NUMBR-ROW.
          ENDIF.
        ENDIF.
*       Update row index
        IF I_SHEETFIELD IS NOT INITIAL.
          ASSIGN COMPONENT I_SHEETFIELD OF STRUCTURE <LF_DATA>
            TO <LF_VALUE>.
          IF SY-SUBRC IS INITIAL.
            <LF_VALUE> = I_SHEETNAME.
          ENDIF.
        ENDIF.
*        INSERT <LF_DATA> INTO TABLE T_OUTTAB.
        APPEND <LF_DATA> TO T_OUTTAB.

      ENDIF.
    ENDAT.
  ENDLOOP.





ENDFUNCTION.
