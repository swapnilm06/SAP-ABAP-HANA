REFRESH iout[].
  REFRESH fieldcatalog[].

** interna table -- records to be displayed in excel file

  it_excel = VALUE #( FOR wa_ann IN it_ann[]

                     ( srno                  = wa_ann-srno
*                     )
                 ).

** interna table -- lable for records to be displayed in excel file
  it_fieldcatalog = VALUE #(
                           (  fieldname = 'test'                    scrtext_m = 'SR NO'                                                              outputlen = '20'   )
                             ).




  DATA: xout TYPE string.
  DATA: var TYPE string.
  FIELD-SYMBOLS: <fs>.
  DATA: ls_result TYPE match_result.

  DATA : lv_fname TYPE string.
  LOOP AT it_fieldcatalog INTO DATA(wa_fieldcatalog) .

    IF sy-tabix = 1.
      xout = wa_fieldcatalog-fieldname.
    ELSE.
      var = wa_fieldcatalog-fieldname.
      CONDENSE var.    "use string , it will work for all data type
      CONCATENATE xout var INTO xout SEPARATED BY ','.    "separator will be as per given
    ENDIF.

    CLEAR wa_fieldcatalog.
  ENDLOOP.
  APPEND xout TO iout.

  LOOP AT it_excel ASSIGNING FIELD-SYMBOL(<wa_table_1>) .
    CLEAR xout.
    DO.
      ASSIGN COMPONENT sy-index OF STRUCTURE <wa_table_1> TO <fs>.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.


      IF sy-index = 1.
        xout = <fs>.
        FIND ALL OCCURRENCES OF ',' IN  xout RESULTS ls_result.
        IF sy-subrc EQ 0.
          xout = |"| & |{ xout }| & |"|.
        ENDIF.
      ELSE.
        var = <fs>.    "use string , it will work for all data type

        FIND ALL OCCURRENCES OF ',' IN var RESULTS ls_result.
        IF sy-subrc EQ 0.
          var = |"| & |{ var }| & |"|.
        ENDIF.

*          If var is NOT INITIAL.
        CONDENSE var.
        CONCATENATE xout var INTO xout SEPARATED BY ','.
*          endif.   "separator will be as per given
      ENDIF.
    ENDDO.
    APPEND xout TO iout.
  ENDLOOP.

*  CONCATENATE lv_fname 'csv' INTO lv_fname SEPARATED BY '.'.

  CONCATENATE 'Annexure_A_Format'sy-datum sy-uzeit datetype lv_fname 'csv' INTO lv_fname SEPARATED BY '_'.

  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
*     window_title      = 'SAVE FILE PATH'
      default_extension = 'CSV'
      default_file_name = lv_fname  " 'MU IVR EXCEL'
    CHANGING
      filename          = ld_filename
      path              = ld_path
      fullpath          = ld_fullpath
      user_action       = ld_result.

  ld_filename1 = ld_filename.
  ld_fullpath1 = ld_path.


*  CALL FUNCTION 'ISHMED_IS_FILE_OPEN'
  CALL FUNCTION 'ZUTIL_IS_FILE_OPEN'
    EXPORTING
      ss_wavfile     = ld_filename1
      ss_wavfilepath = ld_fullpath1
    IMPORTING
      ss_ret         = lv_ret.

  IF lv_ret = 1.
    MESSAGE 'File is already opened. Close the file' TYPE 'E' DISPLAY LIKE 'I'.
  ENDIF.

  lv_fname = ld_filename1.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename              = lv_fname  " File name including path, give CSV as extention of the file
      filetype              = 'ASC'
      append                = 'X'
      write_field_separator = 'X'    " Provide comma as separator
    TABLES
      data_tab              = iout "it_final " <gfs_dyn_table>     " Pass the Output internal table
*     FIELDNAMES            =
    EXCEPTIONS
      OTHERS                = 22.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

