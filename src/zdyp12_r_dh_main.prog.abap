*&---------------------------------------------------------------------*
*& Include          ZDYP12_R_DH_MAIN
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  go_main = NEW #( ) .

*----------------------------------------------------------------------*
*AT SELECTION-SCREEN.
*----------------------------------------------------------------------*
AT SELECTION-SCREEN.
*  go_main->selection_screen( ).


*----------------------------------------------------------------------*
*AT SELECTION-SCREEN OUTPUT.
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*  go_main->modify_selection_screen( ).

*----------------------------------------------------------------------*
*START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
  go_main->get_data( ).
  go_main->doluluk_oranlari( ).
  go_main->yas_ortalamalari( ).
  go_main->erkek_kadin_doktor_oranlari( ).
  go_main->en_az_ve_en_cok_hasta_bakan( ).
  go_main->en_genc_ve_yasli_hasta( ).
  go_main->min_max_hasta_sayisi_hastane( ).
  go_main->izmir_doktor_hasta_ort( ).
  go_main->erkek_kadin_doktor_hasta_yuz( ).
  go_main->erkek_kadin_doktor_hasta_ort( ).
  go_main->dol_orani_ve_doktor_yas_ort( ).

*----------------------------------------------------------------------*
*END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.
*  go_main->display( ).
