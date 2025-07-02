*&---------------------------------------------------------------------*
*& Include          ZDYP12_R_TERMINAL_TOP
*&---------------------------------------------------------------------*

DATA:BEGIN OF ls_ekko,
       cbox(1),
       sira_no TYPE int2,
       ebeln   TYPE ekko-ebeln,
       bukrs   TYPE ekko-bukrs,
       bstyp   TYPE ekko-bstyp,
       bsart   TYPE ekko-bsart,
     END OF ls_ekko.

DATA: lt_ekko LIKE TABLE OF ls_ekko.

DATA:BEGIN OF ls_ekpo,
       sira_no TYPE int2,
       ebelp   TYPE ekpo-ebelp,
       matnr   TYPE ekpo-matnr,
       lgort   TYPE ekpo-lgort,
       matkl   TYPE ekpo-matkl,
       idnlf   TYPE ekpo-idnlf,
     END OF ls_ekpo.

DATA: lt_ekpo LIKE TABLE OF ls_ekpo.

DATA: gv_line      TYPE i,
      gv_line110   TYPE i,
      lines        TYPE i,
      idx          TYPE i,
      gv_line_ekpo TYPE i.

DATA : lv_number_of_scr_f    TYPE f,
       lv_number_of_scr_f110 TYPE f,
       lv_number_of_scr      TYPE i,
       lv_number_of_scr110   TYPE i,
       lv_current_page       TYPE    i VALUE 1,
       lv_current_page110    TYPE    i VALUE 1.

*      fill type i,
*      line1 type i,
*      lines1 type i,
*      fill1 type i.

DATA: lv_data TYPE ekko-bukrs.
