public interface ICampaignsSelector
    extends IApplicationSObjectSelector
{
    List<Campaign> selectById( Set<Id> idSet );
}