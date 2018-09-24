public with sharing class Cases
    extends ApplicationSObjectDomain
    implements ICases
{
    public static ICases newInstance(List<Case> records)
    {
        return (ICases) Application.Domain.newInstance(records);
    }

    public static ICases newInstance(Set<Id> recordIds)
    {
        return (ICases) Application.Domain.newInstance(recordIds);
    }

    public Cases(List<Case> records)
    {
        super(records);

        // don't enforce CRUD security for Case records
        this.Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor
        implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Cases(sObjectList);
        }
    }
}
