*&---------------------------------------------------------------------*
*& Report  ZFK_OTOMASYON
*&
*&---------------------------------------------------------------------*
REPORT zfk_otomasyon.


TABLES:zfk_ogrenci,
        zfk_ogretmen,
        sscrfields.   " for pushbutton

"-----------------dropdown menu
TYPE-POOLS: vrm.
DATA: gt_list     TYPE vrm_values.
DATA: gwa_list    TYPE vrm_value.


TYPE-POOLS: slis.
*----------------------------------------------------------------------*
*     Data Decalaration
*----------------------------------------------------------------------*
DATA: it_spfli TYPE TABLE OF spfli.
DATA: g_repid TYPE sy-repid.
DATA: it_listheader TYPE slis_t_listheader,
      wa_listheader TYPE slis_listheader.

"---alv yazdırma için

DATA: it_sbook     TYPE TABLE OF zfk_ogrenci.
DATA: it_fieldcat  TYPE slis_t_fieldcat_alv,
      wa_fieldcat  TYPE slis_fieldcat_alv.


" define tables
DATA ogrenci_ TYPE zfk_ogrenci.
DATA ogretmen_ TYPE zfk_ogretmen.

START-OF-SELECTION.

  PARAMETERS: tanim TYPE c AS LISTBOX VISIBLE LENGTH 20 OBLIGATORY.
  PARAMETERS: id TYPE zfk_ogrenci-id OBLIGATORY.
  PARAMETERS: ad TYPE zfk_ogrenci-ad OBLIGATORY.
  PARAMETERS: soyad TYPE zfk_ogrenci-soyad OBLIGATORY.
  PARAMETERS: bolum TYPE zfk_ogrenci-bolum OBLIGATORY.
  PARAMETERS: maas TYPE zfk_ogretmen-maas.
  PARAMETERS: g_tarih TYPE isellist-month OBLIGATORY.

  SELECTION-SCREEN:
      PUSHBUTTON /35(35) button1 USER-COMMAND but1,
      PUSHBUTTON /35(35) button2 USER-COMMAND but2.

END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&select date from popup menu
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR g_tarih.

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      actual_month               = sy-datum(6)
    IMPORTING
      selected_month             = g_tarih
    EXCEPTIONS
      factory_calendar_not_found = 1
      holiday_calendar_not_found = 2
      month_not_found            = 3
      OTHERS                     = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


*--------------------------------------------------------------*
*dropdown list for tanim
*--------------------------------------------------------------*
INITIALIZATION.
  gwa_list-key = '1'.
  gwa_list-text = 'ogrenci'.
  APPEND gwa_list TO gt_list.
  gwa_list-key = '2'.
  gwa_list-text = 'ogretmen'.
  APPEND gwa_list TO gt_list.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'tanim'
      values          = gt_list
    EXCEPTIONS
      id_illegal_name = 1
      OTHERS          = 2.

*--------------------------------------------------------------*
*pushbutton
*--------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields.
    WHEN 'BUT1'.
       IF tanım = '1'.
        ogrenci_-id = id.
        ogrenci_-ad = ad.
        ogrenci_-soyad = soyad.
        ogrenci_-bolum = bolum.
        ogrenci_-g_tarih = g_tarih.
        INSERT zfk_ogrenci FROM ogrenci_.
        MESSAGE 'Successfully added to Ogrenci Table' TYPE 'S'.

        ELSEIF tanım = '2'.
          ogretmen_-id = id.
          ogretmen_-ad = ad.
          ogretmen_-soyad = soyad.
          ogretmen_-maas = maas.
          ogretmen_-g_tarih = g_tarih.
          ogretmen_-bolum = bolum.
          INSERT zfk_ogretmen FROM ogretmen_.
          MESSAGE 'Successfully added to Ogretmen Table' TYPE 'S'.

        ENDIF.
     WHEN 'BUT2'.
       SELECT * FROM zfk_ogrenci INTO TABLE it_sbook.



        wa_fieldcat-fieldname  = 'ID'.    " Fieldname in the data table
        wa_fieldcat-seltext_m  = 'ID'.   " Column description in the output
        APPEND wa_fieldcat TO it_fieldcat.

        wa_fieldcat-fieldname  = 'AD'.
        wa_fieldcat-seltext_m  = 'AD'.
        APPEND wa_fieldcat TO it_fieldcat.

        wa_fieldcat-fieldname  = 'SOYAD'.
        wa_fieldcat-seltext_m  = 'SOYAD'.
        APPEND wa_fieldcat TO it_fieldcat.

        wa_fieldcat-fieldname  = 'BOLUM'.
        wa_fieldcat-seltext_m  = 'BOLUM'.
        APPEND wa_fieldcat TO it_fieldcat.

        wa_fieldcat-fieldname  = 'G_TARIH'.
        wa_fieldcat-seltext_m  = 'G_TARIH'.
        APPEND wa_fieldcat TO it_fieldcat.

        CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          it_fieldcat   = it_fieldcat
          i_callback_program     = g_repid
          i_callback_top_of_page = 'top_of_page'
          i_structure_name       = 'zfk_ogrenci'
        TABLES
          t_outtab      = it_sbook

        EXCEPTIONS
          program_error = 1
          OTHERS        = 2.

  ENDCASE.
INITIALIZATION.
  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_okay
      text = 'ADD'
    IMPORTING
      result = button1
    EXCEPTIONS
      OTHERS = 0.
  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      name   = icon_xls
      text = 'Check'
    IMPORTING
      result = button2
    EXCEPTIONS
      OTHERS = 0.


FORM top_of_page.

  DATA lt_list TYPE slis_t_listheader.
  DATA ls_list LIKE LINE OF lt_list.
  DATA lv_itab_sayi TYPE c LENGTH 4.
  DATA lv_yaz_sayi TYPE c LENGTH 40.
  "DESCRIBE TABLE gt_sfr LINES lv_itab_sayi  .

  CONCATENATE 'GOSTERILEN YOLCU SAYISI : ' lv_itab_sayi
                        INTO lv_yaz_sayi.

  ls_list-typ = 'H'.
  ls_list-info = 'YOLCU SEFER BİLGİLERİ'.
  APPEND ls_list TO lt_list.

  ls_list-typ = 'S'.
  WRITE sy-datum TO ls_list-info DD/MM/YYYY.
  APPEND ls_list TO lt_list.

  ls_list-typ = 'S'.
  ls_list-info =  lv_yaz_sayi.
  APPEND ls_list TO lt_list.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_list
      i_logo             = 'INNOVA'
*     I_END_OF_LIST_GRID =
*     I_ALV_FORM         =
    .


ENDFORM.
