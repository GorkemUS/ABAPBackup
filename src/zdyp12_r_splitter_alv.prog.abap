*&---------------------------------------------------------------------*
*& Report ZDYP12_R_SPLITTER_ALV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDYP12_R_SPLITTER_ALV.

TABLES: vbak, vbap, mara, marde, makt.

DATA: splitter_1 TYPE REF TO cl_gui_splitter_container,
      splitter_2 TYPE REF TO cl_gui_splitter_container,
      container   TYPE REF TO cl_gui_custom_container,
      container_1 TYPE REF TO cl_gui_container,
      container_2 TYPE REF TO cl_gui_container,
      container_3 TYPE REF TO cl_gui_container.

DATA : it_vbap     TYPE TABLE OF vbap,
       it_vbak     TYPE TABLE OF vbak,
*       c_container TYPE scrfname VALUE 'CCONTAINER',
       grid1       TYPE REF TO cl_gui_alv_grid,
       grid2       TYPE REF TO cl_gui_alv_grid.
*       grid3       TYPE REF TO cl_gui_alv_grid.


SELECT * FROM vbap INTO TABLE it_vbap UP TO 100 ROWS.
SELECT * FROM vbak INTO TABLE it_vbak UP TO 100 ROWS.

  START-OF-SELECTION.
    CALL SCREEN 9000.


MODULE status_9000 OUTPUT.

  SET PF-STATUS 'STANDARD'.
  PERFORM create_splitter_1.
  PERFORM create_splitter_2.
  PERFORM display_grid1.
  PERFORM display_grid2.

ENDMODULE.

FORM create_splitter_1 .

  CREATE OBJECT splitter_1
    EXPORTING
      parent = cl_gui_container=>default_screen
      rows = 2
      columns = 1.

    CALL METHOD splitter_1->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = container_1.

    CALL METHOD splitter_1->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = container_2.

ENDFORM.


FORM create_splitter_2 .

*  CREATE OBJECT splitter_2
*    EXPORTING
*      parent  = container_2
*      rows    = 2
*      columns = 1.
*
*  CALL METHOD splitter_2->get_container
*    EXPORTING
*      row       = 1
*      column    = 1
*    RECEIVING
*      container = container_2.
*
*  CALL METHOD splitter_2->get_container
*    EXPORTING
*      row       = 2
*      column    = 1
*    RECEIVING
*      container = container_3.

ENDFORM.

FORM display_grid1 .

*    CREATE OBJECT container
*    EXPORTING
*      container_name = c_container.

  CREATE OBJECT grid1
    EXPORTING
      i_parent = container_1.

  CALL METHOD grid1->set_table_for_first_display
    EXPORTING
      i_structure_name = 'VBAP'
    CHANGING
      it_outtab        = it_vbap.

ENDFORM.

FORM display_grid2 .

*    CREATE OBJECT container
*    EXPORTING
*      container_name = c_container.

  CREATE OBJECT grid2
    EXPORTING
      i_parent = container_2.

  CALL METHOD grid2->set_table_for_first_display
    EXPORTING
      i_structure_name = 'VBAK'
    CHANGING
      it_outtab        = it_vbak.
ENDFORM.

MODULE user_command_9000 INPUT.

  CASE sy-ucomm.

    WHEN '&F03' or '&F15' or '&F12'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " U
