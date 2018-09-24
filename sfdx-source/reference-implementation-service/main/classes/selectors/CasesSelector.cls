public with sharing class CasesSelector
    extends ApplicationSObjectSelector
    implements ICasesSelector
{
    public static ICasesSelector newInstance()
    {
        return (ICasesSelector) Application.Selector.newInstance( Case.SObjectType );
    }

    public Schema.sObjectType getSObjectType()
    {
        return Case.SObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            Case.Id,
            Case.CaseNumber
        };
    }

    private List<Schema.SObjectField> getAdditionalSObjectFieldList()
    {
        return new List<Schema.SObjectField> { };
    }

    public List<Case> selectById(Set<Id> idSet)
    {
        return (List<Case>) selectSObjectsById( idSet == null ? new Set<Id>() : idSet );
    }
}
