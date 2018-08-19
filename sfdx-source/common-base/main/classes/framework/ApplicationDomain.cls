public abstract class ApplicationDomain 
    extends fflib_SObjectDomain
{
//    public ApplicationDomain() {
        //super(new List<SObject>() );
//    }

    public ApplicationDomain(List<SObject> records) {
        super(records);
        // Disable the base class CRUD checking in preference to explicit checking elsewhere
        Configuration.disableTriggerCRUDSecurity();
    }
}
