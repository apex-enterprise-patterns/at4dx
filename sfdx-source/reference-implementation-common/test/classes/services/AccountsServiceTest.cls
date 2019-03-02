/**
 * Copyright (c) 2018, John M. Daniel
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the John M. Daniel, nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

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