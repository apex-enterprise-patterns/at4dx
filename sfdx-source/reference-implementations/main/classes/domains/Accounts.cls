public with sharing class Accounts 
    extends ApplicationDomain
    implements IAccounts
{
    public static IAccounts newInstance(List<Account> records)
    {
        return (IAccounts) Application.Domain.newInstance(records);
    }

    public static IAccounts newInstance(Set<Id> recordIds)
    {
        return (IAccounts) Application.Domain.newInstance(recordIds);
    }

    public Accounts(List<Account> records)
    {
        super(records);

        // don't enforce CRUD security for Account records
        this.Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor
        implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Accounts(sObjectList);
        }
    }
}
