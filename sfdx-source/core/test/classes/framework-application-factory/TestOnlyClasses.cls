@IsTest
public class TestOnlyClasses
{
        /*=======================================================
         *    Selector Classes
         *=====================================================*/
        public interface ITestAccountsSelector
            extends IApplicationSObjectSelector
        {
            List<Account> selectById(Set<Id> idSet);
        }

        public with sharing class TestAccountsSelector 
            extends ApplicationSObjectSelector
            implements TestOnlyClasses.ITestAccountsSelector
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
                return (List<Account>) selectSObjectsById( idSet == null ? new Set<Id>() : idSet );
            }
        }

        public with sharing class MockAccountsSelector
            extends ApplicationSObjectSelector
            implements TestOnlyClasses.ITestAccountsSelector
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

        public with sharing class TestContactsSelector 
            extends ApplicationSObjectSelector
            implements TestOnlyClasses.ITestContactsSelector
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
}
