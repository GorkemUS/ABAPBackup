*&---------------------------------------------------------------------*
*& Include          ZDYP12_R_BATCH_TOP
*&---------------------------------------------------------------------*

DATA: gs_data TYPE zdyp12_s_batch,
      gt_data TYPE TABLE OF zdyp12_s_batch.

CLASS lcl_event_receiver DEFINITION DEFERRED.

DATA : grid TYPE REF TO cl_gui_alv_grid,
       main TYPE REF TO lcl_event_receiver.

DATA: lt_fieldcatalog TYPE TABLE OF lvc_s_fcat.
DATA: ls_fieldcatalog TYPE lvc_s_fcat .
DATA: ls_layout   TYPE lvc_s_layo .

DATA: lt_selected_rows TYPE lvc_t_row,
      ls_selected_row  TYPE lvc_s_row.

DATA: gs_toolbar TYPE stb_button.

CONSTANTS:c_ext_xls TYPE string VALUE '*.xls'.
DATA: lt_filetable   TYPE filetable,
      lv_return_code TYPE i,
      lx_filetable   TYPE file_table,
      t_upload       TYPE TABLE OF alsmex_tabline,
      t_tmp_excel    TYPE alsmex_tabline.

DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
DATA:   messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
DATA :  bdcmsg TYPE TABLE OF bdcmsgcoll.

DATA: lt_message TYPE bapirettab,
      ls_message TYPE bapiret2.

TYPES: BEGIN OF ty_rows,
         row TYPE numc4,
       END OF ty_rows.
DATA: lt_rows TYPE TABLE OF ty_rows.

FIELD-SYMBOLS: <ls_row> TYPE ty_rows.


SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME.

  PARAMETERS p_file TYPE localfile OBLIGATORY.

SELECTION-SCREEN END OF BLOCK a1.
