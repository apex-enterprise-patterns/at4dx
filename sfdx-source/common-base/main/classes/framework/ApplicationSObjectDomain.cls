public abstract class ApplicationSObjectDomain 
    extends fflib_SObjectDomain
{
    public ApplicationSObjectDomain(List<SObject> records) {
        super(records);
        // Disable the base class CRUD checking in preference to explicit checking elsewhere
        Configuration.disableTriggerCRUDSecurity();
    }
}
