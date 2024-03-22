*&---------------------------------------------------------------------*
*& Include ZPG_CE104_08_TOP                                  Report ZPG_CE104_08
*&
*&---------------------------------------------------------------------*

REPORT ZPG_CE104_08.

TYPES:
  BEGIN OF GTY_OBJECT,
    OBJNAME TYPE TABNAME,
  END OF GTY_OBJECT.

DATA: GT_KEY TYPE APB_LPD_T_E071K,
      GT_OBJ TYPE /SAPCND/T_KO200.
DATA: GW_OBJNAME TYPE TABNAME.

SELECT-OPTIONS:
  S_OBJNM FOR GW_OBJNAME.
