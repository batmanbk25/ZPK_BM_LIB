FUNCTION Z_JSON_DEFORMATER_VALUE.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  CHANGING
*"     REFERENCE(STR)
*"--------------------------------------------------------------------
DATA: elemdescr TYPE REF TO cl_abap_elemdescr.
* Description of element
  elemdescr ?= cl_abap_elemdescr=>describe_by_data( STR ).

  CHECK elemdescr->TYPE_KIND <> 'P' and elemdescr->TYPE_KIND <> 'I'.

  REPLACE ALL OCCURRENCES OF '\n' IN str WITH cl_abap_char_utilities=>cr_lf.

  REPLACE ALL OCCURRENCES OF '\"' IN str WITH '"'.





ENDFUNCTION.
