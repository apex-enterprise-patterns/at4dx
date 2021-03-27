/**
 * Copyright (c) 2020, John M. Daniel & John Storey
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

/**
 *  Application Factory
 */
public class Application
{
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
        private SelectorFactory() {  }

        public IApplicationSObjectSelector newInstance(SObjectType sObjectType)
        {
            return (IApplicationSObjectSelector) di_Injector.Org.getInstance( IApplicationSObjectSelector.class, sObjectType );
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
         *        (List<Account>) Application.Selector.selectByRelationship(myOpps, Opportunity.AccountId);
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
        private void setMock(IApplicationSObjectSelector selectorInstance)
        {
            // system.debug('Application.SelectorFactory.setMock flag 1');
            di_Injector.Org.Bindings.byName( IApplicationSObjectSelector.class.getName() )
                                    .bySObject( selectorInstance.sObjectType() )
                                    .replaceBindingWith( selectorInstance );
            // system.debug('Application.SelectorFactory.setMock flag 2');
        } 
    }

    /**
     * Simple Service Factory implementaiton
     **/
    public class ServiceFactory
    {
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
            // system.debug('Application.ServiceFactory.newInstance flag 1');
            return di_Injector.Org.getInstance( serviceInterfaceType );
        }

        @TestVisible
        private void setMock(System.Type serviceInterfaceType, Object serviceImpl)
        {
            // system.debug('Application.ServiceFactory.setMock flag 1');
            di_Injector.Org.Bindings.byName( serviceInterfaceType.getName() )
                                    .replaceBindingWith( serviceImpl );
            // system.debug('Application.ServiceFactory.setMock flag 2');
        }
    }

    /**
     * Class implements a Domain class factory
     **/
    public class DomainFactory 
    {
        private DomainFactory() {  }

        /**
         * Dynamically constructs an instance of a Domain class for the given record Ids
         *   Internally uses the Selector Factory to query the records before passing to a
         *   dynamically constructed instance of the application Apex Domain class
         *
         * @param recordIds A list of Id's of the same type
         * @exception Throws an exception via the Selector Factory if the Ids are not all of the same SObjectType
         **/
        public IApplicationSObjectDomain newInstance(Set<Id> recordIds)
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
        public IApplicationSObjectDomain newInstance(List<SObject> records)
        {
            SObjectType domainSObjectType = records.getSObjectType();
            if (domainSObjectType == null)
                throw new DeveloperException('Unable to determine SObjectType');

            Object injector_return = di_Injector.Org.getInstance( IApplicationSObjectDomain.class, domainSObjectType );

            if (injector_return instanceOf fflib_SObjectDomain.IConstructable)
            {
                return (IApplicationSObjectDomain) ((fflib_SObjectDomain.IConstructable) injector_return).construct(records);
            }

            if (injector_return instanceOf IApplicationSObjectDomain)
            {
                return (IApplicationSObjectDomain) injector_return;
            }

            throw new ApplicationException('Object returned by di_Injector is neither IConststructable nor IApplicationSObjectDomain.');
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
        public IApplicationSObjectDomain newInstance(List<SObject> records, SObjectType domainSObjectType)
        {
            if(domainSObjectType == null)
                throw new DeveloperException('Must specify sObjectType');

            Object injector_return = di_Injector.Org.getInstance( IApplicationSObjectDomain.class, domainSObjectType );

            if (injector_return instanceOf fflib_SObjectDomain.IConstructable2)
            {
                return (IApplicationSObjectDomain) ((fflib_SObjectDomain.IConstructable2) injector_return).construct(records, domainSObjectType);
            }

            if (injector_return instanceOf IApplicationSObjectDomain)
            {
                return (IApplicationSObjectDomain) injector_return;
            }

            throw new ApplicationException('Object returned by di_Injector is neither IConststructable2 nor IApplicationSObjectDomain.');
        }

        @TestVisible
        private void setMock(IApplicationSObjectDomain mockDomain)
        {
            di_Injector.Org.Bindings.byName( IApplicationSObjectDomain.class.getName() )
                                    .bySObject( mockDomain.sObjectType() )
                                    .replaceBindingWith( mockDomain );
        }
    }

    /**
     * Class implements a Unit of Work factory
     **/
    public class UnitOfWorkFactory
    {
        private UnitOfWorkFactory() {  }

        /**
         * Returns a new IApplicationSObjectUnitOfWork configured with the 
         *   SObjectType list provided by the ApplicationFactory_UnitOfWorkBinding__mdt records
         *
         *  @returns IApplicationSObjectUnitOfWork
         **/
        public IApplicationSObjectUnitOfWork newInstance()
        {
            return (IApplicationSObjectUnitOfWork) di_Injector.Org.getInstance( IApplicationSObjectUnitOfWork.class );
        }

        /**
         * Returns a new IApplicationSObjectUnitOfWork configured with the 
         *   SObjectType list provided
         *
         *  @param list of SObjectTypes
         *  @returns IApplicationSObjectUnitOfWork
         **/
        public IApplicationSObjectUnitOfWork newInstance(List<SObjectType> objectTypes)
        {
            return (IApplicationSObjectUnitOfWork) di_Injector.Org.getInstance( IApplicationSObjectUnitOfWork.class, objectTypes );
        }

        /**
         * Returns a new IApplicationSObjectUnitOfWork configured with the 
         *   fflib_SObjectUnitOfWork.IDML specified and the SObjectType list
         *   provided by the ApplicationFactory_UnitOfWorkBinding__mdt records
         *
         *  @param an implementation of fflib_SObjectUnitOfWork.IDML to replace the standard fflib_SObjectUnitOfWork.SimpleDML implementation.
         *  @returns IApplicationSObjectUnitOfWork
         **/
        public IApplicationSObjectUnitOfWork newInstance(fflib_SObjectUnitOfWork.IDML dml)
        {
            return (IApplicationSObjectUnitOfWork) di_Injector.Org.getInstance( IApplicationSObjectUnitOfWork.class, dml );
        }

        /**
         * Returns a new IApplicationSObjectUnitOfWork configured with the 
         *   fflib_SObjectUnitOfWork.IDML specified and the SObjectType list
         *   provided.
         *
         *  @param list of SObjectTypes
         *  @param an implementation of fflib_SObjectUnitOfWork.IDML to replace the standard fflib_SObjectUnitOfWork.SimpleDML implementation.
         *  @returns IApplicationSObjectUnitOfWork
         **/
        public IApplicationSObjectUnitOfWork newInstance(List<SObjectType> objectTypes, fflib_SObjectUnitOfWork.IDML dml)
        {
            List<Object> params = new List<Object>();

            params.add( objectTypes );
            params.add( dml );

            return (IApplicationSObjectUnitOfWork) di_Injector.Org.getInstance( IApplicationSObjectUnitOfWork.class, params );
        }

        @TestVisible
        private void setMock(IApplicationSObjectUnitOfWork mockUow)
        {
            di_Injector.Org.Bindings.byName( IApplicationSObjectUnitOfWork.class.getName() )
                        .replaceBindingWith( mockUow );
        }
    }

    public class ApplicationException extends Exception { }

    /**
     * Exception representing a developer coding error, not intended for end user eyes
     **/
    public class DeveloperException extends Exception { } 
}