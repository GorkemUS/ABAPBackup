*&---------------------------------------------------------------------*
*& Report ZDYP12_R_SPLITTER_ALV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDYP12_R_SPLITTER_ALV2.

TABLES: mara,marde, makt.

DATA: splitter_1 TYPE REF TO cl_gui_splitter_container,
      splitter_2 TYPE REF TO cl_gui_splitter_container,
      container   TYPE REF TO cl_gui_custom_container,
      container_1 TYPE REF TO cl_gui_container,
      container_2 TYPE REF TO cl_gui_container,
      container_3 TYPE REF TO cl_gui_container.

DATA : it_mara     TYPE TABLE OF mara,
       it_marde    TYPE TABLE OF marde,
       it_makt     TYPE TABLE OF makt,
*       c_container TYPE scrfname VALUE 'CCONTAINER',
       grid1       TYPE REF TO cl_gui_alv_grid,
       grid2       TYPE REF TO cl_gui_alv_grid,
       grid3       TYPE REF TO cl_gui_alv_grid.


SELECT * FROM mara INTO TABLE it_mara UP TO 100 ROWS.
SELECT * FROM marde INTO TABLE it_marde UP TO 100 ROWS.
SELECT * FROM makt INTO TABLE it_makt UP TO 100 ROWS.

  START-OF-SELECTION.
    CALL SCREEN 9000.


MODULE status_9000 OUTPUT.

  SET PF-STATUS 'STANDARD'.
  PERFORM create_splitter_1.
  PERFORM create_splitter_2.
  PERFORM display_grid1.
  PERFORM display_grid2.
  PERFORM display_grid3.

ENDMODULE.

FORM create_splitter_1 .

  CREATE OBJECT splitter_1
    EXPORTING
      parent = cl_gui_container=>default_screen
      rows = 3
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

    CALL METHOD splitter_1->get_container
    EXPORTING
      row       = 3
      column    = 1
    RECEIVING
      container = container_3.

ENDFORM.


FORM create_splitter_2 .

*  CREATE OBJECT splitter_2
*    EXPORTING
*      parent  = container_2
*      rows    = 3
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
      i_structure_name = 'MARA'
    CHANGING
      it_outtab        = it_mara.

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
      i_structure_name = 'MARDE'
    CHANGING
      it_outtab        = it_marde.
ENDFORM.

FORM display_grid3 .

*    CREATE OBJECT container
*    EXPORTING
*      container_name = c_container.

  CREATE OBJECT grid3
    EXPORTING
      i_parent = container_3.

  CALL METHOD grid3->set_table_for_first_display
    EXPORTING
      i_structure_name = 'MAKT'
    CHANGING
      it_outtab        = it_makt.
ENDFORM.

MODULE user_command_9000 INPUT.

  CASE sy-ucomm.

    WHEN '&F03' or '&F15' or '&F12'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " U
