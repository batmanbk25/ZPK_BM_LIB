FUNCTION ZFM_BM_ALV_TREE_REFRESH.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_TREE_STR) TYPE  ZST_TREE_STR OPTIONAL
*"  CHANGING
*"     REFERENCE(C_TREE_CONTROL) TYPE REF TO  CL_GUI_ALV_TREE
*"     REFERENCE(T_TREE_TAB) TYPE  ANY TABLE
*"----------------------------------------------------------------------
DATA:
    LT_ROOTS                  TYPE LVC_T_NKEY,
    LS_ROOT                   TYPE LVC_NKEY,
    LW_WHERE                  TYPE STRING.
  FIELD-SYMBOLS:
    <LF_TREE_DATA>            TYPE ANY.

* Standard tree structure
  PERFORM ALV_TREE_STANDARD_STRUCTURE
    USING T_TREE_TAB
    CHANGING I_TREE_STR.

  CONCATENATE GC_ATREE_TREEKEY 'IS INITIAL'
         INTO LW_WHERE SEPARATED BY SPACE.

  LOOP AT T_TREE_TAB ASSIGNING <LF_TREE_DATA>
    WHERE (LW_WHERE).
*   Push single node to tree
    PERFORM ALV_TREE_NODES_PUSH_SINGLE
      USING     I_TREE_STR
                T_TREE_TAB
      CHANGING  <LF_TREE_DATA>
                C_TREE_CONTROL
                LT_ROOTS.
  ENDLOOP.

  SORT LT_ROOTS DESCENDING.
  LOOP AT LT_ROOTS INTO LS_ROOT.
    CALL METHOD C_TREE_CONTROL->EXPAND_NODE
      EXPORTING
        I_NODE_KEY          = LS_ROOT
        I_EXPAND_SUBTREE    = GC_XMARK
      EXCEPTIONS
        FAILED              = 1
        ILLEGAL_LEVEL_COUNT = 2
        CNTL_SYSTEM_ERROR   = 3
        NODE_NOT_FOUND      = 4
        CANNOT_EXPAND_LEAF  = 5
        OTHERS              = 6.

  ENDLOOP.

  CALL METHOD C_TREE_CONTROL->FRONTEND_UPDATE.

  CALL METHOD C_TREE_CONTROL->SET_SCREEN_UPDATE
    EXPORTING
      I_UPDATE          = GC_XMARK
    EXCEPTIONS
      CNTL_SYSTEM_ERROR = 1
      FAILED            = 2
      OTHERS            = 3.





ENDFUNCTION.
