public class AccountsService 
{
    private static IAccountsService service()
    {
        return (IAccountsService) Application.Service.newInstance( IAccountsService.class );
    }

    public static void createWithName( String name )
    {
        System.debug('Calling IAccountsService.createWithName(String) method');
        service().createWithName( name );
    }
}
