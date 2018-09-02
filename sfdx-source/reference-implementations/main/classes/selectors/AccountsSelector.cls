public with sharing class AccountsSelector 
    extends ApplicationSObjectSelector
    implements IAccountsSelector
{
    public static IAccountsSelector newInstance()
    {
        return (IAccountsSelector) Application.Selector.newInstance( Account.SObjectType );
    }

    public Schema.sObjectType getSObjectType()
    {
        return Account.SObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFieldList()
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

    public List<Account> selectByName( Set<String> nameSet )
    {
        // system.debug('AccountsSelector.selectByName(Set<String>) method is called');
        return Database.query( newQueryFactory().setCondition( Account.Name + ' in :nameSet').toSOQL() );
    }
}
