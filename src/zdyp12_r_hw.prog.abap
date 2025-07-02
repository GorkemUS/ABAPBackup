*&---------------------------------------------------------------------*
*& Report ZDYP12_R_ODEV2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdyp12_r_hw.

INCLUDE ZDHP12_R_HW_TOP.
INCLUDE ZDHP12_R_HW_SCR.
INCLUDE ZDHP12_R_HW_FORM.

START-OF-SELECTION.

  PERFORM get_data.

  IF gt_data[] IS NOT INITIAL.
    PERFORM alv_list.
  ELSE.
    MESSAGE 'No data' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

END-OF-SELECTION.
