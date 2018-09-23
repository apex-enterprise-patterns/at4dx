public with sharing class CampaignsSelector 
    extends ApplicationSObjectSelector
    implements ICampaignsSelector
{
    public static ICampaignsSelector newInstance()
    {
        return (ICampaignsSelector) Application.Selector.newInstance( Campaign.SObjectType );
    }

    public Schema.sObjectType getSObjectType()
    {
        return Campaign.SObjectType;
    }

    public override List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            Campaign.Id,
            Campaign.Name
        };
    }

    private List<Schema.SObjectField> getAdditionalSObjectFieldList()
    {
        return new List<Schema.SObjectField> { };
    }

    public List<Campaign> selectById(Set<Id> idSet)
    {
        return (List<Campaign>) selectSObjectsById( idSet == null ? new Set<Id>() : idSet );
    }
}
