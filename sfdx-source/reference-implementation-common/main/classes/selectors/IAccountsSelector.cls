public interface IAccountsSelector 
    extends IApplicationSObjectSelector
{
    List<Account> selectById( Set<Id> idSet );
    List<Account> selectByName( Set<String> nameSet );
}
