*&---------------------------------------------------------------------*
*& Include          ZDYP12_R_002_TOP
*&---------------------------------------------------------------------*

DATA : gt_data TYPE TABLE OF ZDYP12_S_002,
       gs_data TYPE ZDYP12_S_002.

CLASS lcl_event_receiver DEFINITION DEFERRED.
DATA : go_main TYPE REF TO lcl_event_receiver.
DATA : grid TYPE REF TO cl_gui_alv_grid.

DATA: gt_color TYPE TABLE OF lvc_s_scol.
