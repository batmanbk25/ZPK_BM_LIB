*******************************************************************
*   System-defined Include-files.                                 *
*******************************************************************
  INCLUDE LZFG_BM_SCRLOGTOP.                 " Global Data
  INCLUDE LZFG_BM_SCRLOGUXX.                 " Function Modules

*******************************************************************
*   User-defined Include-files (if necessary).                    *
*******************************************************************
* INCLUDE LZFG_BM_SCRLOGF...                 " Subroutines
* INCLUDE LZFG_BM_SCRLOGO...                 " PBO-Modules
* INCLUDE LZFG_BM_SCRLOGI...                 " PAI-Modules
* INCLUDE LZFG_BM_SCRLOGE...                 " Events
* INCLUDE LZFG_BM_SCRLOGP...                 " Local class implement.
* INCLUDE LZFG_BM_SCRLOGT99.                 " ABAP Unit tests

  LOAD-OF-PROGRAM.
    PERFORM 0000_INIT_PROG.

INCLUDE lzfg_bm_scrlogf01.
