*&---------------------------------------------------------------------*
*& Include          ZDYP12_R_DH_CLS
*&---------------------------------------------------------------------*

CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.


    METHODS:get_data,
      doluluk_oranlari,
      yas_ortalamalari,
      erkek_kadin_doktor_oranlari,
      en_az_ve_en_cok_hasta_bakan,
      en_genc_ve_yasli_hasta,
      min_max_hasta_sayisi_hastane,
      izmir_doktor_hasta_ort,
      erkek_kadin_doktor_hasta_yuz,
      erkek_kadin_doktor_hasta_ort,
      dol_orani_ve_doktor_yas_ort.

ENDCLASS.

CLASS lcl_event_receiver IMPLEMENTATION.

  METHOD get_data.

    SELECT * FROM zdyp2024_t_dr INTO TABLE gt_doktor.
    SELECT * FROM zdyp2024_t_hast INTO TABLE gt_hastane.
    SELECT * FROM zdyp2024_t_islem INTO TABLE gt_hasta.

*    SELECT *
*      FROM ZDYP2024_T_ISLEM
*      INNER JOIN ZDYP2024_T_DR ON ZDYP2024_T_ISLEM~DOKTOR_ID = ZDYP2024_T_DR~DOKTOR_ID
*      INNER JOIN ZDYP2024_T_HAST ON ZDYP2024_T_HAST~HASTANE_ID = ZDYP2024_T_DR~HASTANE_ID
*      INTO TABLE @DATA(gt_data).

  ENDMETHOD.
  METHOD doluluk_oranlari.
    DATA: lv_total_capacity_istanbul TYPE i,                " Toplam kapasite
          lv_total_patients_istanbul TYPE i,                " Toplam hasta sayısı
          lv_total_patients_ankara   TYPE i,                " Toplam hasta sayısı
          lv_total_capacity_ankara   TYPE i,                " Toplam kapasite
          lv_total_patients_izmir    TYPE i,                " Toplam hasta sayısı
          lv_total_capacity_izmir    TYPE i,                " Toplam kapasite
          lv_total_patients_bolu     TYPE i,                " Toplam hasta sayısı
          lv_total_capacity_bolu     TYPE i,                " Toplam kapasite
          lv_total_patients_duzce    TYPE i,                " Toplam hasta sayısı
          lv_total_capacity_duzce    TYPE i,                " Toplam kapasite
          lv_istanbul_fill_rate      TYPE p DECIMALS 2,     " İstanbul doluluk oranı
          lv_ankara_fill_rate        TYPE p DECIMALS 2,     " İstanbul doluluk oranı
          lv_izmir_fill_rate         TYPE p DECIMALS 2,     " İzmir doluluk oranı
          lv_bolu_fill_rate          TYPE p DECIMALS 2,     " Bolu doluluk oranı
          lv_duzce_fill_rate         TYPE p DECIMALS 2.     " Düzce doluluk oranı

    LOOP AT gt_hasta INTO DATA(ls_hasta).
      READ TABLE gt_doktor INTO DATA(ls_doktor) WITH KEY doktor_id = ls_hasta-doktor_id.
      READ TABLE gt_hastane INTO DATA(ls_hastane) WITH KEY hastane_id = ls_doktor-hastane_id.

      CASE ls_hastane-sehir.

        WHEN 'İSTANBUL'.
          lv_total_patients_istanbul = lv_total_patients_istanbul + 1.
          lv_total_capacity_istanbul = ls_hastane-kapasite.

        WHEN'ANKARA'.
          lv_total_patients_ankara = lv_total_patients_ankara + 1.
          lv_total_capacity_ankara = ls_hastane-kapasite.

        WHEN'İZMIR'.
          lv_total_patients_izmir = lv_total_patients_izmir + 1.
          lv_total_capacity_izmir = ls_hastane-kapasite.

        WHEN 'BOLU'.
          lv_total_patients_bolu = lv_total_patients_bolu + 1.
          lv_total_capacity_bolu  = ls_hastane-kapasite.

        WHEN'DÜZCE'.
          lv_total_patients_duzce = lv_total_patients_duzce + 1.
          lv_total_capacity_duzce = ls_hastane-kapasite.
      ENDCASE.
    ENDLOOP.

    "İstanbul doluluk oranını
    IF lv_total_capacity_istanbul > 0.
      lv_istanbul_fill_rate = ( lv_total_patients_istanbul * 100 ) / lv_total_capacity_istanbul.
    ENDIF.
    "Ankara doluluk oranını
    IF lv_total_capacity_ankara > 0.
      lv_ankara_fill_rate = ( lv_total_patients_ankara * 100 ) / lv_total_capacity_ankara.
    ENDIF.
    "İzmir doluluk oranını
    IF lv_total_capacity_izmir > 0.
      lv_izmir_fill_rate = ( lv_total_patients_izmir * 100 ) / lv_total_capacity_izmir.
    ENDIF.
    "Bolu doluluk oranını
    IF lv_total_capacity_bolu > 0.
      lv_bolu_fill_rate = ( lv_total_patients_bolu * 100 ) / lv_total_capacity_bolu.
    ENDIF.
    "Düzce doluluk oranını
    IF lv_total_capacity_bolu > 0.
      lv_duzce_fill_rate = ( lv_total_patients_duzce * 100 ) / lv_total_capacity_duzce.
    ENDIF.

    WRITE: / 'İllere göre doluluk oranları' COLOR COL_GROUP.

    WRITE: / 'İstanbul doluluk oranı:', lv_istanbul_fill_rate , '%'.

    WRITE: / 'Ankara doluluk oranı:', lv_ankara_fill_rate , '%'.

    WRITE: / 'İzmir doluluk oranı:', lv_izmir_fill_rate , '%'.

    WRITE: / 'Bolu doluluk oranı:', lv_bolu_fill_rate , '%'.

    WRITE: / 'Düzce doluluk oranı:', lv_duzce_fill_rate , '%'.
    ULINE.
  ENDMETHOD.
  METHOD yas_ortalamalari.
    DATA: lv_total_age_istanbul     TYPE i,
          lv_patient_count_istanbul TYPE i,
          lv_avg_age_istanbul       TYPE p DECIMALS 2,

          lv_total_age_ankara       TYPE i,
          lv_patient_count_ankara   TYPE i,
          lv_avg_age_ankara         TYPE p DECIMALS 2,

          lv_total_age_izmir        TYPE i,
          lv_patient_count_izmir    TYPE i,
          lv_avg_age_izmir          TYPE p DECIMALS 2,

          lv_total_age_bolu         TYPE i,
          lv_patient_count_bolu     TYPE i,
          lv_avg_age_bolu           TYPE p DECIMALS 2,

          lv_total_age_duzce        TYPE i,
          lv_patient_count_duzce    TYPE i,
          lv_avg_age_duzce          TYPE p DECIMALS 2.

    LOOP AT gt_hasta INTO DATA(ls_hasta).
      READ TABLE gt_doktor INTO DATA(ls_doktor) WITH KEY doktor_id = ls_hasta-doktor_id.
      READ TABLE gt_hastane INTO DATA(ls_hastane) WITH KEY hastane_id = ls_doktor-hastane_id.

      CASE ls_hastane-sehir.
        WHEN 'İSTANBUL'.
          lv_total_age_istanbul = lv_total_age_istanbul + ls_hasta-hasta_yas.
          lv_patient_count_istanbul = lv_patient_count_istanbul + 1.

        WHEN 'ANKARA'.
          lv_total_age_ankara = lv_total_age_ankara + ls_hasta-hasta_yas.
          lv_patient_count_ankara = lv_patient_count_ankara + 1.

        WHEN 'İZMIR'.
          lv_total_age_izmir = lv_total_age_izmir + ls_hasta-hasta_yas.
          lv_patient_count_izmir = lv_patient_count_izmir + 1.

        WHEN 'BOLU'.
          lv_total_age_bolu = lv_total_age_bolu + ls_hasta-hasta_yas.
          lv_patient_count_bolu = lv_patient_count_bolu + 1.

        WHEN 'DÜZCE'.
          lv_total_age_duzce = lv_total_age_duzce + ls_hasta-hasta_yas.
          lv_patient_count_duzce = lv_patient_count_duzce + 1.
      ENDCASE.
    ENDLOOP.

    " Ortalama yaşların hesabı
    IF lv_patient_count_istanbul > 0.
      lv_avg_age_istanbul = lv_total_age_istanbul / lv_patient_count_istanbul.
    ENDIF.
    IF lv_patient_count_ankara > 0.
      lv_avg_age_ankara = lv_total_age_ankara / lv_patient_count_ankara.
    ENDIF.
    IF lv_patient_count_izmir > 0.
      lv_avg_age_izmir = lv_total_age_izmir / lv_patient_count_izmir.
    ENDIF.
    IF lv_patient_count_bolu > 0.
      lv_avg_age_bolu = lv_total_age_bolu / lv_patient_count_bolu.
    ENDIF.
    IF lv_patient_count_duzce > 0.
      lv_avg_age_duzce = lv_total_age_duzce / lv_patient_count_duzce.
    ENDIF.

    " Ortalama yaşları yazdır
    WRITE: / 'İllere göre hastaların yaş ortalamaları' COLOR COL_GROUP.

    WRITE: / 'İstanbulda ki hastaların  yaş ortalaması:', lv_avg_age_istanbul.

    WRITE: / 'Ankarada ki hastaların yaş ortalaması:', lv_avg_age_ankara.

    WRITE: / 'İzmirde ki hastaların yaş ortalaması:', lv_avg_age_izmir.

    WRITE: / 'Boluda ki hastaların yaş ortalaması:', lv_avg_age_bolu.

    WRITE: / 'Düzcede ki hastaların yaş ortalaması:', lv_avg_age_duzce.
    ULINE.

  ENDMETHOD.
  METHOD erkek_kadin_doktor_oranlari.
    DATA: lv_total_doktor_istanbul TYPE i,
          lv_total_doktor_ankara   TYPE i,
          lv_total_doktor_izmir    TYPE i,
          lv_total_doktor_bolu     TYPE i,
          lv_total_doktor_duzce    TYPE i,

          lv_erkek_doktor_istanbul TYPE i,
          lv_kadin_doktor_istanbul TYPE i,
          lv_erkek_doktor_ankara   TYPE i,
          lv_kadin_doktor_ankara   TYPE i,
          lv_erkek_doktor_izmir    TYPE i,
          lv_kadin_doktor_izmir    TYPE i,
          lv_erkek_doktor_bolu     TYPE i,
          lv_kadin_doktor_bolu     TYPE i,
          lv_erkek_doktor_duzce    TYPE i,
          lv_kadin_doktor_duzce    TYPE i,

          lv_istanbul_erkek_orani  TYPE p DECIMALS 2,
          lv_istanbul_kadin_orani  TYPE p DECIMALS 2,
          lv_ankara_erkek_orani    TYPE p DECIMALS 2,
          lv_ankara_kadin_orani    TYPE p DECIMALS 2,
          lv_izmir_erkek_orani     TYPE p DECIMALS 2,
          lv_izmir_kadin_orani     TYPE p DECIMALS 2,
          lv_bolu_erkek_orani      TYPE p DECIMALS 2,
          lv_bolu_kadin_orani      TYPE p DECIMALS 2,
          lv_duzce_erkek_orani     TYPE p DECIMALS 2,
          lv_duzce_kadin_orani     TYPE p DECIMALS 2.

    LOOP AT gt_doktor INTO DATA(ls_doktor).
      READ TABLE gt_hastane INTO DATA(ls_hastane) WITH KEY hastane_id = ls_doktor-hastane_id.

      CASE ls_hastane-sehir.
        WHEN 'İSTANBUL'.
          lv_total_doktor_istanbul = lv_total_doktor_istanbul + 1.
          IF ls_doktor-cinsiyet = 'ERKEK'.
            lv_erkek_doktor_istanbul = lv_erkek_doktor_istanbul + 1.
          ELSEIF ls_doktor-cinsiyet = 'KADIN'.
            lv_kadin_doktor_istanbul = lv_kadin_doktor_istanbul + 1.
          ENDIF.
        WHEN 'ANKARA'.
          lv_total_doktor_ankara = lv_total_doktor_ankara + 1.
          IF ls_doktor-cinsiyet = 'ERKEK'.
            lv_erkek_doktor_ankara = lv_erkek_doktor_ankara + 1.
          ELSEIF ls_doktor-cinsiyet = 'KADIN'.
            lv_kadin_doktor_ankara = lv_kadin_doktor_ankara + 1.
          ENDIF.

        WHEN 'İZMIR'.
          lv_total_doktor_izmir = lv_total_doktor_izmir + 1.
          IF ls_doktor-cinsiyet = 'ERKEK'.
            lv_erkek_doktor_izmir = lv_erkek_doktor_izmir + 1.
          ELSEIF ls_doktor-cinsiyet = 'KADIN'.
            lv_kadin_doktor_izmir = lv_kadin_doktor_izmir + 1.
          ENDIF.

        WHEN 'BOLU'.
          lv_total_doktor_bolu = lv_total_doktor_bolu + 1.
          IF ls_doktor-cinsiyet = 'ERKEK'.
            lv_erkek_doktor_bolu = lv_erkek_doktor_bolu + 1.
          ELSEIF ls_doktor-cinsiyet = 'KADIN'.
            lv_kadin_doktor_bolu = lv_kadin_doktor_bolu + 1.
          ENDIF.

        WHEN 'DÜZCE'.
          lv_total_doktor_duzce = lv_total_doktor_duzce + 1.
          IF ls_doktor-cinsiyet = 'ERKEK'.
            lv_erkek_doktor_duzce = lv_erkek_doktor_duzce + 1.
          ELSEIF ls_doktor-cinsiyet = 'KADIN'.
            lv_kadin_doktor_duzce = lv_kadin_doktor_duzce + 1.
          ENDIF.

      ENDCASE.
    ENDLOOP.

    " Oranları hesaplama yeri

    IF lv_total_doktor_istanbul > 0.
      lv_istanbul_erkek_orani = ( lv_erkek_doktor_istanbul * 100 ) / lv_total_doktor_istanbul.
      lv_istanbul_kadin_orani = ( lv_kadin_doktor_istanbul * 100 ) / lv_total_doktor_istanbul.
    ENDIF.
    IF lv_total_doktor_ankara > 0.
      lv_ankara_erkek_orani = ( lv_erkek_doktor_ankara * 100 ) / lv_total_doktor_ankara.
      lv_ankara_kadin_orani = ( lv_kadin_doktor_ankara * 100 ) / lv_total_doktor_ankara.
    ENDIF.
    IF lv_total_doktor_izmir > 0.
      lv_izmir_erkek_orani = ( lv_erkek_doktor_izmir * 100 ) / lv_total_doktor_izmir.
      lv_izmir_kadin_orani = ( lv_kadin_doktor_izmir * 100 ) / lv_total_doktor_izmir.
    ENDIF.
    IF lv_total_doktor_bolu > 0.
      lv_bolu_erkek_orani = ( lv_erkek_doktor_bolu * 100 ) / lv_total_doktor_bolu.
      lv_bolu_kadin_orani = ( lv_kadin_doktor_bolu * 100 ) / lv_total_doktor_bolu.
    ENDIF.
    IF lv_total_doktor_duzce > 0.
      lv_duzce_erkek_orani = ( lv_erkek_doktor_duzce * 100 ) / lv_total_doktor_duzce.
      lv_duzce_kadin_orani = ( lv_kadin_doktor_duzce * 100 ) / lv_total_doktor_duzce.
    ENDIF.

    WRITE: / 'İllere göre kadın ve doktor oranları' COLOR COL_GROUP.

    WRITE: / 'İstanbul erkek doktor oranı:', lv_istanbul_erkek_orani, '%'.

    WRITE: / 'İstanbul kadın doktor oranı:', lv_istanbul_kadin_orani, '%'.

    WRITE: / 'Ankara erkek doktor oranı:', lv_ankara_erkek_orani, '%'.

    WRITE: / 'Ankara kadın doktor oranı:', lv_ankara_kadin_orani, '%'.

    WRITE: / 'İzmir erkek doktor oranı:', lv_izmir_erkek_orani, '%'.

    WRITE: / 'İzmir kadın doktor oranı:', lv_izmir_kadin_orani, '%'.

    WRITE: / 'Bolu erkek doktor oranı:', lv_bolu_erkek_orani, '%'.

    WRITE: / 'Bolu kadın doktor oranı:', lv_bolu_kadin_orani, '%'.

    WRITE: / 'Düzce erkek doktor oranı:', lv_duzce_erkek_orani, '%'.

    WRITE: / 'Düzce kadın doktor oranı:', lv_duzce_kadin_orani, '%'.
    ULINE.



  ENDMETHOD.
  METHOD en_az_ve_en_cok_hasta_bakan.

    TYPES: BEGIN OF ty_doktor_hasta_sayisi,
             doktor_id    TYPE zdyp2024_t_dr-doktor_id,
             doktor_ad    TYPE zdyp2024_t_dr-doktor_ad,
             doktor_soy   TYPE zdyp2024_t_dr-doktor_soyad,
             cinsiyet     TYPE zdyp2024_t_dr-cinsiyet,
             hastane_id   TYPE zdyp2024_t_dr-hastane_id,
             hasta_sayisi TYPE i,
           END OF ty_doktor_hasta_sayisi.

    DATA: lt_doktor_hasta_sayisi TYPE TABLE OF ty_doktor_hasta_sayisi,
          ls_doktor_hasta_sayisi TYPE ty_doktor_hasta_sayisi,
          lt_min_doktor          TYPE TABLE OF ty_doktor_hasta_sayisi,  " En az hasta bakan doktorlar
          lt_max_doktor          TYPE TABLE OF ty_doktor_hasta_sayisi,  " En çok hasta bakan doktorlar
          lv_min_hasta_sayisi    TYPE i,
          lv_max_hasta_sayisi    TYPE i.


    " Her doktorun baktığı hasta sayısını hesapla
    LOOP AT gt_doktor INTO DATA(ls_doktor).
      CLEAR ls_doktor_hasta_sayisi.
      ls_doktor_hasta_sayisi-doktor_id = ls_doktor-doktor_id.
      ls_doktor_hasta_sayisi-doktor_ad = ls_doktor-doktor_ad.
      ls_doktor_hasta_sayisi-doktor_soy = ls_doktor-doktor_soyad.
      ls_doktor_hasta_sayisi-cinsiyet = ls_doktor-cinsiyet.
      ls_doktor_hasta_sayisi-hastane_id = ls_doktor-hastane_id.

      LOOP AT gt_hasta INTO DATA(ls_hasta) WHERE doktor_id = ls_doktor-doktor_id.
        ls_doktor_hasta_sayisi-hasta_sayisi = ls_doktor_hasta_sayisi-hasta_sayisi + 1.
      ENDLOOP.
      APPEND ls_doktor_hasta_sayisi TO lt_doktor_hasta_sayisi.
    ENDLOOP.

