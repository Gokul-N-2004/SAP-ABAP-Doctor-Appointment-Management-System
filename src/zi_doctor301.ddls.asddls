@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Doctor Interface View'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZI_DOCTOR301
  as select from ydoctor301
{
  key doctor_id      as DoctorId,
      doctor_name    as DoctorName,
      specialization as Specialization,
      phone          as Phone,
      experience     as Experience,
      joining_date   as JoiningDate,
      success_cases  as SuccessCases
}
