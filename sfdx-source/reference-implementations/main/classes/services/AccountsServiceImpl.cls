public with sharing class AccountsServiceImpl 
    implements IAccountsService
{
    public AccountsServiceImpl() {

    }

    public void createWithName( String name )
    {
        System.debug('AccountsServiceImpl.createWithName(String) method was called');

        List<Account> accountsFound = AccountsSelector.newInstance().selectByName( new Set<String>{ name } );

        System.debug( accountsFound.isEmpty() ? 'No Accounts found with name of \'' + name + '\'' : 'Found Account ID ' + accountsFound[0].Id );
    }
}
