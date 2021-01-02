public with sharing class TestOnlyAccounts
    extends ApplicationSObjectDomain
    implements ITestOnlyAccounts
{
    public static ITestOnlyAccounts newInstance(Set<Id> recordIds)
    {
        return (ITestOnlyAccounts) Application.Domain.newInstance(recordIds);
    }
    
    public static ITestOnlyAccounts newInstance(List<Account> records)
    {
        return (ITestOnlyAccounts) Application.Domain.newInstance(records);
    }
    
    public static ITestOnlyAccounts newInstance(List<Account> records, SObjectType sobjType)
    {
        return (ITestOnlyAccounts) Application.Domain.newInstance(records, sobjType);
    }

    public TestOnlyAccounts(List<Account> records)
    {
        super(records);
    }

    public class Constructor
        implements fflib_SObjectDomain.IConstructable2
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new TestOnlyAccounts((List<Account>) sObjectList);
        }

        public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sobjType)
        {
            return new TestOnlyAccounts((List<Account>) sObjectList);
        }
    }

    public interface ITestOnlyAccounts
        extends IApplicationSObjectDomain
    {

    }
}