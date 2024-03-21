*******************************************************************
*   System-defined Include-files.                                 *
*******************************************************************
  INCLUDE LZFG_EXCEL_INTERFACETOP.           " Global Data
  INCLUDE LZFG_EXCEL_INTERFACEUXX.           " Function Modules

*******************************************************************
*   User-defined Include-files (if necessary).                    *
*******************************************************************
* INCLUDE LZFG_EXCEL_INTERFACEF...           " Subroutines
* INCLUDE LZFG_EXCEL_INTERFACEO...           " PBO-Modules
* INCLUDE LZFG_EXCEL_INTERFACEI...           " PAI-Modules
* INCLUDE LZFG_EXCEL_INTERFACEE...           " Events
* INCLUDE LZFG_EXCEL_INTERFACEP...           " Local class implement.

  INCLUDE LZFG_EXCEL_INTERFACEF01.

  INCLUDE LZXLWBF01.                         " Subprograms

  LOAD-OF-PROGRAM.
    PERFORM INIT_PROC.
