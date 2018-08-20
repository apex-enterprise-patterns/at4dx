public with sharing class AccountsSelector 
    extends ApplicationSObjectSelector
    implements IAccountsSelector
{
    public static IAccountsSelector newInstance()
    {
        return (IAccountsSelector) Application.Selector.newInstance( Account.SObjectType );
    }

    private Schema.sObjectType getSObjectType()
    {
        return Account.SObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            Account.Id,
            Account.Name
        };
    }

    private List<Schema.SObjectField> getAdditionalSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            
        };
    }

    public List<Account> selectById(Set<Id> idSet)
    {
        return (List<Account>) selectSObjectsById( idSet == null ? new Set<Id>() : idSet );
    }

}
