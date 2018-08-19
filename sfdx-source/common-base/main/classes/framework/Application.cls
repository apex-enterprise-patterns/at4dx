/**
 *  Application Factory
 */
public class Application
{
    private static final String CMT_RECORD_APP_FACTORY_PREFIX = 'apex_';

    private static final String CMT_RECORD_SELECTOR_FACTORY_PREFIX = CMT_RECORD_APP_FACTORY_PREFIX + 'Selector_';
    private static final String CMT_RECORD_DOMAIN_FACTORY_PREFIX = CMT_RECORD_APP_FACTORY_PREFIX + 'Domain_';
    private static final String CMT_RECORD_SERVICE_FACTORY_PREFIX = CMT_RECORD_APP_FACTORY_PREFIX + 'Service_';
    private static final String CMT_RECORD_UOW_FACTORY_PREFIX = CMT_RECORD_APP_FACTORY_PREFIX + 'UOW_';

    /**
     * Configure and create the DomainFactory for this  mm_Application
     */
    public static final Application.DomainFactory Domain = new Application.DomainFactory();

    /**
     *  Configure and create the SelectorFactory for this mm_Application
     */
    public static final Application.SelectorFactory Selector = new Application.SelectorFactory();

    /**
     *  Configure and create the ServiceFactory for this Application
     */
    public static final Application.ServiceFactory Service = new Application.ServiceFactory();

    /**
     *  Configure and create the UnitOfWorkFactory for this Application
     */
    public static final Application.UnitOfWorkFactory UnitOfWork = new Application.UnitOfWorkFactory();

    /**
	 * Class implements a Selector class factory
	 **/
    public class SelectorFactory
    {
        private Map<SObjectType, fflib_ISObjectSelector> m_sObjectByMockSelector = new Map<SObjectType, fflib_ISObjectSelector>();

        private SelectorFactory() {  }

        public fflib_ISObjectSelector newInstance(SObjectType sObjectType)
		{
            // Mock implementation?
			if (m_sObjectByMockSelector.containsKey(sObjectType))
				return m_sObjectByMockSelector.get(sObjectType);

            return (fflib_ISObjectSelector) di_Injector.Org.getInstance( CMT_RECORD_SELECTOR_FACTORY_PREFIX + sObjectType.getDescribe().getName() );
		}

        /**
		 * Helper method to query the given SObject records
		 *   Internally creates an instance of the registered Selector and calls its
		 *     selectSObjectById method
		 *
		 * @param recordIds The SObject record Ids, must be all the same SObjectType
		 * @exception Is thrown if the record Ids are not all the same or the SObjectType is not registered
		 **/
        public List<SObject> selectById(Set<Id> recordIds)
        {
			// No point creating an empty Domain class, nor can we determine the SObjectType anyway
			if(recordIds == null || recordIds.isEmpty())
				throw new DeveloperException('Invalid record Id\'s set');	

			// Determine SObjectType
			SObjectType domainSObjectType = new List<Id>(recordIds)[0].getSObjectType();

			for (Id recordId : recordIds)
            {
				if (recordId.getSobjectType() != domainSObjectType)
                {
                    throw new DeveloperException('Unable to determine SObjectType, Set contains Id\'s from different SObject types');	
                }
            }

			// Construct Selector class and query by Id for the records
			return newInstance(domainSObjectType).selectSObjectsById(recordIds);
        }

        /**
		 * Helper method to query related records to those provided, for example
		 *   if passed a list of Opportunity records and the Account Id field will
		 *   construct internally a list of Account Ids and call the registered 
		 *   Account selector to query the related Account records, e.g.
		 *
		 *     List<Account> accounts = 
		 *        (List<Account>) Applicaiton.Selector.selectByRelationship(myOpps, Opportunity.AccountId);
		 *
		 * @param relatedRecords used to extract the related record Ids, e.g. Opportunty records
		 * @param relationshipField field in the passed records that contains the relationship records to query, e.g. Opportunity.AccountId
		 **/
		public List<SObject> selectByRelationship(List<SObject> relatedRecords, SObjectField relationshipField)
        {
            Set<Id> relatedIds = new Set<Id>();
			for (SObject relatedRecord : relatedRecords)
			{
				Id relatedId = (Id) relatedRecord.get(relationshipField);
				if (relatedId != null)
                {
                    relatedIds.add(relatedId);
                }
			}
			return selectById(relatedIds);
        }

		@TestVisible
		private void setMock(fflib_ISObjectSelector selectorInstance)
		{
			m_sObjectByMockSelector.put(selectorInstance.sObjectType(), selectorInstance);
		} 
    }


	/**
	 * Simple Service Factory implementaiton
	 **/
	public class ServiceFactory
	{
        private Map<Type, Object> m_serviceInterfaceTypeByMockService = new Map<Type, Object>();

        private ServiceFactory() {  }

        /**
		 * Returns a new instance of the Apex class associated with the given Apex interface
		 *   Will return any mock implementation of the interface provided via setMock
		 *   Note that this method will not check the configured Apex class actually implements the interface
		 *
		 * @param serviceInterfaceType Apex interface type
		 * @exception Is thrown if there is no registered Apex class for the interface type
		 **/
		public Object newInstance(System.Type serviceInterfaceType)
		{
			// Mock implementation?
			if(m_serviceInterfaceTypeByMockService.containsKey(serviceInterfaceType))
				return m_serviceInterfaceTypeByMockService.get(serviceInterfaceType);

            return di_Injector.Org.getInstance( CMT_RECORD_SERVICE_FACTORY_PREFIX + serviceInterfaceType );
        }

