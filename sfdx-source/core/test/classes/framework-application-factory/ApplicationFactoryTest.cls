/**
 * Copyright (c) 2021, John M. Daniel & John Storey
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
private class ApplicationFactoryTest
{
    /********************************************************
     *    Selector-related Testing
    ********************************************************/
    @isTest
    private static void Application_Selector_HappyPathTest()
    {
        configureSelectors();

        ITestAccountsSelector sel = (ITestAccountsSelector) Application.Selector.newInstance(Account.SObjectType);
        List<Account> accountList = sel.selectById(new Set<Id> {fflib_IdGenerator.generate(Account.SObjectType)});

        Assert.isTrue(accountList != null);
        Assert.isTrue(accountList.isEmpty());
    }

    @IsTest
    private static void Application_Selector_SelectByIdHelperTest()
    {
        configureSelectors();

        List<Account> accountList = Application.Selector.selectById(new Set<Id> {fflib_IdGenerator.generate(Account.SObjectType)});

        Assert.isTrue(accountList != null);
        Assert.isTrue(accountList.isEmpty());
    }

    @IsTest
    private static void Application_Selector_SelectByRelationshipTest()
    {
        configureSelectors();

        Contact ctc = new Contact();
        ctc.LastName = 'Doe';
        ctc.AccountId = fflib_IdGenerator.generate(Account.SObjectType);

        List<Contact> contactList =
            new List<Contact>
            {
                ctc
            };

        List<Account> accountList = (List<Account>) Application.Selector.selectByRelationship(contactList, Contact.AccountId);

        Assert.isTrue(accountList != null);
        Assert.isTrue(accountList.isEmpty());
    }

    @IsTest
    private static void Application_Selector_SetMockTest()
    {
        configureSelectors();  //comment

        Account acct = new Account(ID = fflib_IDGenerator.generate(Account.SObjectType));

        MockAccountsSelector mock_selector = new MockAccountsSelector();
        mock_selector.setAccountsToSelect(new List<Account> {acct});

        Application.Selector.setMock(mock_selector);

        ITestAccountsSelector sel = (ITestAccountsSelector) Application.Selector.newInstance(Account.SObjectType);
        List<Account> accountList = sel.selectById(new Set<Id> {fflib_IdGenerator.generate(Account.SObjectType)});

        Assert.isTrue(accountList != null);
        Assert.areEqual(1, accountList.size());
        Assert.areEqual(acct.Id, accountList.get(0).Id);
    }

    /********************************************************
     *    Configures CMD records for two selectors
     *    for Account and Contact
    ********************************************************/
    private static void configureSelectors()
    {
        ApplicationFactory_SelectorBinding__mdt accountsSelectorBinding = new ApplicationFactory_SelectorBinding__mdt();
        accountsSelectorBinding.BindingSObjectAlternate__c = 'Account';
        accountsSelectorBinding.To__c = 'ApplicationFactoryTest.TestAccountsSelector';

        ApplicationFactory_SelectorBinding__mdt contactsSelectorBinding = new ApplicationFactory_SelectorBinding__mdt();
        contactsSelectorBinding.BindingSObjectAlternate__c = 'Contact';
        contactsSelectorBinding.To__c = 'ApplicationFactoryTest.TestContactsSelector';

        List<ApplicationFactory_SelectorBinding__mdt> bindingList = new List<ApplicationFactory_SelectorBinding__mdt>
        {
            accountsSelectorBinding,
            contactsSelectorBinding
        };

        ApplicationSObjectSelectorDIModule.bindingRecords.addAll(bindingList);

        // override the selector bindings just in case this method
        //  executes in an org that already has an AccountsSelector.
        Application.Selector.setMock(new TestAccountsSelector());
    }

    /********************************************************
     *    Service-related Testing
    ********************************************************/
    @IsTest
    private static void Application_Service_HappyPathTest()
    {
        configureServices();

        // Service instantiated because, for testing, it's an inner class
        TestService serv = new TestService();
        String phrase = serv.getHelloWorldPhrase('Jane Doe');

        Assert.isTrue(String.isNotBlank(phrase));
        Assert.areEqual('Hello Jane Doe!!!', phrase);
    }
    
    @IsTest
    private static void Application_Service_MockServiceTest()
    {
        configureServices();

        Application.Service.setMock(ITestService.class, TestServiceMockImpl.class.getName());

        // Service instantiated because, for testing, it's an inner class
        TestService serv = new TestService();
        String phrase = serv.getHelloWorldPhrase('Jane Doe');

        Assert.isTrue(String.isNotBlank(phrase));
        Assert.areEqual('this is the mock', phrase);
    }

    private static void configureServices()
    {
        ApplicationFactory_ServiceBinding__mdt binding = new ApplicationFactory_ServiceBinding__mdt();
        binding.BindingInterface__c = 'ApplicationFactoryTest.ITestService';
        binding.To__c = 'ApplicationFactoryTest.TestServiceImpl';

        ApplicationServiceDIModule.bindingRecords.addAll(new List<ApplicationFactory_ServiceBinding__mdt> {binding});
    }

    /********************************************************
     *    Domain-related Testing
    ********************************************************/
    @IsTest
    private static void Application_Domain_ConstructorTest()
    {
        configureDomains();

        ITestOnlyAccounts test_domain = new TestOnlyAccounts(new List<Account>()).newInstance(new List<Account>());
        Assert.isTrue(test_domain != null);
    }

    @IsTest
    private static void Application_Domain_Constructor2Test()
    {
        configureDomains();

        ITestOnlyAccounts test_domain = new TestOnlyAccounts(new List<Account>()).newInstance(new List<Account>(), Account.SObjectType);
        Assert.isTrue(test_domain != null);
    }

    @IsTest
    private static void Application_Domain_MockDomainConstructorTest()
    {
        configureDomains();

        TestOnlyAccounts mock_domain = new TestOnlyAccounts(new List<Account>());

        Application.Domain.setMock(mock_domain);
        ITestOnlyAccounts test_domain = new TestOnlyAccounts(new List<Account>()).newInstance(new List<Account>());
        Assert.isTrue(test_domain != null);
    }

    @IsTest
    private static void Application_Domain_MockDomainConstructor2Test()
    {
        configureDomains();

        TestOnlyAccounts mock_domain = new TestOnlyAccounts(new List<Account>());

        Application.Domain.setMock(mock_domain);
        ITestOnlyAccounts test_domain = new TestOnlyAccounts(new List<Account>()).newInstance(new List<Account>(), Account.SObjectType);
        Assert.isTrue(test_domain != null);
    }

    private static void configureDomains()
    {
        ApplicationFactory_DomainBinding__mdt binding = new ApplicationFactory_DomainBinding__mdt();
        binding.BindingSObjectAlternate__c = 'Account';
        binding.To__c = 'ApplicationFactoryTest.AccountsConstructor';

        List<ApplicationFactory_DomainBinding__mdt> bindingList = new List<ApplicationFactory_DomainBinding__mdt>
        {
            binding
        };

        ApplicationSObjectDomainDIModule.bindingRecords.addAll(bindingList);

        Application.Domain.setMock( new ApplicationFactoryTest.TestOnlyAccounts( new List<Account>() ) );
    }

    /********************************************************
     *    Unit-of-Work-related Testing
    ********************************************************/
    @IsTest
    private static void Application_UnitOfWork_HappyPathTest()
    {
        configureUnitOfWork();

        IApplicationSObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        Assert.isTrue(uow != null);

        uow = Application.UnitOfWork.newInstance(new List<SObjectType> {Account.SObjectType, Contact.SObjectType});
        Assert.isTrue(uow != null);

        uow = Application.UnitOfWork.newInstance(new MockDml());
        Assert.isTrue(uow != null);

        uow = Application.UnitOfWork.newInstance(new List<SObjectType> {Account.SObjectType, Contact.SObjectType}, new MockDml());
        Assert.isTrue(uow != null);
    }

    private static void configureUnitOfWork()
    {
        ApplicationFactory_UnitOfWorkBinding__mdt accountBinding = new ApplicationFactory_UnitOfWorkBinding__mdt();
        accountBinding.BindingSObjectAlternate__c = 'Account';
        accountBinding.BindingSequence__c = 10.0;

        ApplicationFactory_UnitOfWorkBinding__mdt contactBinding = new ApplicationFactory_UnitOfWorkBinding__mdt();
        contactBinding.BindingSObjectAlternate__c = 'Contact';
        contactBinding.BindingSequence__c = 20.0;

        List<ApplicationFactory_UnitOfWorkBinding__mdt> bindingList = new List<ApplicationFactory_UnitOfWorkBinding__mdt>
        {
            accountBinding,
            contactBinding
        };

        ApplicationSObjectUnitOfWorkDIProvider.bindingRecords.addAll(bindingList);
    }

    private class MockDml
        implements fflib_SObjectUnitOfWork.IDML
    {
        public void dmlInsert(List<SObject> objList)
        {
            //Intentionally blank
        }

        public void dmlUpdate(List<SObject> objList)
        {
            //Intentionally blank
        }

        public void dmlDelete(List<SObject> objList)
        {
            //Intentionally blank
        }

        public void eventPublish(List<SObject> objList)
        {
            //Intentionally blank
        }

        public void emptyRecycleBin(List<SObject> objList)
        {
            //Intentionally blank
        }
    }

    /****************************************************************************************************************
     *    !!! Classes used for testing only !!!
     * 
     *    This IS NOT a typical testing pattern that architects should for general Apex development.  Because 
     *    libraries and frameworks do not have implementation, by their nature.  This pattern is used to facilitate 
     *    the deployment of AT4DX to a development org by providing the necessary code-testing coverage.
     * 
     *    Refer to `at4dx-samplecode` for examples of testing metadata that consumes this library.
    ****************************************************************************************************************/
    /*=======================================================
     *    Selector Classes
    *=====================================================*/
    public interface ITestAccountsSelector
        extends IApplicationSObjectSelector
    {
        List<Account> selectById(Set<Id> idSet);
    }

    @TestVisible
    public class TestAccountsSelector 
        extends ApplicationSObjectSelector
        implements ITestAccountsSelector
    {
        public Schema.sObjectType getSObjectType()
        {
            return Account.SObjectType;
        }

        private List<Schema.SObjectField> getAdditionalSObjectFieldList()
        {
            return new List<Schema.SObjectField> { };
        }

        public List<Account> selectById(Set<Id> idSet)
        {
            return (List<Account>) selectSObjectsById( idSet == null ? new Set<Id>() : idSet );
        }
    }

    public class MockAccountsSelector
        extends ApplicationSObjectSelector
        implements ITestAccountsSelector
    {
        public Schema.sObjectType getSObjectType()
        {
            return Account.SObjectType;
        }

        public override List<Schema.SObjectField> getSObjectFieldList()
        {
            return new List<Schema.SObjectField> {
                Account.Id,
                Account.Name
            };
        }

        private List<Schema.SObjectField> getAdditionalSObjectFieldList()
        {
            return new List<Schema.SObjectField> { };
        }

        public List<Account> selectById(Set<Id> idSet)
        {
            return mockAccountList;
        }

        private List<Account> mockAccountList = null;

        public void setAccountsToSelect(List<Account> mocks)
        {
            mockAccountList = mocks;
        }
    }

    public interface ITestContactsSelector
        extends IApplicationSObjectSelector
    {
        List<Contact> selectById(Set<Id> idSet);
    }

    public class TestContactsSelector 
        extends ApplicationSObjectSelector
        implements ITestContactsSelector
    {
        public Schema.sObjectType getSObjectType()
        {
            return Contact.SObjectType;
        }

        public override List<Schema.SObjectField> getSObjectFieldList()
        {
            return new List<Schema.SObjectField> {
                Contact.Id,
                Contact.LastName
            };
        }

        private List<Schema.SObjectField> getAdditionalSObjectFieldList()
        {
            return new List<Schema.SObjectField> { };
        }

        public List<Contact> selectById(Set<Id> idSet)
        {
            return (List<Contact>) selectSObjectsById( idSet == null ? new Set<Id>() : idSet );
        }
    }

    /*=======================================================
     *    Service Classes
    *=====================================================*/
    public interface ITestService
    {
        String getHelloWorldPhrase(String name);
    }

    public class TestService
    {
        private ITestService service()
        {
            return (ITestService) Application.Service.newInstance(ITestService.class);
        }

        public String getHelloWorldPhrase(String name)
        {
            return service().getHelloWorldPhrase(name);
        } 
    }

    public class TestServiceImpl
        implements ITestService
    {
        public String getHelloWorldPhrase(String name)
        {
            String local_name = String.isNotBlank(name) ? name : 'World';
            return 'Hello ' + local_name + '!!!';
        }
    }

    public class TestServiceMockImpl
        implements ITestService
    {
        public String getHelloWorldPhrase(String name)
        {
            return 'this is the mock';
        }
    }

    public class TestOnlyAccounts
        extends ApplicationSObjectDomain
        implements ITestOnlyAccounts
    {
        public ITestOnlyAccounts newInstance(Set<Id> recordIds)
        {
            return (ITestOnlyAccounts) Application.Domain.newInstance(recordIds);
        }
        
        public ITestOnlyAccounts newInstance(List<Account> records)
        {
            return (ITestOnlyAccounts) Application.Domain.newInstance(records);
        }
        
        public ITestOnlyAccounts newInstance(List<Account> records, SObjectType sobjType)
        {
            return (ITestOnlyAccounts) Application.Domain.newInstance(records, sobjType);
        }

        public TestOnlyAccounts(List<Account> records)
        {
            super(records);
        }
    }

    public interface ITestOnlyAccounts
        extends IApplicationSObjectDomain
    {
        // Intentionally blank
    }

    public class AccountsConstructor
        implements fflib_SObjectDomain.IConstructable2
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new TestOnlyAccounts((List<Account>) sObjectList);
        }

        public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sobjType)
        {
            return new TestOnlyAccounts((List<Account>) sObjectList);
        }
    }
}