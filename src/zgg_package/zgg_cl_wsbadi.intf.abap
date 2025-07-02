INTERFACE zgg_cl_wsbadi
  PUBLIC .


  INTERFACES if_badi_interface .

  METHODS before_save IMPORTING iv_ulke    TYPE char4
                                iv_lig     TYPE INT4
                                iv_player  TYPE INT4
                      EXPORTING ev_rc      TYPE sy-subrc
                      CHANGING  ls_strbadi TYPE ZGG_BLOCK_PLAYER.


  METHODS after_save IMPORTING iv_ulke    TYPE char4
                               iv_lig     TYPE INT4
                               iv_player  TYPE INT4
                     CHANGING  ls_strbadi TYPE ZGG_LOG_CH_PLAY.
ENDINTERFACE.
