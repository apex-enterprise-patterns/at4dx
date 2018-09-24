public interface ICasesSelector
    extends IApplicationSObjectSelector
{
    List<Case> selectById( Set<Id> idSet );
}
