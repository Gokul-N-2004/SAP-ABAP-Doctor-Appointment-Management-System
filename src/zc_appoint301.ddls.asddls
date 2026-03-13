@EndUserText.label: 'Appointment Consumption View'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@UI.headerInfo: {
  typeName: 'Appointment',
  typeNamePlural: 'Appointments',
  title: { type: #STANDARD, value: 'AppointmentId' },
  description: { type: #STANDARD, value: 'Status' }
}

define root view entity ZC_APPOINT301
  provider contract transactional_query
  as projection on ZI_APPOINT301
{
      @UI.facet: [
        {
          id:              'AppointInfo',
          purpose:         #STANDARD,
          type:            #FIELDGROUP_REFERENCE,
          targetQualifier: 'AppointGroup',
          label:           'Appointment Details',
          position:        10
        },
        {
          id:              'DoctorInfo',
          purpose:         #STANDARD,
          type:            #FIELDGROUP_REFERENCE,
          targetQualifier: 'DoctorGroup',
          label:           'Doctor Details',
          position:        20
        }
      ]

      @UI.lineItem: [
        { position: 10, label: 'Appointment ID' },
        { type: #FOR_ACTION, dataAction: 'MarkVisited',
          label: 'Mark Visited', position: 90 },
        { type: #FOR_ACTION, dataAction: 'MarkCancelled',
          label: 'Mark Cancelled', position: 95 }
      ]
      @UI.fieldGroup: [{ qualifier: 'AppointGroup', position: 10,
                         label: 'Appointment ID' }]
  key AppointmentId,

      @UI.lineItem:   [{ position: 20, label: 'Patient ID' }]
      @UI.fieldGroup: [{ qualifier: 'AppointGroup', position: 20,
                         label: 'Patient ID' }]
      @Consumption.valueHelpDefinition: [{
        entity: { name: 'ZC_PATIENT301', element: 'PatientId' }
      }]
      PatientId,

      @UI.lineItem:   [{ position: 30, label: 'Doctor ID' }]
      @UI.fieldGroup: [{ qualifier: 'AppointGroup', position: 30,
                         label: 'Doctor ID' }]
      @Consumption.valueHelpDefinition: [{
        entity: { name: 'ZC_DOCTOR301', element: 'DoctorId' }
      }]
      DoctorId,

      @UI.lineItem:   [{ position: 40, label: 'Doctor Name' }]
      @UI.fieldGroup: [{ qualifier: 'AppointGroup', position: 40,
                         label: 'Doctor Name' }]
      DoctorName,

      @UI.lineItem:   [{ position: 50, label: 'Specialization' }]
      @UI.fieldGroup: [{ qualifier: 'AppointGroup', position: 50,
                         label: 'Specialization' }]
      Specialization,

      @UI.lineItem:   [{ position: 60, label: 'Appointment Date' }]
      @UI.fieldGroup: [{ qualifier: 'AppointGroup', position: 60,
                         label: 'Appointment Date' }]
      AppointmentDate,

      @UI.lineItem:   [{ position: 70, label: 'Appointment Time' }]
      @UI.fieldGroup: [{ qualifier: 'AppointGroup', position: 70,
                         label: 'Appointment Time' }]
      AppointmentTime,

      @UI.lineItem: [{
        position: 80,
        label: 'Status',
        criticality: 'StatusCriticality',
        criticalityRepresentation: #WITH_ICON
      }]
      @UI.fieldGroup: [{
        qualifier: 'AppointGroup',
        position:  80,
        label:     'Status',
        criticality: 'StatusCriticality',
        criticalityRepresentation: #WITH_ICON
      }]
      Status,

      @UI.lineItem:   [{ position: 85, label: 'Doctor Phone' }]
      @UI.fieldGroup: [{ qualifier: 'DoctorGroup', position: 10,
                         label: 'Doctor Phone' }]
      DoctorPhone,

      @UI.lineItem:   [{ position: 86, label: 'Experience (Years)' }]
      @UI.fieldGroup: [{ qualifier: 'DoctorGroup', position: 20,
                         label: 'Experience (Years)' }]
      DoctorExperience,

      @UI.lineItem:   [{ position: 87, label: 'Joining Date' }]
      @UI.fieldGroup: [{ qualifier: 'DoctorGroup', position: 30,
                         label: 'Joining Date' }]
      DoctorJoiningDate,

      @UI.lineItem:   [{ position: 88, label: 'Success Cases' }]
      @UI.fieldGroup: [{ qualifier: 'DoctorGroup', position: 40,
                         label: 'Success Cases' }]
      DoctorSuccessCases,

      @UI.hidden: true
      StatusCriticality,

      @UI.hidden: true
      RowHighlight,

      _Doctor,
      _Patient
}