		@TestVisible
		private void setMock(System.Type serviceInterfaceType, Object serviceImpl)
		{
			m_serviceInterfaceTypeByMockService.put(serviceInterfaceType, serviceImpl);
		}
    }

    /**
	 * Class implements a Domain class factory
	 **/
	public class DomainFactory 
    {
		private Map<SObjectType, fflib_ISObjectDomain> m_sObjectByMockDomain = new Map<SObjectType, fflib_ISObjectDomain>();

        private DomainFactory() {  }

        /**
		 * Dynamically constructs an instance of a Domain class for the given record Ids
		 *   Internally uses the Selector Factory to query the records before passing to a
		 *   dynamically constructed instance of the application Apex Domain class
		 *
		 * @param recordIds A list of Id's of the same type
		 * @exception Throws an exception via the Selector Factory if the Ids are not all of the same SObjectType
		 **/
		public fflib_ISObjectDomain newInstance(Set<Id> recordIds)
		{
			return newInstance( Application.Selector.selectById(recordIds) );
		}	

		/**
		 * Dynamically constructs an instace of the Domain class for the given records
		 *   Will return a Mock implementation if one has been provided via setMock
		 *
		 * @param records A concreate list (e.g. List<Account> vs List<SObject>) of records
		 * @exception Throws an exception if the SObjectType cannot be determined from the list 
		 *              or the constructor for Domain class was not registered for the SOBjectType
		 **/
		public fflib_ISObjectDomain newInstance(List<SObject> records)
		{
			SObjectType domainSObjectType = records.getSObjectType();
			if(domainSObjectType == null)
				throw new DeveloperException('Unable to determine SObjectType');

			// Mock implementation?
			if(m_sObjectByMockDomain.containsKey(domainSObjectType))
				return m_sObjectByMockDomain.get(domainSObjectType);

            // Construct Domain class passing in the queried records
            fflib_SObjectDomain.IConstructable domainConstructor = (fflib_SObjectDomain.IConstructable) di_Injector.Org.getInstance( CMT_RECORD_DOMAIN_FACTORY_PREFIX + domainSObjectType.getDescribe().getName() );

            return (fflib_ISObjectDomain) domainConstructor.construct(records);
		}	

		/**
		 * Dynamically constructs an instace of the Domain class for the given records and SObjectType
		 *   Will return a Mock implementation if one has been provided via setMock
		 *
		 * @param records A list records
		 * @param domainSObjectType SObjectType for list of records
		 * @exception Throws an exception if the SObjectType is not specified or if constructor for Domain class was not registered for the SObjectType
		 *
		 * @remark Will support List<SObject> but all records in the list will be assumed to be of
		 *         the type specified in sObjectType
		 **/
		public fflib_ISObjectDomain newInstance(List<SObject> records, SObjectType domainSObjectType)
		{
			if(domainSObjectType==null)
				throw new DeveloperException('Must specify sObjectType');

			// Mock implementation?
			if(m_sObjectByMockDomain.containsKey(domainSObjectType))
				return m_sObjectByMockDomain.get(domainSObjectType);

            // Construct Domain class passing in the queried records
            fflib_SObjectDomain.IConstructable2 domainConstructor = (fflib_SObjectDomain.IConstructable2) di_Injector.Org.getInstance( CMT_RECORD_DOMAIN_FACTORY_PREFIX + domainSObjectType.getDescribe().getName() );

            return (fflib_ISObjectDomain) domainConstructor.construct(records, domainSObjectType);
		}

		@TestVisible
		private void setMock(fflib_ISObjectDomain mockDomain)
		{
			m_sObjectByMockDomain.put(mockDomain.sObjectType(), mockDomain);
		}
    }

    /**
	 * Class implements a Unit of Work factory
	 **/
    public class UnitOfWorkFactory
	{
        private UnitOfWorkFactory() {  }

        /**
		 * Returns a new fflib_SObjectUnitOfWork configured with the 
		 *   SObjectType list provided in the constructor, returns a Mock implementation
		 *   if set via the setMock method
		 **/
        public fflib_ISObjectUnitOfWork newInstance()
		{
            return (fflib_ISObjectUnitOfWork) di_Injector.Org.getInstance( CMT_RECORD_UOW_FACTORY_PREFIX + fflib_ISObjectUnitOfWork.class );
        }

        /**
		 * Returns a new fflib_SObjectUnitOfWork configured with the 
		 *   SObjectType list specified, returns a Mock implementation
		 *   if set via the setMock method
		 *
		 * @remark If mock is set, the list of SObjectType in the mock could be different
		 *         then the list of SObjectType specified in this method call
		 **/
		public fflib_ISObjectUnitOfWork newInstance(List<SObjectType> objectTypes)
		{
            // TODO: Need to make this ForceDI-aware
			return new fflib_SObjectUnitOfWork(objectTypes);
		}
    }

	public class ApplicationException extends Exception { }			

	/**
	 * Exception representing a developer coding error, not intended for end user eyes
	 **/
	public class DeveloperException extends Exception { } 
}