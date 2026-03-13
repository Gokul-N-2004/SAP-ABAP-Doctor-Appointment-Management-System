CLASS lhc_doctor DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      create             FOR MODIFY IMPORTING entities FOR CREATE doctor,
      update             FOR MODIFY IMPORTING entities FOR UPDATE doctor,
      delete             FOR MODIFY IMPORTING keys     FOR DELETE doctor,
      read               FOR READ   IMPORTING keys     FOR READ doctor
                                    RESULT result,
      lock               FOR LOCK   IMPORTING keys     FOR LOCK doctor,
      get_authorizations FOR AUTHORIZATION
                         IMPORTING keys REQUEST requested_authorizations
                         FOR doctor RESULT result.
ENDCLASS.

CLASS lhc_doctor IMPLEMENTATION.

  METHOD create.
    DATA ls_doctor TYPE ydoctor301.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).

      IF <entity>-doctorid IS INITIAL.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Doctor ID is mandatory.' )
        ) TO reported-doctor.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-doctor.
        CONTINUE.
      ENDIF.

      IF <entity>-doctorname IS INITIAL.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Doctor Name is mandatory.' )
        ) TO reported-doctor.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-doctor.
        CONTINUE.
      ENDIF.

      IF <entity>-specialization IS INITIAL.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Specialization is mandatory.' )
        ) TO reported-doctor.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-doctor.
        CONTINUE.
      ENDIF.

      IF <entity>-phone IS INITIAL.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Phone is mandatory.' )
        ) TO reported-doctor.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-doctor.
        CONTINUE.
      ENDIF.

      " Duplicate check
      SELECT SINGLE doctor_id
        FROM ydoctor301
        WHERE doctor_id = @<entity>-doctorid
        INTO @DATA(lv_exists).
      IF sy-subrc = 0.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Doctor ID already exists.' )
        ) TO reported-doctor.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-doctor.
        CONTINUE.
      ENDIF.

      CLEAR ls_doctor.
      ls_doctor-client         = sy-mandt.
      ls_doctor-doctor_id      = <entity>-doctorid.
      ls_doctor-doctor_name    = <entity>-doctorname.
      ls_doctor-specialization = <entity>-specialization.
      ls_doctor-phone          = <entity>-phone.
      ls_doctor-experience     = <entity>-experience.
      ls_doctor-joining_date   = <entity>-joiningdate.
      ls_doctor-success_cases  = <entity>-successcases.

      MODIFY ydoctor301 FROM @ls_doctor.

      APPEND VALUE #(
        %cid     = <entity>-%cid
        doctorid = <entity>-doctorid
      ) TO mapped-doctor.

    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).

      SELECT SINGLE *
        FROM ydoctor301
        WHERE doctor_id = @<entity>-doctorid
        INTO @DATA(ls_doc).
      IF sy-subrc <> 0.
        APPEND VALUE #( doctorid = <entity>-doctorid ) TO failed-doctor.
        CONTINUE.
      ENDIF.

      IF <entity>-%control-doctorname     = if_abap_behv=>mk-on.
        ls_doc-doctor_name    = <entity>-doctorname.
      ENDIF.
      IF <entity>-%control-specialization = if_abap_behv=>mk-on.
        ls_doc-specialization = <entity>-specialization.
      ENDIF.
      IF <entity>-%control-phone          = if_abap_behv=>mk-on.
        ls_doc-phone          = <entity>-phone.
      ENDIF.
      IF <entity>-%control-experience     = if_abap_behv=>mk-on.
        ls_doc-experience     = <entity>-experience.
      ENDIF.
      IF <entity>-%control-joiningdate    = if_abap_behv=>mk-on.
        ls_doc-joining_date   = <entity>-joiningdate.
      ENDIF.
      IF <entity>-%control-successcases   = if_abap_behv=>mk-on.
        ls_doc-success_cases  = <entity>-successcases.
      ENDIF.

      MODIFY ydoctor301 FROM @ls_doc.

    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      DELETE FROM ydoctor301
        WHERE doctor_id = @<key>-doctorid.
      IF sy-subrc <> 0.
        APPEND VALUE #( doctorid = <key>-doctorid ) TO failed-doctor.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      SELECT SINGLE *
        FROM ydoctor301
        WHERE doctor_id = @<key>-doctorid
        INTO @DATA(ls_doc).
      IF sy-subrc = 0.
        APPEND VALUE #(
          doctorid       = ls_doc-doctor_id
          doctorname     = ls_doc-doctor_name
          specialization = ls_doc-specialization
          phone          = ls_doc-phone
          experience     = ls_doc-experience
          joiningdate    = ls_doc-joining_date
          successcases   = ls_doc-success_cases
        ) TO result.
      ELSE.
        APPEND VALUE #( doctorid = <key>-doctorid ) TO failed-doctor.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      SELECT SINGLE doctor_id
        FROM ydoctor301
        WHERE doctor_id = @<key>-doctorid
        INTO @DATA(lv_id).
      IF sy-subrc <> 0.
        APPEND VALUE #( doctorid = <key>-doctorid ) TO failed-doctor.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_authorizations.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      APPEND VALUE #(
        %key    = <key>-%key
        %update = if_abap_behv=>auth-allowed
        %delete = if_abap_behv=>auth-allowed
      ) TO result.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
