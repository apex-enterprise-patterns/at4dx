public interface IAccountsSelector 
    extends fflib_ISObjectSelector
{
    List<Account> selectById( Set<Id> idSet );
}
