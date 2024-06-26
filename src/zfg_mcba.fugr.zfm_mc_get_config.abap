FUNCTION ZFM_MC_GET_CONFIG.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_MCBAID) TYPE  ZDD_MCBAID OPTIONAL
*"  EXPORTING
*"     REFERENCE(E_MCCF_BUSAREA) TYPE  ZST_MCCF_BUSAREA
*"--------------------------------------------------------------------
DATA:
    LT_MC_BUSELE        TYPE TABLE OF ZTB_MC_BUSELE,
    LS_MC_BUSELE        TYPE ZTB_MC_BUSELE,
    LT_MCCF_BUSELE      TYPE TABLE OF ZST_MCCF_BUSELE,
    LS_MCCF_BUSELE      TYPE ZST_MCCF_BUSELE,
    LT_MC_BUSFLD        TYPE TABLE OF ZTB_MC_BUSFLD,
    LS_MC_BUSFLD        TYPE ZTB_MC_BUSFLD,
    LS_FIELD_CHANGE     TYPE ZST_MCBA_FIELD_CHANGE.

  CLEAR: GS_MC_BUSAREA, LT_MC_BUSELE, LT_MCCF_BUSELE, LT_MC_BUSFLD.

* Check data got
  IF I_MCBAID = GS_MC_BUSAREA-MCBAID.
    E_MCCF_BUSAREA = GS_MC_BUSAREA.
    RETURN.
  ENDIF.

* Get bus.area
  SELECT SINGLE *
    FROM ZTB_MC_BUSAREA
    INTO CORRESPONDING FIELDS OF GS_MC_BUSAREA
   WHERE MCBAID = I_MCBAID.

* Get bus elements
  SELECT *
    FROM ZTB_MC_BUSELE
    INTO TABLE LT_MC_BUSELE
   WHERE MCBAID = I_MCBAID.
  SORT LT_MC_BUSELE BY MCBAID MCBAELID.

* Get change fields
  SELECT *
    FROM ZTB_MC_BUSFLD
    INTO TABLE LT_MC_BUSFLD
   WHERE MCBAID = I_MCBAID.
  SORT LT_MC_BUSFLD BY MCBAID MCBAELID FPOSI.

* Aggregare
  LOOP AT LT_MC_BUSELE INTO LS_MC_BUSELE.
    MOVE-CORRESPONDING LS_MC_BUSELE TO LS_MCCF_BUSELE.
    LOOP AT LT_MC_BUSFLD INTO LS_MC_BUSFLD
      WHERE MCBAELID = LS_MC_BUSELE-MCBAELID.
      MOVE-CORRESPONDING LS_MC_BUSFLD TO LS_FIELD_CHANGE.
      APPEND LS_FIELD_CHANGE TO LS_MCCF_BUSELE-FIELDS.
    ENDLOOP.

    APPEND LS_MCCF_BUSELE TO LT_MCCF_BUSELE.
  ENDLOOP.

  GS_MC_BUSAREA-ELEMENTS = LT_MCCF_BUSELE.

* Output data
  E_MCCF_BUSAREA = GS_MC_BUSAREA.

* Get map data
  PERFORM GET_MAP_DATA.





ENDFUNCTION.