*    SORT lt_doktor_hasta_sayisi BY hasta_sayisi ASCENDING .
    READ TABLE lt_doktor_hasta_sayisi INDEX 19 INTO ls_doktor_hasta_sayisi.
    lv_min_hasta_sayisi = ls_doktor_hasta_sayisi-hasta_sayisi.

    " En az ve en çok hasta bakan doktorlar
    LOOP AT lt_doktor_hasta_sayisi INTO ls_doktor_hasta_sayisi.
      " En az hasta sayısı için
      IF ls_doktor_hasta_sayisi-hasta_sayisi = lv_min_hasta_sayisi.
        APPEND ls_doktor_hasta_sayisi TO lt_min_doktor.
      ENDIF.
*      IF lv_min_hasta_sayisi IS INITIAL OR ls_doktor_hasta_sayisi-hasta_sayisi < lv_min_hasta_sayisi.
*        CLEAR lt_min_doktor.
*        lv_min_hasta_sayisi = ls_doktor_hasta_sayisi-hasta_sayisi.
*        APPEND ls_doktor_hasta_sayisi TO lt_min_doktor.
*      ELSEIF ls_doktor_hasta_sayisi-hasta_sayisi = lv_min_hasta_sayisi.
*        APPEND ls_doktor_hasta_sayisi TO lt_min_doktor.
*      ENDIF.

      " En çok hasta sayısı için
      IF lv_max_hasta_sayisi IS INITIAL OR ls_doktor_hasta_sayisi-hasta_sayisi > lv_max_hasta_sayisi.
        CLEAR lt_max_doktor.
        lv_max_hasta_sayisi = ls_doktor_hasta_sayisi-hasta_sayisi.
        APPEND ls_doktor_hasta_sayisi TO lt_max_doktor.
      ENDIF.
    ENDLOOP.

    " En çok hasta bakan doktorların bilgileri
    WRITE: / 'En çok hasta bakan doktorlar:'.
    LOOP AT lt_max_doktor INTO ls_doktor_hasta_sayisi.
      WRITE: / 'Doktor ID:', ls_doktor_hasta_sayisi-doktor_id,
             / 'Doktor Adı:', ls_doktor_hasta_sayisi-doktor_ad,
             / 'Doktor Soyadı:', ls_doktor_hasta_sayisi-doktor_soy,
             / 'Cinsiyet:', ls_doktor_hasta_sayisi-cinsiyet,
             / 'Hastane ID:', ls_doktor_hasta_sayisi-hastane_id.
      ULINE.
    ENDLOOP.

    " En az hasta bakan doktorların bilgileri
    WRITE: / 'En az hasta bakan doktorlar:'.
    LOOP AT lt_min_doktor INTO ls_doktor_hasta_sayisi.
      WRITE: / 'Doktor ID:', ls_doktor_hasta_sayisi-doktor_id,
             / 'Doktor Adı:', ls_doktor_hasta_sayisi-doktor_ad,
             / 'Doktor Soyadı:', ls_doktor_hasta_sayisi-doktor_soy,
             / 'Cinsiyet:', ls_doktor_hasta_sayisi-cinsiyet,
             / 'Hastane ID:', ls_doktor_hasta_sayisi-hastane_id.
      ULINE.
    ENDLOOP.

  ENDMETHOD.
  METHOD en_genc_ve_yasli_hasta.
    DATA: ls_hasta       TYPE zdyp2024_t_islem,
          ls_genc_hasta  TYPE zdyp2024_t_islem,
          ls_yasli_hasta TYPE zdyp2024_t_islem,
          lv_min_yas     TYPE i,
          lv_max_yas     TYPE i.

    LOOP AT gt_hasta INTO ls_hasta.
      IF lv_min_yas IS INITIAL OR ls_hasta-hasta_yas < lv_min_yas.
        lv_min_yas = ls_hasta-hasta_yas.
        ls_genc_hasta = ls_hasta.
      ENDIF.

      IF lv_max_yas IS INITIAL OR ls_hasta-hasta_yas > lv_max_yas.
        lv_max_yas = ls_hasta-hasta_yas.
        ls_yasli_hasta = ls_hasta.
      ENDIF.
    ENDLOOP.

    " En yaşlı hastanın bilgileri
    WRITE: / 'En Yaşlı Hasta Bilgileri:',
           / 'Ad:', ls_yasli_hasta-hasta_ad,
           / 'Soyad:', ls_yasli_hasta-hasta_soyad,
           / 'Yaş:', ls_yasli_hasta-hasta_yas,
           / 'Cinsiyet:', ls_yasli_hasta-hasta_yas.
    ULINE.

    " En genç hastanın bilgileri
    WRITE: / 'En Genç Hasta Bilgileri:',
           / 'Ad:', ls_genc_hasta-hasta_ad,
           / 'Soyad:', ls_genc_hasta-hasta_soyad,
           / 'Yaş:', ls_genc_hasta-hasta_yas,
           / 'Cinsiyet:', ls_genc_hasta-hasta_cins.
    ULINE.

  ENDMETHOD.
  METHOD min_max_hasta_sayisi_hastane.

    TYPES: BEGIN OF ty_hastane_hasta_sayisi,
             hastane_id   TYPE zdyp2024_t_hast-hastane_id,
             hastane_ad   TYPE zdyp2024_t_hast-hastane_ad,
             sehir        TYPE zdyp2024_t_hast-sehir,
             kapasite     TYPE zdyp2024_t_hast-kapasite,
             hasta_sayisi TYPE i,
           END OF ty_hastane_hasta_sayisi.

    DATA: lt_hastane_hasta_sayisi TYPE TABLE OF ty_hastane_hasta_sayisi,
          ls_hastane_hasta_sayisi TYPE ty_hastane_hasta_sayisi,
          lt_min_hastane          TYPE TABLE OF   ty_hastane_hasta_sayisi,
          lt_max_hastane          TYPE TABLE OF   ty_hastane_hasta_sayisi,
          lv_min_hasta_sayisi     TYPE i,
          lv_max_hasta_sayisi     TYPE i.

    "Toplam Hasta sayılarını hesaplama
    LOOP AT gt_hastane INTO DATA(ls_hastane).
      CLEAR ls_hastane_hasta_sayisi.
      ls_hastane_hasta_sayisi-hastane_id = ls_hastane-hastane_id.
      ls_hastane_hasta_sayisi-hastane_ad = ls_hastane-hastane_ad.
      ls_hastane_hasta_sayisi-sehir = ls_hastane-sehir.
      ls_hastane_hasta_sayisi-kapasite = ls_hastane-kapasite.


      LOOP AT gt_doktor INTO DATA(ls_doktor) WHERE hastane_id = ls_hastane-hastane_id.
        LOOP AT gt_hasta INTO DATA(ls_hasta) WHERE doktor_id = ls_doktor-doktor_id.
          ls_hastane_hasta_sayisi-hasta_sayisi = ls_hastane_hasta_sayisi-hasta_sayisi + 1.
        ENDLOOP.
      ENDLOOP.
      APPEND ls_hastane_hasta_sayisi TO lt_hastane_hasta_sayisi.

    ENDLOOP.

    SORT lt_hastane_hasta_sayisi BY hasta_sayisi ASCENDING .
    READ TABLE lt_hastane_hasta_sayisi INDEX 1 INTO ls_hastane_hasta_sayisi.
    lv_min_hasta_sayisi = ls_hastane_hasta_sayisi-hasta_sayisi.

    LOOP AT lt_hastane_hasta_sayisi INTO ls_hastane_hasta_sayisi.

      " En az hasta sayısı için
      IF ls_hastane_hasta_sayisi-hasta_sayisi = lv_min_hasta_sayisi.
        APPEND ls_hastane_hasta_sayisi TO lt_min_hastane.
      ENDIF.

      " En çok hasta sayısı için
      IF lv_max_hasta_sayisi IS INITIAL OR ls_hastane_hasta_sayisi-hasta_sayisi > lv_max_hasta_sayisi.
        CLEAR lt_max_hastane.
        lv_max_hasta_sayisi = ls_hastane_hasta_sayisi-hasta_sayisi.
        APPEND ls_hastane_hasta_sayisi TO lt_max_hastane.
      ENDIF.
    ENDLOOP.

    " En çok hastanın olduğu hastane bilgileri
    WRITE: / 'En çok hasta bakan hastaneler:'.
    LOOP AT lt_max_hastane INTO ls_hastane_hasta_sayisi.
      WRITE: / 'Hastane ID:', ls_hastane_hasta_sayisi-hastane_id,
             / 'Hastane Adı:', ls_hastane_hasta_sayisi-hastane_ad,
             / 'Şehir:', ls_hastane_hasta_sayisi-sehir,
             / 'Kapasite:', ls_hastane_hasta_sayisi-kapasite,
             / 'Hasta Sayısı:', ls_hastane_hasta_sayisi-hasta_sayisi.
      ULINE.
    ENDLOOP.

    " En az hastanın olduğu hastane bilgileri
    WRITE: / 'En çok hasta bakan hastaneler:'.
    LOOP AT lt_min_hastane INTO ls_hastane_hasta_sayisi.
      WRITE: / 'Hastane ID:', ls_hastane_hasta_sayisi-hastane_id,
             / 'Hastane Adı:', ls_hastane_hasta_sayisi-hastane_ad,
             / 'Şehir:', ls_hastane_hasta_sayisi-sehir,
             / 'Kapasite:', ls_hastane_hasta_sayisi-kapasite,
             / 'Hasta Sayısı:', ls_hastane_hasta_sayisi-hasta_sayisi.
      ULINE.
    ENDLOOP.

  ENDMETHOD.
  METHOD izmir_doktor_hasta_ort.
    DATA:
      lv_ttl_erkek_yas   TYPE i,
      lv_ttl_kadin_yas   TYPE i,
      lv_erkek_hasta_ort TYPE p DECIMALS 2,
      lv_kadin_hasta_ort TYPE p DECIMALS 2.


    LOOP AT gt_hasta INTO DATA(ls_hasta).
      READ TABLE gt_doktor INTO DATA(ls_doktor) WITH KEY doktor_id = ls_hasta-doktor_id.
      READ TABLE gt_hastane INTO DATA(ls_hastane) WITH KEY hastane_id = ls_doktor-hastane_id.

      CASE ls_hastane-sehir.
        WHEN 'İZMIR'.
          IF ls_doktor-cinsiyet = 'KADIN'.
            lv_ttl_kadin_yas = lv_ttl_kadin_yas + 1.
            lv_kadin_hasta_ort = lv_kadin_hasta_ort + ls_hasta-hasta_yas.
          ELSEIF ls_doktor-cinsiyet = 'ERKEK'.
            lv_ttl_erkek_yas = lv_ttl_erkek_yas + 1.
            lv_erkek_hasta_ort = lv_erkek_hasta_ort + ls_hasta-hasta_yas.
          ENDIF.
      ENDCASE.

    ENDLOOP.

    "Kadın doktor hastalarının yaş ortalamaları
    IF lv_ttl_kadin_yas > 0.
      lv_kadin_hasta_ort = lv_kadin_hasta_ort / lv_ttl_kadin_yas.
    ENDIF.
    "Erkek doktor hastalarının yaş ortalamaları
    IF lv_ttl_erkek_yas > 0.
      lv_erkek_hasta_ort = lv_erkek_hasta_ort / lv_ttl_erkek_yas.
    ENDIF.

    "Yazdırma yeri
    WRITE: / 'İzmirde ki doktorların hastalarının yaş ortalamaları' COLOR COL_GROUP.
    WRITE : / 'İzmirde ki kadın doktorların baktığı hastaların yaş ortalamaları:', lv_kadin_hasta_ort.
    WRITE : / 'İzmirde ki erkek doktorların baktığı hastaların yaş ortalamaları:', lv_erkek_hasta_ort.
    ULINE.

  ENDMETHOD.
  METHOD erkek_kadin_doktor_hasta_yuz.
    DATA:
      lv_ttl_kadin_hasta_istanbul TYPE i,
      lv_ttl_erkek_hasta_istanbul TYPE i,
      lv_ttl_erkek_hasta_ankara   TYPE i,
      lv_ttl_kadin_hasta_ankara   TYPE i,
      lv_ttl_hasta_ankara         TYPE i,
      lv_ttl_hasta_istanbul       TYPE i,
      lv_erkek_hasta_yuz_istanbul TYPE p DECIMALS 2,
      lv_kadin_hasta_yuz_istanbul TYPE p DECIMALS 2,
      lv_erkek_hasta_yuz_ankara   TYPE p DECIMALS 2,
      lv_kadin_hasta_yuz_ankara   TYPE p DECIMALS 2.


    LOOP AT gt_hasta INTO DATA(ls_hasta).
      READ TABLE gt_doktor INTO DATA(ls_doktor) WITH KEY doktor_id = ls_hasta-doktor_id.
      READ TABLE gt_hastane INTO DATA(ls_hastane) WITH KEY hastane_id = ls_doktor-hastane_id.

      CASE ls_hastane-sehir.
        WHEN 'İSTANBUL'.
          IF ls_doktor-cinsiyet = 'KADIN'.
            IF ls_hasta-hasta_cins = 'KADIN'.
              lv_ttl_kadin_hasta_istanbul = lv_ttl_kadin_hasta_istanbul + 1.

            ELSEIF ls_hasta-hasta_cins = 'ERKEK'.
              lv_ttl_erkek_hasta_istanbul = lv_ttl_erkek_hasta_istanbul + 1.

            ENDIF.
            lv_ttl_hasta_istanbul = lv_ttl_hasta_istanbul + 1.
          ENDIF.
        WHEN 'ANKARA'.
          IF ls_doktor-cinsiyet = 'ERKEK'.
            IF ls_hasta-hasta_cins = 'ERKEK'.
              lv_ttl_erkek_hasta_ankara = lv_ttl_erkek_hasta_ankara + 1.
            ELSEIF ls_hasta-hasta_cins = 'KADIN'.
              lv_ttl_kadin_hasta_ankara = lv_ttl_kadin_hasta_ankara + 1.
            ENDIF.
            lv_ttl_hasta_ankara = lv_ttl_hasta_ankara + 1.
          ENDIF.

      ENDCASE.
    ENDLOOP.

    "Istanbulda ki kadın doktorların baktığı erkek ve kadın hasta yüzdeleri
    IF lv_ttl_hasta_istanbul > 0.
      lv_erkek_hasta_yuz_istanbul = ( lv_ttl_erkek_hasta_istanbul * 100 ) / lv_ttl_hasta_istanbul.
      lv_kadin_hasta_yuz_istanbul = ( lv_ttl_kadin_hasta_istanbul * 100 ) / lv_ttl_hasta_istanbul.
    ENDIF.
    "Ankarada ki erkek doktorların baktığı erkek ve kadın hasta yüzdeleri
    IF lv_ttl_hasta_ankara >= 0.
      lv_erkek_hasta_yuz_ankara = ( lv_ttl_erkek_hasta_ankara * 100 ) / lv_ttl_hasta_ankara.
      lv_kadin_hasta_yuz_ankara = ( lv_ttl_kadin_hasta_ankara * 100 ) / lv_ttl_hasta_ankara.
    ENDIF.

    WRITE: / 'Doktorların hastalarının yüzdeleri' COLOR COL_GROUP.
    WRITE: / 'İstanbul Kadın Doktorların Kadın Hasta Yüzdesi:',lv_kadin_hasta_yuz_istanbul, '%'.
    WRITE: / 'İstanbul Kadın Doktorların Erkek Hasta Yüzdesi:', lv_erkek_hasta_yuz_istanbul, '%'.
    WRITE: / 'Ankaradaki Kadın Doktorların Erkek Hasta Yüzdesi:', lv_kadin_hasta_yuz_ankara, '%'.
    WRITE: / 'Ankaradaki Erkek Doktorların Erkek Hasta Yüzdesi:', lv_erkek_hasta_yuz_ankara, '%'.
    ULINE.

  ENDMETHOD.
  METHOD erkek_kadin_doktor_hasta_ort.
    DATA: lv_ttl_kdoktor_hasta_sayisi   TYPE i,
          lv_ttl_edoktor_hasta_sayisi   TYPE i,
          lv_ttl_kdoktor_hasta_yasi     TYPE i,
          lv_ttl_edoktor_hasta_yasi     TYPE i,
          lv_kadin_doktor_hasta_yas_ort TYPE p DECIMALS 2,
          lv_erkek_doktor_hasta_yas_ort TYPE p DECIMALS 2.

    " Erkek ve Kadin doktorların hasta sayisi ve hasta yaşlarının hesaplandığı yer

    LOOP AT gt_hasta INTO DATA(ls_hasta).
      READ TABLE gt_doktor INTO DATA(ls_doktor) WITH KEY doktor_id = ls_hasta-doktor_id.
      READ TABLE gt_hastane INTO DATA(ls_hastane) WITH KEY hastane_id = ls_doktor-hastane_id.


      IF ls_doktor-cinsiyet = 'KADIN'.
        lv_ttl_kdoktor_hasta_sayisi = lv_ttl_kdoktor_hasta_sayisi + 1.
        lv_ttl_kdoktor_hasta_yasi = lv_ttl_kdoktor_hasta_yasi + ls_hasta-hasta_yas.

      ELSEIF ls_doktor-cinsiyet = 'ERKEK'.
        lv_ttl_edoktor_hasta_sayisi = lv_ttl_edoktor_hasta_sayisi + 1.
        lv_ttl_edoktor_hasta_yasi = lv_ttl_edoktor_hasta_yasi + ls_hasta-hasta_yas.
      ENDIF.

    ENDLOOP.

    "Hastaların yaşlarının ortalanmasının alındığı yer

    lv_kadin_doktor_hasta_yas_ort = lv_ttl_kdoktor_hasta_yasi / lv_ttl_kdoktor_hasta_sayisi.
    lv_erkek_doktor_hasta_yas_ort = lv_ttl_edoktor_hasta_yasi / lv_ttl_edoktor_hasta_sayisi.

    WRITE: / 'Kadın ve Erkek doktorların hastalarının ortalamaları' COLOR COL_GROUP.
    WRITE: / 'Kadın Doktorların hastalarının yaşlarının ortalaması:',lv_kadin_doktor_hasta_yas_ort.
    WRITE: / 'Erkek Doktorların hastalarının yaşlarının ortalaması:',lv_erkek_doktor_hasta_yas_ort.
    ULINE.
  ENDMETHOD.
  METHOD dol_orani_ve_doktor_yas_ort.
    DATA: lv_ttl_doktor_yas       TYPE i,
          lv_ttl_kapasite         TYPE i,
          lv_ttl_edoktor_yas      TYPE i,
          lv_ttl_kdoktor_yas      TYPE i,
          lv_ttl_doktor_sayisi    TYPE i,
          lv_ttl_edoktor_sayisi   TYPE i,
          lv_ttl_kdoktor_sayisi   TYPE i,
          lv_ttl_hasta_sayisi     TYPE i,
          lv_ttl_kdoktor_hasta    TYPE i,
          lv_ttl_edoktor_hasta    TYPE i,

          lv_erkek_hasta_istanbul TYPE i,
          lv_kadin_hasta_istanbul TYPE i,
          lv_erkek_hasta_ankara   TYPE i,
          lv_kadin_hasta_ankara   TYPE i,
          lv_erkek_hasta_izmir    TYPE i,
          lv_kadin_hasta_izmir    TYPE i,
          lv_erkek_hasta_bolu     TYPE i,
          lv_kadin_hasta_bolu     TYPE i,
          lv_erkek_hasta_duzce    TYPE i,
          lv_kadin_hasta_duzce    TYPE i,

          lv_ttl_dol_orani        TYPE p DECIMALS 2,
          lv_ttl_doktor_yas_ort   TYPE p DECIMALS 2,
          lv_ttl_kdoktor_yas_ort  TYPE p DECIMALS 2,
          lv_ttl_edoktor_yas_ort  TYPE p DECIMALS 2.

    LOOP AT gt_doktor INTO DATA(ls_doktor).
      READ TABLE gt_hastane INTO DATA(ls_hastane) WITH KEY hastane_id = ls_doktor-hastane_id.


      IF ls_doktor-cinsiyet = 'KADIN'.
        lv_ttl_kdoktor_yas = lv_ttl_kdoktor_yas + ls_doktor-doktor_yas.
        lv_ttl_kdoktor_sayisi = lv_ttl_kdoktor_sayisi + 1.
      ELSEIF ls_doktor-cinsiyet = 'ERKEK'.
        lv_ttl_edoktor_yas = lv_ttl_edoktor_yas + ls_doktor-doktor_yas.
        lv_ttl_edoktor_sayisi = lv_ttl_edoktor_sayisi + 1.
      ENDIF.
      lv_ttl_doktor_sayisi = lv_ttl_doktor_sayisi + 1.
      lv_ttl_doktor_yas = lv_ttl_edoktor_yas + lv_ttl_kdoktor_yas.
    ENDLOOP.

    LOOP AT gt_hastane INTO ls_hastane.
      lv_ttl_kapasite = lv_ttl_kapasite + ls_hastane-kapasite.
    ENDLOOP.

    LOOP AT gt_hasta INTO DATA(ls_hasta).
      READ TABLE gt_doktor INTO ls_doktor WITH KEY doktor_id = ls_hasta-doktor_id.
      READ TABLE gt_hastane INTO ls_hastane WITH KEY hastane_id = ls_doktor-hastane_id.

      "49-50.madde kadın ve erkek doktorların hasta sayıları
      IF ls_doktor-cinsiyet = 'ERKEK'.
        lv_ttl_edoktor_hasta = lv_ttl_edoktor_hasta + 1.
      ELSEIF ls_doktor-cinsiyet = 'KADIN'.
        lv_ttl_kdoktor_hasta = lv_ttl_kdoktor_hasta + 1.
      ENDIF.

      "39-40-41-42-43-44-45-46-47-48.Maddelerin kodu
      CASE ls_hastane-sehir.

        WHEN 'İSTANBUL'.
          IF ls_hasta-hasta_cins = 'ERKEK'.
            lv_erkek_hasta_istanbul = lv_erkek_hasta_istanbul + 1.
          ELSEIF ls_hasta-hasta_cins = 'KADIN'.
            lv_kadin_hasta_istanbul = lv_kadin_hasta_istanbul + 1.
          ENDIF.
        WHEN 'ANKARA'.
          IF ls_hasta-hasta_cins = 'ERKEK'.
            lv_erkek_hasta_ankara = lv_erkek_hasta_ankara + 1.
          ELSEIF ls_hasta-hasta_cins = 'KADIN'.
            lv_kadin_hasta_ankara = lv_kadin_hasta_ankara + 1.
          ENDIF.
        WHEN 'İZMIR'.
          IF ls_hasta-hasta_cins = 'ERKEK'.
            lv_erkek_hasta_izmir = lv_erkek_hasta_izmir + 1.
          ELSEIF ls_hasta-hasta_cins = 'KADIN'.
            lv_kadin_hasta_izmir = lv_kadin_hasta_izmir + 1.
          ENDIF.
        WHEN 'BOLU'.
          IF ls_hasta-hasta_cins = 'ERKEK'.
            lv_erkek_hasta_bolu = lv_erkek_hasta_bolu + 1.
          ELSEIF ls_hasta-hasta_cins = 'KADIN'.
            lv_kadin_hasta_bolu = lv_kadin_hasta_bolu + 1.
          ENDIF.
        WHEN 'DÜZCE'.
          IF ls_hasta-hasta_cins = 'ERKEK'.
            lv_erkek_hasta_duzce = lv_erkek_hasta_duzce + 1.
          ELSEIF ls_hasta-hasta_cins = 'KADIN'.
            lv_kadin_hasta_duzce = lv_kadin_hasta_duzce + 1.
          ENDIF.
      ENDCASE.

      lv_ttl_hasta_sayisi = lv_ttl_hasta_sayisi + 1.

    ENDLOOP.

    lv_ttl_dol_orani = ( lv_ttl_hasta_sayisi * 100 ) / lv_ttl_kapasite.
    lv_ttl_doktor_yas_ort = lv_ttl_doktor_yas / lv_ttl_doktor_sayisi.
    lv_ttl_kdoktor_yas_ort = lv_ttl_kdoktor_yas / lv_ttl_kdoktor_sayisi.
    lv_ttl_edoktor_yas_ort = lv_ttl_edoktor_yas / lv_ttl_edoktor_sayisi.

    WRITE: / '35 ile 50 arasındaki maddelerin sonuçları' COLOR COL_GROUP.

    WRITE: / '5 İl Doluluk oranı:',lv_ttl_dol_orani, '%'.

    WRITE: / '5 İl Doktor yaş ortalaması:',lv_ttl_doktor_yas_ort.

    WRITE: / '5 İl Kadın Doktor yaş ortalaması:',lv_ttl_kdoktor_yas_ort.

    WRITE: / '5 İl Erkek Doktor yaş ortalaması:',lv_ttl_edoktor_yas_ort.

    WRITE: / 'İstanbul Erkek hasta sayısı:',lv_erkek_hasta_istanbul.

    WRITE: / 'İstanbul Kadın hasta sayısı:',lv_kadin_hasta_istanbul.

    WRITE: / 'Ankara Erkek hasta sayısı:',lv_erkek_hasta_ankara.

    WRITE: / 'Ankara Kadın hasta sayısı:',lv_kadin_hasta_ankara.

    WRITE: / 'İzmir Erkek hasta sayısı:',lv_erkek_hasta_izmir.

    WRITE: / 'İzmir Kadın hasta sayısı:',lv_kadin_hasta_izmir.

    WRITE: / 'Bolu Erkek hasta sayısı:',lv_erkek_hasta_bolu.

    WRITE: / 'Bolu Kadın hasta sayısı:',lv_kadin_hasta_bolu.

    WRITE: / 'Düzce Erkek hasta sayısı:',lv_erkek_hasta_duzce.

    WRITE: / 'Düzce Kadın hasta sayısı:',lv_kadin_hasta_duzce.

    WRITE: / '5 İl Kadın Doktorların baktığı hasta sayısı:',lv_ttl_kdoktor_hasta.

    WRITE: / '5 İl Erkek Doktorların baktığı hasta sayısı:',lv_ttl_edoktor_hasta.
    ULINE.

  ENDMETHOD.

ENDCLASS.
