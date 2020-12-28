@isTest
private class CustomMetadataTest
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
}
