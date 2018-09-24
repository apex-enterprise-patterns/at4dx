public interface ILeadsSelector
    extends IApplicationSObjectSelector
{
    List<Lead> selectById( Set<Id> idSet );
}
