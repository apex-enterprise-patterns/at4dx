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
        return new List<Schema.SObjectField> { };
    }

    public List<Account> selectById(Set<Id> idSet)
    {
        // How do we incorporate fieldsets here, using the abstract functionality?
        return (List<Account>) selectSObjectsById( idSet == null ? new Set<Id>() : idSet );
    }

    public List<Account> selectByName( Set<String> nameSet )
    {
        fflib_QueryFactory qf = newQueryFactory();
        
        for (FieldSet fs : sObjectFieldSetList)
        {
            qf.selectFieldSet(fs);
        }

        qf.setCondition( Account.Name + ' in :nameSet');
        return Database.query(qf.toSOQL());

        // The above is not as fluid as ...
        // return Database.query(newQueryFactory().selectFieldSets(sObjectFieldSetList).setCondition( Account.Name + ' in :nameSet').toSOQL());
    }
}
