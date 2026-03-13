CLASS lhc_appointment DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      create             FOR MODIFY IMPORTING entities FOR CREATE appointment,
      update             FOR MODIFY IMPORTING entities FOR UPDATE appointment,
      delete             FOR MODIFY IMPORTING keys     FOR DELETE appointment,
      read               FOR READ   IMPORTING keys     FOR READ appointment
                                    RESULT result,
      lock               FOR LOCK   IMPORTING keys     FOR LOCK appointment,
      get_authorizations FOR AUTHORIZATION
                         IMPORTING keys REQUEST requested_authorizations
                         FOR appointment RESULT result,
      markvisited        FOR MODIFY IMPORTING keys FOR ACTION appointment~markvisited
                         RESULT result,
      markcancelled      FOR MODIFY IMPORTING keys FOR ACTION appointment~markcancelled
                         RESULT result.
ENDCLASS.

CLASS lhc_appointment IMPLEMENTATION.

  METHOD create.
    DATA lv_appoint_id TYPE char10.
    DATA lv_max_id     TYPE char10.
    DATA lv_num        TYPE i.
    DATA lv_today      TYPE d.
    DATA lv_conflict   TYPE char10.
    DATA ls_appoint    TYPE yappoint301.
    DATA ls_doctor     TYPE ydoctor301.
    DATA lv_num_c      TYPE char7.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).

      IF <entity>-patientid IS INITIAL.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Patient is mandatory.' )
        ) TO reported-appointment.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-appointment.
        CONTINUE.
      ENDIF.

      IF <entity>-doctorid IS INITIAL.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Doctor is mandatory.' )
        ) TO reported-appointment.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-appointment.
        CONTINUE.
      ENDIF.

      IF <entity>-doctorname IS INITIAL.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Doctor Name is mandatory.' )
        ) TO reported-appointment.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-appointment.
        CONTINUE.
      ENDIF.

      IF <entity>-specialization IS INITIAL.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Specialization is mandatory.' )
        ) TO reported-appointment.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-appointment.
        CONTINUE.
      ENDIF.

      IF <entity>-appointmentdate IS INITIAL.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Date is mandatory.' )
        ) TO reported-appointment.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-appointment.
        CONTINUE.
      ENDIF.

      IF <entity>-appointmenttime IS INITIAL.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Time is mandatory.' )
        ) TO reported-appointment.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-appointment.
        CONTINUE.
      ENDIF.

      " Past date check
      lv_today = cl_abap_context_info=>get_system_date( ).
      IF <entity>-appointmentdate < lv_today.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Appointment date cannot be in the past.' )
        ) TO reported-appointment.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-appointment.
        CONTINUE.
      ENDIF.

      " Time slot conflict check
      CLEAR lv_conflict.
      SELECT SINGLE appoint_id
        FROM yappoint301
        WHERE doctor_id    = @<entity>-doctorid
          AND appoint_date = @<entity>-appointmentdate
          AND appoint_time = @<entity>-appointmenttime
        INTO @lv_conflict.
      IF sy-subrc = 0.
        APPEND VALUE #(
          %cid = <entity>-%cid
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = 'Doctor already booked at this date and time.' )
        ) TO reported-appointment.
        APPEND VALUE #( %cid = <entity>-%cid ) TO failed-appointment.
        CONTINUE.
      ENDIF.

      " Generate Appointment ID
      CLEAR lv_max_id.
      CLEAR lv_num.
      CLEAR lv_num_c.
      CLEAR lv_appoint_id.

      SELECT SINGLE MAX( appoint_id )
        FROM yappoint301
        INTO @lv_max_id.

      IF lv_max_id IS INITIAL.
        lv_num = 1.
      ELSE.
        lv_num_c = lv_max_id+3(7).
        lv_num   = lv_num_c.
        lv_num   = lv_num + 1.
      ENDIF.

      IF lv_num < 10.
        lv_num_c = '000000'.
        lv_num_c+6(1) = lv_num.
      ELSEIF lv_num < 100.
        lv_num_c = '00000'.
        lv_num_c+5(2) = lv_num.
      ELSEIF lv_num < 1000.
        lv_num_c = '0000'.
        lv_num_c+4(3) = lv_num.
      ELSEIF lv_num < 10000.
        lv_num_c = '000'.
        lv_num_c+3(4) = lv_num.
      ELSEIF lv_num < 100000.
        lv_num_c = '00'.
        lv_num_c+2(5) = lv_num.
      ELSEIF lv_num < 1000000.
        lv_num_c = '0'.
        lv_num_c+1(6) = lv_num.
      ELSE.
        lv_num_c = lv_num.
      ENDIF.

      lv_appoint_id = 'APT'.
      lv_appoint_id+3(7) = lv_num_c.

      " Write appointment to DB
      CLEAR ls_appoint.
      ls_appoint-client         = sy-mandt.
      ls_appoint-appoint_id     = lv_appoint_id.
      ls_appoint-patient_id     = <entity>-patientid.
      ls_appoint-doctor_id      = <entity>-doctorid.
      ls_appoint-doctor_name    = <entity>-doctorname.
      ls_appoint-specialization = <entity>-specialization.
      ls_appoint-appoint_date   = <entity>-appointmentdate.
      ls_appoint-appoint_time   = <entity>-appointmenttime.
      ls_appoint-status         = 'Booked'.

      MODIFY yappoint301 FROM @ls_appoint.

      " Update doctor details in ydoctor301
      SELECT SINGLE *
        FROM ydoctor301
        WHERE doctor_id = @<entity>-doctorid
        INTO @ls_doctor.

      IF sy-subrc = 0.
        " Doctor exists — update details
        IF <entity>-doctorphone IS NOT INITIAL.
          ls_doctor-phone = <entity>-doctorphone.
        ENDIF.
        IF <entity>-doctorexperience IS NOT INITIAL.
          ls_doctor-experience = <entity>-doctorexperience.
        ENDIF.
        IF <entity>-doctorjoiningdate IS NOT INITIAL.
          ls_doctor-joining_date = <entity>-doctorjoiningdate.
        ENDIF.
        IF <entity>-doctorsuccesscases IS NOT INITIAL.
          ls_doctor-success_cases = <entity>-doctorsuccesscases.
        ENDIF.
        MODIFY ydoctor301 FROM @ls_doctor.
      ELSE.
        " Doctor does not exist — create new doctor record
        CLEAR ls_doctor.
        ls_doctor-client         = sy-mandt.
        ls_doctor-doctor_id      = <entity>-doctorid.
        ls_doctor-doctor_name    = <entity>-doctorname.
        ls_doctor-specialization = <entity>-specialization.
        ls_doctor-phone          = <entity>-doctorphone.
        ls_doctor-experience     = <entity>-doctorexperience.
        ls_doctor-joining_date   = <entity>-doctorjoiningdate.
        ls_doctor-success_cases  = <entity>-doctorsuccesscases.
        MODIFY ydoctor301 FROM @ls_doctor.
      ENDIF.

      APPEND VALUE #(
        %cid          = <entity>-%cid
        appointmentid = lv_appoint_id
      ) TO mapped-appointment.

    ENDLOOP.
  ENDMETHOD.

  METHOD markvisited.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

      UPDATE yappoint301
        SET status = 'Visited'
        WHERE appoint_id = @<key>-appointmentid.

      READ ENTITIES OF zi_appoint301
        ENTITY appointment
        ALL FIELDS WITH VALUE #( ( %key = <key>-%key ) )
        RESULT DATA(lt_result)
        FAILED DATA(lt_failed).

      result = CORRESPONDING #( lt_result ).

    ENDLOOP.
  ENDMETHOD.

  METHOD markcancelled.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

      UPDATE yappoint301
        SET status = 'Cancelled'
        WHERE appoint_id = @<key>-appointmentid.

      READ ENTITIES OF zi_appoint301
        ENTITY appointment
        ALL FIELDS WITH VALUE #( ( %key = <key>-%key ) )
        RESULT DATA(lt_result)
        FAILED DATA(lt_failed).

      result = CORRESPONDING #( lt_result ).

    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    DATA lv_today  TYPE d.
    DATA ls_doctor TYPE ydoctor301.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<entity>).

      SELECT SINGLE *
        FROM yappoint301
        WHERE appoint_id = @<entity>-appointmentid
        INTO @DATA(ls_appoint).

      IF sy-subrc <> 0.
        APPEND VALUE #( appointmentid = <entity>-appointmentid ) TO failed-appointment.
        CONTINUE.
      ENDIF.

      IF <entity>-%control-doctorname = if_abap_behv=>mk-on.
        ls_appoint-doctor_name    = <entity>-doctorname.
      ENDIF.
      IF <entity>-%control-specialization = if_abap_behv=>mk-on.
        ls_appoint-specialization = <entity>-specialization.
      ENDIF.
      IF <entity>-%control-appointmentdate = if_abap_behv=>mk-on.
        lv_today = cl_abap_context_info=>get_system_date( ).
        IF <entity>-appointmentdate < lv_today.
          APPEND VALUE #(
            appointmentid = <entity>-appointmentid
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = 'Appointment date cannot be in the past.' )
          ) TO reported-appointment.
          APPEND VALUE #( appointmentid = <entity>-appointmentid ) TO failed-appointment.
          CONTINUE.
        ENDIF.
        ls_appoint-appoint_date = <entity>-appointmentdate.
      ENDIF.
      IF <entity>-%control-appointmenttime = if_abap_behv=>mk-on.
        ls_appoint-appoint_time = <entity>-appointmenttime.
      ENDIF.
      IF <entity>-%control-status = if_abap_behv=>mk-on.
        ls_appoint-status = <entity>-status.
      ENDIF.

      MODIFY yappoint301 FROM @ls_appoint.

      " Update doctor details if changed
      SELECT SINGLE *
        FROM ydoctor301
        WHERE doctor_id = @ls_appoint-doctor_id
        INTO @ls_doctor.

      IF sy-subrc = 0.
        IF <entity>-%control-doctorphone = if_abap_behv=>mk-on.
          ls_doctor-phone = <entity>-doctorphone.
        ENDIF.
        IF <entity>-%control-doctorexperience = if_abap_behv=>mk-on.
          ls_doctor-experience = <entity>-doctorexperience.
        ENDIF.
        IF <entity>-%control-doctorjoiningdate = if_abap_behv=>mk-on.
          ls_doctor-joining_date = <entity>-doctorjoiningdate.
        ENDIF.
        IF <entity>-%control-doctorsuccesscases = if_abap_behv=>mk-on.
          ls_doctor-success_cases = <entity>-doctorsuccesscases.
        ENDIF.
        MODIFY ydoctor301 FROM @ls_doctor.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      DELETE FROM yappoint301
        WHERE appoint_id = @<key>-appointmentid.
      IF sy-subrc <> 0.
        APPEND VALUE #( appointmentid = <key>-appointmentid ) TO failed-appointment.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).

      SELECT SINGLE *
        FROM yappoint301
        WHERE appoint_id = @<key>-appointmentid
        INTO @DATA(ls_appoint).

      IF sy-subrc = 0.

        SELECT SINGLE *
          FROM ydoctor301
          WHERE doctor_id = @ls_appoint-doctor_id
          INTO @DATA(ls_doctor).

        APPEND VALUE #(
          appointmentid      = ls_appoint-appoint_id
          patientid          = ls_appoint-patient_id
          doctorid           = ls_appoint-doctor_id
          doctorname         = ls_appoint-doctor_name
          specialization     = ls_appoint-specialization
          appointmentdate    = ls_appoint-appoint_date
          appointmenttime    = ls_appoint-appoint_time
          status             = ls_appoint-status
          doctorphone        = ls_doctor-phone
          doctorexperience   = ls_doctor-experience
          doctorjoiningdate  = ls_doctor-joining_date
          doctorsuccesscases = ls_doctor-success_cases
          statuscriticality  = SWITCH #( ls_appoint-status
                                 when 'Booked'    then 2
                                 when 'Visited'   then 3
                                 when 'Cancelled' then 1
                                 else 0 )
          rowhighlight       = SWITCH #( ls_appoint-status
                                 when 'Cancelled' then 1
                                 else 0 )
        ) TO result.

      ELSE.
        APPEND VALUE #( appointmentid = <key>-appointmentid ) TO failed-appointment.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      SELECT SINGLE appoint_id
        FROM yappoint301
        WHERE appoint_id = @<key>-appointmentid
        INTO @DATA(lv_id).
      IF sy-subrc <> 0.
        APPEND VALUE #( appointmentid = <key>-appointmentid ) TO failed-appointment.
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
