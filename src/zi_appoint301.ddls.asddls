@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Appointment Interface View'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZI_APPOINT301
  as select from yappoint301
  association [1] to ZI_DOCTOR301  as _Doctor
    on $projection.DoctorId = _Doctor.DoctorId
  association [1] to ZI_PATIENT301 as _Patient
    on $projection.PatientId = _Patient.PatientId
{
  key appoint_id               as AppointmentId,
      patient_id               as PatientId,
      doctor_id                as DoctorId,
      doctor_name              as DoctorName,
      specialization           as Specialization,
      appoint_date             as AppointmentDate,
      appoint_time             as AppointmentTime,
      status                   as Status,

      _Doctor.Phone            as DoctorPhone,
      _Doctor.Experience       as DoctorExperience,
      _Doctor.JoiningDate      as DoctorJoiningDate,
      _Doctor.SuccessCases     as DoctorSuccessCases,

      case status
        when 'Booked'    then 2
        when 'Visited'   then 3
        when 'Cancelled' then 1
        else 0
      end                      as StatusCriticality,

      case status
        when 'Cancelled' then 1
        else 0
      end                      as RowHighlight,

      _Doctor,
      _Patient
}
