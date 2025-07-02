*&---------------------------------------------------------------------*
*& Report ZDYP12_R_STOCK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDYP12_R_STOCK.

INCLUDE ZDYP12_R_STOCK_TOP.
INCLUDE ZDYP12_R_STOCK_CLASS.
INCLUDE ZDYP12_R_STOCK_SCR.

START-OF-SELECTION.

  g_main->get_data( ).


IF gt_data IS INITIAL.
  MESSAGE 'No data' TYPE 'S' DISPLAY LIKE 'E'.
  ELSE.
    CALL SCREEN 1903.
 ENDIF.

 MODULE status_1903 OUTPUT.

   SET PF-STATUS 'STANDARD'.
   g_main->display_alv( ).
   g_main->set_trafficdesign( ).

   ENDMODULE.

MODULE user_command_1903 INPUT.

  CASE sy-ucomm.
    WHEN '&F03' OR '&F15' OR '&F12'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
