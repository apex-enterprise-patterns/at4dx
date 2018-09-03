@isTest
private class AccountsServiceTest
{
    @isTest 
    static void givenNewAccountsServiceImplWhenCreateWithNameThenNewImplExecutes()
    {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        //IAccountsService mockAccountsService = (IAccountsService) mocks.mock( IAccountsService.class );
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock( IAccountsSelector.class );
        IContactsSelector mockContactsSelector = (IContactsSelector) mocks.mock( IContactsSelector.class );

        // given
        mocks.startStubbing();

        String testAccountName = 'red';

        Account testAcct = new Account();
        testAcct.Id = fflib_IDGenerator.generate( Account.SObjectType );
        testAcct.Name = testAccountName;

        Contact testContact = new Contact();
        testContact.id = fflib_IDGenerator.generate( Contact.SObjectType );
        testContact.FirstName = testAccountName;
        testContact.LastName = 'fish';
        testContact.AccountId = testAcct.Id;

        //mocks.when( mockAccountsService.createWithName(testAccountName) );

        mocks.when( mockAccountsSelector.sObjectType() ).thenReturn( Account.SObjectType );
        mocks.when( mockAccountsSelector.selectByName( new Set<String>{ testAccountName } ) ).thenReturn(new List<Account>{ testAcct });

        mocks.when( mockContactsSelector.sObjectType() ).thenReturn( Contact.SObjectType );
        mocks.when( mockContactsSelector.selectById( new Set<Id>{ testContact.Id } ) ).thenReturn(new List<Contact>{ testContact });

        mocks.stopStubbing();

        //Application.Service.setMock(mmcommon_IPersonAccountsService.class, mockPersonAccountsService);
        system.debug('AccountsServiceTest flag 1');
        Application.Selector.setMock(mockAccountsSelector);
        system.debug('AccountsServiceTest flag 2');
        
        // When

        Test.startTest();

        AccountsService.createWithName(testAccountName);

        // Call the ContactsSelector PRIOR TO SETTING THE MOCK. Expected result is that the mock testContact record will not be found in the database.
        System.assert( ContactsSelector.newInstance().selectById( new Set<Id>{ testContact.Id } ).isEmpty() );

        Application.Selector.setMock(mockContactsSelector);

        // Call the ContactsSelector AFTER TO SETTING THE MOCK.  Expected results is that the mock testContact record will be returned by the selector.
        System.assert( ! ContactsSelector.newInstance().selectById( new Set<Id>{ testContact.Id } ).isEmpty() );

        Test.stopTest();

        // Then
        ((IAccountsSelector) mocks.verify( mockAccountsSelector )).selectByName( new Set<String>{ testAccountName } ); // should have been called by the AccountsService.createWithName(testAccountName); method call
        ((IContactsSelector) mocks.verify( mockContactsSelector )).selectById( new Set<Id>{ testContact.Id } );
        
    }
}