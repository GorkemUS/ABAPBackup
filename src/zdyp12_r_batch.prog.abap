*&---------------------------------------------------------------------*
*& Report ZDYP12_R_BATCH
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdyp12_r_batch.

INCLUDE zdyp12_r_batch_top.
INCLUDE zdyp12_r_batch_class.
INCLUDE zdyp12_r_batch_frm.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  CREATE OBJECT main.
  main->upload_excel( ).

START-OF-SELECTION.

  CALL SCREEN 1903.

MODULE status_1903 OUTPUT.
  SET PF-STATUS 'STANDARD'.
  SET TITLEBAR 'ALV DISPLAY'.

  main->display_alv( ).

ENDMODULE.

MODULE user_command_1903 INPUT.

  CASE sy-ucomm.
    WHEN '&F03' OR '&F15' OR '&F12'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
