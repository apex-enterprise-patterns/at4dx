@isTest
private class AccountsServiceTest
{
    @isTest 
    static void givenNewAccountsServiceImplWhenCreateWithNameThenNewImplExecutes()
    {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        //IAccountsService mockAccountsService = (IAccountsService) mocks.mock( IAccountsService.class );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock( IAccountsSelector.class );

        Account testAcct = new Account();
        testAcct.Id = fflib_IDGenerator.generate( Account.SObjectType );
        testAcct.Name = 'red';

        mocks.startStubbing();
        //mocks.when( mockAccountsService.createWithName('red') );
        mocks.when( mockAccountsSelector.selectByName( new Set<String>{ 'red' } ) ).thenReturn(new List<Account>{ testAcct });
        mocks.when( mockAccountsSelector.sObjectType() ).thenReturn( Account.SObjectType );

        mocks.stopStubbing();

        //Application.Service.setMock(mmcommon_IPersonAccountsService.class, mockPersonAccountsService);
        Application.Selector.setMock(mockAccountsSelector);

        Test.startTest();

        AccountsService.createWithName('red');

        Test.stopTest();
    }
}