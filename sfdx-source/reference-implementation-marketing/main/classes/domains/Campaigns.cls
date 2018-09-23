public with sharing class Campaigns
    extends ApplicationSObjectDomain
    implements ICampaigns
{
    public static ICampaigns newInstance(List<Campaign> records)
    {
        return (ICampaigns) Application.Domain.newInstance(records);
    }

    public static ICampaigns newInstance(Set<Id> recordIds)
    {
        return (ICampaigns) Application.Domain.newInstance(recordIds);
    }

    public Campaigns(List<Campaign> records)
    {
        super(records);

        // don't enforce CRUD security for Campaign records
        this.Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor
        implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Campaigns(sObjectList);
        }
    }
}
