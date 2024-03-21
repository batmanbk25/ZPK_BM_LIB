*FUNCTION-POOL BDS_BAPI MESSAGE-ID SBDS.

type-pools: cndp.

*data: g_logical_system like  bapibds01-log_system,
*      g_classname like bapibds01-classname,
*      g_classtype like bapibds01-classtype,
*      g_client like bapibds01-client,
*      g_object_key like  bapibds01-objkey
*      g_return like  bapiret2,
*
*      g_files like bapifiles occurs 1 with header line,
*      g_signature like bapisignat occurs 1 with header line.

CONSTANTS: CREATE LIKE TACT-ACTVT VALUE '01',
           CHANGE LIKE TACT-ACTVT VALUE '02',
           DISPLAY LIKE TACT-ACTVT VALUE '03',
           PRINT LIKE TACT-ACTVT VALUE '04',
           ENQUEUE LIKE TACT-ACTVT VALUE '05',
           DELETE LIKE TACT-ACTVT VALUE '06',
           ARCHIVE LIKE TACT-ACTVT VALUE '24',
           RELOAD LIKE TACT-ACTVT VALUE '25',
           GET_INFO LIKE TACT-ACTVT VALUE '30',
           ADMINISTRATE LIKE TACT-ACTVT VALUE '70',
           ASSIGN LIKE TACT-ACTVT VALUE '78',
           VERSION LIKE TACT-ACTVT VALUE '82'.

Tables: bds_t_phio.
