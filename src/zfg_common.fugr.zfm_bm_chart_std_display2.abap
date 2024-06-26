FUNCTION ZFM_BM_CHART_STD_DISPLAY2.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_TABDATA) TYPE  TABLE
*"     REFERENCE(I_ON_CALL) TYPE  XMARK OPTIONAL
*"     REFERENCE(I_CPROG) TYPE  CPROG DEFAULT SY-CPROG
*"     REFERENCE(I_DYNNR) TYPE  DYNNR DEFAULT SY-DYNNR
*"     REFERENCE(I_CUS_CONTROL_NAME) TYPE  SCRFNAME
*"         DEFAULT 'CUS_CHART'
*"     REFERENCE(I_EXTENSION) TYPE  INT4 DEFAULT 800
*"     REFERENCE(I_SIDE) TYPE  INT4 DEFAULT 1
*"--------------------------------------------------------------------
DATA:
      LO_IXML_DATA_DOC   TYPE REF TO IF_IXML_DOCUMENT,
      LO_IXML_CUSTOM_DOC TYPE REF TO IF_IXML_DOCUMENT,
      LO_OSTREAM         TYPE REF TO IF_IXML_OSTREAM,
      LW_XSTR            TYPE XSTRING,
      LW_STR             TYPE STRING.

  CALL FUNCTION 'ZFM_BM_CHART_STD_GET_CONFIG'
    EXPORTING
      I_CPROG      = I_CPROG
    CHANGING
      C_CHART_CONF = GS_BM_CHART_CONF.

* For initial display of graph data.
  IF GO_BM_CHART IS INITIAL.
*   Create chart object
    CREATE OBJECT GO_BM_CHART
      EXPORTING
        I_CHA_PROG     = I_CPROG
        I_REPID        = SY-REPID
        I_DYNNR        = '0101'
        I_SIDE         = I_SIDE
        I_EXTENSION    = I_EXTENSION
        I_CUS_CON_NAME = I_CUS_CONTROL_NAME
        IT_TABDATA     = IT_TABDATA.
  ENDIF.

  IF I_ON_CALL IS INITIAL.
    CALL SCREEN 0101.
  ENDIF.





ENDFUNCTION.
