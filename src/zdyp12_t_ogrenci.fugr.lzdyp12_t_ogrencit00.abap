*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDYP12_T_OGRENCI................................*
DATA:  BEGIN OF STATUS_ZDYP12_T_OGRENCI              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDYP12_T_OGRENCI              .
CONTROLS: TCTRL_ZDYP12_T_OGRENCI
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZDYP12_T_OGRENCI              .
TABLES: ZDYP12_T_OGRENCI               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
