FUNCTION ZFM_RFC_SYSTEM_INFO.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(RFCSI_EXPORT) LIKE  RFCSI STRUCTURE  RFCSI
*"     VALUE(CURRENT_RESOURCES) LIKE  SY-INDEX
*"     VALUE(MAXIMAL_RESOURCES) LIKE  SY-INDEX
*"     VALUE(RECOMMENDED_DELAY) LIKE  SY-INDEX
*"--------------------------------------------------------------------
WAIT UP TO 10 SECONDS.

* Call Kernel
  CALL 'RFCSystemInfo' ID 'RFCSI' FIELD RFCSI_EXPORT.





ENDFUNCTION.
