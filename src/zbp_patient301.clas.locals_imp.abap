CLASS lhc_patient DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      create             FOR MODIFY IMPORTING entities FOR CREATE patient,
      update             FOR MODIFY IMPORTING entities FOR UPDATE patient,
      delete             FOR MODIFY IMPORTING keys     FOR DELETE patient,
      read               FOR READ   IMPORTING keys     FOR READ patient
                                    RESULT result,
      lock               FOR LOCK   IMPORTING keys     FOR LOCK patient,
      get_authorizations FOR AUTHORIZATION
                         IMPORTING keys REQUEST requested_authorizations
                         FOR patient RESULT result.
ENDCLASS.

CLASS lhc_patient IMPLEMENTATION.

  METHOD create.
    DATA ls_patient TYPE ypatient301.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).

      IF <entity>-patientid IS INITIAL.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Patient ID is mandatory.' )
        ) TO reported-patient.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-patient.
        CONTINUE.
      ENDIF.

      IF <entity>-patientname IS INITIAL.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Patient Name is mandatory.' )
        ) TO reported-patient.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-patient.
        CONTINUE.
      ENDIF.

      IF <entity>-age IS INITIAL.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Age is mandatory.' )
        ) TO reported-patient.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-patient.
        CONTINUE.
      ENDIF.

      IF <entity>-gender IS INITIAL.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Gender is mandatory.' )
        ) TO reported-patient.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-patient.
        CONTINUE.
      ENDIF.

      IF <entity>-phone IS INITIAL.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Phone is mandatory.' )
        ) TO reported-patient.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-patient.
        CONTINUE.
      ENDIF.

      " Duplicate check
      SELECT SINGLE patient_id
        FROM ypatient301
        WHERE patient_id = @<entity>-patientid
        INTO @DATA(lv_exists).
      IF sy-subrc = 0.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Patient ID already exists.' )
        ) TO reported-patient.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-patient.
        CONTINUE.
      ENDIF.

      CLEAR ls_patient.
      ls_patient-client       = sy-mandt.
      ls_patient-patient_id   = <entity>-patientid.
      ls_patient-patient_name = <entity>-patientname.
      ls_patient-age          = <entity>-age.
      ls_patient-gender       = <entity>-gender.
      ls_patient-phone        = <entity>-phone.
      ls_patient-address      = <entity>-address.

      MODIFY ypatient301 FROM @ls_patient.

      APPEND VALUE #(
        %cid      = <entity>-%cid
        patientid = <entity>-patientid
      ) TO mapped-patient.

    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).

      SELECT SINGLE *
        FROM ypatient301
        WHERE patient_id = @<entity>-patientid
        INTO @DATA(ls_pat).
      IF sy-subrc <> 0.
        APPEND VALUE #( patientid = <entity>-patientid ) TO failed-patient.
        CONTINUE.
      ENDIF.

      IF <entity>-%control-patientname = if_abap_behv=>mk-on.
        ls_pat-patient_name = <entity>-patientname.
      ENDIF.
      IF <entity>-%control-age         = if_abap_behv=>mk-on.
        ls_pat-age          = <entity>-age.
      ENDIF.
      IF <entity>-%control-gender      = if_abap_behv=>mk-on.
        ls_pat-gender       = <entity>-gender.
      ENDIF.
      IF <entity>-%control-phone       = if_abap_behv=>mk-on.
        ls_pat-phone        = <entity>-phone.
      ENDIF.
      IF <entity>-%control-address     = if_abap_behv=>mk-on.
        ls_pat-address      = <entity>-address.
      ENDIF.

      MODIFY ypatient301 FROM @ls_pat.

    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      DELETE FROM ypatient301
        WHERE patient_id = @<key>-patientid.
      IF sy-subrc <> 0.
        APPEND VALUE #( patientid = <key>-patientid ) TO failed-patient.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      SELECT SINGLE *
        FROM ypatient301
        WHERE patient_id = @<key>-patientid
        INTO @DATA(ls_pat).
      IF sy-subrc = 0.
        APPEND VALUE #(
          patientid   = ls_pat-patient_id
          patientname = ls_pat-patient_name
          age         = ls_pat-age
          gender      = ls_pat-gender
          phone       = ls_pat-phone
          address     = ls_pat-address
        ) TO result.
      ELSE.
        APPEND VALUE #( patientid = <key>-patientid ) TO failed-patient.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      SELECT SINGLE patient_id
        FROM ypatient301
        WHERE patient_id = @<key>-patientid
        INTO @DATA(lv_id).
      IF sy-subrc <> 0.
        APPEND VALUE #( patientid = <key>-patientid ) TO failed-patient.
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
