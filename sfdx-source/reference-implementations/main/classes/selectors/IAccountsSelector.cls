public interface IAccountsSelector 
    extends IApplicationSObjectSelector
{
    List<Account> selectById( Set<Id> idSet );
}
