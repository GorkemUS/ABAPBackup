*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDYP12_T_002....................................*
DATA:  BEGIN OF STATUS_ZDYP12_T_002                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDYP12_T_002                  .
CONTROLS: TCTRL_ZDYP12_T_002
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZDYP12_T_002                  .
TABLES: ZDYP12_T_002                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
