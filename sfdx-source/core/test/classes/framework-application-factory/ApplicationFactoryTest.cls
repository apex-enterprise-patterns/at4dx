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

        TestOnlyClasses.ITestAccountsSelector sel = (TestOnlyClasses.ITestAccountsSelector) Application.Selector.newInstance(Account.SObjectType);
        List<Account> accountList = sel.selectById(new Set<Id> {fflib_IdGenerator.generate(Account.SObjectType)});

        System.assert(accountList != null);
        System.assert(accountList.isEmpty());
    }

    @IsTest
    private static void Application_Selector_SelectByIdHelperTest()
    {
        configureSelectors();

        List<Account> accountList = Application.Selector.selectById(new Set<Id> {fflib_IdGenerator.generate(Account.SObjectType)});

        System.assert(accountList != null);
        System.assert(accountList.isEmpty());
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

        System.assert(accountList != null);
        System.assert(accountList.isEmpty());
    }

    @IsTest
    private static void Application_Selector_SetMockTest()
    {
        configureSelectors();  //comment

        Account acct = new Account(ID = fflib_IDGenerator.generate(Account.SObjectType));

        TestOnlyClasses.MockAccountsSelector mock_selector = new TestOnlyClasses.MockAccountsSelector();
        mock_selector.setAccountsToSelect(new List<Account> {acct});

        Application.Selector.setMock(mock_selector);

        TestOnlyClasses.ITestAccountsSelector sel = (TestOnlyClasses.ITestAccountsSelector) Application.Selector.newInstance(Account.SObjectType);
        List<Account> accountList = sel.selectById(new Set<Id> {fflib_IdGenerator.generate(Account.SObjectType)});

        System.assert(accountList != null);
        System.assertEquals(1, accountList.size());
        System.assertEquals(acct.Id, accountList.get(0).Id);
    }

    private static void configureSelectors()
    {
        ApplicationFactory_SelectorBinding__mdt accountsSelectorBinding = new ApplicationFactory_SelectorBinding__mdt();
        accountsSelectorBinding.BindingSObjectAlternate__c = 'Account';
        accountsSelectorBinding.To__c = 'TestOnlyClasses.TestAccountsSelector';

        ApplicationFactory_SelectorBinding__mdt contactsSelectorBinding = new ApplicationFactory_SelectorBinding__mdt();
        contactsSelectorBinding.BindingSObjectAlternate__c = 'Contact';
        contactsSelectorBinding.To__c = 'TestOnlyClasses.TestContactsSelector';

        List<ApplicationFactory_SelectorBinding__mdt> bindingList = new List<ApplicationFactory_SelectorBinding__mdt>
        {
            accountsSelectorBinding,
            contactsSelectorBinding
        };

        ApplicationSObjectSelectorDIModule.setMock(bindingList);
    }

    /********************************************************
     *    Service-related Testing
    ********************************************************/
    @IsTest
    private static void Application_Service_HappyPathTest()
    {
        configureServices();

        // Service instantiated because, for testing, it's an inner class
        TestOnlyClasses.TestService serv = new TestOnlyClasses.TestService();
        String phrase = serv.getHelloWorldPhrase('Jane Doe');

        System.assert(String.isNotBlank(phrase));
        System.assertEquals('Hello Jane Doe!!!', phrase);
    }
    
    @IsTest
    private static void Application_Service_MockServiceTest()
    {
        configureServices();

        Application.Service.setMock(TestOnlyClasses.ITestService.class, TestOnlyClasses.TestServiceMockImpl.class.getName());

        // Service instantiated because, for testing, it's an inner class
        TestOnlyClasses.TestService serv = new TestOnlyClasses.TestService();
        String phrase = serv.getHelloWorldPhrase('Jane Doe');

        System.assert(String.isNotBlank(phrase));
        System.assertEquals('this is the mock', phrase);
    }

    private static void configureServices()
    {
        ApplicationFactory_ServiceBinding__mdt binding = new ApplicationFactory_ServiceBinding__mdt();
        binding.BindingInterface__c = 'TestOnlyClasses.ITestService';
        binding.To__c = 'TestOnlyClasses.TestServiceImpl';

        List<ApplicationFactory_ServiceBinding__mdt> bindingList = new List<ApplicationFactory_ServiceBinding__mdt>
        {
            binding
        };

        ApplicationServiceDIModule.setMock(bindingList);
    }

    /********************************************************
     *    Domain-related Testing
    ********************************************************/
    @IsTest
    private static void Application_Domain_ConstructorTest()
    {
        configureDomains();

        TestOnlyAccounts.ITestOnlyAccounts test_domain = TestOnlyAccounts.newInstance(new List<Account>());
        System.assert(test_domain != null);
    }

    @IsTest
    private static void Application_Domain_Constructor2Test()
    {
        configureDomains();

        TestOnlyAccounts.ITestOnlyAccounts test_domain = TestOnlyAccounts.newInstance(new List<Account>(), Account.SObjectType);
        System.assert(test_domain != null);
    }

    @IsTest
    private static void Application_Domain_MockDomainConstructorTest()
    {
        configureDomains();

        TestOnlyAccounts mock_domain = new TestOnlyAccounts(new List<Account>());

        Application.Domain.setMock(mock_domain);
        TestOnlyAccounts.ITestOnlyAccounts test_domain = TestOnlyAccounts.newInstance(new List<Account>());
        System.assert(test_domain != null);
    }

    @IsTest
    private static void Application_Domain_MockDomainConstructor2Test()
    {
        configureDomains();

        TestOnlyAccounts mock_domain = new TestOnlyAccounts(new List<Account>());

        Application.Domain.setMock(mock_domain);
        TestOnlyAccounts.ITestOnlyAccounts test_domain = TestOnlyAccounts.newInstance(new List<Account>(), Account.SObjectType);
        System.assert(test_domain != null);
    }

    private static void configureDomains()
    {
        ApplicationFactory_DomainBinding__mdt binding = new ApplicationFactory_DomainBinding__mdt();
        binding.BindingSObjectAlternate__c = 'Account';
        binding.To__c = 'TestOnlyAccounts.Constructor';

        List<ApplicationFactory_DomainBinding__mdt> bindingList = new List<ApplicationFactory_DomainBinding__mdt>
        {
            binding
        };

        ApplicationSObjectDomainDIModule.setMock(bindingList);
    }

    /********************************************************
     *    Unit-of-Work-related Testing
    ********************************************************/
    @IsTest
    private static void Application_UnitOfWork_HappyPathTest()
    {
        configureUnitOfWork();

        IApplicationSObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        System.assert(uow != null);

        uow = Application.UnitOfWork.newInstance(new List<SObjectType> {Account.SObjectType, Contact.SObjectType});
        System.assert(uow != null);

        uow = Application.UnitOfWork.newInstance(new MockDml());
        System.assert(uow != null);

        uow = Application.UnitOfWork.newInstance(new List<SObjectType> {Account.SObjectType, Contact.SObjectType}, new MockDml());
        System.assert(uow != null);
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

        ApplicationSObjectUnitOfWorkDIProvider.setMock(bindingList);
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
}
